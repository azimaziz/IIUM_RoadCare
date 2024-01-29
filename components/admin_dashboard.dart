import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:roadcare/pages/admin/completed_req.dart';
import 'package:roadcare/pages/admin/new_request.dart';
import 'package:roadcare/pages/login/auth_page.dart';


class AdminDashboard extends StatelessWidget {
  AdminDashboard({Key? key}) : super(key: key);

  final user = FirebaseAuth.instance.currentUser!;

  void signUserOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    
    // Navigate to the login screen and remove all routes from the stack
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => AuthPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: SizedBox(
              width: 70, 
              height: 70,
              child: Image.asset('lib/images/IIUMRoadCareLogo.png'), // Use your image as the title
            ),
            centerTitle: true, // This will center the title widget
            actions: [
              IconButton(
                onPressed: () => signUserOut(context), // Pass the context here
                icon: const Icon(Icons.logout),
              ),
            ],
            bottom: const TabBar(
              tabs: [
                Tab(text: 'New Request'),
                Tab(text: 'Updated'),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              NewRequest(),  // Replace Center(child: Text('New Request')) with your NewRequest widget
              CompletedRequest(),
            ],
          ),
        ),
      ),
    );
  }
}