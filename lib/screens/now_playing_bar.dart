import 'package:flutter/material.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:overflow_text_animated/overflow_text_animated.dart';
import '../viewmodels/radio_list_viewmodel.dart';
import 'radio_detail_screen.dart';

class NowPlayingBar extends StatefulWidget {
  final RadioListViewModel viewModel;

  NowPlayingBar({required this.viewModel});

  @override
  _NowPlayingBarState createState() => _NowPlayingBarState();
}

class _NowPlayingBarState extends State<NowPlayingBar> {
  bool _isVisible = true;

  @override
  void didUpdateWidget(NowPlayingBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.viewModel.currentlyPlayingRadio?.id !=
        widget.viewModel.currentlyPlayingRadio?.id) {
      setState(() {
        _isVisible = false;
      });
      Future.delayed(Duration(milliseconds: 50), () {
        setState(() {
          _isVisible = true;
        });
      });
    }
  }

  void _playNextRadio() {
    widget.viewModel.playNextRadio();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.viewModel.currentlyPlayingRadio == null)
      return SizedBox.shrink();

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
                    widget.viewModel.currentlyPlayingRadio!.thumbnail,
                    fit: BoxFit.cover,
                    width: 40,
                    height: 40,
                  ),
                ),
                title: Visibility(
                  visible: _isVisible,
                  child: OverflowTextAnimated(
                    key: ValueKey(widget.viewModel.currentlyPlayingRadio!.id),
                    text: widget.viewModel.currentlyPlayingRadio!.title,
                    style: TextStyle(color: Colors.white),
                    curve: Curves.linear,
                    animation: OverFlowTextAnimations.scrollOpposite,
                    animateDuration: Duration(milliseconds: 1500),
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        widget.viewModel.audioState == AudioState.playing
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        if (widget.viewModel.audioState == AudioState.playing) {
                          widget.viewModel.pause();
                        } else {
                          widget.viewModel.play();
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.skip_next,
                        color: Colors.white,
                      ),
                      onPressed: _playNextRadio,
                    ),
                  ],
                ),
              ),
              ProgressBar(
                progress: widget.viewModel.progressBarState.current,
                buffered: widget.viewModel.progressBarState.buffered,
                total: widget.viewModel.progressBarState.total,
                onSeek: (Duration position) {
                  widget.viewModel.seek(position);
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
