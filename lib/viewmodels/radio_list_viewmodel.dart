import 'package:flutter/material.dart';
import '../models/radio.dart' as custom_radio;
import '../services/radio_service.dart';

class RadioListViewModel extends ChangeNotifier {
  final RadioService _radioService = RadioService();
  List<custom_radio.Radio> radios = [];

  RadioListViewModel() {
    fetchRadios();
  }

  Future<void> fetchRadios() async {
    final radiosStream = _radioService.getRadios();
    radiosStream.listen((radiosData) {
      radios = radiosData;
      notifyListeners();
    });
  }
}
