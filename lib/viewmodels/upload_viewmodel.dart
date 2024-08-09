import 'dart:io';
import 'package:flutter/material.dart';
import '../services/upload_service.dart';
import 'auth_viewmodel.dart';

class UploadViewModel extends ChangeNotifier {
  final UploadService _uploadService = UploadService();
  bool _isUploading = false;

  bool get isUploading => _isUploading;

  Future<void> uploadFiles(List<File> files) async {
    _isUploading = true;
    notifyListeners();

    try {
      final userId = AuthViewModel().currentUser?.id;
      if (userId != null) {
        await _uploadService.uploadFiles(files, userId);
      } else {
        print('Error: User ID is null');
      }
    } catch (e) {
      print(e);
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }
}
