import 'package:flutter/material.dart';

import '../models.dart';
import '../services.dart';
import '../utils.dart';

class VerticalOverlayShape extends SliderComponentShape {
  const VerticalOverlayShape({required this.height});

  final double height;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(0, height);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Paint paint = Paint()
      ..color = sliderTheme.overlayColor!
      ..style = PaintingStyle.fill;

    final Rect rect = Rect.fromCenter(center: center, width: 0, height: height);
    context.canvas.drawRect(rect, paint);
  }
}

class AudioView extends StatefulWidget {
  const AudioView({super.key});

  @override
  _AudioViewState createState() => _AudioViewState();
}

class _AudioViewState extends State<AudioView> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    final audioSummariesLength = AudioPlayApi.audioSummaries?.length ?? 0;
    var currIndex =
        AudioPlayApi.currentIndex < 0 ? 0 : AudioPlayApi.currentIndex;
    if (audioSummariesLength > 1) {
      currIndex++;
    }

    _tabController = TabController(
      length: audioSummariesLength > 1
          ? audioSummariesLength + 2
          : audioSummariesLength,
      initialIndex: currIndex,
      vsync: this,
    );
    _tabController.addListener(_syncAudioState);

    AudioSequenceNotifier.registerListener(_updateAudioSequence);
    AudioPlayingNotifier.registerListener(_updateState);
  }

  @override
  void dispose() {
    AudioSequenceNotifier.unregisterListener(_updateAudioSequence);
    AudioPlayingNotifier.unregisterListener(_updateState);
    _tabController.removeListener(_syncAudioState);
    _tabController.dispose();
    super.dispose();
  }

  void _updateAudioSequence() {
    final audioSummariesLength = AudioPlayApi.audioSummaries?.length ?? 0;
    var currIndex =
        AudioPlayApi.currentIndex < 0 ? 0 : AudioPlayApi.currentIndex;
    // TODO: Unknowing currIndex update not in time
    if (currIndex > audioSummariesLength ||
        (currIndex == audioSummariesLength && currIndex > 0)) {
      return;
    }

    if (audioSummariesLength > 1) {
      currIndex++;
    }
    setState(() {
      _tabController.dispose();
      _tabController = TabController(
        length: audioSummariesLength > 1
            ? audioSummariesLength + 2
            : audioSummariesLength,
        initialIndex: currIndex,
        vsync: this,
      );
      _tabController.addListener(_syncAudioState);
    });
  }

  void _updateState() => setState(() {});

  Future<void> _syncAudioState() async {
    var currIndex = _tabController.index;
    var prevIndex = AudioPlayApi.currentIndex;
    final audioSummariesLength = AudioPlayApi.audioSummaries?.length ?? 0;

    if (audioSummariesLength > 1) {
      prevIndex++;
      if (currIndex == 0) {
        currIndex = audioSummariesLength;
        await AudioPlayApi.pause();
        await AudioPlayApi.seekToPrevious();
        AudioPlayApi.play();
        return _tabController.animateTo(currIndex);
      } else if (currIndex == audioSummariesLength + 1) {
        currIndex = 1;
        await AudioPlayApi.pause();
        await AudioPlayApi.seekToNext();
        AudioPlayApi.play();
        return _tabController.animateTo(currIndex);
      }
    }

    if (currIndex == prevIndex) {
      return;
    }

    await AudioPlayApi.pause();
    if (prevIndex == 0) {
      return;
    }

    currIndex < prevIndex
        ? await AudioPlayApi.seekToPrevious()
        : await AudioPlayApi.seekToNext();

    return AudioPlayApi.play();
  }

  @override
  Widget build(BuildContext context) {
    final currAudioSummary = AudioPlayApi.currentAudioSummary;
    final audioSummaries = AudioPlayApi.audioSummaries ?? <AudioSummary>[];

    final previewImage = Stack(
      alignment: Alignment.center,
      children: [
        (currAudioSummary?.isValid ?? false)
            ? ClipOval(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.memory(
                        currAudioSummary!.pic,
                        fit: BoxFit.cover,
                      ),
                      Container(color: Colors.black26),
                    ],
                  ),
                ),
              )
            : AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(.75),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
        Icon(
          AudioPlayApi.isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
          size: 20,
        ),
      ],
    );

    final audioHandler = Flexible(
      child: TabBarView(
        controller: _tabController,
        children: [
          if (audioSummaries.length > 1) ...[
            AudioTabView(audioSummary: audioSummaries.last),
            for (var audioSummary in audioSummaries)
              AudioTabView(audioSummary: audioSummary),
            AudioTabView(audioSummary: audioSummaries.first),
          ] else
            for (var audioSummary in audioSummaries)
              AudioTabView(audioSummary: audioSummary),
        ],
      ),
    );

    return currAudioSummary?.isValid ?? false
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TrackProgress(),
              SizedBox(
                height: 42,
                child: Row(
                  children: [
                    Flexible(
                      child: InkWell(
                        onTap: () {
                          if (currAudioSummary?.isValid ?? false) {
                            setState(() {
                              AudioPlayApi.isPlaying
                                  ? AudioPlayApi.pause()
                                  : AudioPlayApi.play();
                            });
                          }
                        },
                        onLongPress: () => showModalBottomSheet(
                          context: context,
                          builder: (context) => const AudioPlaylistView(),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 10),
                            previewImage,
                            const SizedBox(width: 8),
                            audioHandler,
                            const PlayModeButton(),
                            const SizedBox(width: 4),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          )
        : const SizedBox.shrink();
  }
}

class AudioTabView extends StatelessWidget {
  const AudioTabView({
    super.key,
    required this.audioSummary,
  });

  final AudioSummary audioSummary;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          Display.formatTitle(audioSummary.title, simplify: true),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2.5),
        const Opacity(
          opacity: .4,
          child: TrackTime(),
        ),
      ],
    );
  }
}

