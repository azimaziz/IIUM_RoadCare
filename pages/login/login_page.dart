import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:roadcare/components/my_button.dart';
import 'package:roadcare/components/my_textfield.dart';
import 'package:roadcare/components/square_tile.dart';
import 'package:roadcare/services/auth_service.dart';

class loginPage extends StatefulWidget {
  final Function()? onTap;
  loginPage({super.key, required this.onTap});

  @override
  State<loginPage> createState() => _loginPageState();
}

class _loginPageState extends State<loginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isGoogleSignInLoading = false;

  // Function to validate email format
  bool isValidEmail(String email) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(email);
  }

  // Function to validate the form
  bool validateForm() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showSnackBar('Please fill in all fields');
      return false;
    } else if (!isValidEmail(email)) {
      showSnackBar('Please enter a valid email');
      return false;
    }
    return true;
  }

  // Function to show a snackbar
  void showSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Sign in function with validation
  void signUserIn() async {
    if (validateForm()) {
      // Show "Signing in..." snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Signing in...'),
          duration: const Duration(seconds: 2),
        ),
      );

      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        // Dismiss the "Signing in..." snackbar
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        // Show "Sign in successful" snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign in successful'),
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate to another page or show a success message here
      } on FirebaseAuthException catch (e) {
        // Dismiss the "Signing in..." snackbar before showing the error message
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        String errorMessage = 'An error occurred. Please try again later.';
        if (e.code == 'user-not-found' || e.code == 'wrong-password') {
          errorMessage = 'Incorrect email or password.';
        }

        // Show error message snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }


  // Google Sign-in function with loading state
  void handleGoogleSignIn() async {
    setState(() {
      isGoogleSignInLoading = true; // Start loading
    });

    try {
      await AuthService().googleSignIn();
      setState(() {
        isGoogleSignInLoading = false; // Stop loading on success
      });
    } catch (error) {
      setState(() {
        isGoogleSignInLoading = false; // Stop loading on error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 150,
                  height: 150,
                  child: Image.asset('lib/images/IIUMRoadCareLogo.png'),
                ),

                const SizedBox(height: 25),

                const Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 25),

                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),

                const SizedBox(height: 10),

                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 25.0),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.end,
                //     children: [
                //       Text(
                //         'Forgot Password?',
                //         style: TextStyle(
                //           color: Colors.grey[600],
                //         ),
                //       ),
                //     ],
                //   ),
                // ),

                const SizedBox(height: 25),

                MyButton(
                  text: "Login",
                  onTap: signUserIn,
                ),

                const SizedBox(height: 25),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.grey[400],
                          thickness: 0.5,
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Or',
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
                        ),
                      ),

                      Expanded(
                        child: Divider(
                          color: Colors.grey[400],
                          thickness: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                SquareTile(
                  onTap: isGoogleSignInLoading ? null : handleGoogleSignIn,
                  imagePath: 'lib/images/GoogleLoginIcon.png',
                  isLoading: isGoogleSignInLoading,
                ),

                const SizedBox(height: 50),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t have an account?',
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        'Sign up',
                        style: TextStyle(
                          color: Colors.blue,
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
