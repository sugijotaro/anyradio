import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../models/radio.dart' as custom_radio;
import '../services/radio_service.dart';
import '../services/service_locator.dart';
import '../services/audio_handler.dart';

enum AudioState {
  ready,
  paused,
  playing,
  loading,
}

class ProgressBarState {
  ProgressBarState({
    required this.current,
    required this.buffered,
    required this.total,
  });

  final Duration current;
  final Duration buffered;
  final Duration total;
}

class RadioListViewModel extends ChangeNotifier {
  final RadioService _radioService = RadioService();
  final AudioServiceHandler _audioHandler = getIt<AudioServiceHandler>();

  List<custom_radio.Radio> radios = [];
  custom_radio.Radio? currentlyPlayingRadio;

  String selectedLanguage = 'all';

  ProgressBarState progressBarState = ProgressBarState(
    current: Duration.zero,
    buffered: Duration.zero,
    total: Duration.zero,
  );

  AudioState audioState = AudioState.paused;
  late StreamSubscription _playbackSubscription;
  late StreamSubscription _progressBarSubscription;

  RadioListViewModel() {
    fetchRadios();
    _listenToPlaybackState();
    _listenForProgressBarState();
  }

  Future<void> fetchRadios() async {
    final radiosStream = _radioService.getRadios();
    radiosStream.listen((radiosData) {
      radios = radiosData.where((radio) {
        if (selectedLanguage == 'all') {
          return true;
        }
        return radio.language == selectedLanguage;
      }).toList();
      notifyListeners();
    });
  }

  void setLanguageFilter(String language) {
    selectedLanguage = language;
    fetchRadios();
  }

  Future<void> fetchRadioById(String id) async {
    final radio = await _radioService.getRadioById(id);
    if (radio != null) {
      currentlyPlayingRadio = radio;
      incrementPlayCount();
      await cacheAndPlayAudio(radio.audioUrl);
      notifyListeners();
    }
  }

  Future<void> deleteRadio(String radioId) async {
    await _radioService.deleteRadio(radioId);
    radios.removeWhere((radio) => radio.id == radioId);
    if (currentlyPlayingRadio?.id == radioId) {
      currentlyPlayingRadio = null;
    }
    notifyListeners();
  }

  void incrementPlayCount() {
    if (currentlyPlayingRadio != null) {
      _radioService.incrementPlayCount(currentlyPlayingRadio!.id);
    }
  }

  Future<void> cacheAndPlayAudio(String url) async {
    final file = await DefaultCacheManager().getSingleFile(url);
    final filePath = 'file://${file.path}';

    final mediaItem = MediaItem(
      id: filePath,
      album: "AnyRadio",
      title: currentlyPlayingRadio!.title,
      artist: currentlyPlayingRadio!.uploaderId,
      artUri: Uri.parse(currentlyPlayingRadio!.thumbnail),
    );

    _audioHandler.initPlayer(mediaItem);
  }

  void play() => _audioHandler.play();

  void pause() => _audioHandler.pause();

  void seek(Duration position) => _audioHandler.seek(position);

  void setAudioState(AudioState state) {
    if (audioState != state) {
      audioState = state;
      notifyListeners();

      if (state == AudioState.paused &&
          progressBarState.current >= progressBarState.total &&
          progressBarState.total != Duration.zero) {
        print("Audio has completed playing: ${currentlyPlayingRadio?.title}");
        playNextRadio();
      } else {
        print("Audio state changed to: $audioState");
      }
    }
  }

  void setProgressBarState(ProgressBarState state) {
    if (progressBarState.current != state.current ||
        progressBarState.buffered != state.buffered ||
        progressBarState.total != state.total) {
      progressBarState = state;
      notifyListeners();
    }
  }

  void _listenToPlaybackState() {
    _playbackSubscription =
        _audioHandler.playbackState.listen((PlaybackState state) {
      if (isLoadingState(state)) {
        setAudioState(AudioState.loading);
      } else if (isAudioReady(state)) {
        setAudioState(AudioState.ready);
      } else if (isAudioPlaying(state)) {
        setAudioState(AudioState.playing);
      } else if (isAudioPaused(state)) {
        setAudioState(AudioState.paused);
      } else if (hasCompleted(state)) {
        setAudioState(AudioState.paused);
      }
    });
  }

  void playNextRadio() {
    if (radios.isEmpty) return;

    final currentIndex = radios.indexOf(currentlyPlayingRadio!);
    final nextIndex = (currentIndex + 1) % radios.length;
    final nextRadio = radios[nextIndex];

    print("Playing next radio: ${nextRadio.title}");
    fetchRadioById(nextRadio.id);
  }

  void _listenForProgressBarState() {
    _progressBarSubscription = CombineLatestStream.combine3(
      AudioService.position,
      _audioHandler.playbackState,
      _audioHandler.mediaItem,
      (Duration current, PlaybackState state, MediaItem? mediaItem) =>
          ProgressBarState(
        current: current,
        buffered: state.bufferedPosition,
        total: mediaItem?.duration ?? Duration.zero,
      ),
    ).listen((ProgressBarState state) => setProgressBarState(state));
  }

  bool isLoadingState(PlaybackState state) {
    return state.processingState == AudioProcessingState.loading ||
        state.processingState == AudioProcessingState.buffering;
  }

  bool isAudioReady(PlaybackState state) {
    return state.processingState == AudioProcessingState.ready &&
        !state.playing;
  }

  bool isAudioPlaying(PlaybackState state) {
    return state.playing && !hasCompleted(state);
  }

  bool isAudioPaused(PlaybackState state) {
    return !state.playing && !isLoadingState(state);
  }

  bool hasCompleted(PlaybackState state) {
    return state.processingState == AudioProcessingState.completed;
  }

  @override
  void dispose() {
    _playbackSubscription.cancel();
    _progressBarSubscription.cancel();
    super.dispose();
  }
}
