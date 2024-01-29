import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:roadcare/pages/view_status_report.dart';

class DeleteReportPage extends StatefulWidget {
  final DocumentSnapshot report;

  const DeleteReportPage({Key? key, required this.report}) : super(key: key);

  @override
  _DeleteReportPageState createState() => _DeleteReportPageState();
}

class _DeleteReportPageState extends State<DeleteReportPage> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Delete Report'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (_isDeleting) LinearProgressIndicator(),
              SizedBox(height: _isDeleting ? 8.0 : 0),
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.network(
                  widget.report['imageUrl'],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 300,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) return child;
                    return SizedBox(
                      width: double.infinity,
                      height: 300,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (BuildContext context, Object exception,
                      StackTrace? stackTrace) {
                    return SizedBox(
                      width: double.infinity,
                      height: 300,
                      child: Center(
                        child: Text('Image not available',
                            style: TextStyle(color: Colors.grey)),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text('Location',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                    '${widget.report['latitude']}, ${widget.report['longitude']}'),
              ),
              ListTile(
                title: Text('Severity',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(widget.report['severity']),
              ),
              ListTile(
                title: Text('Status',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(widget.report['status']),
              ),
              ListTile(
                title: Text('Description',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(widget.report['description']),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed:
                    _isDeleting ? null : () => _showDeleteConfirmation(context),
                child: _isDeleting
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 3),
                      )
                    : Text('Delete Report'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                  onPrimary: Colors.white,
                  fixedSize: Size(MediaQuery.of(context).size.width, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Report'),
          content: Text('Are you sure you want to delete this report?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _deleteReport();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteReport() {
    setState(() {
      _isDeleting = true;
    });

    FirebaseStorage storage = FirebaseStorage.instance;
    String decodedUrl = Uri.decodeFull(widget
        .report['imageUrl']); // Use widget.report to access the report object
    Uri fileUri = Uri.parse(decodedUrl);
    String filePath = fileUri.pathSegments.last;

    Reference storageRef = storage.ref().child("reports/$filePath");

    storageRef.delete().then((_) {
      FirebaseFirestore.instance
          .collection('reports')
          .doc(widget.report.id)
          .delete()
          .then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Report deleted successfully")));

        Future.delayed(Duration(seconds: 0), () {
          if (Navigator.canPop(context)) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else {
            // Assuming ViewStatus() is a valid page in your app to navigate to after deletion
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => ViewStatus()));
          }
        });
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error deleting report: $error")));
      }).whenComplete(() => setState(() => _isDeleting = false));
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error deleting image: $error")));
      setState(() => _isDeleting = false);
    });
  }
}
