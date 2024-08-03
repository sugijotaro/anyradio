import 'dart:io';
import 'package:flutter/material.dart';
import '../services/upload_service.dart';

class UploadViewModel extends ChangeNotifier {
  final UploadService _uploadService = UploadService();
  bool _isUploading = false;

  bool get isUploading => _isUploading;

  Future<void> uploadFiles(List<File> files) async {
    _isUploading = true;
    notifyListeners();

    try {
      List<String> downloadUrls = [];
      for (var file in files) {
        String downloadUrl = await _uploadService.uploadFile(file);
        downloadUrls.add(downloadUrl);
      }
      await _uploadService.saveUploadData(downloadUrls);
    } catch (e) {
      print(e);
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }
}