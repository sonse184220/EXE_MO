import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';
import 'package:inner_child_app/domain/usecases/auth_usecase.dart';
import 'package:inner_child_app/presentation/pages/authentication_pages/forgot_password_2.dart';

class ForgotPassword1 extends ConsumerStatefulWidget {
  const ForgotPassword1({super.key});

  @override
  ConsumerState<ForgotPassword1> createState() => _ForgotPassword1State();
}

class _ForgotPassword1State extends ConsumerState<ForgotPassword1>
    with SingleTickerProviderStateMixin {
  late final AuthUsecase _authUsecase;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  late final AnimationController _controller;
  final FocusNode _emailFocusNode = FocusNode();
  bool _isFieldFocused = false;

  Future<void> _handleRequestPasswordChange() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final email = _emailController.text.trim();

      final result = await _authUsecase.forgotPassword(email);

      setState(() => _isLoading = false);

      if (result.isSuccess) {
        // Navigate or show success dialog
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Email Sent'),
            content: Text(
              'We\'ve sent a password reset link to $email. Please check your inbox.',
            ),
            actions: [
              TextButton(
                onPressed:
                    () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const ForgotPassword2()),
                  );
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else if (result.isFailure) {
        // Show error dialog
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(result.error ?? 'An unknown error occurred.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
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

    _authUsecase = ref.read(authUseCaseProvider);

    _emailFocusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    super.dispose();

    _emailController.dispose();

    _controller.dispose();
    _emailFocusNode.dispose();
  }

  void _handleFocusChange() {
    final isNowFocused = _emailFocusNode.hasFocus;
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
                              'Forgot Password?',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Enter your email address and we\'ll check your account to reset your password.',
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            focusNode: _emailFocusNode,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              hintText: 'Enter your email address',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
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
                        onPressed: _isLoading ? null : _handleRequestPasswordChange,
                        // onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPassword2()));},
                            // _isLoading
                            //     ? null
                            //     : () async {
                            //       if (_formKey.currentState!.validate()) {
                            //         setState(() => _isLoading = true);
                            //         await Future.delayed(Duration(seconds: 2));
                            //         setState(() => _isLoading = false);
                            //
                            //         showDialog(
                            //           context: context,
                            //           builder:
                            //               (context) => AlertDialog(
                            //                 title: Text('Email Sent'),
                            //                 content: Text(
                            //                   'We\'ve sent a password reset link to ${_emailController.text}. Please check your inbox.',
                            //                 ),
                            //                 actions: [
                            //                   TextButton(
                            //                     onPressed:
                            //                         () =>
                            //                             Navigator.pop(context),
                            //                     child: Text('OK'),
                            //                   ),
                            //                 ],
                            //               ),
                            //         );
                            //       }
                            //     },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          disabledBackgroundColor: Colors.blue.withAlpha((0.5 * 255).toInt()),
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
                                  'Request Password Change',
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
