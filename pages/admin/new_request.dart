import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:roadcare/pages/admin/update_report.dart';
import 'package:roadcare/pages/user/delete_report_page.dart';
import 'package:url_launcher/url_launcher.dart';

class NewRequest extends StatefulWidget {
  const NewRequest({super.key});

  @override
  State<NewRequest> createState() => _NewRequestState();
}

class _NewRequestState extends State<NewRequest> {
  
  Widget newReport(DocumentSnapshot ds) {
    String googleMapsUrl = "https://www.google.com/maps?q=${ds['latitude']},${ds['longitude']}";

    Future<void> _launchURL(String urlString) async {
      final Uri url = Uri.parse(urlString);
      if (!await launchUrl(url)) {
        throw 'Could not launch $urlString';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(10),
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
                )
              : Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 50), // Placeholder for an image
                ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column( // Text Column
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Severity: ${ds['severity']}",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  )
                ),

                const SizedBox(height: 10),

                GestureDetector(
                  onTap: () => _launchURL(googleMapsUrl),
                  child: const Text(
                    "Location",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "Status: ${ds['status']}",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
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
                      builder: (context) => UpdateReport(report: ds),
                    ),
                  );
                },
                child: Icon(Icons.edit, color: Colors.orange),
              ),

              const SizedBox(height: 20),

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
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('reports')
              .where('status', isEqualTo: 'Pending')
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              return Column(
                children: snapshot.data!.docs.map((ds) => newReport(ds)).toList(),
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}