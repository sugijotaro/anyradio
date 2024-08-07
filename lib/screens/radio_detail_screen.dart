import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
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
                    height: 200,
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
                      child: Consumer<RadioDetailViewModel>(
                        builder: (context, state, child) {
                          switch (state.audioState) {
                            case AudioState.loading:
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SizedBox(
                                  height: 32,
                                  width: 32,
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            case AudioState.ready:
                            case AudioState.paused:
                              return IconButton(
                                onPressed: () =>
                                    context.read<RadioDetailViewModel>().play(),
                                icon: Icon(Icons.play_arrow),
                                iconSize: 32.0,
                              );
                            case AudioState.playing:
                              return IconButton(
                                onPressed: () => context
                                    .read<RadioDetailViewModel>()
                                    .pause(),
                                icon: Icon(Icons.pause),
                                iconSize: 32.0,
                              );
                            default:
                              return SizedBox(
                                height: 32,
                                width: 32,
                              );
                          }
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Consumer<RadioDetailViewModel>(
                      builder: (context, state, child) {
                        return ProgressBar(
                          progress: state.progressBarState.current,
                          buffered: state.progressBarState.buffered,
                          total: state.progressBarState.total,
                          onSeek: (Duration position) {
                            state.seek(position);
                          },
                        );
                      },
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
}
