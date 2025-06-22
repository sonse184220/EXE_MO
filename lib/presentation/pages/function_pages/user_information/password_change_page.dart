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

  bool _isLoading = false;
  int _retryAttempts = 0;
  static const int _maxRetryAttempts = 3;

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
        // Reset retry attempts on success
        _retryAttempts = 0;

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
        _handlePasswordChangeFailure(result.error ?? 'Failed to change password. Please try again.');
      }

    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // Handle different types of errors
      String errorMessage = _getErrorMessage(e);
      _handlePasswordChangeFailure(errorMessage);
    }
  }

  void _handlePasswordChangeFailure(String errorMessage) {
    _retryAttempts++;

    if (_retryAttempts >= _maxRetryAttempts) {
      // Show error with option to reset retry count
      Notify.showAwesomeDialog(
        title: 'Password Change Failed',
        message: '$errorMessage\n\nYou have reached the maximum retry attempts. Please check your information and try again.',
        dialogType: DialogType.error,
        btnOkText: 'Try Again',
        onOkPress: () {
          _retryAttempts = 0; // Reset retry attempts
        },
      );
    } else {
      // Show error with retry count
      int remainingAttempts = _maxRetryAttempts - _retryAttempts;
      Notify.showFlushbar(
        '$errorMessage (Attempt $_retryAttempts/$_maxRetryAttempts - $remainingAttempts attempts remaining)',
        isError: true,
      );
    }
  }

  String _getErrorMessage(dynamic error) {
    String errorString = error.toString().toLowerCase();

    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    } else if (errorString.contains('timeout')) {
      return 'Request timeout. Please try again.';
    } else if (errorString.contains('unauthorized') || errorString.contains('401')) {
      return 'Current password is incorrect.';
    } else if (errorString.contains('forbidden') || errorString.contains('403')) {
      return 'You are not authorized to change the password.';
    } else if (errorString.contains('server') || errorString.contains('500')) {
      return 'Server error. Please try again later.';
    } else if (errorString.contains('bad request') || errorString.contains('400')) {
      return 'Invalid password format. Please check the requirements.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  bool _validateForm() {
    bool isValid = true;
    List<String> errorMessages = [];

    // Reset all errors
    setState(() {
      _currentPasswordError = null;
      _newPasswordError = null;
      _confirmPasswordError = null;
    });

    // Current Password validation
    final currentPassword = _currentPasswordController.text.trim();
    if (currentPassword.isEmpty) {
      setState(() {
        _currentPasswordError = 'Current password is required';
      });
      errorMessages.add(_currentPasswordError!);
      isValid = false;
    }

    // New Password validation
    final newPassword = _newPasswordController.text;
    if (newPassword.isEmpty) {
      setState(() {
        _newPasswordError = 'New password is required';
      });
      errorMessages.add(_newPasswordError!);
      isValid = false;
    } else {
      // Check password length
      if (newPassword.length < 5) {
        setState(() {
          _newPasswordError = 'Password must be at least 5 characters';
        });
        errorMessages.add(_newPasswordError!);
        isValid = false;
      } else if (newPassword.length > 100) {
        setState(() {
          _newPasswordError = 'Password must not exceed 100 characters';
        });
        errorMessages.add(_newPasswordError!);
        isValid = false;
      }

      // Check if new password is different from current password
      if (newPassword == currentPassword && currentPassword.isNotEmpty) {
        setState(() {
          _newPasswordError = 'New password must be different from current password';
        });
        errorMessages.add(_newPasswordError!);
        isValid = false;
      }
    }

    // Confirm Password validation
    final confirmPassword = _confirmPasswordController.text;
    if (confirmPassword.isEmpty) {
      setState(() {
        _confirmPasswordError = 'Confirm password is required';
      });
      errorMessages.add(_confirmPasswordError!);
      isValid = false;
    } else if (newPassword != confirmPassword) {
      setState(() {
        _confirmPasswordError = 'Passwords do not match';
      });
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
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Future<void> _changePassword() async {
  //   if (!_validateForm()) {
  //     return;
  //   }
  //
  //   try {
  //     setState(() {
  //       _isLoading = true;
  //     });
  //
  //     final currentPassword = _currentPasswordController.text;
  //   final newPassword = _newPasswordController.text;
  //     final confirmPassword = _confirmPasswordController.text;
  //
  //     // Call your actual API method here
  //     // Replace 'YourApiService.changePassword' with your actual API call
  //     final result = await _authUsecase.changePassword(
  //       currentPassword,
  //       newPassword,
  //         confirmPassword
  //     );
  //
  //     setState(() {
  //       _isLoading = false;
  //     });
  //
  //     // Handle successful response
  //     if (result.isSuccess) {
  //       // Show success dialog
  //       Notify.showAwesomeDialog(
  //         title: 'Password successfully updated',
  //         message:
  //         'Your password has been updated successfully. Please use your new password the next time you sign in.',
  //         dialogType: DialogType.success,
  //         btnOkText: 'Okay, Thanks',
  //         onOkPress: () {
  //           Navigator.pop(context); // Return to previous screen
  //         },
  //       );
  //
  //       // Clear the form
  //       _currentPasswordController.clear();
  //       _newPasswordController.clear();
  //       _confirmPasswordController.clear();
  //     } else {
  //       // Handle API error response
  //       Notify.showFlushbar(
  //         result.error ?? 'Failed to change password. Please try again.',
  //         isError: true,
  //       );
  //     }
  //
  //   } catch (e) {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //
  //     // Handle different types of errors
  //     String errorMessage;
  //     if (e.toString().contains('network') || e.toString().contains('connection')) {
  //       errorMessage = 'Network error. Please check your internet connection.';
  //     } else if (e.toString().contains('timeout')) {
  //       errorMessage = 'Request timeout. Please try again.';
  //     } else if (e.toString().contains('unauthorized') || e.toString().contains('401')) {
  //       errorMessage = 'Current password is incorrect.';
  //     } else {
  //       errorMessage = 'An unexpected error occurred. Please try again.';
  //     }
  //
  //     Notify.showFlushbar(
  //       errorMessage,
  //       isError: true,
  //     );
  //   }
  // }
  //
  // bool _validateForm() {
  //   bool isValid = true;
  //   List<String> errorMessages = [];
  //
  //   // Reset all errors
  //   setState(() {
  //     _currentPasswordError = null;
  //     _newPasswordError = null;
  //     _confirmPasswordError = null;
  //   });
  //
  //   // Current Password
  //   if (_currentPasswordController.text.isEmpty) {
  //     _currentPasswordError = 'Current password is required';
  //     errorMessages.add(_currentPasswordError!);
  //     isValid = false;
  //   }
  //
  //   // New Password
  //   final newPassword = _newPasswordController.text;
  //   if (newPassword.isEmpty) {
  //     _newPasswordError = 'New password is required';
  //     errorMessages.add(_newPasswordError!);
  //     isValid = false;
  //   } else if (newPassword.length < 5 || newPassword.length > 100) {
  //     _newPasswordError = 'Password must be 5-100 characters';
  //     errorMessages.add(_newPasswordError!);
  //     isValid = false;
  //   }
  //
  //   // Confirm Password
  //   final confirmPassword = _confirmPasswordController.text;
  //   if (confirmPassword.isEmpty) {
  //     _confirmPasswordError = 'Confirm password is required';
  //     errorMessages.add(_confirmPasswordError!);
  //     isValid = false;
  //   } else if (newPassword != confirmPassword) {
  //     _confirmPasswordError = 'Passwords do not match';
  //     errorMessages.add(_confirmPasswordError!);
  //     isValid = false;
  //   }
  //
  //   // Show flushbar with the first error message if any
  //   if (errorMessages.isNotEmpty) {
  //     Notify.showFlushbar(
  //       'Please fix the following: ${errorMessages.first}',
  //       isError: true,
  //     );
  //   }
  //
  //   return isValid;
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF89B7C2), // SPRING SKY background
        body: GestureDetector(
          // Dismiss keyboard when tapping outside of text fields
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              return ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Container(
                  width: double.infinity,
                  // margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    // borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF89B7C2).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
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
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFE37083).withOpacity(0.1), // RASPBERRY
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios,
                                color: Color(0xFFE37083), // RASPBERRY
                              ),
                              padding: const EdgeInsets.all(8),
                              constraints: const BoxConstraints(),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                          // Centered title
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Change Password',
                              style: TextStyle(
                                color: const Color(0xFFE37083), // RASPBERRY
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                fontFamily: 'League Spartan',
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
                              const SizedBox(height: 24),

                              // Security icon and title
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(0xFFFFB876), // PAPAYA
                                          const Color(0xFFFFCB7C), // SUNSHINE
                                        ],
                                      ),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFFFB876).withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.lock,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    "Password Security",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: const Color(0xFFE37083), // RASPBERRY
                                      fontFamily: 'League Spartan',
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // Description
                              Text(
                                "Please enter your current password and a new password to update your credentials.",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  height: 1.6,
                                  fontSize: 15,
                                  fontFamily: 'Inter',
                                ),
                              ),

                              const SizedBox(height: 32),

                              // Current Password
                              Text(
                                "Current Password*",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: const Color(0xFFE37083), // RASPBERRY
                                  fontFamily: 'Inter',
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _currentPasswordController,
                                obscureText: !_isCurrentPasswordVisible,
                                style: const TextStyle(fontFamily: 'Inter'),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: const Color(0xFF89B7C2), // SPRING SKY
                                      width: 2,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: const Color(0xFF89B7C2).withOpacity(0.5),
                                      width: 2,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE37083), // RASPBERRY
                                      width: 2,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFF49AA2), // ICE CREAM
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  errorText: _currentPasswordError,
                                  errorStyle: const TextStyle(
                                    fontFamily: 'Inter',
                                    color: Color(0xFFF49AA2), // ICE CREAM
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFF89B7C2).withOpacity(0.05),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isCurrentPasswordVisible
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: const Color(0xFFE37083), // RASPBERRY
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

                              const SizedBox(height: 24),

                              // New Password
                              Text(
                                "New Password*",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: const Color(0xFFE37083), // RASPBERRY
                                  fontFamily: 'Inter',
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _newPasswordController,
                                obscureText: !_isNewPasswordVisible,
                                style: const TextStyle(fontFamily: 'Inter'),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: const Color(0xFF89B7C2), // SPRING SKY
                                      width: 2,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: const Color(0xFF89B7C2).withOpacity(0.5),
                                      width: 2,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE37083), // RASPBERRY
                                      width: 2,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFF49AA2), // ICE CREAM
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  errorText: _newPasswordError,
                                  errorStyle: const TextStyle(
                                    fontFamily: 'Inter',
                                    color: Color(0xFFF49AA2), // ICE CREAM
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFF89B7C2).withOpacity(0.05),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isNewPasswordVisible
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: const Color(0xFFE37083), // RASPBERRY
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

                              const SizedBox(height: 24),

                              // Confirm New Password
                              Text(
                                "Confirm New Password*",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: const Color(0xFFE37083), // RASPBERRY
                                  fontFamily: 'Inter',
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: !_isConfirmPasswordVisible,
                                style: const TextStyle(fontFamily: 'Inter'),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: const Color(0xFF89B7C2), // SPRING SKY
                                      width: 2,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: const Color(0xFF89B7C2).withOpacity(0.5),
                                      width: 2,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE37083), // RASPBERRY
                                      width: 2,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFF49AA2), // ICE CREAM
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  errorText: _confirmPasswordError,
                                  errorStyle: const TextStyle(
                                    fontFamily: 'Inter',
                                    color: Color(0xFFF49AA2), // ICE CREAM
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFF89B7C2).withOpacity(0.05),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isConfirmPasswordVisible
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: const Color(0xFFE37083), // RASPBERRY
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

                              const SizedBox(height: 24),

                              // Password requirements
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFFA8BF8A).withOpacity(0.1), // MEADOW
                                      const Color(0xFF89B7C2).withOpacity(0.1), // SPRING SKY
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFA8BF8A).withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Password requirements:",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: const Color(0xFFE37083), // RASPBERRY
                                        fontFamily: 'League Spartan',
                                      ),
                                    ),
                                    const SizedBox(height: 12),
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

                      const SizedBox(height: 24),

                      // Change Password Button
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE37083).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _changePassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE37083), // RASPBERRY
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            disabledBackgroundColor: Colors.grey.shade400,
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                              : Text(
                            "Change Password",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              fontFamily: 'League Spartan',
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isMet
                  ? const Color(0xFFA8BF8A) // MEADOW
                  : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(2),
            child: Icon(
              isMet ? Icons.check : Icons.circle_outlined,
              color: Colors.white,
              size: 14,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isMet
                    ? const Color(0xFFA8BF8A) // MEADOW
                    : Colors.grey.shade600,
                fontWeight: isMet ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return  SafeArea(
  //     child:  Scaffold(
  //     body: GestureDetector(
  //       // Dismiss keyboard when tapping outside of text fields
  //       onTap: () {
  //         FocusScope.of(context).unfocus();
  //       },
  //       child:LayoutBuilder(
  //           builder: (context, constraints) {
  //             return ConstrainedBox(
  //               constraints: BoxConstraints(minHeight: constraints.maxHeight),
  //               child: Container(
  //                 width: double.infinity,
  //                 padding: const EdgeInsets.all(20),
  //                 decoration: BoxDecoration(
  //                   color: Colors.white,
  //                   borderRadius: BorderRadius.circular(16),
  //                   boxShadow: [
  //                     BoxShadow(
  //                       color: Colors.black12,
  //                       blurRadius: 10,
  //                       offset: const Offset(0, 5),
  //                     ),
  //                   ],
  //                 ),
  //                 child: Column(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     // Back button and title
  //                     Stack(
  //                       alignment: Alignment.centerLeft,
  //                       children: [
  //                         // Back button on the left
  //                         IconButton(
  //                           icon: const Icon(
  //                             Icons.arrow_back_ios,
  //                             color: Colors.blue,
  //                           ),
  //                           padding: EdgeInsets.zero,
  //                           constraints: const BoxConstraints(),
  //                           onPressed: () => Navigator.of(context).pop(),
  //                         ),
  //                         // Centered title
  //                         const Align(
  //                           alignment: Alignment.center,
  //                           child: Text(
  //                             'Change Password',
  //                             style: TextStyle(
  //                               color: Colors.black,
  //                               fontWeight: FontWeight.bold,
  //                               fontSize: 20,
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //
  //                     Expanded(
  //                       child: SingleChildScrollView(
  //                         child: Column(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           children: [
  //                             const SizedBox(height: 20),
  //
  //                             // Security icon and title
  //                             Row(
  //                               children: [
  //                                 Container(
  //                                   padding: const EdgeInsets.all(8),
  //                                   decoration: const BoxDecoration(
  //                                     color: Colors.deepOrange,
  //                                     shape: BoxShape.circle,
  //                                   ),
  //                                   child: const Icon(
  //                                     Icons.lock,
  //                                     color: Colors.white,
  //                                     size: 16,
  //                                   ),
  //                                 ),
  //                                 const SizedBox(width: 10),
  //                                 const Text(
  //                                   "Password Security",
  //                                   style: TextStyle(
  //                                     fontWeight: FontWeight.bold,
  //                                     fontSize: 16,
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //
  //                             const SizedBox(height: 20),
  //
  //                             // Description
  //                             Text(
  //                               "Please enter your current password and a new password to update your credentials.",
  //                               style: TextStyle(
  //                                 color: Colors.grey.shade700,
  //                                 height: 1.5,
  //                               ),
  //                             ),
  //
  //                             const SizedBox(height: 30),
  //
  //                             // Current Password
  //                             const Text(
  //                               "Current Password*",
  //                               style: TextStyle(fontWeight: FontWeight.w500),
  //                             ),
  //                             const SizedBox(height: 8),
  //                             TextFormField(
  //                               controller: _currentPasswordController,
  //                               obscureText: !_isCurrentPasswordVisible,
  //                               decoration: InputDecoration(
  //                                 border: OutlineInputBorder(
  //                                   borderRadius: BorderRadius.circular(8),
  //                                   borderSide: BorderSide(
  //                                     color: Colors.grey.shade300,
  //                                   ),
  //                                 ),
  //                                 contentPadding: const EdgeInsets.symmetric(
  //                                   horizontal: 15,
  //                                   vertical: 15,
  //                                 ),
  //                                 errorText: _currentPasswordError,
  //                                 suffixIcon: IconButton(
  //                                   icon: Icon(
  //                                     _isCurrentPasswordVisible
  //                                         ? Icons.visibility_off
  //                                         : Icons.visibility,
  //                                     color: Colors.grey,
  //                                   ),
  //                                   onPressed: () {
  //                                     setState(() {
  //                                       _isCurrentPasswordVisible =
  //                                       !_isCurrentPasswordVisible;
  //                                     });
  //                                   },
  //                                 ),
  //                               ),
  //                               onChanged: (value) {
  //                                 if (_currentPasswordError != null) {
  //                                   setState(() {
  //                                     _currentPasswordError = null;
  //                                   });
  //                                 }
  //                               },
  //                             ),
  //
  //                             const SizedBox(height: 20),
  //
  //                             // New Password
  //                             const Text(
  //                               "New Password*",
  //                               style: TextStyle(fontWeight: FontWeight.w500),
  //                             ),
  //                             const SizedBox(height: 8),
  //                             TextFormField(
  //                               controller: _newPasswordController,
  //                               obscureText: !_isNewPasswordVisible,
  //                               decoration: InputDecoration(
  //                                 border: OutlineInputBorder(
  //                                   borderRadius: BorderRadius.circular(8),
  //                                   borderSide: BorderSide(
  //                                     color: Colors.grey.shade300,
  //                                   ),
  //                                 ),
  //                                 contentPadding: const EdgeInsets.symmetric(
  //                                   horizontal: 15,
  //                                   vertical: 15,
  //                                 ),
  //                                 errorText: _newPasswordError,
  //                                 suffixIcon: IconButton(
  //                                   icon: Icon(
  //                                     _isNewPasswordVisible
  //                                         ? Icons.visibility_off
  //                                         : Icons.visibility,
  //                                     color: Colors.grey,
  //                                   ),
  //                                   onPressed: () {
  //                                     setState(() {
  //                                       _isNewPasswordVisible =
  //                                       !_isNewPasswordVisible;
  //                                     });
  //                                   },
  //                                 ),
  //                               ),
  //                               onChanged: (value) {
  //                                 if (_newPasswordError != null) {
  //                                   setState(() {
  //                                     _newPasswordError = null;
  //                                   });
  //                                 }
  //                               },
  //                             ),
  //
  //                             const SizedBox(height: 20),
  //
  //                             // Confirm New Password
  //                             const Text(
  //                               "Confirm New Password*",
  //                               style: TextStyle(fontWeight: FontWeight.w500),
  //                             ),
  //                             const SizedBox(height: 8),
  //                             TextFormField(
  //                               controller: _confirmPasswordController,
  //                               obscureText: !_isConfirmPasswordVisible,
  //                               decoration: InputDecoration(
  //                                 border: OutlineInputBorder(
  //                                   borderRadius: BorderRadius.circular(8),
  //                                   borderSide: BorderSide(
  //                                     color: Colors.grey.shade300,
  //                                   ),
  //                                 ),
  //                                 contentPadding: const EdgeInsets.symmetric(
  //                                   horizontal: 15,
  //                                   vertical: 15,
  //                                 ),
  //                                 errorText: _confirmPasswordError,
  //                                 suffixIcon: IconButton(
  //                                   icon: Icon(
  //                                     _isConfirmPasswordVisible
  //                                         ? Icons.visibility_off
  //                                         : Icons.visibility,
  //                                     color: Colors.grey,
  //                                   ),
  //                                   onPressed: () {
  //                                     setState(() {
  //                                       _isConfirmPasswordVisible =
  //                                       !_isConfirmPasswordVisible;
  //                                     });
  //                                   },
  //                                 ),
  //                               ),
  //                               onChanged: (value) {
  //                                 if (_confirmPasswordError != null) {
  //                                   setState(() {
  //                                     _confirmPasswordError = null;
  //                                   });
  //                                 }
  //                               },
  //                             ),
  //
  //                             const SizedBox(height: 20),
  //
  //                             // Password requirements
  //                             Container(
  //                               padding: const EdgeInsets.all(15),
  //                               decoration: BoxDecoration(
  //                                 color: Colors.grey.shade100,
  //                                 borderRadius: BorderRadius.circular(8),
  //                               ),
  //                               child: Column(
  //                                 crossAxisAlignment: CrossAxisAlignment.start,
  //                                 children: [
  //                                   const Text(
  //                                     "Password requirements:",
  //                                     style: TextStyle(
  //                                       fontWeight: FontWeight.bold,
  //                                     ),
  //                                   ),
  //                                   const SizedBox(height: 10),
  //                                   _buildRequirementItem(
  //                                     "At least 5 characters",
  //                                     _newPasswordController.text.length >= 5,
  //                                   ),
  //                                   _buildRequirementItem(
  //                                     "Maximum 100 characters",
  //                                     _newPasswordController.text.length <= 100,
  //                                   ),
  //                                 ],
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //
  //                     const SizedBox(height: 20),
  //
  //                     // Change Password Button
  //                     SizedBox(
  //                       width: double.infinity,
  //                       child: ElevatedButton(
  //                         onPressed: _isLoading ? null : _changePassword,
  //                         style: ElevatedButton.styleFrom(
  //                           backgroundColor: Colors.deepOrange,
  //                           padding: const EdgeInsets.symmetric(vertical: 15),
  //                           shape: RoundedRectangleBorder(
  //                             borderRadius: BorderRadius.circular(8),
  //                           ),
  //                           disabledBackgroundColor: Colors.grey,
  //                         ),
  //                         child: _isLoading
  //                             ? const SizedBox(
  //                           height: 20,
  //                           width: 20,
  //                           child: CircularProgressIndicator(
  //                             color: Colors.white,
  //                             strokeWidth: 2,
  //                           ),
  //                         )
  //                             : const Text(
  //                           "Change Password",
  //                           style: TextStyle(
  //                             color: Colors.white,
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             );
  //           },
  //         ),
  //       ),
  //     ),
  //   );
  // }
  //
  // Widget _buildRequirementItem(String text, bool isMet) {
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 5),
  //     child: Row(
  //       children: [
  //         Icon(
  //           isMet ? Icons.check_circle : Icons.circle_outlined,
  //           color: isMet ? Colors.green : Colors.grey,
  //           size: 16,
  //         ),
  //         const SizedBox(width: 8),
  //         Text(
  //           text,
  //           style: TextStyle(
  //             color: isMet ? Colors.green : Colors.grey.shade700,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
