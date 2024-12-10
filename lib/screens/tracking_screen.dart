import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TrackingScreen extends StatefulWidget {
  final String trackingNumber;

  TrackingScreen({required this.trackingNumber});

  @override
  _TrackingScreenState createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  List<dynamic> milestones = [];
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchTrackingData();
  }

  Future<void> fetchTrackingData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final String apiUrl =
        'https://test-api.xhipment.com/v1/utils/publictracking?track=${widget.trackingNumber}';
    final String username = 'xhipment';
    final String password = 'Xhipment@123';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$username:$password'))}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          milestones = data['result']['milestones'] ?? [];
        });
      } else {
        setState(() {
          errorMessage =
          'Failed to fetch tracking data. HTTP Status: ${response.statusCode}';
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = 'Error fetching data: $error';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tracking Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : errorMessage != null
            ? Center(
          child: Text(
            errorMessage!,
            style: TextStyle(color: Colors.red, fontSize: 16),
          ),
        )
            : milestones.isEmpty
            ? Center(
          child: Text(
            'No milestones found.',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        )
            : ListView.builder(
          itemCount: milestones.length,
          itemBuilder: (context, index) {
            final milestone = milestones[index];
            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: Icon(
                  Icons.check_circle,
                  color: milestone['dateTime'] != null
                      ? Colors.green
                      : Colors.grey,
                ),
                title: Text(
                  milestone['value'] ?? 'Unknown milestone',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  milestone['dateTime'] ?? 'Pending',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
