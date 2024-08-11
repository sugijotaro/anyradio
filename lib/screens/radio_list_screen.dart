import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../viewmodels/radio_list_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'radio_detail_screen.dart';
import 'horizontal_card_tile.dart';
import 'section_with_horizontal_scroll.dart';
import 'now_playing_bar.dart';
import '../models/radio.dart';

class RadioListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final radioViewModel =
        Provider.of<RadioListViewModel>(context, listen: true);
    final authViewModel = Provider.of<AuthViewModel>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.anyRadio),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              radioViewModel.setLanguageFilter(value);
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'all',
                  child: Text(l10n.showAllLanguages),
                ),
                PopupMenuItem<String>(
                  value: 'en',
                  child: Text(l10n.showEnglishOnly),
                ),
                PopupMenuItem<String>(
                  value: 'ja',
                  child: Text(l10n.showJapaneseOnly),
                ),
              ];
            },
            icon: Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Stack(
        children: [
          if (radioViewModel.radios.isEmpty)
            Center(child: CircularProgressIndicator())
          else
            RefreshIndicator(
              onRefresh: () async {
                await radioViewModel.fetchRadios();
              },
              child: ListView(
                padding: const EdgeInsets.only(
                  left: 8.0,
                  right: 8.0,
                  bottom: 100.0,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 12),
                    child: Text(
                      l10n.newArrivals,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (radioViewModel.radios.isNotEmpty)
                    HorizontalCardTile(
                      radio: radioViewModel.radios.first,
                      onTap: () {
                        if (radioViewModel.currentlyPlayingRadio?.id !=
                            radioViewModel.radios.first.id) {
                          radioViewModel
                              .fetchRadioById(radioViewModel.radios.first.id);
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
                  _buildUserPostedRadiosSection(
                      context, radioViewModel, authViewModel, l10n),
                  ..._buildGenreSections(radioViewModel, l10n, context),
                  SizedBox(height: 16),
                ],
              ),
            ),
          NowPlayingBar(viewModel: radioViewModel),
        ],
      ),
    );
  }

  List<Widget> _buildGenreSections(
      RadioListViewModel viewModel, L10n l10n, BuildContext context) {
    final genresWithCounts = RadioGenre.values.map((genre) {
      final genreRadios =
          viewModel.radios.where((radio) => radio.genre == genre).toList();
      return MapEntry(genre, genreRadios.length);
    }).toList();

    genresWithCounts.sort((a, b) => b.value.compareTo(a.value));

    return genresWithCounts.map((entry) {
      final genre = entry.key;
      final genreRadios =
          viewModel.radios.where((radio) => radio.genre == genre).toList();
      if (genreRadios.isEmpty) return SizedBox.shrink();

      return SectionWithHorizontalScroll(
        title: genreToString(genre, l10n),
        radios: genreRadios,
        itemWidth: 120,
        itemHeight: 120,
        onTap: (radio) {
          if (viewModel.currentlyPlayingRadio?.id != radio.id) {
            viewModel.fetchRadioById(radio.id);
          }
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.black,
            useSafeArea: true,
            builder: (context) => RadioDetailScreen(),
          );
        },
      );
    }).toList();
  }

  Widget _buildUserPostedRadiosSection(
      BuildContext context,
      RadioListViewModel radioViewModel,
      AuthViewModel authViewModel,
      L10n l10n) {
    final userRadios = radioViewModel.radios
        .where((radio) => radio.uploaderId == authViewModel.currentUser?.id)
        .toList();

    if (userRadios.isEmpty) return SizedBox.shrink();

    return SectionWithHorizontalScroll(
      title: l10n.yourPostedRadios,
      radios: userRadios,
      itemWidth: 120,
      itemHeight: 120,
      onTap: (radio) {
        if (radioViewModel.currentlyPlayingRadio?.id != radio.id) {
          radioViewModel.fetchRadioById(radio.id);
        }
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.black,
          useSafeArea: true,
          builder: (context) => RadioDetailScreen(),
        );
      },
    );
  }

  String genreToString(RadioGenre genre, L10n l10n) {
    switch (genre) {
      case RadioGenre.comedy:
        return l10n.comedyGenre;
      case RadioGenre.news:
        return l10n.newsGenre;
      case RadioGenre.education:
        return l10n.educationGenre;
      case RadioGenre.parenting:
        return l10n.parentingGenre;
      case RadioGenre.mentalHealth:
        return l10n.mentalHealthGenre;
      case RadioGenre.romance:
        return l10n.romanceGenre;
      case RadioGenre.mystery:
        return l10n.mysteryGenre;
      case RadioGenre.business:
        return l10n.businessGenre;
      case RadioGenre.entertainment:
        return l10n.entertainmentGenre;
      case RadioGenre.history:
        return l10n.historyGenre;
      case RadioGenre.health:
        return l10n.healthGenre;
      case RadioGenre.science:
        return l10n.scienceGenre;
      case RadioGenre.sports:
        return l10n.sportsGenre;
      case RadioGenre.fiction:
        return l10n.fictionGenre;
      case RadioGenre.religion:
        return l10n.religionGenre;
      default:
        return '';
    }
  }
}
