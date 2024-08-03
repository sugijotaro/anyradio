import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../viewmodels/upload_viewmodel.dart';

class UploadScreen extends StatefulWidget {
  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _imageFile;
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UploadViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Upload Image/Video'),
        ),
        body: Consumer<UploadViewModel>(
          builder: (context, viewModel, child) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _imageFile == null
                      ? Text('No image selected.')
                      : Image.file(_imageFile!),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: Text('Pick Image'),
                  ),
                  SizedBox(height: 20),
                  viewModel.isUploading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () {
                            if (_imageFile != null) {
                              viewModel.uploadFile(_imageFile!);
                            }
                          },
                          child: Text('Upload'),
                        ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}