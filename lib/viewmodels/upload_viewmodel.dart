import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../services/upload_service.dart';
import 'auth_viewmodel.dart';

class UploadViewModel extends ChangeNotifier {
  final UploadService _uploadService = UploadService();
  bool _isUploading = false;

  bool get isUploading => _isUploading;

  Future<void> uploadFiles(List<File> files, String language) async {
    _isUploading = true;
    notifyListeners();

    final completer = Completer<void>();

    try {
      final userId = AuthViewModel().currentUser?.id;
      if (userId != null) {
        await _uploadService.uploadFiles(files, userId, language);
        completer.complete();
      } else {
        print('Error: User ID is null');
        completer.completeError('User ID is null');
      }
    } catch (e) {
      print(e);
      completer.completeError(e);
    } finally {
      _isUploading = false;
      notifyListeners();
    }

    return completer.future;
  }
}
