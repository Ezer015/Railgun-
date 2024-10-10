import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:just_audio/just_audio.dart';
// import 'package:just_audio_background/just_audio_background.dart';

import 'seamless_audio_handler.dart';
import 'local_lock_caching_audio_source.dart';
import '../models.dart';
import 'remote_api.dart';

enum PlayMode {
  all,
  one,
  shuffle,
}

class SummaryLockCachingAudioSource extends LocalLockCachingAudioSource {
  final AudioSummary audioSummary;

  SummaryLockCachingAudioSource(
    super.uri, {
    super.headers,
    super.cacheFile,
    super.tag,
    required this.audioSummary,
  });
}

class SeamlessAudioPlayer extends AudioPlayer {
  @override
  Future<void> seekToNext() async {
    if (loopMode == LoopMode.one) {
      await setLoopMode(LoopMode.all);
      await super.seekToNext();
      return await setLoopMode(LoopMode.one);
    }
    return super.seekToNext();
  }

  @override
  Future<void> seekToPrevious() async {
    if (loopMode == LoopMode.one) {
      await setLoopMode(LoopMode.all);
      await super.seekToPrevious();
      return await setLoopMode(LoopMode.one);
    }
    return super.seekToPrevious();
  }
}

class AudioPlayApi {
  static final AudioPlayApi _instance = AudioPlayApi._();

  factory AudioPlayApi() => _instance;

  AudioPlayApi._() : _player = SeamlessAudioPlayer();

  static Future<void> init() async {
    await _instance._player.setAudioSource(_instance._audios);
    await _instance._player.setShuffleModeEnabled(false);
    return await _instance._player.setLoopMode(LoopMode.all);
  }

  final AudioPlayer _player;
  final ConcatenatingAudioSource _audios =
      ConcatenatingAudioSource(children: <SummaryLockCachingAudioSource>[]);
  PlayMode _currentPlayMode = PlayMode.all;

  static AudioPlayer get player => _instance._player;

  static bool get isPlaying => _instance._isPlaying;
  bool get _isPlaying => _player.playing;

  static PlayMode get currentPlayMode => _instance._currentPlayMode;

  static List<AudioSummary>? get audioSummaries => _instance._audioSummaries;
  List<AudioSummary>? get _audioSummaries {
    final seq = _player.sequence;
    if (seq == null) {
      return null;
    }

    if (_player.shuffleModeEnabled) {
      final indices = _player.shuffleIndices;
      if (indices == null) {
        return null;
      }

      return [
        for (var index in indices)
          (seq[index] as SummaryLockCachingAudioSource).audioSummary
      ];
    }

    return [
      for (var audio in seq)
        (audio as SummaryLockCachingAudioSource).audioSummary
    ];
  }

  static int get currentIndex => _instance._currentIndex;
  int get _currentIndex {
    final realCurrentIndex = _player.currentIndex;
    if (realCurrentIndex == null) {
      return -1;
    }

    if (_player.shuffleModeEnabled) {
      final indices = _player.shuffleIndices;
      if (indices == null) {
        return -1;
      }

      return indices.indexOf(realCurrentIndex);
    }

    return realCurrentIndex;
  }

  static AudioSummary? get currentAudioSummary =>
      _instance._currentAudioSummary;
  AudioSummary? get _currentAudioSummary {
    if (currentIndex == -1) {
      return null;
    }

    final seq = audioSummaries;
    if (seq == null || seq.isEmpty) {
      return null;
    }

    return seq[currentIndex];
  }

  static Duration get position => _instance._position;
  Duration get _position => _player.position;

  static Duration? get duration => _instance._duration;
  Duration? get _duration => _player.duration;

  static Future<void> add(AudioSummary audioSummary) async =>
      await _instance._add(audioSummary);
  Future<void> _add(AudioSummary audioSummary) async {
    if (!audioSummary.isValid) {
      return;
    }

    if (_audios.children.any((audio) =>
        (audio as SummaryLockCachingAudioSource).audioSummary.bvid ==
        audioSummary.bvid)) {
      return;
    }

    final viewResponse = await RemoteApi.getBaseSrc(
      RemoteApiPath.audioInfo,
      query: {'bvid': audioSummary.bvid as String},
    );
    final cid = json.decode(viewResponse.body)['data']['cid'];

    final playUrlResponse = await RemoteApi.getBaseSrc(
      RemoteApiPath.audioStream,
      query: {
        'bvid': audioSummary.bvid as String,
        'cid': cid.toString(),
        'fnval': 16.toString(),
      },
    );
    final playUrl = Uri.parse(
        (json.decode(playUrlResponse.body)['data']['dash']['audio'] as List)
            .last['baseUrl']);

    return await _audios.add(
      SummaryLockCachingAudioSource(
        playUrl,
        headers: RemoteApi.headers,
        tag: MediaItem(
          id: audioSummary.bvid!,
          title: audioSummary.title,
          artist: audioSummary.author,
        ),
        audioSummary: audioSummary,
      ),
    );
  }

