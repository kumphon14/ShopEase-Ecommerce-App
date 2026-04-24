// test/unit/providers/auth_provider_test.dart
//
// Covers only pure validation logic that executes BEFORE any Firebase call:
//   • _fallbackUsername() — tested indirectly via a public test accessor added
//     below using the @visibleForTesting workaround is not available here.
//     Instead we test it via the provider state initialization path and via
//     adminLogin() (which returns early before Firebase for wrong keys).
//   • adminLogin() secret-key guard
//   • changePassword() all early-return validation branches
//   • reauthenticateAndUpdateProfile() all required-field validation branches
//   • updateProfile() email-change block
//   • _resetUserState() field reset (tested via getters after construction)
//
// Firebase-requiring paths (actual sign-in, Firestore reads) are NOT called.
// The provider is constructed with MockFirebaseAuth + FakeFirebaseFirestore
// so the authStateChanges() listener fires synchronously with no user,
// which allows the provider to be stable for validation-only tests.

import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:shopease_ecommerce_app/services/providers/auth_provider.dart';

/// Build an AuthProvider with a signed-out MockFirebaseAuth and FakeFirebaseFirestore.
/// No user is logged in, so _uid and _auth.currentUser are both null.
AuthProvider _makeProvider() {
  return AuthProvider(
    auth: MockFirebaseAuth(),
    firestore: FakeFirebaseFirestore(),
  );
}

