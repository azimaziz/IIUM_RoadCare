import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class UpdateReport extends StatefulWidget {
  final DocumentSnapshot report;

  const UpdateReport({Key? key, required this.report}) : super(key: key);

  @override
  _UpdateReportState createState() => _UpdateReportState();
}

class _UpdateReportState extends State<UpdateReport> {
  String? _selectedStatus;
  bool _isUpdating = false;
  File? _image;

  pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateStatus() async {
    setState(() {
      _isUpdating = true;
    });

    try {
      // If a new image is selected, upload it to storage and get the download URL
      String? imageUrl;
      if (_image != null) {
        String fileName =
            'reports/${DateTime.now().millisecondsSinceEpoch}_${_image!.path.split('/').last}';
        firebase_storage.Reference ref =
            firebase_storage.FirebaseStorage.instance.ref().child(fileName);
        firebase_storage.UploadTask uploadTask = ref.putFile(_image!);
        imageUrl = await (await uploadTask).ref.getDownloadURL();
      }

      // Update the status and image URL in Firestore
      await FirebaseFirestore.instance
          .collection('reports')
          .doc(widget.report.id)
          .update({
        'status': _selectedStatus,
        'imageUrl': imageUrl,
      });
      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Status updated successfully.'),
          backgroundColor: Colors.green,
        ),
      );

      // Add a delay before navigating back to the previous screen
      await Future.delayed(const Duration(seconds: 2));

      // Navigate back to the previous screen
      Navigator.pop(context);
    } catch (error) {
      // Show an error message if updating fails
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update status. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  void _showUpdateConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Report'),
          content: const Text('Are you sure you want to update this report?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Update'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _updateStatus();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Update Report'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (_isUpdating) const LinearProgressIndicator(),
              SizedBox(height: _isUpdating ? 8.0 : 0),
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: _image != null
                    ? Image.file(
                        _image!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 300,
                      )
                    : Image.network(
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
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (BuildContext context, Object exception,
                            StackTrace? stackTrace) {
                          return const SizedBox(
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
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    icon: const CircleAvatar(
                      radius: 25.0,
                      child: Icon(Icons.photo_camera,
                          color: Colors.white, size: 30.0),
                      backgroundColor: Colors.blue,
                    ),
                    onPressed: () {
                      pickImage(ImageSource.camera);
                    },
                  ),
                  IconButton(
                    icon: const CircleAvatar(
                      radius: 25.0,
                      child: Icon(Icons.photo_library,
                          color: Colors.white, size: 30.0),
                      backgroundColor: Colors.blue,
                    ),
                    onPressed: () {
                      pickImage(ImageSource.gallery);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Location',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                    '${widget.report['latitude']}, ${widget.report['longitude']}'),
              ),
              ListTile(
                title: const Text('Severity',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(widget.report['severity']),
              ),
              ListTile(
                title: const Text('Description',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(widget.report['description']),
              ),
              ListTile(
                title: const Text('Status',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: DropdownButtonFormField<String>(
                  value: _selectedStatus ?? widget.report['status'],
                  items: ['Pending', 'Fixed'].map((status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed:
                    _isUpdating ? null : () => _showUpdateConfirmation(context),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                  fixedSize: Size(MediaQuery.of(context).size.width, 50),
                ),
                child: _isUpdating
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 3),
                      )
                    : const Text('Update Report'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
