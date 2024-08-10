import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/radio_list_viewmodel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'radio_grid_item.dart';

class RadioListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return ChangeNotifierProvider(
      create: (_) => RadioListViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.radioList),
        ),
        body: Consumer<RadioListViewModel>(
          builder: (context, viewModel, child) {
            return Stack(
              children: [
                if (viewModel.radios.isEmpty)
                  Center(child: CircularProgressIndicator())
                else
                  RefreshIndicator(
                    onRefresh: () async {
                      await viewModel.fetchRadios();
                    },
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                        childAspectRatio: 0.75,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      itemCount: viewModel.radios.length,
                      itemBuilder: (context, index) {
                        var radio = viewModel.radios[index];
                        return GestureDetector(
                          onTap: () {
                            viewModel.fetchRadioById(radio.id);
                          },
                          child: RadioGridItem(radio: radio),
                        );
                      },
                    ),
                  ),
                if (viewModel.currentlyPlayingRadio != null)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      color: Colors.black.withOpacity(0.9),
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
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
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
