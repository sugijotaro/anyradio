import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/radio_list_viewmodel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'radio_grid_item.dart';
import 'radio_detail_screen.dart';
import 'horizontal_card_tile.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

class RadioListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final viewModel = Provider.of<RadioListViewModel>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.radioList),
      ),
      body: Stack(
        children: [
          if (viewModel.radios.isEmpty)
            Center(child: CircularProgressIndicator())
          else
            RefreshIndicator(
              onRefresh: () async {
                await viewModel.fetchRadios();
              },
              child: ListView(
                padding: const EdgeInsets.only(
                  left: 8.0,
                  right: 8.0,
                  bottom: 100.0,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      "新着",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (viewModel.radios.isNotEmpty)
                    HorizontalCardTile(
                      radio: viewModel.radios.first,
                      onTap: () {
                        if (viewModel.currentlyPlayingRadio?.id !=
                            viewModel.radios.first.id) {
                          viewModel.fetchRadioById(viewModel.radios.first.id);
                        }
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.black,
                          useSafeArea: true,
                          builder: (context) => RadioDetailScreen(),
                        );
                      },
                    ),
                  SizedBox(height: 16),
                  // グリッドのリスト
                  GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      childAspectRatio: 0.75,
                    ),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: viewModel.radios.length,
                    itemBuilder: (context, index) {
                      var radio = viewModel.radios[index];
                      return RadioGridItem(radio: radio);
                    },
                  ),
                ],
              ),
            ),
          if (viewModel.currentlyPlayingRadio != null)
            Align(
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
                        ),
                        title: Text(
                          viewModel.currentlyPlayingRadio!.title,
                          style: TextStyle(color: Colors.white),
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
            ),
        ],
      ),
    );
  }
}
