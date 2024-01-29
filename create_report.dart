import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:roadcare/components/navigation_menu.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:roadcare/pages/user/set_location.dart';

class CreateReport extends StatefulWidget {
  @override
  _CreateReportState createState() => _CreateReportState();
}

class _CreateReportState extends State<CreateReport> {
  Location location = new Location();
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  File? _image;
  String? _selectedSeverity;
  double? _selectedLatitude;
  double? _selectedLongitude;
  double _uploadProgress = 0.0; // Track upload progress
  String? userUID = FirebaseAuth.instance.currentUser?.uid;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isSubmitting = false; // Added for progress indicator

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> submitReport() async {
  if (_image == null) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text('Please select an image for the report.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
    return;
  }

  setState(() {
    _isSubmitting = true; // Indicate that submission has started
    _uploadProgress = 0.1; // Initial progress after validation
  });

  try {
    // Image Upload Stage
    String fileName = 'reports/${DateTime.now().millisecondsSinceEpoch}_${_image!.path.split('/').last}';
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref().child(fileName);
    firebase_storage.UploadTask uploadTask = ref.putFile(_image!);

    // Listen to upload progress
    uploadTask.snapshotEvents.listen((firebase_storage.TaskSnapshot snapshot) {
      setState(() {
        // Calculate the upload stage progress (0.1 to 0.6 range)
        _uploadProgress = 0.1 + (snapshot.bytesTransferred.toDouble() / snapshot.totalBytes.toDouble()) * 0.5;
      });
    });

    // Wait for the upload to complete
    await uploadTask;

    // Get the image URL
    final imageUrl = await ref.getDownloadURL();

    // Firestore Document Add Stage
    await FirebaseFirestore.instance.collection('reports').add({
      'imageUrl': imageUrl,
      'latitude': _selectedLatitude,
      'longitude': _selectedLongitude,
      'severity': _selectedSeverity,
      'description': _descriptionController.text,
      'status': 'Pending', 
      'userUID': userUID,   
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Update progress to indicate Firestore update is complete
    setState(() {
      _uploadProgress = 0.9; // Almost complete, leaving some space for finalization
    });

    // Show success dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Success'),
        content: Text('Report has been submitted successfully.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MainLayout()),
                (Route<dynamic> route) => false,
              );
            },
            child: Text('OK'),
          ),
        ],
      ),
    );

  } catch (e) {
    // Handle errors, e.g., show an error dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text('Failed to submit report. Please try again later.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  } finally {
    // Finalization stage
    setState(() {
      _isSubmitting = false; // Stop the submission process
      _uploadProgress = 1.0; // Mark completion before hiding the indicator
    });

    // Optionally, add a delay to show the completed progress indicator before hiding it
    await Future.delayed(Duration(milliseconds: 500));

    setState(() {
      _uploadProgress = 0.0; // Reset progress
    });
  }
}


@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Report Pothole"),
        centerTitle: true,
      ),
      body: Column( // Wrap your main content in a Column
        children: [
          if (_isSubmitting) // Show the progress indicator only when submitting
            LinearProgressIndicator(
              value: _uploadProgress, // Bind the progress indicator to the _uploadProgress variable
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue), // Set the progress bar color to green
            ),
          Expanded( // Wrap the SingleChildScrollView with Expanded
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                       Container(
                          margin: EdgeInsets.all(20),
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: _image != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    _image!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Center(child: Text('No Image Selected', style: TextStyle(color: Colors.grey[500]))),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            IconButton(
                              icon: CircleAvatar(
                                radius: 25.0,
                                child: Icon(Icons.photo_camera, color: Colors.white, size: 30.0),
                                backgroundColor: Colors.blue,
                              ),
                              onPressed: () {
                                pickImage(ImageSource.camera);
                              },
                            ),
                            IconButton(
                              icon: CircleAvatar(
                                radius: 25.0,
                                child: Icon(Icons.photo_library, color: Colors.white, size: 30.0),
                                backgroundColor: Colors.blue,
                              ),
                              onPressed: () {
                                pickImage(ImageSource.gallery);
                              },
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: MaterialButton(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => setLocation()),
                              );

                              if (result != null) {
                                setState(() {
                                  _selectedLatitude = result['latitude'];
                                  _selectedLongitude = result['longitude'];
                                });
                              }
                            },
                            color: Colors.blue,
                            textColor: Colors.white,
                            padding: EdgeInsets.all(15.0),
                            minWidth: double.infinity,
                            child: Text(
                              _selectedLatitude != null && _selectedLongitude != null
                                  ? 'Location: $_selectedLatitude, $_selectedLongitude'
                                  : 'Set Location',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Select Severity',
                              border: OutlineInputBorder(),
                            ),
                            value: _selectedSeverity,
                            items: ['Low', 'Medium', 'High'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _selectedSeverity = newValue;
                              });
                            },
                            validator: (value) => value == null ? 'Please select severity' : null,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: _descriptionController,
                            decoration: InputDecoration(
                              labelText: 'Description',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a description';
                              }
                              return null;
                            },
                          ),
                        ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : () {
                            if (_formKey.currentState!.validate()) {
                              submitReport();
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.blue),
                            foregroundColor: MaterialStateProperty.all(Colors.white),
                            padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 16.0)),
                            minimumSize: MaterialStateProperty.all(Size(150, 48)),
                          ),
                          child: _isSubmitting
                              ? SizedBox(
                                  width: 24.0,
                                  height: 24.0,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3.0,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text('Submit Report'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}