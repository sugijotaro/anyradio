import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import '../viewmodels/radio_detail_viewmodel.dart';

class RadioDetailScreen extends StatelessWidget {
  final String radioId;

  RadioDetailScreen({required this.radioId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RadioDetailViewModel()..fetchRadioById(radioId),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Radio Detail'),
        ),
        body: Consumer<RadioDetailViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.radio == null) {
              return Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 画像リストを表示
                  SizedBox(
                    height: 200, // 必要に応じて高さを調整
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: viewModel.radio!.imageUrls.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child:
                              Image.network(viewModel.radio!.imageUrls[index]),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(viewModel.radio!.title,
                        style: TextStyle(fontSize: 24)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(viewModel.radio!.description),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () => _togglePlayPause(
                            viewModel.radio!.audioUrl, context),
                        child: Text('Play'),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _togglePlayPause(String audioUrl, BuildContext context) {
    final AudioPlayer _audioPlayer = AudioPlayer();
    bool _isPlaying = false;

    _audioPlayer.playerStateStream.listen((playerState) {
      _isPlaying = playerState.playing;
    });

    if (_isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.setUrl(audioUrl).then((_) => _audioPlayer.play());
    }
  }
}
