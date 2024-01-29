import 'package:flutter/material.dart';

class SquareTile extends StatelessWidget {
  final String imagePath;
  final Function()? onTap;
  final bool isLoading;

  const SquareTile({
    super.key,
    required this.imagePath,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: isLoading
            ? SizedBox(
                width: 150, // Specify the width
                height: 40, // Specify the height
                child: Center(
                  child: CircularProgressIndicator(), // Center the CircularProgressIndicator
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Image.asset(
                    imagePath,
                    height: 40,
                  ),
                  const SizedBox(width: 10),
                  const Text("Connect with Google"),
                ],
              ),
      ),
    );
  }
}
