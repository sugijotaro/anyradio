import 'package:flutter/material.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
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
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Image.network(
                  viewModel.currentlyPlayingRadio!.thumbnail,
                  fit: BoxFit.cover,
                  width: 50,
                  height: 50,
                ),
                title: Text(
                  viewModel.currentlyPlayingRadio!.title,
                  style: TextStyle(color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ProgressBar(
                  progress: viewModel.progressBarState.current,
                  buffered: viewModel.progressBarState.buffered,
                  total: viewModel.progressBarState.total,
                  onSeek: (Duration position) {
                    viewModel.seek(position);
                  },
                  timeLabelLocation: TimeLabelLocation.none,
                  thumbRadius: 0.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
