import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../viewmodels/radio_list_viewmodel.dart';

class RadioDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<RadioListViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.currentlyPlayingRadio == null) {
          return Center(child: CircularProgressIndicator());
        }

        final radio = viewModel.currentlyPlayingRadio!;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(radio.title),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: CachedNetworkImage(
                        cacheManager: CacheManager(
                          Config(
                            'customCacheKey',
                            stalePeriod: const Duration(days: 7),
                            maxNrOfCacheObjects: 100,
                          ),
                        ),
                        imageUrl: radio.thumbnail,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey,
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey,
                          child: Icon(
                            Icons.error,
                            color: Colors.red,
                            size: 48.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    radio.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ProgressBar(
                    progress: viewModel.progressBarState.current,
                    buffered: viewModel.progressBarState.buffered,
                    total: viewModel.progressBarState.total,
                    onSeek: (Duration position) {
                      viewModel.seek(position);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: IconButton(
                      onPressed: () {
                        if (viewModel.audioState == AudioState.playing) {
                          viewModel.pause();
                        } else {
                          viewModel.play();
                        }
                      },
                      icon: Icon(
                        viewModel.audioState == AudioState.playing
                            ? Icons.pause
                            : Icons.play_arrow,
                        size: 48.0,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(radio.description),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
