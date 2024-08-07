import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import '../models/radio.dart' as custom_radio;
import '../services/radio_service.dart';

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

  late AudioPlayer _audioPlayer;
  ProgressBarState progressBarState = ProgressBarState(
    current: Duration.zero,
    buffered: Duration.zero,
    total: Duration.zero,
  );
  AudioState audioState = AudioState.paused;
  late StreamSubscription<PlayerState> _playerStateSubscription;
  late StreamSubscription<ProgressBarState> _progressBarSubscription;

  Future<void> fetchRadioById(String id) async {
    radio = await _radioService.getRadioById(id);
    if (radio != null) {
      init();
    }
    notifyListeners();
  }

  void init() {
    _audioPlayer = AudioPlayer()..setUrl(radio!.audioUrl);
    _listenToPlaybackState();
    _listenForProgressBarState();
  }

  void play() => _audioPlayer.play();

  void pause() => _audioPlayer.pause();

  void seek(Duration position) => _audioPlayer.seek(position);

  void setAudioState(AudioState state) {
    audioState = state;
    notifyListeners();
  }

  void setProgressBarState(ProgressBarState state) {
    progressBarState = state;
    notifyListeners();
  }

  void _listenToPlaybackState() {
    _playerStateSubscription =
        _audioPlayer.playerStateStream.listen((PlayerState state) {
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
      _audioPlayer.positionStream,
      _audioPlayer.bufferedPositionStream,
      _audioPlayer.durationStream,
      (Duration current, Duration buffer, Duration? total) => ProgressBarState(
        current: current,
        buffered: buffer,
        total: total ?? Duration.zero,
      ),
    ).listen((ProgressBarState state) => setProgressBarState(state));
  }

  bool isLoadingState(PlayerState state) {
    return state.processingState == ProcessingState.loading ||
        state.processingState == ProcessingState.buffering;
  }

  bool isAudioReady(PlayerState state) {
    return state.processingState == ProcessingState.ready && !state.playing;
  }

  bool isAudioPlaying(PlayerState state) {
    return state.playing && !hasCompleted(state);
  }

  bool isAudioPaused(PlayerState state) {
    return !state.playing && !isLoadingState(state);
  }

  bool hasCompleted(PlayerState state) {
    return state.processingState == ProcessingState.completed;
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _playerStateSubscription.cancel();
    _progressBarSubscription.cancel();
    super.dispose();
  }
}
