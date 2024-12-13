import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _trackingController = TextEditingController();
  List<dynamic> milestones = [];
  bool isLoading = false;
  String? errorMessage;
  String? enteredTrackingNumber;

  Future<void> fetchTrackingData(String trackingNumber) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      milestones = [];
    });

    final String apiUrl =
        'https://api.xhipment.com/api/v1/utils/publictracking?track=$trackingNumber';
    try {
      final response = await http.get(Uri.parse(apiUrl));
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

  String formatDate(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return 'Date not available';
    try {
      final parsedDate = DateTime.parse(dateTime);
      return DateFormat('MMMM d, yyyy HH:mm').format(parsedDate);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  bool isMilestoneCompleted(String? dateTime) {
    return dateTime != null && dateTime.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5), // Light background color
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Logo
              Center(
                child: Image.asset(
                  'assets/header_image.png', // Replace with your header_image asset
                  height: 50,
                ),
              ),
              SizedBox(height: 20),
              // Input Section and Tracking Number
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter your tracking number:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF8E5D), // Updated to #FF8E5D
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _trackingController,
                      decoration: InputDecoration(
                        hintText: 'e.g., XQFCL12345678',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20), // Gap between input and button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus(); // Dismiss the keyboard
                        final trackingNumber = _trackingController.text.trim();
                        if (trackingNumber.isNotEmpty) {
                          setState(() {
                            enteredTrackingNumber = trackingNumber;
                          });
                          fetchTrackingData(trackingNumber);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Please enter a valid tracking number'),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFF4E00), // Orange button color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14.0),
                      ),
                      child: Text(
                        'Track',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  if (enteredTrackingNumber != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),
                        Text(
                          'Tracking ID: $enteredTrackingNumber',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF4E00), // Orange color
                          ),
                        ),
                        Divider(color: Colors.grey[400]),
                      ],
                    ),
                ],
              ),
              SizedBox(height: 20),
              // Milestones Section
              Expanded(
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
                                  '',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: milestones.length,
                                itemBuilder: (context, index) {
                                  final milestone = milestones[index];
                                  final isCompleted =
                                      isMilestoneCompleted(
                                          milestone['dateTime']);
                                  final formattedDate =
                                      formatDate(milestone['dateTime']);
                                  final showDottedLine = index <
                                      milestones.length -
                                          1; // Draw line between milestones
                                  return Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        children: [
                                          // Adjust circle position
                                          SizedBox(height: 4), // Lower the circle
                                          Icon(
                                            Icons.circle,
                                            size: 12,
                                            color: isCompleted
                                                ? Colors.green
                                                : Colors.grey,
                                          ),
                                          if (showDottedLine)
                                            CustomPaint(
                                              size: Size(2, 60), // Adjusted height
                                              painter: DottedLinePainter(
                                                color: isCompleted
                                                    ? Colors.green
                                                    : Colors.grey,
                                              ),
                                            ),
                                        ],
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              milestone['value'] ??
                                                  'No description',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: isCompleted
                                                    ? Colors.green
                                                    : Colors.black87,
                                                fontWeight: isCompleted
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              formattedDate,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Painter for Dotted Line
class DottedLinePainter extends CustomPainter {
  final Color color;

  DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final double dashHeight = 4;
    final double gap = 3;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        paint,
      );
      startY += dashHeight + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
