import 'dart:io';
import 'package:flutter/material.dart';
import '../services/upload_service.dart';

class UploadViewModel extends ChangeNotifier {
  final UploadService _uploadService = UploadService();
  bool _isUploading = false;

  bool get isUploading => _isUploading;

  Future<void> uploadFile(File file) async {
    _isUploading = true;
    notifyListeners();

    try {
      String downloadUrl = await _uploadService.uploadFile(file);
      await _uploadService.saveUploadData(downloadUrl);
    } catch (e) {
      print(e);
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }
}