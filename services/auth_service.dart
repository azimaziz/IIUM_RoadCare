import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService{

    googleSignIn() async {
      try {
        UserCredential userCredential = await signInWithGoogle();
        User? user = userCredential.user;

        if (user != null) {
          bool userDataExists = await checkUserDataInFirestore(user.uid);

          if (!userDataExists) {
            await saveUserEmailToFirestore(user);
          }
        }
      } catch (error) {
        print('Error signing in with Google: $error');
      }
    }

    Future<UserCredential> signInWithGoogle() async {
      final GoogleSignInAccount? googleSignInAccount =
          await GoogleSignIn().signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        return FirebaseAuth.instance.signInWithCredential(credential);
      } else {
        throw Exception('Google Sign In canceled');
      }
    }

    Future<bool> checkUserDataInFirestore(String uid) async {
      try {
        // Reference to the Firestore collection where user data is stored
        final CollectionReference usersCollection =
            FirebaseFirestore.instance.collection('users');

        // Check if the document with the given UID exists
        DocumentSnapshot documentSnapshot = await usersCollection.doc(uid).get();
        return documentSnapshot.exists;
      } catch (error) {
        print('Error checking user data in Firestore: $error');
        return false;
      }
    }

    Future<void> saveUserEmailToFirestore(User user) async {
      try {
        // Reference to the Firestore collection where user data is stored
        final CollectionReference usersCollection =
            FirebaseFirestore.instance.collection('users');

        // Save user email to Firestore with user ID as document ID
        await usersCollection.doc(user.uid).set({
          'email': user.email,
          'role': 'user',
          // Add any additional fields you want to save
        });
      } catch (error) {
        print('Error saving user email to Firestore: $error');
      }
    }
}