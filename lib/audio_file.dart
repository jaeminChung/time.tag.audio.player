import 'package:audioplayers/audioplayers.dart';
import 'package:audiotagger/audiotagger.dart';
import 'package:audiotagger/models/tag.dart';
import 'package:flutter/material.dart';
import 'package:widget_marquee/widget_marquee.dart';

class AudioFile extends StatefulWidget {
  final AudioPlayer advancedPlayer;
  final String audioPath;
  const AudioFile(
      {Key? key, required this.advancedPlayer, required this.audioPath})
      : super(key: key);

  @override
  _AudioFileState createState() => _AudioFileState();
}

class _AudioFileState extends State<AudioFile> {
  Duration _duration = const Duration();
  Duration _position = const Duration();
  bool isPlaying = false;
  bool isPaused = false;
  bool isRepeat = false;
  bool isShuffle = false;
  final Audiotagger _tagger = Audiotagger();
  Tag? _audioTag;

  final List<IconData> _icons = [
    Icons.play_circle_fill,
    Icons.pause_circle_filled,
  ];

  static const double _iconSize = 30;

  @override
  void initState() {
    super.initState();
    widget.advancedPlayer.onDurationChanged.listen((d) {
      setState(() {
        _duration = d;
      });
    });
    widget.advancedPlayer.onAudioPositionChanged.listen((p) {
      setState(() {
        _position = p;
      });
    });

    widget.advancedPlayer.setUrl(widget.audioPath);
    widget.advancedPlayer.onPlayerCompletion.listen((event) {
      setState(() {
        _position = const Duration(seconds: 0);
        if (isRepeat) {
          isPlaying = true;
        } else {
          isPlaying = false;
          isRepeat = false;
        }
      });
    });
    readTag();
  }

  Future<void> readTag() async {
    final tag = await _tagger.readTags(path: widget.audioPath);
    setState(() {
      _audioTag = tag;
      parseAudioList();
    });
  }

  void parseAudioList() {
    String comment = _audioTag?.comment ?? '';
    RegExp regExp = RegExp(r'(\d{1,2}:\d{1,2}(:\d{1,2})?)[ \t]+(.+)$', multiLine: true);
    Iterable<RegExpMatch> allMatches = regExp.allMatches(comment);
    allMatches.forEach((m) {
      final time = m.group(1);
      final title = m.group(3);

    });
  }

  Widget btnStart() {
    return IconButton(
      padding: const EdgeInsets.only(bottom: 10),
      icon: isPlaying == false
          ? Icon(_icons[0], size: 50)
          : Icon(_icons[1], size: 50),
      onPressed: () {
        if (isPlaying == false) {
          widget.advancedPlayer.play(widget.audioPath);
          setState(() {
            isPlaying = true;
          });
        } else if (isPlaying) {
          widget.advancedPlayer.pause();
          setState(() {
            isPlaying = false;
          });
        }
      },
    );
  }

  Widget btnNext() {
    return IconButton(
      icon: const Icon(
        Icons.skip_next,
        size: _iconSize,
        color: Colors.black,
      ),
      onPressed: () {
        widget.advancedPlayer.setPlaybackRate(1.5);
      },
    );
  }

  Widget btnPrevious() {
    return IconButton(
      icon: const Icon(
        Icons.skip_previous,
        size: _iconSize,
        color: Colors.black,
      ),
      onPressed: () {
        widget.advancedPlayer.setPlaybackRate(0.5);
      },
    );
  }

  Widget btnShuffle() {
    return IconButton(
      icon: Icon(
        Icons.shuffle,
        size: _iconSize,
        color: isShuffle ? Colors.red : Colors.black,
      ),
      onPressed: () {
        setState(() {
          isShuffle = !isShuffle;
        });
      },
    );
  }

  Widget btnRepeat() {
    return IconButton(
      icon: Icon(
        Icons.loop,
        size: _iconSize,
        color: isRepeat ? Colors.red : Colors.black,
      ),
      onPressed: () {
        setState(() {
          isRepeat = !isRepeat;
          if (isRepeat) {
            widget.advancedPlayer.setReleaseMode(ReleaseMode.RELEASE);
          } else {
            widget.advancedPlayer.setReleaseMode(ReleaseMode.LOOP);
          }
        });
      },
    );
  }

  Widget slider() {
    return Slider(
        activeColor: Colors.red,
        inactiveColor: Colors.grey,
        value: _position.inSeconds.toDouble(),
        min: 0.0,
        max: _duration.inSeconds.toDouble(),
        onChanged: (double value) {
          setState(() {
            changeToSecond(value.toInt());
            value = value;
          });
        });
  }

  void changeToSecond(int second) {
    Duration newDuration = Duration(seconds: second);
    widget.advancedPlayer.seek(newDuration);
  }

  Widget loadAsset() {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          btnRepeat(),
          btnPrevious(),
          btnStart(),
          btnNext(),
          btnShuffle()
        ]);
  }

  Widget loadTitle() {
    return Marquee(
      loopDuration: const Duration(milliseconds: 5000),
      child: Text(
        _audioTag?.title ?? "Unnamed",
        style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            fontFamily: "Avenir"),
      ),
    );
  }

  Widget loadArtist() {
    return Text(
      _audioTag?.artist ?? "Unknown",
      style: const TextStyle(fontSize: 20),
    );
  }

  Widget loadStartEndTime() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _position.toString().split(".")[0],
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            _duration.toString().split(".")[0],
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        loadTitle(),
        loadArtist(),
        loadStartEndTime(),
        slider(),
        loadAsset(),
      ],
    );
  }
}
