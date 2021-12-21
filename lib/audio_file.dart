import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:widget_marquee/widget_marquee.dart';

import 'audio_tag.dart';

class AudioFile extends StatefulWidget {
  final AudioPlayer advancedPlayer;
  final AudioTag audioTag;
  const AudioFile(
      {Key? key, required this.advancedPlayer, required this.audioTag})
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
  String? audioTitle;
  String? audioArtist;
  final List<Map<String, dynamic>> audioList = [];

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

    widget.advancedPlayer.setUrl(widget.audioTag.audioPath);
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
    setState(() {
      audioTitle = widget.audioTag.title;
      audioArtist = widget.audioTag.artist;
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
          widget.advancedPlayer.play(widget.audioTag.audioPath);
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
        int curr = _position.inSeconds;
        Map<String, dynamic> audio = widget.audioTag.getNextAudio(curr);
        setState(() {
          audioTitle = audio['title'];
        });
        changeToSecond(audio['time']);
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
        int curr = _position.inSeconds;
        Map<String, dynamic> audio = widget.audioTag.getPreviousAudio(curr);
        setState(() {
          audioTitle = audio['title'];
        });
        changeToSecond(audio['time']);
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
      child: Text(
        audioTitle ?? 'Untitle',
        style: const TextStyle(
            fontSize: 30, fontWeight: FontWeight.bold, fontFamily: "Avenir"),
      ),
    );
  }

  Widget loadArtist() {
    return Text(
      audioArtist ?? "Unknown",
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
