import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../viewmodels/radio_list_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';

class RadioDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<RadioListViewModel, AuthViewModel>(
      builder: (context, radioViewModel, authViewModel, child) {
        if (radioViewModel.currentlyPlayingRadio == null) {
          return Center(child: CircularProgressIndicator());
        }

        final radio = radioViewModel.currentlyPlayingRadio!;
        final currentUser = authViewModel.currentUser;

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(
              radio.title,
              maxLines: 1,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            leading: IconButton(
              icon: Icon(
                Icons.expand_more,
                color: Colors.white,
                size: 32,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              if (currentUser != null && currentUser.id == radio.uploaderId)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      _confirmDelete(context, radioViewModel, radio.id);
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('削除'),
                      ),
                    ];
                  },
                ),
            ],
          ),
          body: SafeArea(
            child: Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: SingleChildScrollView(
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
                        progress: radioViewModel.progressBarState.current,
                        buffered: radioViewModel.progressBarState.buffered,
                        total: radioViewModel.progressBarState.total,
                        onSeek: (Duration position) {
                          radioViewModel.seek(position);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: IconButton(
                          onPressed: () {
                            if (radioViewModel.audioState ==
                                AudioState.playing) {
                              radioViewModel.pause();
                            } else {
                              radioViewModel.play();
                            }
                          },
                          icon: Icon(
                            radioViewModel.audioState == AudioState.playing
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
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(
      BuildContext context, RadioListViewModel viewModel, String radioId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('削除の確認'),
          content: Text('このラジオを削除しますか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                viewModel.deleteRadio(radioId);
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Close the detail screen as well
              },
              child: Text('削除'),
            ),
          ],
        );
      },
    );
  }
}
