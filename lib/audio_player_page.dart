import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:time_tag_audio_player/id3_edit_page.dart';

import 'audio_file.dart';
import 'common.dart';

class AudioPlayerPage extends StatefulWidget {
  final FileSystemEntity audioFile;
  const AudioPlayerPage({Key? key, required this.audioFile}) : super(key: key);

  @override
  _AudioPlayerPageState createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage>
    with WidgetsBindingObserver {
  late final AudioPlayer _player = AudioPlayer();
  late Future<AudioFile> _audioFileFuture;
  late AudioFile _audioFile;

  final double _initFabHeight = 120.0;
  double _fabHeight = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    _init();

    _audioFileFuture = AudioFile.of(widget.audioFile);

    _fabHeight = _initFabHeight;

    setState(() {
      _audioFileFuture.then((value) => _audioFile = value);
    });
  }

  Future<void> _init() async {
    // Inform the operating system of our app's audio attributes etc.
    // We pick a reasonable default for an app that plays speech.
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    // Listen to errors during playback.
    _player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      debugPrint('A stream error occurred: $e');
    });
    try {
      _audioFileFuture.then((v) {
        var _playList = v.createPlayList();
        _player.setAudioSource(_playList);
      });
    } catch (e) {
      debugPrint('Error loading audio source : $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);

    _player.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Release the player's resources when not in use. We use "stop" so that
      // if the app resumes later, it will still remember what position to
      // resume from.
      //_player.stop();
    }
  }

  /// Collects the data useful for displaying in a seek bar, using a handy
  /// feature of rx_dart to combine the 3 streams of interest into one.
  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          _player.positionStream,
          _player.bufferedPositionStream,
          _player.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  @override
  Widget build(BuildContext context) {
    double _panelHeightClosed = 50.0;
    double _panelHeightOpen = MediaQuery.of(context).size.height * .85;

    return Scaffold(
      appBar: AppBar(actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.edit),
          tooltip: 'Edit ID3 Tag',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Id3EditPage(audioFile: _audioFile),
              ),
            ).then((value) {
              _audioFileFuture = AudioFile.of(widget.audioFile);
              _audioFileFuture.then((value) => _audioFile = value);
              _init();
            });
          },
        )
      ]),
      body: SlidingUpPanel(
        maxHeight: _panelHeightOpen,
        minHeight: _panelHeightClosed,
        parallaxEnabled: true,
        parallaxOffset: .5,
        body: _body(),
        panelBuilder: (sc) => _panel(sc),
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18.0), topRight: Radius.circular(18.0)),
        onPanelSlide: (double pos) => setState(() {
          _fabHeight =
              pos * (_panelHeightOpen - _panelHeightClosed) + _initFabHeight;
        }),
      ),
    );
  }

  Widget _body() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FutureBuilder<AudioFile>(
              future: _audioFileFuture,
              builder:
                  (BuildContext context, AsyncSnapshot<AudioFile> snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    children: [
                      snapshot.data?.artwork ?? const Text(''),
                    ],
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              }),
          // Display play/pause button and volume/speed sliders.
          ControlButtons(player: _player),
          // Display seek bar. Using StreamBuilder, this widget rebuilds
          // each time the position, buffered position or duration changes.
          StreamBuilder<PositionData>(
            stream: _positionDataStream,
            builder: (context, snapshot) {
              final positionData = snapshot.data;
              return SeekBar(
                duration: positionData?.duration ?? Duration.zero,
                position: positionData?.position ?? Duration.zero,
                bufferedPosition:
                    positionData?.bufferedPosition ?? Duration.zero,
                onChangeEnd: _player.seek,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _panel(ScrollController sc) {
    return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView(
          controller: sc,
          children: <Widget>[
            const SizedBox(
              height: 12.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 30,
                  height: 5,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius:
                          const BorderRadius.all(Radius.circular(12.0))),
                ),
              ],
            ),
            const SizedBox(
              height: 18.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                Text(
                  "Play list",
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 24.0,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 36.0,
            ),
            const SizedBox(
              height: 24,
            ),
          ],
        ));
  }
}

/// Displays the play/pause button and volume/speed sliders.
class ControlButtons extends StatelessWidget {
  final AudioPlayer player;

  const ControlButtons({Key? key, required this.player}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      StreamBuilder<SequenceState?>(
          stream: player.sequenceStateStream,
          builder: (context, snapshot) {
            final state = snapshot.data;
            if (state?.sequence.isEmpty ?? true) return const SizedBox();
            final metadata = state!.currentSource!.tag as MediaItem;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(metadata.album!,
                    style: Theme.of(context).textTheme.headline6),
                Text(metadata.title),
              ],
            );
          }),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Opens volume slider dialog
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: () {
              showSliderDialog(
                context: context,
                title: "Adjust volume",
                divisions: 10,
                min: 0.0,
                max: 1.0,
                value: player.volume,
                stream: player.volumeStream,
                onChanged: player.setVolume,
              );
            },
          ),
          StreamBuilder<SequenceState?>(
            stream: player.sequenceStateStream,
            builder: (context, snapshot) => IconButton(
              icon: Icon(Icons.skip_previous),
              iconSize: 48.0,
              onPressed: player.hasPrevious ? player.seekToPrevious : null,
            ),
          ),

          /// This StreamBuilder rebuilds whenever the player state changes, which
          /// includes the playing/paused state and also the
          /// loading/buffering/ready state. Depending on the state we show the
          /// appropriate button or loading indicator.
          StreamBuilder<PlayerState>(
            stream: player.playerStateStream,
            builder: (context, snapshot) {
              final playerState = snapshot.data;
              final processingState = playerState?.processingState;
              final playing = playerState?.playing;
              if (processingState == ProcessingState.loading ||
                  processingState == ProcessingState.buffering) {
                return Container(
                  margin: const EdgeInsets.all(8.0),
                  width: 64.0,
                  height: 64.0,
                  child: const CircularProgressIndicator(),
                );
              } else if (playing != true) {
                return IconButton(
                  icon: const Icon(Icons.play_arrow),
                  iconSize: 64.0,
                  onPressed: player.play,
                );
              } else if (processingState != ProcessingState.completed) {
                return IconButton(
                  icon: const Icon(Icons.pause),
                  iconSize: 64.0,
                  onPressed: player.pause,
                );
              } else {
                return IconButton(
                  icon: const Icon(Icons.replay),
                  iconSize: 64.0,
                  onPressed: () => player.seek(Duration.zero),
                );
              }
            },
          ),
          StreamBuilder<SequenceState?>(
            stream: player.sequenceStateStream,
            builder: (context, snapshot) => IconButton(
              icon: Icon(Icons.skip_next),
              iconSize: 48.0,
              onPressed: player.hasNext ? player.seekToNext : null,
            ),
          ),
          // Opens speed slider dialog
          StreamBuilder<double>(
            stream: player.speedStream,
            builder: (context, snapshot) => IconButton(
              icon: Text("${snapshot.data?.toStringAsFixed(1)}x",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                showSliderDialog(
                  context: context,
                  title: "Adjust speed",
                  divisions: 10,
                  min: 0.5,
                  max: 1.5,
                  value: player.speed,
                  stream: player.speedStream,
                  onChanged: player.setSpeed,
                );
              },
            ),
          ),
        ],
      ),
    ]);
  }
}
