import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:roadcare/components/my_button.dart';
import 'package:roadcare/components/my_textfield.dart';
import 'package:roadcare/components/square_tile.dart';
import 'package:roadcare/services/auth_service.dart';


class registerPage extends StatefulWidget {
  final Function()? onTap;
  registerPage({super.key, required this.onTap});

  @override
  State<registerPage> createState() => _registerPageState();
}

class _registerPageState extends State<registerPage> {
  //text editing controller
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Sign Up function
  void signUserUp() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Signing Up...'),
        duration: const Duration(seconds: 2),
      ),
    );

    try {
      if (passwordController.text == confirmPasswordController.text) {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'email': emailController.text,
          'role': 'user'
        });
        // Dismiss the "Signing Up..." snackbar
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        // You might want to navigate to a different page or show a success message here
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Passwords do not match'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Dismiss the "Signing Up..." snackbar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      
      String errorMessage = 'An error occurred. Please try again later.'; // Default error message

      if (e.code == 'weak-password') {
        errorMessage = 'The given password is invalid. Password should be at least 6 characters';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: const Duration(seconds: 2),
        ),
      );
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
              children:[
            
                const SizedBox(height: 25),
            
                //sign in text
                Column(
                  children: [
                    const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Create your account',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
            
                const SizedBox(height: 25),
            
                //email textfield
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),
            
                const SizedBox(height: 10),
            
                //password textfield
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),
            
                const SizedBox(height: 10),

                //confirm password textfield
                MyTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ),
            
            
                const SizedBox(height: 25),
            
                //sign up button
                MyButton(
                  text: "Sign Up",
                  onTap: signUserUp,
                ),
            
                const SizedBox(height: 25),
            
                //or continue with text
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
            
                //google sign in button
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SquareTile(
                      onTap: () => AuthService().signInWithGoogle(),
                      imagePath: 'lib/images/GoogleLoginIcon.png'
                    ),
                  ],
                ),
            
                const SizedBox(height: 50),
            
                //Don't have an account? Sign up
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        'Login Now',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
            ]),
          ),
        ),
      ),
    );
  }
}