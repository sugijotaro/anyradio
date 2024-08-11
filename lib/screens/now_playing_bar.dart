import 'package:flutter/material.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:overflow_text_animated/overflow_text_animated.dart';
import '../viewmodels/radio_list_viewmodel.dart';
import 'radio_detail_screen.dart';

class NowPlayingBar extends StatelessWidget {
  final RadioListViewModel viewModel;

  NowPlayingBar({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    if (viewModel.currentlyPlayingRadio == null) return SizedBox.shrink();

    return Align(
      alignment: Alignment.bottomCenter,
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.black,
            useSafeArea: true,
            builder: (context) => RadioDetailScreen(),
          );
        },
        child: Container(
          color: Colors.black.withOpacity(0.9),
          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 0),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    viewModel.currentlyPlayingRadio!.thumbnail,
                    fit: BoxFit.cover,
                    width: 40,
                    height: 40,
                  ),
                ),
                title: OverflowTextAnimated(
                  text: viewModel.currentlyPlayingRadio!.title,
                  style: TextStyle(color: Colors.white),
                  curve: Curves.linear,
                  animation: OverFlowTextAnimations.scrollOpposite,
                  animateDuration: Duration(milliseconds: 1500),
                ),
                trailing: IconButton(
                  icon: Icon(
                    viewModel.audioState == AudioState.playing
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (viewModel.audioState == AudioState.playing) {
                      viewModel.pause();
                    } else {
                      viewModel.play();
                    }
                  },
                ),
              ),
              ProgressBar(
                progress: viewModel.progressBarState.current,
                buffered: viewModel.progressBarState.buffered,
                total: viewModel.progressBarState.total,
                onSeek: (Duration position) {
                  viewModel.seek(position);
                },
                timeLabelLocation: TimeLabelLocation.none,
                thumbRadius: 0.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
