import 'dart:io';
import 'package:flutter/material.dart';
import '../services/upload_service.dart';
import 'package:uuid/uuid.dart';

class UploadViewModel extends ChangeNotifier {
  final UploadService _uploadService = UploadService();
  bool _isUploading = false;

  bool get isUploading => _isUploading;

  Future<void> uploadFiles(List<File> files) async {
    _isUploading = true;
    notifyListeners();

    try {
      await _uploadService.uploadFiles(files);
    } catch (e) {
      print(e);
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }
}