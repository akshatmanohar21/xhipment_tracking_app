import 'package:flutter/material.dart';
import 'tracking_screen.dart';

class HomeScreen extends StatelessWidget {
  final TextEditingController _trackingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Xhipment Tracking App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter Your Quote ID:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _trackingController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'e.g., XQFCL12345678',
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  final trackingNumber = _trackingController.text.trim();
                  if (trackingNumber.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TrackingScreen(trackingNumber: trackingNumber),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please enter a valid Quote ID')),
                    );
                  }
                },
                child: Text('Track Shipment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
