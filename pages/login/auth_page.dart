import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:roadcare/components/admin_dashboard.dart';
import 'package:roadcare/components/navigation_menu.dart';
import 'package:roadcare/pages/login/login_or_register_page.dart';


class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // User is logged in, let's get their role from Firestore
            return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: FirebaseFirestore.instance.collection('users').doc(snapshot.data!.uid).get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  // Loading state while fetching user data
                  return Center(
                    child: const CircularProgressIndicator()
                  ); // You can replace this with your loading widget
                } else if (userSnapshot.hasError) {
                  // Error handling
                  return Text('Error fetching user data: ${userSnapshot.error}');
                } else if (!userSnapshot.hasData || userSnapshot.data == null) {
                  // User document not found or empty
                  return const Text('User document not found or empty');
                } else {
                  // User data is available
                  Map<String, dynamic> userData = userSnapshot.data!.data()!;
                  String userRole = userData['role'] ?? 'user'; // Replace 'default' with your default role
                  
                  // Now you have the user's role, you can use it as needed
                  if (userRole == 'admin') {
                    // User is an admin, you can navigate to the admin page
                    return AdminDashboard();
                  } else {
                    // User is not an admin, you can navigate to a regular user page
                    return const MainLayout();
                  }
                }
              },
            );
          } else {
            // User is NOT logged in
            return const loginOrRegisterPage();
          }
        },
      ),
    );
  }
}