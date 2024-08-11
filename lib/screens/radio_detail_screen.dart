import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:overflow_text_animated/overflow_text_animated.dart';
import '../viewmodels/radio_list_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
        final l10n = L10n.of(context);

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
                      _confirmDelete(context, radioViewModel, radio.id, l10n);
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(l10n.delete),
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
                      child: OverflowTextAnimated(
                        text: radio.title,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        curve: Curves.linear,
                        animation: OverFlowTextAnimations.scrollOpposite,
                        animateDuration: Duration(milliseconds: 1500),
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

  void _confirmDelete(BuildContext context, RadioListViewModel viewModel,
      String radioId, L10n l10n) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.deleteConfirmationTitle),
          content: Text(l10n.deleteConfirmationMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                viewModel.deleteRadio(radioId);
                Navigator.of(context).pop();
                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.radioDeleted),
                  ),
                );
              },
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );
  }
}
