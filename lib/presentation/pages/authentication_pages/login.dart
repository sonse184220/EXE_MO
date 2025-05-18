import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/core/utils/auth_utils/google_authentication.dart';
import 'package:inner_child_app/core/utils/notify_another_flushbar.dart';
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

  bool _obscurePassword = true;

  late final _authUseCase;

  @override
  void initState() {
    super.initState();
    // Initialize the authUseCase once
    _authUseCase = ref.read(authUseCaseProvider);
  }

  Future<void> _handleLoginWithGoogle() async {
    try {
      var userCredential = await signInWithGoogle();
      final idToken = await userCredential.user?.getIdToken();
      print(idToken);
      final result = await _authUseCase.loginWithGoogle(idToken);
      if (result.isSuccess) {
        NotifyAnotherFlushBar.showFlushbar(
          result.data ?? 'Login google success.',
          isError: false,
        );
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => const MainScreen()),
        // );
      } else {
        NotifyAnotherFlushBar.showFlushbar(
          result.error ?? 'Login google failed. Please check your credentials',
          isError: true,
        );
      }
    } catch (e) {
      print(e.toString());
      NotifyAnotherFlushBar.showFlushbar(
        e.toString() ?? 'Login google failed. Please check your credentials',
        isError: true,
      );
    }
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (email.isEmpty || password.isEmpty) {
      NotifyAnotherFlushBar.showFlushbar(
        'Please fill in both fields',
        isError: true,
      );
      return;
    }

    if (!emailRegex.hasMatch(_emailController.text)) {
      NotifyAnotherFlushBar.showFlushbar(
        'Email is not valid.',
        isError: true,
      );
      return;
    }

    final loginModel = UserLoginModel(email: email, password: password);

    final result = await _authUseCase.loginWithCredentials(loginModel);

    if (result.isSuccess) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfileChoosingPage()),
      );
    } else {
      NotifyAnotherFlushBar.showFlushbar(
        result.error ?? 'Login failed. Please check your credentials',
        isError: true,
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authUseCase = ref.read(authUseCaseProvider);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Container(
                  width: double.infinity,
                  // height: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
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
                                fillColor: Color(0xFFEBEBEB),
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
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
                                fillColor: Colors.grey[200],
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
                            ),

                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPassword1()));},
                                child: const Text(
                                  'FORGET PASSWORD?',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
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
                                backgroundColor: Colors.brown,
                                minimumSize: const Size.fromHeight(50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed:
                              _handleLogin,
                              //     () {
                              //   Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //       builder: (context) => const ProfileChoosingPage(),
                              //     ),
                              //   );
                              // },
                              child: const Text(
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
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Text("Or continue with"),
                                ),
                                Expanded(child: Divider()),
                              ],
                            ),

                            const SizedBox(height: 20),

                            GestureDetector(
                              onTap: _handleLoginWithGoogle,
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
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/googleIcon.png',
                                      width: 24,
                                      height: 24,
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      'SIGN IN WITH GOOGLE',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
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
                                          color: Colors.black,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      // spacing between lines
                                      GestureDetector(
                                        onTap: () {
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
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  Icon(
                                    Icons.arrow_right_alt,
                                    size: 28,
                                    color: Colors.black,
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
