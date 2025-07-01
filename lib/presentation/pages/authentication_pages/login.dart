import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/core/utils/auth_utils/google_authentication.dart';
import 'package:inner_child_app/core/utils/notify_another_flushbar.dart';
import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/domain/usecases/auth_usecase.dart';
import 'package:inner_child_app/presentation/pages/authentication_pages/forgot_password_1.dart';
import 'package:inner_child_app/presentation/pages/authentication_pages/profile_choosing_page.dart';
import 'package:inner_child_app/presentation/pages/authentication_pages/register.dart';

import '../../../core/utils/dependency_injection/injection.dart';
import '../../../domain/entities/auth/user_login_model.dart';

class Login extends ConsumerStatefulWidget {
  const Login({super.key});

  @override
  LoginPage createState() => LoginPage();
}

class LoginPage extends ConsumerState<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _resendEmailController = TextEditingController();

  bool _obscurePassword = true;
  bool _isEmailLoginLoading = false;
  bool _isGoogleLoginLoading = false;
  bool _isResendLoading = false;

  late final AuthUsecase _authUseCase;

  @override
  void initState() {
    super.initState();
    // Initialize the authUseCase once
    _authUseCase = ref.read(authUseCaseProvider);
  }

  Future<void> _handleResendEmailConfirmation() async {
    final email = _resendEmailController.text.trim();
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (email.isEmpty) {
      Notify.showFlushbar(
        'Please enter your email address',
        isError: true,
      );
      return;
    }

    if (!emailRegex.hasMatch(email)) {
      Notify.showFlushbar('Please enter a valid email address.', isError: true);
      return;
    }

    setState(() {
      _isResendLoading = true;
    });

    try {
      // Replace this with your actual API method call
      final result = await _authUseCase.resendEmailConfirm(email);
      // final result = new Result.success('');

      if (result.isSuccess) {
        Notify.showFlushbar(
          result.data!,
          // 'Confirmation email sent successfully!',
          isError: false,
        );
        Navigator.of(context).pop(); // Close the dialog
        _resendEmailController.clear();
      } else {
        Notify.showFlushbar(
          result.error ?? 'Failed to send confirmation email. Please try again.',
          isError: true,
        );
      }
    } catch (e) {
      Notify.showFlushbar(
        'An error occur while sending confirmation email. Please try again.',
        // e.toString(),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isResendLoading = false;
        });
      }
    }
  }

  void _showResendEmailDialog() {
    showDialog(
      context: context,
      barrierDismissible: !_isResendLoading,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Resend Email Confirmation'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Enter your email address to resend the confirmation email.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _resendEmailController,
                    enabled: !_isResendLoading,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: _isResendLoading ? Colors.grey[300] : Color(0xFFEBEBEB),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: _isResendLoading ? null : () {
                    Navigator.of(context).pop();
                    _resendEmailController.clear();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: _isResendLoading ? Colors.grey : Colors.black54,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isResendLoading ? Colors.grey : Color(0xFFE37083),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _isResendLoading ? null : () async {
                    setDialogState(() {
                      _isResendLoading = true;
                    });
                    await _handleResendEmailConfirmation();
                    if (mounted) {
                      setDialogState(() {
                        _isResendLoading = false;
                      });
                    }
                  },
                  child: _isResendLoading
                      ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Sending...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  )
                      : const Text(
                    'Send',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _handleLoginWithGoogle() async {
    if (_isGoogleLoginLoading || _isEmailLoginLoading) return;

    setState(() {
      _isGoogleLoginLoading = true;
    });

    try {
      var userCredential = await signInWithGoogle();
      final idToken = await userCredential.user?.getIdToken();
      print('cl nè id token: $idToken con cc');
      final result = await _authUseCase.loginWithGoogle(idToken!);
      if (result.isSuccess) {
        Notify.showFlushbar(
          'Login google success.',
          isError: false,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileChoosingPage()),
        );
      } else {
        Notify.showFlushbar(
          result.error ?? 'Login google failed. Please check your credentials',
          isError: true,
        );
      }
    } catch (e) {
      Notify.showFlushbar(
        e.toString() ?? 'Login google failed. Please check your credentials',
        isError: true,
      );
    }finally {
      if (mounted) {
        setState(() {
          _isGoogleLoginLoading = false;
        });
      }
    }
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (email.isEmpty || password.isEmpty) {
      Notify.showFlushbar(
        'Please fill in both fields',
        isError: true,
      );
      return;
    }

    if (!emailRegex.hasMatch(_emailController.text)) {
      Notify.showFlushbar('Email is not valid.', isError: true);
      return;
    }

    setState(() {
      _isEmailLoginLoading = true;
    });

    try{final loginModel = UserLoginModel(email: email, password: password);

    final result = await _authUseCase.loginWithCredentials(loginModel);

    if (!mounted) return;

    if (result.isSuccess) {
      // context.go('/user${AppRoute.profileChoosing}');
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => const ProfileChoosingPage()),
      // );
    } else {
      Notify.showFlushbar(
        result.error ?? 'Login failed. Please check your credentials',
        isError: true,
      );
    }}catch(e){
      Notify.showFlushbar(
        e.toString() ?? 'Login failed. Please check your credentials',
        isError: true,
      );
    }finally {
      if (mounted) {
        setState(() {
          _isEmailLoginLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _resendEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isAnyLoading = _isEmailLoginLoading || _isGoogleLoginLoading;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        // floatingActionButton: FloatingActionButton(
        //   onPressed: isAnyLoading ? null :
        //       () =>
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(builder: (context) => AdminMainScreen()),
        //       ),
        //   child: const Icon(Icons.add),
        // ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Container(
                  // width: double.infinity,
                  // height: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    // color: Colors.white,
                    // borderRadius: BorderRadius.circular(16),
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: Colors.black12,
                    //     blurRadius: 10,
                    //     offset: Offset(0, 5),
                    //   ),
                    // ],
                  ),
                  // child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 70,
                        height: 80,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/appLogo.png'),
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),

                      // Welcome Text section
                      Container(
                        margin: const EdgeInsets.only(top: 20, bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome Back',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Sign In to a Healthier, Happier You',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      //Input Fields Section
                      Container(
                        margin: EdgeInsets.only(top: 20, bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextFormField(
                              controller: _emailController,
                              enabled: !isAnyLoading,
                              decoration: InputDecoration(
                                hintText: 'Enter your email',
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor:  isAnyLoading ? Colors.grey[300] : Color(0xFFEBEBEB),
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              enabled: !isAnyLoading,
                              decoration: InputDecoration(
                                hintText: 'Enter your password',
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: isAnyLoading ? Colors.grey[300] : Colors.grey[200],
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed:  isAnyLoading ? null :  () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: isAnyLoading ? null : _showResendEmailDialog,
                                  child: Text(
                                    'RESEND EMAIL CONFIRM',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isAnyLoading ? Colors.grey : Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: isAnyLoading ? null : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ForgotPassword1(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'FORGET PASSWORD?',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isAnyLoading ? Colors.grey: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      //Buttons Section
                      Container(
                        margin: EdgeInsets.only(top: 20, bottom: 20),
                        child: Column(
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:  isAnyLoading ? Colors.grey : Color(0xFFE37083),
                                minimumSize: const Size.fromHeight(50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed:  isAnyLoading ? null : _handleLogin,
                              child: _isEmailLoginLoading
                                  ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'SIGNING IN...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              )
                                  : const Text(
                                'SIGN IN',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            Row(
                              children: [
                                Expanded(child: Divider()),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Text("Or continue with", style: TextStyle(
                                    color: isAnyLoading ? Colors.grey : Colors.black,
                                  ),),
                                ),
                                Expanded(child: Divider()),
                              ],
                            ),

                            const SizedBox(height: 20),

                            GestureDetector(
                              onTap:  isAnyLoading ? null :  _handleLoginWithGoogle,
                              //     () async {
                              //   var user = await signInWithGoogle();
                              //
                              // },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 20,
                                ),
                                decoration: BoxDecoration(
                                  color: isAnyLoading ? Colors.grey[300] : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (_isGoogleLoginLoading) ...[
                                      SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.black54),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        'SIGNING IN...',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ] else ...[
                                      Image.asset(
                                        'assets/images/googleIcon.png',
                                        width: 24,
                                        height: 24,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        'SIGN IN WITH GOOGLE',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isAnyLoading ? Colors.grey : Colors.black87,
                                        ),
                                      ),
                                    ],
                                    // Image.asset(
                                    //   'assets/images/googleIcon.png',
                                    //   width: 24,
                                    //   height: 24,
                                    // ),
                                    // const SizedBox(width: 10),
                                    // const Text(
                                    //   'SIGN IN WITH GOOGLE',
                                    //   style: TextStyle(
                                    //     fontSize: 14,
                                    //     color: Colors.black87,
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 50),

                            //Sign-up Sections
                            Container(
                              margin: EdgeInsets.only(top: 20, bottom: 20),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Don't have an account?",
                                        style: TextStyle(
                                          color: isAnyLoading ? Colors.grey : Colors.black,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      // spacing between lines
                                      GestureDetector(
                                        onTap:  isAnyLoading ? null :  () {
                                          // Navigate to sign-up page
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                              const RegisterPage(),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          'SIGN UP',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: isAnyLoading ? Colors.grey : Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  Icon(
                                    Icons.arrow_right_alt,
                                    size: 28,
                                    color: isAnyLoading ? Colors.grey : Colors.black,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // ),
                ),
              ),
              //   ],
              // ),
            );
          },
        ),
      ),
    );
  }
}