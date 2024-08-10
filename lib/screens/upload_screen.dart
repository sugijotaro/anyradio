import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
  List<File> _imageFiles = [];
  final picker = ImagePicker();

  Future<void> _pickImages() async {
    final pickedFiles = await picker.pickMultiImage();

    setState(() {
      if (pickedFiles != null) {
        _imageFiles =
            pickedFiles.map((pickedFile) => File(pickedFile.path)).toList();
      } else {
        print('No images selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return ChangeNotifierProvider(
      create: (_) => UploadViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.uploadImagesVideos),
        ),
        body: Consumer<UploadViewModel>(
          builder: (context, viewModel, child) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _imageFiles.isEmpty
                      ? Text(l10n.noImagesSelected)
                      : Expanded(
                          child: GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 4.0,
                              mainAxisSpacing: 4.0,
                            ),
                            itemCount: _imageFiles.length,
                            itemBuilder: (context, index) {
                              return Image.file(_imageFiles[index],
                                  fit: BoxFit.cover);
                            },
                          ),
                        ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _pickImages,
                    child: Text(
                      _imageFiles.isEmpty
                          ? l10n.pickImages
                          : l10n.pickImagesAgain,
                    ),
                  ),
                  SizedBox(height: 20),
                  if (_imageFiles.isNotEmpty)
                    viewModel.isUploading
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () {
                              if (_imageFiles.isNotEmpty) {
                                viewModel.uploadFiles(
                                    _imageFiles, l10n.localeName);
                              }
                            },
                            child: Text(l10n.upload),
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
