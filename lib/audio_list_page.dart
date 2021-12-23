import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';

import 'audio_player_page.dart';
import 'folder_item.dart';

class AudioListPage extends StatefulWidget {
  const AudioListPage({Key? key, required this.folderItem}) : super(key: key);

  final FolderItem folderItem;

  @override
  _AudioListPageState createState() => _AudioListPageState();
}

class _AudioListPageState extends State<AudioListPage> {
  final List<FileSystemEntity> _audioFiles = [];

  @override
  void initState() {
    _listOfAudioFiles();
    super.initState();
  }

  Future<void> _listOfAudioFiles() async {
    List<FileSystemEntity> files =
        await _dirContents(Directory(widget.folderItem.folder));
    setState(() {
      files
          .where((item) => extension(item.path) == '.mp3')
          .forEach((item) => _audioFiles.add(item));
    });
  }

  Future<List<FileSystemEntity>> _dirContents(Directory dir) {
    var files = <FileSystemEntity>[];
    var completer = Completer<List<FileSystemEntity>>();
    var lister = dir.list(recursive: false);
    lister.listen((file) => files.add(file),
        // should also register onError
        onDone: () => completer.complete(files));
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select audio')),
      body: ListView.builder(
        itemCount: _audioFiles.length,
        itemBuilder: (context, index) {
          return ListTile(
              title: Row(
                children: <Widget>[
                  const Icon(Icons.audiotrack, size: 36),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(basename(_audioFiles[index].path)),
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AudioPlayerPage(audioFile: _audioFiles[index]),
                  ),
                );
              });
        },
      ),
    );
  }
}
