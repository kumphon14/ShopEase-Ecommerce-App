import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../services/providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _profileFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _emailCurrentPasswordController;

  late TextEditingController _passwordCurrentController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmNewPasswordController;

  late String _originalEmail;

  bool _isProfileLoading = false;
  bool _isPasswordLoading = false;

  bool _obscureEmailPassword = true;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  bool get _isEmailChanged =>
      _emailController.text.trim() != _originalEmail.trim();

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);

    _originalEmail = auth.email;
    _nameController = TextEditingController(text: auth.username);
    _emailController = TextEditingController(text: auth.email);
    _phoneController = TextEditingController(text: auth.phone);
    _addressController = TextEditingController(text: auth.address);
    _emailCurrentPasswordController = TextEditingController();

    _passwordCurrentController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmNewPasswordController = TextEditingController();

    _emailController.addListener(_handleEmailChanged);
  }

  void _handleEmailChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _emailController.removeListener(_handleEmailChanged);

    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailCurrentPasswordController.dispose();

    _passwordCurrentController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();

    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_profileFormKey.currentState!.validate()) return;

    final bool emailChanged = _isEmailChanged;

    setState(() {
      _isProfileLoading = true;
    });

    final auth = Provider.of<AuthProvider>(context, listen: false);

    final result = await auth.reauthenticateAndUpdateProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      currentPassword: _emailCurrentPasswordController.text,
    );

    if (!mounted) return;

    setState(() {
      _isProfileLoading = false;
    });

    if (result == null) {
      if (emailChanged) {
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Verify Your New Email'),
            content: Text(
              'We sent a verification link to ${_emailController.text.trim()}.\n\n'
              'Please verify that email address before the change takes effect.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );

        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context);
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result)));
    }
  }

  Future<void> _changePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    setState(() {
      _isPasswordLoading = true;
    });

    final auth = Provider.of<AuthProvider>(context, listen: false);

    final result = await auth.changePassword(
      currentPassword: _passwordCurrentController.text,
      newPassword: _newPasswordController.text,
      confirmNewPassword: _confirmNewPasswordController.text,
    );

    if (!mounted) return;

    setState(() {
      _isPasswordLoading = false;
    });

    if (result == null) {
      _passwordCurrentController.clear();
      _newPasswordController.clear();
      _confirmNewPasswordController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully!')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Form(
              key: _profileFormKey,
              child: Column(
                children: [
                  _buildSectionTitle('Profile Information'),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    icon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email Address',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      final email = value?.trim() ?? '';
                      if (email.isEmpty) return 'Please enter your email';
                      if (!email.contains('@')) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _addressController,
                    label: 'Shipping Address',
                    icon: Icons.location_on_outlined,
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your shipping address';
                      }
                      return null;
                    },
                  ),
                  if (_isEmailChanged) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.primaryColor.withValues(alpha: 0.15),
                        ),
                      ),
                      child: const Text(
                        'Changing your email requires your current password. '
                        'A verification email will be sent to the new address.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textMediumColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _emailCurrentPasswordController,
                      label: 'Current Password',
                      icon: Icons.lock_outline,
                      obscureText: _obscureEmailPassword,
                      validator: (value) {
                        if (_isEmailChanged &&
                            (value == null || value.trim().isEmpty)) {
                          return 'Please enter your current password to change email';
                        }
                        return null;
                      },
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureEmailPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppTheme.primaryColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureEmailPassword = !_obscureEmailPassword;
                          });
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isProfileLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: AppTheme.primaryColor,
                      ),
                      child: _isProfileLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),
            const Divider(),
            const SizedBox(height: 24),
            Form(
              key: _passwordFormKey,
              child: Column(
                children: [
                  _buildSectionTitle('Change Password'),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryColor.withValues(alpha: 0.15),
                      ),
                    ),
                    child: const Text(
                      'To change your password, enter your current password and a new password. '
                      'Your new password must be at least 6 characters.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textMediumColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _passwordCurrentController,
                    label: 'Current Password',
                    icon: Icons.lock_outline,
                    obscureText: _obscureCurrentPassword,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your current password';
                      }
                      return null;
                    },
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureCurrentPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppTheme.primaryColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureCurrentPassword = !_obscureCurrentPassword;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _newPasswordController,
                    label: 'New Password',
                    icon: Icons.lock_reset_outlined,
                    obscureText: _obscureNewPassword,
                    validator: (value) {
                      final password = value?.trim() ?? '';
                      if (password.isEmpty) {
                        return 'Please enter your new password';
                      }
                      if (password.length < 6) {
                        return 'New password must be at least 6 characters';
                      }
                      return null;
                    },
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNewPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppTheme.primaryColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureNewPassword = !_obscureNewPassword;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _confirmNewPasswordController,
                    label: 'Confirm New Password',
                    icon: Icons.lock_reset_outlined,
                    obscureText: _obscureConfirmPassword,
                    validator: (value) {
                      final confirmPassword = value?.trim() ?? '';
                      if (confirmPassword.isEmpty) {
                        return 'Please confirm your new password';
                      }
                      if (confirmPassword !=
                          _newPasswordController.text.trim()) {
                        return 'New password and confirm password do not match';
                      }
                      return null;
                    },
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppTheme.primaryColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _isPasswordLoading ? null : _changePassword,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(
                          color: AppTheme.primaryColor,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        foregroundColor: AppTheme.primaryColor,
                      ),
                      child: _isPasswordLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Update Password',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.textDarkColor,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      key: ValueKey<String>('shopease.editProfile.input.$label'),
      controller: controller,
      maxLines: obscureText ? 1 : maxLines,
      keyboardType: keyboardType,
      validator: validator,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: maxLines == 1
            ? Icon(icon, color: AppTheme.primaryColor)
            : Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Icon(icon, color: AppTheme.primaryColor),
              ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }
}
