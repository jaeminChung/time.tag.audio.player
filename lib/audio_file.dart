import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

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
  Color color = Colors.black;
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
        if (isRepeat == true) {
          isPlaying = true;
        } else {
          isPlaying = false;
          isRepeat = false;
        }
      });
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
        } else if (isPlaying == true) {
          widget.advancedPlayer.pause();
          setState(() {
            isPlaying = false;
          });
        }
      },
    );
  }

  Widget btnFast() {
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

  Widget btnSlow() {
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
      icon: const Icon(
        Icons.shuffle,
        size: _iconSize,
        color: Colors.black,
      ),
      onPressed: () {},
    );
  }

  Widget btnRepeat() {
    return IconButton(
      icon: const Icon(
        Icons.loop,
        size: _iconSize,
        color: Colors.black,
      ),
      onPressed: () {
        if (isRepeat == false) {
          widget.advancedPlayer.setReleaseMode(ReleaseMode.LOOP);
          setState(() {
            isRepeat = true;
            color = Colors.blue;
          });
        } else if (isRepeat == true) {
          widget.advancedPlayer.setReleaseMode(ReleaseMode.RELEASE);
          color = Colors.black;
          isRepeat = false;
        }
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
      btnSlow(),
      btnStart(),
      btnFast(),
      btnShuffle()
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
    Padding(
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
    ),
    slider(),
    loadAsset(),
      ],
    );
  }
}
