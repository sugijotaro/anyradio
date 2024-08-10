import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:rxdart/rxdart.dart';
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

class RadioDetailViewModel extends ChangeNotifier {
  final RadioService _radioService = RadioService();
  custom_radio.Radio? radio;
  final AudioServiceHandler _audioHandler = getIt<AudioServiceHandler>();

  ProgressBarState progressBarState = ProgressBarState(
    current: Duration.zero,
    buffered: Duration.zero,
    total: Duration.zero,
  );
  AudioState audioState = AudioState.paused;
  late StreamSubscription _playbackSubscription;
  late StreamSubscription _progressBarSubscription;

  Future<void> fetchRadioById(String id) async {
    radio = await _radioService.getRadioById(id);
    if (radio != null) {
      incrementPlayCount();
      init();
    }
    notifyListeners();
  }

  void incrementPlayCount() {
    if (radio != null) {
      _radioService.incrementPlayCount(radio!.id);
    }
  }

  void init() {
    final mediaItem = MediaItem(
      id: radio!.audioUrl,
      album: "AnyRadio",
      title: radio!.title,
      artist: radio!.uploaderId,
      artUri: Uri.parse(radio!.thumbnail),
    );
    _audioHandler.initPlayer(mediaItem);
    _listenToPlaybackState();
    _listenForProgressBarState();
  }

  void play() => _audioHandler.play();

  void pause() => _audioHandler.pause();

  void seek(Duration position) => _audioHandler.seek(position);

  void setAudioState(AudioState state) {
    audioState = state;
    notifyListeners();
  }

  void setProgressBarState(ProgressBarState state) {
    progressBarState = state;
    notifyListeners();
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
