import 'package:flutter/material.dart';

class ReportDetailPage extends StatelessWidget {
  final String imageUrl;
  final String status;
  final String severity;
  final String description;

  ReportDetailPage({
    required this.imageUrl,
    required this.status,
    required this.severity,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Report Details'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // Go back on tap
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0), // Add padding around the Scaffold body
        child: SingleChildScrollView(
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0), // Add rounded corners to the image
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover, // Use BoxFit.cover to ensure the image covers the box, might crop
                  width: double.infinity, // Take the full width of the screen
                  height: 300, // Increase the height to better accommodate vertical images
                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) return child; // Return the image if it's fully loaded
                    return SizedBox(
                      width: double.infinity,
                      height: 300,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                    // Display an error widget if the image fails to load
                    return SizedBox(
                      width: double.infinity,
                      height: 300,
                      child: Center(
                        child: Text('Image not available'),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16), // Add some space between the image and the first ListTile
              ListTile(
                title: Text(
                  'Status',
                  style: TextStyle(fontWeight: FontWeight.bold), // Make title text bold
                ),
                subtitle: Text(status),
              ),
              ListTile(
                title: Text(
                  'Severity',
                  style: TextStyle(fontWeight: FontWeight.bold), // Make title text bold
                ),
                subtitle: Text(severity),
              ),
              ListTile(
                title: Text(
                  'Description',
                  style: TextStyle(fontWeight: FontWeight.bold), // Make title text bold
                ),
                subtitle: Text(description),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
