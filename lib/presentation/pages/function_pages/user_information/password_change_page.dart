import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';
import 'package:inner_child_app/core/utils/notify_another_flushbar.dart';
import 'package:inner_child_app/domain/usecases/auth_usecase.dart';

class PasswordChangePage extends ConsumerStatefulWidget {
  const PasswordChangePage({super.key});

  @override
  ConsumerState<PasswordChangePage> createState() => _PasswordChangePageState();
}

class _PasswordChangePageState extends ConsumerState<PasswordChangePage> {
  late final AuthUsecase _authUsecase;
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  String? _currentPasswordError;
  String? _newPasswordError;
  String? _confirmPasswordError;

  Future<void> _changePassword() async {
    if (!_validateForm()) {
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
      final confirmPassword = _confirmPasswordController.text;

      // Call your actual API method here
      // Replace 'YourApiService.changePassword' with your actual API call
      final result = await _authUsecase.changePassword(
        currentPassword,
        newPassword,
          confirmPassword
      );

      setState(() {
        _isLoading = false;
      });

      // Handle successful response
      if (result.isSuccess) {
        // Show success dialog
        Notify.showAwesomeDialog(
          title: 'Password successfully updated',
          message:
          'Your password has been updated successfully. Please use your new password the next time you sign in.',
          dialogType: DialogType.success,
          btnOkText: 'Okay, Thanks',
          onOkPress: () {
            Navigator.pop(context); // Return to previous screen
          },
        );

        // Clear the form
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      } else {
        // Handle API error response
        Notify.showFlushbar(
          result.error ?? 'Failed to change password. Please try again.',
          isError: true,
        );
      }

    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // Handle different types of errors
      String errorMessage;
      if (e.toString().contains('network') || e.toString().contains('connection')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Request timeout. Please try again.';
      } else if (e.toString().contains('unauthorized') || e.toString().contains('401')) {
        errorMessage = 'Current password is incorrect.';
      } else {
        errorMessage = 'An unexpected error occurred. Please try again.';
      }

      Notify.showFlushbar(
        errorMessage,
        isError: true,
      );
    }
  }

  bool _isLoading = false;

  bool _validateForm() {
    bool isValid = true;
    List<String> errorMessages = [];

    // Reset all errors
    setState(() {
      _currentPasswordError = null;
      _newPasswordError = null;
      _confirmPasswordError = null;
    });

    // Current Password
    if (_currentPasswordController.text.isEmpty) {
      _currentPasswordError = 'Current password is required';
      errorMessages.add(_currentPasswordError!);
      isValid = false;
    }

    // New Password
    final newPassword = _newPasswordController.text;
    if (newPassword.isEmpty) {
      _newPasswordError = 'New password is required';
      errorMessages.add(_newPasswordError!);
      isValid = false;
    } else if (newPassword.length < 5 || newPassword.length > 100) {
      _newPasswordError = 'Password must be 5-100 characters';
      errorMessages.add(_newPasswordError!);
      isValid = false;
    }

    // Confirm Password
    final confirmPassword = _confirmPasswordController.text;
    if (confirmPassword.isEmpty) {
      _confirmPasswordError = 'Confirm password is required';
      errorMessages.add(_confirmPasswordError!);
      isValid = false;
    } else if (newPassword != confirmPassword) {
      _confirmPasswordError = 'Passwords do not match';
      errorMessages.add(_confirmPasswordError!);
      isValid = false;
    }

    // Show flushbar with the first error message if any
    if (errorMessages.isNotEmpty) {
      Notify.showFlushbar(
        'Please fix the following: ${errorMessages.first}',
        isError: true,
      );
    }

    return isValid;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _authUsecase = ref.read(authUseCaseProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        // Dismiss keyboard when tapping outside of text fields
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back button and title
                      Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          // Back button on the left
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios,
                              color: Colors.blue,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          // Centered title
                          const Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Change Password',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ),

                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),

                              // Security icon and title
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: Colors.deepOrange,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.lock,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    "Password Security",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // Description
                              Text(
                                "Please enter your current password and a new password to update your credentials.",
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  height: 1.5,
                                ),
                              ),

                              const SizedBox(height: 30),

                              // Current Password
                              const Text(
                                "Current Password*",
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _currentPasswordController,
                                obscureText: !_isCurrentPasswordVisible,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 15,
                                  ),
                                  errorText: _currentPasswordError,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isCurrentPasswordVisible
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isCurrentPasswordVisible =
                                        !_isCurrentPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                                onChanged: (value) {
                                  if (_currentPasswordError != null) {
                                    setState(() {
                                      _currentPasswordError = null;
                                    });
                                  }
                                },
                              ),

                              const SizedBox(height: 20),

                              // New Password
                              const Text(
                                "New Password*",
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _newPasswordController,
                                obscureText: !_isNewPasswordVisible,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 15,
                                  ),
                                  errorText: _newPasswordError,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isNewPasswordVisible
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isNewPasswordVisible =
                                        !_isNewPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                                onChanged: (value) {
                                  if (_newPasswordError != null) {
                                    setState(() {
                                      _newPasswordError = null;
                                    });
                                  }
                                },
                              ),

                              const SizedBox(height: 20),

                              // Confirm New Password
                              const Text(
                                "Confirm New Password*",
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: !_isConfirmPasswordVisible,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 15,
                                  ),
                                  errorText: _confirmPasswordError,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isConfirmPasswordVisible
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isConfirmPasswordVisible =
                                        !_isConfirmPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                                onChanged: (value) {
                                  if (_confirmPasswordError != null) {
                                    setState(() {
                                      _confirmPasswordError = null;
                                    });
                                  }
                                },
                              ),

                              const SizedBox(height: 20),

                              // Password requirements
                              Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Password requirements:",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    _buildRequirementItem(
                                      "At least 5 characters",
                                      _newPasswordController.text.length >= 5,
                                    ),
                                    _buildRequirementItem(
                                      "Maximum 100 characters",
                                      _newPasswordController.text.length <= 100,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Change Password Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _changePassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            disabledBackgroundColor: Colors.grey,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : const Text(
                            "Change Password",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRequirementItem(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            color: isMet ? Colors.green : Colors.grey,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isMet ? Colors.green : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
