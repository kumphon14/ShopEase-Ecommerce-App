// lib/services/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  bool _isAuthenticated = false;
  bool _isAdmin = false;
  String _username = '';
  String _email = '';
  String _phone = '';
  String _address = '';
  String? _uid;

  bool get isAuthenticated => _isAuthenticated;
  bool get isAdmin => _isAdmin;
  String get username => _username;
  String get email => _email;
  String get phone => _phone;
  String get address => _address;
  String? get uid => _uid;

  static const String _adminSecretKey = 'SHOPEASE2024';

  AuthProvider({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance {
    _auth.authStateChanges().listen((User? user) async {
      await _syncAuthState(user);
      notifyListeners();
    });
  }

  Future<void> _syncAuthState(User? user) async {
    if (user == null) {
      _resetUserState();
      return;
    }

    _isAuthenticated = true;
    _uid = user.uid;
    _email = user.email?.trim() ?? '';

    try {
      final docRef = _firestore.collection('users').doc(user.uid);
      final doc = await docRef.get();

      if (doc.exists) {
        final data = doc.data() ?? <String, dynamic>{};

        _username = (data['name'] as String?)?.trim().isNotEmpty == true
            ? (data['name'] as String).trim()
            : _fallbackUsername(_email);

        _isAdmin = data['role'] == 'admin';
        _phone = (data['phone'] as String?)?.trim() ?? '';
        _address = (data['address'] as String?)?.trim() ?? '';

        final firestoreEmail = (data['email'] as String?)?.trim() ?? '';
        final pendingEmail = (data['pendingEmail'] as String?)?.trim() ?? '';

        final Map<String, dynamic> syncPayload = {};

        // Keep Firestore email aligned with Firebase Auth as source of truth.
        if (_email.isNotEmpty && firestoreEmail != _email) {
          syncPayload['email'] = _email;
        }

        // If the pending email has already become the real auth email,
        // clear the pending marker.
        if (pendingEmail.isNotEmpty && pendingEmail == _email) {
          syncPayload['pendingEmail'] = FieldValue.delete();
        }

        if (syncPayload.isNotEmpty) {
          await docRef.set(syncPayload, SetOptions(merge: true));
        }
      } else {
        _username = _fallbackUsername(_email);
        _isAdmin = false;
        _phone = '';
        _address = '';

        await docRef.set({
          'name': _username,
          'email': _email,
          'role': 'customer',
          'phone': '',
          'address': '',
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Sync auth state error: $e');
      }
      _username = _fallbackUsername(_email);
      _isAdmin = false;
      _phone = '';
      _address = '';
    }
  }

  void _resetUserState() {
    _isAuthenticated = false;
    _isAdmin = false;
    _username = '';
    _email = '';
    _phone = '';
    _address = '';
    _uid = null;
  }

  String _fallbackUsername(String email) {
    if (email.trim().isEmpty || !email.contains('@')) {
      return 'User';
    }
    return email.split('@').first.trim();
  }

  Future<bool> signup(String name, String email, String password) async {
    try {
      final trimmedName = name.trim();
      final trimmedEmail = email.trim();

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: trimmedEmail,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'name': trimmedName,
          'email': trimmedEmail,
          'role': 'customer',
          'phone': '',
          'address': '',
          'createdAt': FieldValue.serverTimestamp(),
        });

        _isAuthenticated = true;
        _isAdmin = false;
        _uid = user.uid;
        _username = trimmedName;
        _email = trimmedEmail;
        _phone = '';
        _address = '';
        notifyListeners();

        return true;
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Signup auth error: ${e.code} - ${e.message}');
      }
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('Signup firestore error: ${e.code} - ${e.message}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Signup error: $e');
      }
    }
    return false;
  }

  Future<bool> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Login auth error: ${e.code} - ${e.message}');
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Login error: $e');
      }
      return false;
    }
  }

  Future<String?> adminLogin(
    String email,
    String password,
    String secretKey,
  ) async {
    if (secretKey != _adminSecretKey) {
      return 'Invalid Admin Secret Key.';
    }

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();

        if (doc.exists && doc.data()?['role'] == 'admin') {
          return null;
        } else {
          await _auth.signOut();
          return 'Unauthorized admin account.';
        }
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Admin login auth error: ${e.code} - ${e.message}');
      }
      return 'Invalid credentials or login failed.';
    } catch (e) {
      if (kDebugMode) {
        print('Admin login error: $e');
      }
      return 'Invalid credentials or login failed.';
    }

    return 'Unknown error occurred.';
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Safe/basic profile update.
  /// This method does NOT allow direct email change.
  /// If email is changed here, it returns false intentionally.
  Future<bool> updateProfile({
    required String name,
    required String email,
    required String phone,
    required String address,
  }) async {
    final user = _auth.currentUser;

    if (_uid == null || user == null) {
      if (kDebugMode) {
        print('Update profile error: user session is not ready.');
      }
      return false;
    }

    final trimmedName = name.trim();
    final trimmedEmail = email.trim();
    final trimmedPhone = phone.trim();
    final trimmedAddress = address.trim();
    final currentEmail = user.email?.trim() ?? _email.trim();

    // Block direct email changes in this basic method.
    if (trimmedEmail != currentEmail) {
      if (kDebugMode) {
        print(
          'Update profile blocked: email change requires re-authentication. '
          'Use reauthenticateAndUpdateProfile(...) instead.',
        );
      }
      return false;
    }

    try {
      await _firestore.collection('users').doc(user.uid).set({
        'name': trimmedName,
        'email': currentEmail,
        'phone': trimmedPhone,
        'address': trimmedAddress,
      }, SetOptions(merge: true));

      _uid = user.uid;
      _username = trimmedName;
      _email = currentEmail;
      _phone = trimmedPhone;
      _address = trimmedAddress;

      notifyListeners();
      return true;
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('Update profile firestore error: ${e.code} - ${e.message}');
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Update profile error: $e');
      }
      return false;
    }
  }

  /// Full secure flow for email change:
  /// 1) Re-authenticate with current password
  /// 2) Send verification email to new email via verifyBeforeUpdateEmail(...)
  /// 3) Save other fields immediately
  /// 4) Keep Firestore email aligned with Auth email until verification completes
  ///
  /// Returns:
  /// - null when request succeeds
  /// - error message when failed
  Future<String?> reauthenticateAndUpdateProfile({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String currentPassword,
  }) async {
    final user = _auth.currentUser;

    if (_uid == null || user == null) {
      return 'User session is not ready. Please sign in again.';
    }

    final trimmedName = name.trim();
    final trimmedEmail = email.trim();
    final trimmedPhone = phone.trim();
    final trimmedAddress = address.trim();
    final trimmedPassword = currentPassword.trim();
    final currentEmail = user.email?.trim() ?? _email.trim();

    if (trimmedName.isEmpty) {
      return 'Full name is required.';
    }
    if (trimmedEmail.isEmpty) {
      return 'Email address is required.';
    }
    if (trimmedPhone.isEmpty) {
      return 'Phone number is required.';
    }
    if (trimmedAddress.isEmpty) {
      return 'Shipping address is required.';
    }
    if (currentEmail.isEmpty) {
      return 'Current account email is unavailable.';
    }

    try {
      if (trimmedEmail != currentEmail) {
        if (trimmedPassword.isEmpty) {
          return 'Current password is required to change email.';
        }

        final credential = EmailAuthProvider.credential(
          email: currentEmail,
          password: trimmedPassword,
        );

        await user.reauthenticateWithCredential(credential);
        await user.verifyBeforeUpdateEmail(trimmedEmail);

        await _firestore.collection('users').doc(user.uid).set({
          'name': trimmedName,
          'email': currentEmail,
          'phone': trimmedPhone,
          'address': trimmedAddress,
          'pendingEmail': trimmedEmail,
        }, SetOptions(merge: true));

        _uid = user.uid;
        _username = trimmedName;
        _email = currentEmail;
        _phone = trimmedPhone;
        _address = trimmedAddress;

        notifyListeners();
        return null;
      }

      await _firestore.collection('users').doc(user.uid).set({
        'name': trimmedName,
        'email': currentEmail,
        'phone': trimmedPhone,
        'address': trimmedAddress,
      }, SetOptions(merge: true));

      _uid = user.uid;
      _username = trimmedName;
      _email = currentEmail;
      _phone = trimmedPhone;
      _address = trimmedAddress;

      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print(
          'Re-auth update profile auth error: ${e.code} - ${e.message}',
        );
      }

      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          return 'Current password is incorrect.';
        case 'email-already-in-use':
          return 'This email is already in use.';
        case 'invalid-email':
          return 'Invalid email format.';
        case 'requires-recent-login':
          return 'Please sign in again and retry.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'user-not-found':
          return 'User account not found.';
        case 'network-request-failed':
          return 'Network error. Please check your connection.';
        case 'too-many-requests':
          return 'Too many requests. Please try again later.';
        default:
          return e.message ?? 'Failed to update profile.';
      }
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print(
          'Re-auth update profile firestore error: ${e.code} - ${e.message}',
        );
      }
      return e.message ?? 'Failed to save profile data.';
    } catch (e) {
      if (kDebugMode) {
        print('Re-auth update profile unknown error: $e');
      }
      return 'Unexpected error occurred while updating profile.';
    }
  }

  Future<String?> changePassword({
  required String currentPassword,
  required String newPassword,
  required String confirmNewPassword,
}) async {
  final user = _auth.currentUser;

  if (_uid == null || user == null) {
    return 'User session is not ready. Please sign in again.';
  }

  final trimmedCurrentPassword = currentPassword.trim();
  final trimmedNewPassword = newPassword.trim();
  final trimmedConfirmPassword = confirmNewPassword.trim();
  final currentEmail = user.email?.trim() ?? _email.trim();

  if (currentEmail.isEmpty) {
    return 'Current account email is unavailable.';
  }

  if (trimmedCurrentPassword.isEmpty) {
    return 'Current password is required.';
  }

  if (trimmedNewPassword.isEmpty) {
    return 'New password is required.';
  }

  if (trimmedConfirmPassword.isEmpty) {
    return 'Please confirm your new password.';
  }

  if (trimmedNewPassword != trimmedConfirmPassword) {
    return 'New password and confirm password do not match.';
  }

  // App-side validation rule (customizable)
  if (trimmedNewPassword.length < 6) {
    return 'New password must be at least 6 characters.';
  }

  try {
    final credential = EmailAuthProvider.credential(
      email: currentEmail,
      password: trimmedCurrentPassword,
    );

    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(trimmedNewPassword);
    await user.reload();

    return null;
  } on FirebaseAuthException catch (e) {
    if (kDebugMode) {
      print('Change password auth error: ${e.code} - ${e.message}');
    }

    switch (e.code) {
      case 'wrong-password':
      case 'invalid-credential':
        return 'Current password is incorrect.';
      case 'weak-password':
        return 'New password is too weak.';
      case 'requires-recent-login':
        return 'Please sign in again and retry.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'User account not found.';
      default:
        return e.message ?? 'Failed to change password.';
    }
  } catch (e) {
    if (kDebugMode) {
      print('Change password unknown error: $e');
    }
    return 'Unexpected error occurred while changing password.';
  }
}
}