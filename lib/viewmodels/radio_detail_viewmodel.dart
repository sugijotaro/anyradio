import 'package:flutter/material.dart';
import '../models/radio.dart' as custom_radio;
import '../services/radio_service.dart';

class RadioDetailViewModel extends ChangeNotifier {
  final RadioService _radioService = RadioService();
  custom_radio.Radio? radio;

  Future<void> fetchRadioById(String id) async {
    radio = await _radioService.getRadioById(id);
    notifyListeners();
  }
}
