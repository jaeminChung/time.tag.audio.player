import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:time_tag_audio_player/folder_item.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();

  static _MyAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<_MyAppState>();
  }
}

class _MyAppState extends State<MyApp> {
  final ThemeData theme = ThemeData();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Time tag audio player',
      theme: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          primary: Colors.grey,
          secondary: Colors.black,
        ),
      ),
      home: const SelectFolderPage(),
    );
  }
}

class SelectFolderPage extends StatefulWidget {
  const SelectFolderPage({Key? key}) : super(key: key);

  @override
  _SelectFolderPageState createState() => _SelectFolderPageState();
}

class _SelectFolderPageState extends State<SelectFolderPage> {
  String? dirPath;

  final Set<FolderItem> _audioFolders = {};

  Future<void> _readJson() async {
    final directory = await getExternalStorageDirectory();
    final String path = directory?.path ?? "";

    final file = File('$path/audio_folder.json');
    final data = json.decode(await file.readAsString());

    setState(() {
      data.map((item) => _audioFolders.add(FolderItem.fromJson(item)));
    });
  }

  Future<void> writeJson() async {
    final directory = await getExternalStorageDirectory();
    final String path = directory?.path ?? "";

    final file = File('$path/audio_folder.json');
    file.writeAsString(json.encode(_audioFolders.toList()));
  }

  @override
  void initState() {
    _readJson();
    super.initState();
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
      if(path != null) {
        _audioFolders.add(FolderItem(folder: path));
      }

      writeJson();
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
            child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: _audioFolders.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  height: 50,
                  color: Colors.black12,
                  child: Center(child: Text(_audioFolders.elementAt(index).folder)),
                );
              },
              separatorBuilder: (BuildContext context, int index) => const Divider(),
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
}