  static Future<void> removeAt(int index) async => _instance._removeAt(index);
  Future<void> _removeAt(int index) async {
    if (index < 0 || index >= _audios.children.length) {
      return;
    }

    if (_player.shuffleModeEnabled) {
      final indices = _player.shuffleIndices;
      if (indices == null) {
        return;
      }

      final realIndex = indices[index];
      if (realIndex == -1) {
        return;
      }

      return await _audios.removeAt(realIndex);
    }

    return await _audios.removeAt(index);
  }

  static Future<void> seek(Duration? position, {int? index}) async =>
      _instance._seek(position, index: index);
  Future<void> _seek(Duration? position, {int? index}) async =>
      _player.seek(position, index: index);

  static Future<void> seekTo(AudioSummary audioSummary) async =>
      _instance._seekTo(audioSummary);
  Future<void> _seekTo(AudioSummary audioSummary) async {
    int index = _player.sequence?.indexWhere((audio) =>
            (audio as SummaryLockCachingAudioSource).audioSummary.bvid ==
            audioSummary.bvid) ??
        -1;

    if (index != -1) {
      return await _seek(null, index: index);
    }
  }

  static Future<void> seekToPrevious() async => _instance._seekToPrevious();
  Future<void> _seekToPrevious() async => await _player.seekToPrevious();

  static Future<void> seekToNext() async => _instance._seekToNext();
  Future<void> _seekToNext() async => await _player.seekToNext();

  static Future<void> play() async => _instance._play();
  Future<void> _play() async => await _player.play();

  static Future<void> pause() async => _instance._pause();
  Future<void> _pause() async => await _player.pause();

  static Future<void> setPlayMode(PlayMode playMode) async =>
      _instance._setPlayMode(playMode);
  Future<void> _setPlayMode(PlayMode playMode) async {
    _currentPlayMode = playMode;
    switch (playMode) {
      case PlayMode.all:
        await _player.setLoopMode(LoopMode.all);
        await _player.setShuffleModeEnabled(false);
      case PlayMode.one:
        await _player.setLoopMode(LoopMode.one);
        await _player.setShuffleModeEnabled(false);
      case PlayMode.shuffle:
        await _player.setLoopMode(LoopMode.all);
        await _player.setShuffleModeEnabled(true);
        await _player.shuffle();
    }
  }
}

class AudioPlayModeNotifier extends ChangeNotifier {
  static final AudioPlayModeNotifier _instance = AudioPlayModeNotifier._();

  factory AudioPlayModeNotifier() => _instance;

  AudioPlayModeNotifier._() {
    AudioPlayApi.player.loopModeStream.listen((loopMode) => notifyListeners());
    AudioPlayApi.player.shuffleModeEnabledStream
        .listen((shuffleMode) => notifyListeners());
  }

  static void registerListener(VoidCallback listener) =>
      _instance.addListener(listener);
  static void unregisterListener(VoidCallback listener) =>
      _instance.removeListener(listener);
}

class AudioPositionNotifier extends ChangeNotifier {
  static final AudioPositionNotifier _instance = AudioPositionNotifier._();

  factory AudioPositionNotifier() => _instance;

  AudioPositionNotifier._() {
    AudioPlayApi.player.positionStream.listen((position) => notifyListeners());
  }

  static void registerListener(VoidCallback listener) =>
      _instance.addListener(listener);
  static void unregisterListener(VoidCallback listener) =>
      _instance.removeListener(listener);
}

class AudioSequenceNotifier extends ChangeNotifier {
  static final AudioSequenceNotifier _instance = AudioSequenceNotifier._();

  factory AudioSequenceNotifier() => _instance;

  AudioSequenceNotifier._() {
    AudioPlayApi.player.sequenceStream.listen((sequence) => notifyListeners());
    AudioPlayApi.player.shuffleIndicesStream
        .listen((indices) => notifyListeners());
    AudioPlayApi.player.currentIndexStream.listen((index) => notifyListeners());
  }

  static void registerListener(VoidCallback listener) =>
      _instance.addListener(listener);
  static void unregisterListener(VoidCallback listener) =>
      _instance.removeListener(listener);
}

class AudioPlayingNotifier extends ChangeNotifier {
  static final AudioPlayingNotifier _instance = AudioPlayingNotifier._();

  factory AudioPlayingNotifier() => _instance;

  AudioPlayingNotifier._() {
    AudioPlayApi.player.playingStream.listen((playing) => notifyListeners());
  }

  static void registerListener(VoidCallback listener) =>
      _instance.addListener(listener);
  static void unregisterListener(VoidCallback listener) =>
      _instance.removeListener(listener);
}
