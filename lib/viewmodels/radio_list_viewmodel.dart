import 'package:flutter/material.dart';
import '../models/radio.dart' as custom_radio;
import '../services/radio_service.dart';

class RadioListViewModel extends ChangeNotifier {
  final RadioService _radioService = RadioService();
  List<custom_radio.Radio> radios = [];

  RadioListViewModel() {
    _fetchRadios();
  }

  void _fetchRadios() {
    _radioService.getRadios().listen((radios) {
      this.radios = radios;
      notifyListeners();
    });
  }
}
