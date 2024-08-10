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

  Future<void> _showCompletionAlert(BuildContext context) async {
    final l10n = L10n.of(context);

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.uploadComplete),
          content: Text(l10n.uploadCompleteMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(l10n.ok),
            ),
          ],
        );
      },
    );

    setState(() {
      _imageFiles = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return ChangeNotifierProvider(
      create: (_) => UploadViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.uploadImages),
        ),
        body: Consumer<UploadViewModel>(
          builder: (context, viewModel, child) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    l10n.uploadInstructions,
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF222222),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.tipsForCreatingGreatRadio,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          l10n.exampleTips,
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    l10n.privacyNotice,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  SizedBox(height: 20),
                  if (_imageFiles.isNotEmpty)
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: viewModel.isUploading ? null : _pickImages,
                    child: Text(
                      _imageFiles.isEmpty
                          ? l10n.pickImages
                          : l10n.pickImagesAgain,
                    ),
                  ),
                  SizedBox(height: 10),
                  if (_imageFiles.isNotEmpty)
                    ElevatedButton(
                      onPressed: viewModel.isUploading
                          ? null
                          : () async {
                              if (_imageFiles.isNotEmpty) {
                                try {
                                  await viewModel.uploadFiles(
                                      _imageFiles, l10n.localeName);
                                  _showCompletionAlert(context);
                                } catch (e) {
                                  print("Upload failed: $e");
                                }
                              }
                            },
                      child: Text(l10n.upload),
                    ),
                  if (viewModel.isUploading) ...[
                    SizedBox(height: 20),
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text(l10n.doNotCloseApp),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
