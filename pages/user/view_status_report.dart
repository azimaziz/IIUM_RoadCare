import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:roadcare/pages/user/delete_report_page.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewStatus extends StatelessWidget {
  const ViewStatus({super.key});

  Widget reportItem(DocumentSnapshot ds, BuildContext context) {
  String googleMapsUrl = "https://www.google.com/maps?q=${ds['latitude']},${ds['longitude']}";

    Future<void> _launchURL(String urlString) async {
      final Uri url = Uri.parse(urlString);
      if (!await launchUrl(url)) {
        throw 'Could not launch $urlString';
      }
    }

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row( // Main Row
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: ds['imageUrl'] != null
              ? Image.network(
                  ds['imageUrl'],
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) return child; // Image is fully loaded, return it
                    return SizedBox(
                      width: 80,
                      height: 80,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null, // Show the loading progress
                        ),
                      ),
                    );
                  },
                  errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                    // If the image fails to load, show an error icon
                    return Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[300],
                      child: Icon(Icons.error, size: 50),
                    );
                  },
                )
              : Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[300],
                  child: Icon(Icons.image, size: 50), // Placeholder for an image
                ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column( // Text Column
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Severity: ${ds['severity']}",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  )
                ),
                GestureDetector(
                  onTap: () => _launchURL(googleMapsUrl),
                  child: Text(
                    "See Location",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                Text(
                  "Status: ${ds['status']}",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  )
                ),
              ],
            ),
          ),
          Column( // Icons Column
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DeleteReportPage(report: ds),
                    ),
                  );
                },
                child: Icon(Icons.delete, color: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    String? userUID = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("My Report Status"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('reports')
              .where('userUID', isEqualTo: userUID)
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              return Column(
                children: snapshot.data!.docs.map((ds) => reportItem(ds, context)).toList(),
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