class AudioPlaylistView extends StatefulWidget {
  const AudioPlaylistView({
    super.key,
  });

  @override
  State<AudioPlaylistView> createState() => _AudioPlaylistViewState();
}

class _AudioPlaylistViewState extends State<AudioPlaylistView> {
  @override
  void initState() {
    super.initState();
    AudioSequenceNotifier.registerListener(_updateState);
  }

  @override
  void dispose() {
    AudioSequenceNotifier.unregisterListener(_updateState);
    super.dispose();
  }

  void _updateState() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final currAudioSummaries = AudioPlayApi.audioSummaries ?? <AudioSummary>[];
    final currIndex = AudioPlayApi.currentIndex;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4,
              width: 36,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(.25),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 16),
            for (var entry in currAudioSummaries.asMap().entries)
              Container(
                color: entry.key == currIndex
                    ? Theme.of(context).colorScheme.primary.withOpacity(.1)
                    : null,
                child: InkWell(
                  onTap: () async {
                    await AudioPlayApi.pause();
                    await AudioPlayApi.seekTo(entry.value);
                    AudioPlayApi.play();
                    // setState(() {});
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 24),
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  Display.formatTitle(
                                    entry.value.title,
                                    simplify: true,
                                  ),
                                  style: TextStyle(
                                    color: entry.key == currIndex
                                        ? Theme.of(context).colorScheme.primary
                                        : null,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Opacity(
                                opacity: .4,
                                child: Text(
                                  ' · ${Display.formatTitle(
                                    entry.value.author,
                                    simplify: true,
                                  )}',
                                  style: TextStyle(
                                    color: entry.key == currIndex
                                        ? Theme.of(context).colorScheme.primary
                                        : null,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Opacity(
                          opacity: .4,
                          child: IconButton(
                              icon: const Icon(Icons.close),
                              iconSize: 20,
                              highlightColor: Colors.transparent,
                              onPressed: () async {
                                await AudioPlayApi.removeAt(entry.key);
                                if (AudioPlayApi.audioSummaries?.isEmpty ??
                                    true) {
                                  setState(() {
                                    Navigator.pop(context);
                                  });
                                }
                              }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class TrackTime extends StatefulWidget {
  const TrackTime({
    super.key,
  });

  @override
  State<TrackTime> createState() => _TrackTimeState();
}

class _TrackTimeState extends State<TrackTime> {
  @override
  void initState() {
    super.initState();
    AudioPositionNotifier.registerListener(_updateState);
  }

  @override
  void dispose() {
    AudioPositionNotifier.unregisterListener(_updateState);
    super.dispose();
  }

  void _updateState() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final position = AudioPlayApi.position;
    final positionMinutes = position.inMinutes;
    final positionSeconds = position.inSeconds.remainder(60);
    final duration = AudioPlayApi.duration;
    final durationMinutes = duration?.inMinutes ?? 0;
    final durationSeconds = duration?.inSeconds.remainder(60) ?? 0;

    return Text(
      '${Display.formatDuration('$positionMinutes:$positionSeconds')} / ${Display.formatDuration('$durationMinutes:$durationSeconds')}',
      style: const TextStyle(fontSize: 10),
    );
  }
}

class PlayModeButton extends StatefulWidget {
  const PlayModeButton({
    super.key,
  });

  @override
  State<PlayModeButton> createState() => _PlayModeButtonState();
}

class _PlayModeButtonState extends State<PlayModeButton> {
  @override
  void initState() {
    super.initState();
    AudioPlayModeNotifier.registerListener(_updateState);
  }

  @override
  void dispose() {
    AudioPlayModeNotifier.unregisterListener(_updateState);
    super.dispose();
  }

  void _updateState() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        switch (AudioPlayApi.currentPlayMode) {
          PlayMode.all => Icons.repeat,
          PlayMode.one => Icons.repeat_one,
          PlayMode.shuffle => Icons.shuffle,
        },
      ),
      onPressed: () => setState(() {
        switch (AudioPlayApi.currentPlayMode) {
          case PlayMode.all:
            AudioPlayApi.setPlayMode(PlayMode.one);
          case PlayMode.one:
            AudioPlayApi.setPlayMode(PlayMode.shuffle);
          case PlayMode.shuffle:
            AudioPlayApi.setPlayMode(PlayMode.all);
        }
      }),
    );
  }
}

class TrackProgress extends StatefulWidget {
  const TrackProgress({
    super.key,
  });

  @override
  State<TrackProgress> createState() => _TrackProgressState();
}

class _TrackProgressState extends State<TrackProgress> {
  @override
  void initState() {
    super.initState();
    AudioPositionNotifier.registerListener(_updateState);
  }

  @override
  void dispose() {
    AudioPositionNotifier.unregisterListener(_updateState);
    super.dispose();
  }

  void _updateState() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: const SliderThemeData(
        trackHeight: 4,
        trackShape: RectangularSliderTrackShape(),
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 0),
        overlayShape: VerticalOverlayShape(height: 21),
        // overlayShape: SliderComponentShape.noOverlay,
        overlayColor: Colors.transparent,
      ),
      child: Slider(
        value: AudioPlayApi.position.inMilliseconds.toDouble(),
        max: AudioPlayApi.duration?.inMilliseconds.toDouble() ??
            AudioPlayApi.position.inMilliseconds.toDouble(),
        onChanged: (value) => setState(() {
          AudioPlayApi.seek(Duration(milliseconds: value.toInt()));
        }),
      ),
    );
  }
}
