import 'package:flutter/material.dart';
import 'package:inner_child_app/presentation/screens/main_screen.dart';

class LoginWrapperMaterial extends StatelessWidget {
  const LoginWrapperMaterial({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Login(), debugShowCheckedModeBanner: false);
  }
}

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  LoginPage createState() => LoginPage();
}

class LoginPage extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // child: Padding(
        //   padding: const EdgeInsets.all(20.0),
        // child: Stack(
        //   children: [
        child: Container(
          width: double.infinity,
          height: double.infinity,
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
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
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
                      // controller: _emailController,
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
                      // controller: _passwordController,
                      // obscureText: _obscurePassword,
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
                          icon: Icon(Icons.visibility_off),
                          // icon: Icon(
                          //     _obscurePassword
                          //     ? Icons.visibility_off
                          //     : Icons.visibility),
                          onPressed: () {
                            // setState(() {
                            //   _obscurePassword = !_obscurePassword;
                            // });
                          },
                        ),
                      ),
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          'FORGET PASSWORD?',
                          style: TextStyle(fontSize: 12, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // const SizedBox(height: 10),

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
                      onPressed: () {
                        Navigator.push( context,
                          MaterialPageRoute(builder: (context) => const MainScreen()),);
                      },
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
                      onTap: () {
                        // Handle Google sign in
                      },
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Don't have an account?",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4), // spacing between lines
                              GestureDetector(
                                onTap: () {
                                  // Navigate to sign-up page
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

                          // RichText(
                          //   text: TextSpan(
                          //     text: "Don't have an account? ",
                          //     style: TextStyle(
                          //       color: Colors.black,
                          //       fontSize: 14,
                          //     ),
                          //     children: [
                          //       TextSpan(
                          //         text: 'SIGN UP',
                          //         style: TextStyle(
                          //           fontWeight: FontWeight.bold,
                          //           fontSize: 14,
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          Icon(
                            Icons.arrow_right_alt,
                            size: 28,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
          // ),
        ),
        //   ],
        // ),
      ),
    );

    // return Container(
    //   width: 375,
    //   height: 812,
    //   decoration: BoxDecoration(
    //     borderRadius: BorderRadius.only(
    //       topLeft: Radius.circular(16),
    //       topRight: Radius.circular(16),
    //       bottomLeft: Radius.circular(16),
    //       bottomRight: Radius.circular(16),
    //     ),
    //     color: Color.fromRGBO(255, 255, 255, 1),
    //   ),
    //   child: Stack(
    //     children: <Widget>[
    //       Positioned(
    //         top: 395,
    //         left: 232,
    //         child: Text(
    //           'Forget Password?',
    //           textAlign: TextAlign.left,
    //           style: TextStyle(
    //             color: Color.fromRGBO(0, 0, 0, 1),
    //             fontFamily: 'League Spartan',
    //             fontSize: 12,
    //             letterSpacing:
    //                 0 /*percentages not used in flutter. defaulting to zero*/,
    //             fontWeight: FontWeight.normal,
    //             height: 1,
    //           ),
    //         ),
    //       ),
    //       Positioned(
    //         top: 542,
    //         left: 138,
    //         child: Text(
    //           'Or continue with',
    //           textAlign: TextAlign.left,
    //           style: TextStyle(
    //             color: Color.fromRGBO(0, 0, 0, 1),
    //             fontFamily: 'League Spartan',
    //             fontSize: 12,
    //             letterSpacing:
    //                 0 /*percentages not used in flutter. defaulting to zero*/,
    //             fontWeight: FontWeight.normal,
    //             height: 1,
    //           ),
    //         ),
    //       ),
    //       Positioned(
    //         top: 130,
    //         left: 20,
    //         child: Text(
    //           'Welcome Back',
    //           textAlign: TextAlign.left,
    //           style: TextStyle(
    //             color: Color.fromRGBO(0, 0, 0, 1),
    //             fontFamily: 'League Spartan',
    //             fontSize: 26,
    //             letterSpacing:
    //                 0 /*percentages not used in flutter. defaulting to zero*/,
    //             fontWeight: FontWeight.normal,
    //             height: 1,
    //           ),
    //         ),
    //       ),
    //       Positioned(
    //         top: 707,
    //         left: 20,
    //         child: Text(
    //           'Don’t have an account?',
    //           textAlign: TextAlign.left,
    //           style: TextStyle(
    //             color: Color.fromRGBO(0, 0, 0, 1),
    //             fontFamily: 'League Spartan',
    //             fontSize: 12,
    //             letterSpacing:
    //                 0 /*percentages not used in flutter. defaulting to zero*/,
    //             fontWeight: FontWeight.normal,
    //             height: 1,
    //           ),
    //         ),
    //       ),
    //       Positioned(
    //         top: 728,
    //         left: 20,
    //         child: Text(
    //           'SIGN UP',
    //           textAlign: TextAlign.left,
    //           style: TextStyle(
    //             color: Color.fromRGBO(0, 0, 0, 1),
    //             fontFamily: 'League Spartan',
    //             fontSize: 18,
    //             letterSpacing:
    //                 0 /*percentages not used in flutter. defaulting to zero*/,
    //             fontWeight: FontWeight.normal,
    //             height: 1,
    //           ),
    //         ),
    //       ),
    //       Positioned(top: 0, left: 0, child: SizedBox.shrink()),
    //       // Positioned(
    //       //   top: 778,
    //       //   left: 0,
    //       //   child: Container(
    //       //     width: 375,
    //       //     height: 34,
    //       //
    //       //     child: Stack(
    //       //       children: <Widget>[
    //       //         Positioned(
    //       //           top: 0,
    //       //           left: 0,
    //       //           child: Container(
    //       //             width: 375,
    //       //             height: 34,
    //       //             decoration: BoxDecoration(
    //       //               color: Color.fromRGBO(255, 255, 255, 1),
    //       //             ),
    //       //           ),
    //       //         ),
    //       //         Positioned(
    //       //           top: 15,
    //       //           left: 118,
    //       //           child: Container(
    //       //             width: 139,
    //       //             height: 5,
    //       //             decoration: BoxDecoration(
    //       //               borderRadius: BorderRadius.only(
    //       //                 topLeft: Radius.circular(100),
    //       //                 topRight: Radius.circular(100),
    //       //                 bottomLeft: Radius.circular(100),
    //       //                 bottomRight: Radius.circular(100),
    //       //               ),
    //       //               color: Color.fromRGBO(0, 0, 0, 1),
    //       //             ),
    //       //           ),
    //       //         ),
    //       //       ],
    //       //     ),
    //       //   ),
    //       // ),
    //       Positioned(
    //         top: 173,
    //         left: 20,
    //         child: Text(
    //           'Sign In to a Healthier, Happier You',
    //           textAlign: TextAlign.left,
    //           style: TextStyle(
    //             color: Color.fromRGBO(0, 0, 0, 1),
    //             fontFamily: 'League Spartan',
    //             fontSize: 16,
    //             letterSpacing:
    //                 0 /*percentages not used in flutter. defaulting to zero*/,
    //             fontWeight: FontWeight.normal,
    //             height: 1.375,
    //           ),
    //         ),
    //       ),
    //       Positioned(
    //         top: 590,
    //         left: 20,
    //         child: Container(
    //           decoration: BoxDecoration(
    //             borderRadius: BorderRadius.only(
    //               topLeft: Radius.circular(1000),
    //               topRight: Radius.circular(1000),
    //               bottomLeft: Radius.circular(1000),
    //               bottomRight: Radius.circular(1000),
    //             ),
    //             color: Color.fromRGBO(241, 241, 241, 1),
    //           ),
    //           padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
    //           child: Row(
    //             mainAxisSize: MainAxisSize.min,
    //
    //             children: <Widget>[
    //               Container(
    //                 width: 35,
    //                 height: 35,
    //                 decoration: BoxDecoration(
    //                   image: DecorationImage(
    //                     image: AssetImage('assets/images/googleIcon.png'),
    //                     fit: BoxFit.fitWidth,
    //                   ),
    //                 ),
    //               ),
    //               SizedBox(width: 10),
    //               Text(
    //                 'Sign in with google',
    //                 textAlign: TextAlign.left,
    //                 style: TextStyle(
    //                   color: Color.fromRGBO(0, 0, 0, 1),
    //                   fontFamily: 'League Spartan',
    //                   fontSize: 14,
    //                   letterSpacing:
    //                       0 /*percentages not used in flutter. defaulting to zero*/,
    //                   fontWeight: FontWeight.normal,
    //                   height: 1,
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ),
    //       ),
    //       Positioned(
    //         top: 245,
    //         left: 20,
    //         child: Container(
    //           decoration: BoxDecoration(
    //             color: Color.fromRGBO(234, 234, 234, 1),
    //           ),
    //           padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    //           child: Row(
    //             mainAxisSize: MainAxisSize.min,
    //
    //             children: <Widget>[
    //               Text(
    //                 'EMAIL',
    //                 textAlign: TextAlign.left,
    //                 style: TextStyle(
    //                   color: Color.fromRGBO(140, 140, 140, 1),
    //                   fontFamily: 'League Spartan',
    //                   fontSize: 12,
    //                   letterSpacing:
    //                       0 /*percentages not used in flutter. defaulting to zero*/,
    //                   fontWeight: FontWeight.normal,
    //                   height: 1,
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ),
    //       ),
    //       Positioned(
    //         top: 324,
    //         left: 20,
    //         child: Container(
    //           decoration: BoxDecoration(
    //             color: Color.fromRGBO(234, 234, 234, 1),
    //           ),
    //           padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    //           child: Row(
    //             mainAxisSize: MainAxisSize.min,
    //
    //             children: <Widget>[
    //               Text(
    //                 'PASSWORD',
    //                 textAlign: TextAlign.left,
    //                 style: TextStyle(
    //                   color: Color.fromRGBO(140, 140, 140, 1),
    //                   fontFamily: 'League Spartan',
    //                   fontSize: 12,
    //                   letterSpacing:
    //                       0 /*percentages not used in flutter. defaulting to zero*/,
    //                   fontWeight: FontWeight.normal,
    //                   height: 1,
    //                 ),
    //               ),
    //               SizedBox(width: 205),
    //               SizedBox.shrink(),
    //             ],
    //           ),
    //         ),
    //       ),
    //       Positioned(top: 726, left: 331, child: SizedBox.shrink()),
    //       Positioned(
    //         top: 47,
    //         left: 35,
    //         child: Container(
    //           width: 45,
    //           height: 54,
    //           decoration: BoxDecoration(
    //             image: DecorationImage(
    //               image: AssetImage('assets/images/appLogo.png'),
    //               fit: BoxFit.fitWidth,
    //             ),
    //           ),
    //         ),
    //       ),
    //       Positioned(
    //         top: 461,
    //         left: 20,
    //         child: Container(
    //           decoration: BoxDecoration(
    //             borderRadius: BorderRadius.only(
    //               topLeft: Radius.circular(1000),
    //               topRight: Radius.circular(1000),
    //               bottomLeft: Radius.circular(1000),
    //               bottomRight: Radius.circular(1000),
    //             ),
    //             color: Color.fromRGBO(78, 51, 33, 1),
    //           ),
    //           padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
    //           child: Row(
    //             mainAxisSize: MainAxisSize.min,
    //
    //             children: <Widget>[
    //               Text(
    //                 'SIGN IN',
    //                 textAlign: TextAlign.left,
    //                 style: TextStyle(
    //                   color: Color.fromRGBO(255, 255, 255, 1),
    //                   fontFamily: 'League Spartan',
    //                   fontSize: 14,
    //                   letterSpacing:
    //                       0 /*percentages not used in flutter. defaulting to zero*/,
    //                   fontWeight: FontWeight.normal,
    //                   height: 1,
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }
}
