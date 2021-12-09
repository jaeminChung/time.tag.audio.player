import 'dart:convert';
import 'dart:io';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:time_tag_audio_player/folder_item.dart';


class SelectFolderPage extends StatefulWidget {
  const SelectFolderPage({Key? key}) : super(key: key);

  @override
  _SelectFolderPageState createState() => _SelectFolderPageState();
}

class _SelectFolderPageState extends State<SelectFolderPage> {
  final Set<FolderItem> _audioFolders = {};

  @override
  void initState() {
    _readJson();
    super.initState();
  }

  Future<void> _readJson() async {
    final directory = await getExternalStorageDirectory();
    final String path = directory?.path ?? "";

    final file = File('$path/audio_folder.json');
    final data = json.decode(await file.readAsString());

    setState(() {
      data.forEach((item) => _audioFolders.add(FolderItem.fromJson(item)));
    });
  }

  Future<void> _writeJson() async {
    final directory = await getExternalStorageDirectory();
    final String path = directory?.path ?? "";

    final file = File('$path/audio_folder.json');
    file.writeAsString(json.encode(_audioFolders.toList()));
  }

  Future<void> _pickDir(BuildContext context) async {
    Directory? sdcardPath = Directory('/sdcard');

    String? path = await FilesystemPicker.open(
      title: 'Select audio folder',
      context: context,
      rootDirectory: sdcardPath,
      fsType: FilesystemType.folder,
//      pickText: 'Select this folder',
      folderIconColor: Colors.grey,
      requestPermission: () async =>
      await Permission.storage.request().isGranted,
    );

    setState(() {
      if (path != null) {
        _audioFolders.add(FolderItem(folder: path));
      }

      _writeJson();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Time tag audio player')),
      body: Builder(
        builder: (context) => Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _audioFolders.length,
              itemBuilder: (BuildContext context, int index) {
                return Center(
                      child: buildFolderCard(_audioFolders.elementAt(index)));
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pickDir(context),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget buildFolderCard(FolderItem item) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: <Widget>[
            const Icon(Icons.folder_open, size: 36),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.folder.replaceFirst('/sdcard/', ''),
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Palatino',
                ),
              ),
            ),
            IconButton(
                icon: const Icon(Icons.play_circle_outline),
                iconSize: 30,
                onPressed: () {
                }),
            IconButton(
                icon: const Icon(Icons.delete_outline),
                iconSize: 30,
                onPressed: () {
                }),
          ],
        ),
      ),
    );
  }
}