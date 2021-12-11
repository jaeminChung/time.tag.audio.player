import 'dart:io';

import 'package:audiotagger/audiotagger.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audiotagger/models/tag.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'audio_file.dart';

class AudioPlayerPage extends StatefulWidget {
  final FileSystemEntity audioFile;
  const AudioPlayerPage({Key? key, required this.audioFile}) : super(key: key);

  @override
  _AudioPlayerPageState createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
  late final AudioPlayer advancedPlayer;
  Tag? _audioTag;
  Image? _audioArtwork;
  final Audiotagger _tagger = Audiotagger();

  @override
  void initState() {
    super.initState();
    advancedPlayer = AudioPlayer();

    _readTag();
    _readArtwork();
  }

  Future<void> _readTag() async {
    final tag = await _tagger.readTags(path: widget.audioFile.path);
    setState(() {
      _audioTag = tag;
    });
  }

  Future<void> _readArtwork() async {
    final artwork = await _tagger.readArtwork(path: widget.audioFile.path);
    setState(() {
      _audioArtwork = Image.memory(artwork!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey,
      body: Stack(
        children: [
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: screenHeight / 3,
              child: Container(color: Colors.black26)),
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AppBar(
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    advancedPlayer.stop();
                  },
                ),
                actions: [
                  IconButton(
                    icon: const Icon(
                      Icons.search,
                    ),
                    onPressed: () {},
                  )
                ],
                backgroundColor: Colors.transparent,
                elevation: 0.0,
              )),
          Positioned(
              left: 0,
              right: 0,
              top: screenHeight * 0.2,
              height: screenHeight * 0.36,
              child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: screenHeight * 0.1,
                      ),
                      Text(
                        _audioTag?.title ?? "Unnamed",
                        style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Avenir"),
                      ),
                      Text(
                        _audioTag?.artist ?? "Unknown",
                        style: const TextStyle(fontSize: 20),
                      ),
                      AudioFile(
                          advancedPlayer: advancedPlayer,
                          audioPath: widget.audioFile.path),
                    ],
                  ))),
          Positioned(
              top: screenHeight * 0.12,
              left: (screenWidth - 150) / 2,
              right: (screenWidth - 150) / 2,
              height: screenHeight * 0.16,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white, width: 2),
                  color: Colors.grey,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    decoration: BoxDecoration(
                      //borderRadius: BorderRadius.circular(20),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 5),
                      image:DecorationImage(
                           image:_audioArtwork?.image??const AssetImage('img/pic-1.png'),
                           fit:BoxFit.cover
                      )
                    ),
                  ),
                ),
              ))
        ],
      ),
    );
  }
}
