import 'package:flutter/material.dart';
import '../services/tracking_service.dart';

class TrackingProvider extends ChangeNotifier {
  final TrackingService _trackingService = TrackingService();

  List<dynamic> milestones = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchTrackingData(String trackingNumber) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      milestones = await _trackingService.getTrackingData(trackingNumber);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