void main() {
  group('AuthProvider', () {
    group('initial getter state (no user signed in)', () {
      test('isAuthenticated is false when no user logged in', () {
        final provider = _makeProvider();
        expect(provider.isAuthenticated, isFalse);
      });

      test('isAdmin is false when no user logged in', () {
        final provider = _makeProvider();
        expect(provider.isAdmin, isFalse);
      });

      test('username is empty string when no user logged in', () {
        final provider = _makeProvider();
        expect(provider.username, equals(''));
      });

      test('email is empty string when no user logged in', () {
        final provider = _makeProvider();
        expect(provider.email, equals(''));
      });

      test('phone is empty string when no user logged in', () {
        final provider = _makeProvider();
        expect(provider.phone, equals(''));
      });

      test('address is empty string when no user logged in', () {
        final provider = _makeProvider();
        expect(provider.address, equals(''));
      });

      test('uid is null when no user logged in', () {
        final provider = _makeProvider();
        expect(provider.uid, isNull);
      });
    });

    group('adminLogin secret key guard', () {
      test('returns error string immediately for wrong secret key', () async {
        final provider = _makeProvider();
        final result = await provider.adminLogin('admin@test.com', 'pass', 'WRONG_KEY');
        expect(result, equals('Invalid Admin Secret Key.'));
      });

      test('returns error string for empty secret key', () async {
        final provider = _makeProvider();
        final result = await provider.adminLogin('admin@test.com', 'pass', '');
        expect(result, equals('Invalid Admin Secret Key.'));
      });

      test('returns error string for key with different casing', () async {
        final provider = _makeProvider();
        final result = await provider.adminLogin('admin@test.com', 'pass', 'shopease2024');
        expect(result, equals('Invalid Admin Secret Key.'));
      });

      test('returns error string for key with extra whitespace', () async {
        final provider = _makeProvider();
        final result = await provider.adminLogin('admin@test.com', 'pass', 'SHOPEASE2024 ');
        expect(result, equals('Invalid Admin Secret Key.'));
      });

      test('passes secret key check for SHOPEASE2024 (proceeds to Firebase — returns error due to no real user)', () async {
        // With MockFirebaseAuth and no registered user, the Firebase call fails,
        // returning the Firebase-failure error string — NOT the secret key error.
        final provider = _makeProvider();
        final result = await provider.adminLogin('admin@test.com', 'pass', 'SHOPEASE2024');
        // Result is NOT the secret key error — it was rejected by Firebase instead.
        expect(result, isNot(equals('Invalid Admin Secret Key.')));
      });
    });

    group('changePassword validation', () {
      // All these return early before reaching Firebase.
      // _uid is null (no user), so the uid guard fires first.
      test('returns user session error when uid is null', () async {
        final provider = _makeProvider();
        final result = await provider.changePassword(
          currentPassword: 'old123',
          newPassword: 'new123',
          confirmNewPassword: 'new123',
        );
        expect(result, equals('User session is not ready. Please sign in again.'));
      });

      // To test the field-level validation, we need a signed-in user.
      // Use MockFirebaseAuth with a pre-signed-in user.
      test('returns current password required error when currentPassword is empty', () async {
        final mockAuth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: 'uid123', email: 'user@test.com'),
        );
        final provider = AuthProvider(
          auth: mockAuth,
          firestore: FakeFirebaseFirestore(),
        );
        // Give the authStateChanges stream time to fire and set _uid
        await Future.delayed(const Duration(milliseconds: 50));

        final result = await provider.changePassword(
          currentPassword: '',
          newPassword: 'new123',
          confirmNewPassword: 'new123',
        );
        expect(result, equals('Current password is required.'));
      });

      test('returns new password required error when newPassword is empty', () async {
        final mockAuth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: 'uid123', email: 'user@test.com'),
        );
        final provider = AuthProvider(
          auth: mockAuth,
          firestore: FakeFirebaseFirestore(),
        );
        await Future.delayed(const Duration(milliseconds: 50));

        final result = await provider.changePassword(
          currentPassword: 'old123',
          newPassword: '',
          confirmNewPassword: 'new123',
        );
        expect(result, equals('New password is required.'));
      });

      test('returns confirm password required error when confirmNewPassword is empty', () async {
        final mockAuth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: 'uid123', email: 'user@test.com'),
        );
        final provider = AuthProvider(
          auth: mockAuth,
          firestore: FakeFirebaseFirestore(),
        );
        await Future.delayed(const Duration(milliseconds: 50));

        final result = await provider.changePassword(
          currentPassword: 'old123',
          newPassword: 'new123',
          confirmNewPassword: '',
        );
        expect(result, equals('Please confirm your new password.'));
      });

      test('returns mismatch error when newPassword and confirmNewPassword differ', () async {
        final mockAuth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: 'uid123', email: 'user@test.com'),
        );
        final provider = AuthProvider(
          auth: mockAuth,
          firestore: FakeFirebaseFirestore(),
        );
        await Future.delayed(const Duration(milliseconds: 50));

        final result = await provider.changePassword(
          currentPassword: 'old123',
          newPassword: 'new123',
          confirmNewPassword: 'different',
        );
        expect(result, equals('New password and confirm password do not match.'));
      });

      test('returns length error when newPassword is less than 6 characters', () async {
        final mockAuth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: 'uid123', email: 'user@test.com'),
        );
        final provider = AuthProvider(
          auth: mockAuth,
          firestore: FakeFirebaseFirestore(),
        );
        await Future.delayed(const Duration(milliseconds: 50));

        final result = await provider.changePassword(
          currentPassword: 'old123',
          newPassword: 'abc',
          confirmNewPassword: 'abc',
        );
        expect(result, equals('New password must be at least 6 characters.'));
      });

      test('returns length error when newPassword has exactly 5 characters', () async {
        final mockAuth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: 'uid123', email: 'user@test.com'),
        );
        final provider = AuthProvider(
          auth: mockAuth,
          firestore: FakeFirebaseFirestore(),
        );
        await Future.delayed(const Duration(milliseconds: 50));

        final result = await provider.changePassword(
          currentPassword: 'old123',
          newPassword: 'abcde',
          confirmNewPassword: 'abcde',
        );
        expect(result, equals('New password must be at least 6 characters.'));
      });
    });

    group('reauthenticateAndUpdateProfile validation', () {
      test('returns user session error when uid is null', () async {
        final provider = _makeProvider();
        final result = await provider.reauthenticateAndUpdateProfile(
          name: 'John',
          email: 'john@test.com',
          phone: '0812345678',
          address: '123 St',
          currentPassword: 'pass',
        );
        expect(result, equals('User session is not ready. Please sign in again.'));
      });

      test('returns full name required error when name is empty', () async {
        final mockAuth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: 'uid123', email: 'user@test.com'),
        );
        final provider = AuthProvider(
          auth: mockAuth,
          firestore: FakeFirebaseFirestore(),
        );
        await Future.delayed(const Duration(milliseconds: 50));

        final result = await provider.reauthenticateAndUpdateProfile(
          name: '',
          email: 'user@test.com',
          phone: '0812345678',
          address: '123 St',
          currentPassword: 'pass',
        );
        expect(result, equals('Full name is required.'));
      });

      test('returns email required error when email is empty', () async {
        final mockAuth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: 'uid123', email: 'user@test.com'),
        );
        final provider = AuthProvider(
          auth: mockAuth,
          firestore: FakeFirebaseFirestore(),
        );
        await Future.delayed(const Duration(milliseconds: 50));

        final result = await provider.reauthenticateAndUpdateProfile(
          name: 'John',
          email: '',
          phone: '0812345678',
          address: '123 St',
          currentPassword: 'pass',
        );
        expect(result, equals('Email address is required.'));
      });

      test('returns phone required error when phone is empty', () async {
        final mockAuth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: 'uid123', email: 'user@test.com'),
        );
        final provider = AuthProvider(
          auth: mockAuth,
          firestore: FakeFirebaseFirestore(),
        );
        await Future.delayed(const Duration(milliseconds: 50));

        final result = await provider.reauthenticateAndUpdateProfile(
          name: 'John',
          email: 'user@test.com',
          phone: '',
          address: '123 St',
          currentPassword: 'pass',
        );
        expect(result, equals('Phone number is required.'));
      });

      test('returns address required error when address is empty', () async {
        final mockAuth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: 'uid123', email: 'user@test.com'),
        );
        final provider = AuthProvider(
          auth: mockAuth,
          firestore: FakeFirebaseFirestore(),
        );
        await Future.delayed(const Duration(milliseconds: 50));

        final result = await provider.reauthenticateAndUpdateProfile(
          name: 'John',
          email: 'user@test.com',
          phone: '0812345678',
          address: '',
          currentPassword: 'pass',
        );
        expect(result, equals('Shipping address is required.'));
      });

      test('returns current password required error when email changes but password is empty', () async {
        final mockAuth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: 'uid123', email: 'user@test.com'),
        );
        final provider = AuthProvider(
          auth: mockAuth,
          firestore: FakeFirebaseFirestore(),
        );
        await Future.delayed(const Duration(milliseconds: 50));

        final result = await provider.reauthenticateAndUpdateProfile(
          name: 'John',
          email: 'newemail@test.com', // different from current
          phone: '0812345678',
          address: '123 St',
          currentPassword: '', // empty password
        );
        expect(result, equals('Current password is required to change email.'));
      });
    });

    group('updateProfile email-change block', () {
      test('returns false when uid is null', () async {
        final provider = _makeProvider();
        final result = await provider.updateProfile(
          name: 'John',
          email: 'john@test.com',
          phone: '0812345678',
          address: '123 St',
        );
        expect(result, isFalse);
      });

      test('returns false when email differs from current Auth email', () async {
        final mockAuth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: 'uid123', email: 'user@test.com'),
        );
        final provider = AuthProvider(
          auth: mockAuth,
          firestore: FakeFirebaseFirestore(),
        );
        await Future.delayed(const Duration(milliseconds: 50));

        final result = await provider.updateProfile(
          name: 'John',
          email: 'different@test.com', // different from current Auth email
          phone: '0812345678',
          address: '123 St',
        );
        expect(result, isFalse);
      });
    });
  });
}
