import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';
import 'package:inner_child_app/domain/usecases/auth_usecase.dart';

class ForgotPassword2 extends ConsumerStatefulWidget {
  const ForgotPassword2({super.key});

  @override
  ConsumerState<ForgotPassword2> createState() => _ForgotPassword2State();
}

class _ForgotPassword2State extends ConsumerState<ForgotPassword2>
    with SingleTickerProviderStateMixin {
  late final AuthUsecase _authUsecase;
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  late final AnimationController _controller;

  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  bool _isFieldFocused = false;

  Future<void> _handleResetPassword() async {
    FocusScope.of(context).unfocus();

    // Validate password fields manually, because you have specific rules
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    List<String> errorMessages = [];
    bool isValid = true;

    if (password.isEmpty) {
      errorMessages.add('Password is required');
      isValid = false;
    } else if (password.length < 5 || password.length > 100) {
      errorMessages.add('Password must be 5-100 characters');
      isValid = false;
    }

    if (confirmPassword.isEmpty) {
      errorMessages.add('Confirm password is required');
      isValid = false;
    } else if (password != confirmPassword) {
      errorMessages.add('Password and confirm password do not match');
      isValid = false;
    }

    if (!isValid) {
      // Show all error messages in a dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Validation Error'),
          content: Text(errorMessages.join('\n')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
// Call your resetPassword usecase
    final result = await _authUsecase.resetPassword(password, confirmPassword);

    setState(() => _isLoading = false);

    if (result.isSuccess) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Success'),
          content: Text(result.data ?? 'Password reset successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to login or previous screen
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text(result.error ?? 'Failed to reset password.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }

  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      value: 1.0,
    );
    _passwordFocusNode.addListener(_handleFocusChange);
    _confirmPasswordFocusNode.addListener(_handleFocusChange);

    _authUsecase = ref.read(authUseCaseProvider);
  }

  @override
  void dispose() {
    super.dispose();

    _controller.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
  }

  void _handleFocusChange() {
    final isNowFocused =
        _passwordFocusNode.hasFocus || _confirmPasswordFocusNode.hasFocus;
    if (isNowFocused != _isFieldFocused) {
      setState(() {
        _isFieldFocused = isNowFocused;
      });

      if (_isFieldFocused) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ===== Top: Back Button and Header =====
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    SizedBox(height: 20),
                    SizeTransition(
                      sizeFactor: _controller,
                      axisAlignment: -1.0,
                      child: Center(
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.lock_reset,
                                size: 60,
                                color: Colors.deepOrangeAccent,
                              ),
                            ),
                            SizedBox(height: 24),
                            Text(
                              'Reset Password',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Please create a new password for your account.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // ===== Middle: Form with scroll if needed =====
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 10),
                        // Form
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Password field
                              TextFormField(
                                focusNode: _passwordFocusNode,
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: 'New Password',
                                  hintText: 'Enter your new password',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a password';
                                  }
                                  if (value.length < 8) {
                                    return 'Password must be at least 8 characters';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 20),

                              // Confirm password field
                              TextFormField(
                                focusNode: _confirmPasswordFocusNode,
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                decoration: InputDecoration(
                                  labelText: 'Confirm Password',
                                  hintText: 'Confirm your new password',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmPassword =
                                            !_obscureConfirmPassword;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please confirm your password';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        // Password requirements
                        Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Password requirements:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: 16,
                                    color: Colors.green,
                                  ),
                                  SizedBox(width: 8),
                                  Text('At least 8 characters'),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: 16,
                                    color: Colors.green,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Include uppercase & lowercase letters'),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: 16,
                                    color: Colors.green,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Include at least one number'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ===== Bottom: Submit Buttons =====
                Column(
                  children: [
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleResetPassword,
                        // onPressed:
                        //     _isLoading
                        //         ? null
                        //         : () async {
                        //           if (_formKey.currentState!.validate()) {
                        //             setState(() => _isLoading = true);
                        //             await Future.delayed(Duration(seconds: 2));
                        //             setState(() => _isLoading = false);
                        //
                        //             showDialog(
                        //               context: context,
                        //               builder:
                        //                   (context) => AlertDialog(
                        //                     title: Text('Email Sent'),
                        //                     // content: Text(
                        //                     //   'We\'ve sent a password reset link to ${_emailController.text}. Please check your inbox.',
                        //                     // ),
                        //                     actions: [
                        //                       TextButton(
                        //                         onPressed:
                        //                             () =>
                        //                                 Navigator.pop(context),
                        //                         child: Text('OK'),
                        //                       ),
                        //                     ],
                        //                   ),
                        //             );
                        //           }
                        //         },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          disabledBackgroundColor: Colors.blue.withOpacity(0.5),
                        ),
                        child:
                            _isLoading
                                ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : Text(
                                  'Send Reset Link',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Back to Login',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
