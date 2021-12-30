import 'dart:convert';
import 'dart:io';

import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:time_tag_audio_player/audio_list_page.dart';
import 'package:time_tag_audio_player/folder_item.dart';

class SelectFolderPage extends StatefulWidget {
  const SelectFolderPage({Key? key}) : super(key: key);

  @override
  _SelectFolderPageState createState() => _SelectFolderPageState();
}

class _SelectFolderPageState extends State<SelectFolderPage> {
  final Set<FolderItem> _audioFolders = {};
  int _selectedIndex = 0;

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

  Future<void> _deleteFolder(FolderItem item) async {
    setState(() {
      _audioFolders.remove(item);
      _writeJson();
    });
  }

  Future<void> _asyncDeleteConfirmDialog(
      BuildContext context, FolderItem item) async {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text(
              'Delete "${item.folder.replaceFirst('/sdcard/', '')}" folder?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                _deleteFolder(item);
                Navigator.of(context, rootNavigator: true).pop();
              },
            )
          ],
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Time tag audio player')),
      body: Builder(
        builder: (context) => ListView.builder(
//          padding: const EdgeInsets.all(8),
          itemCount: _audioFolders.length,
          itemBuilder: (context, index) {
            return buildFolderCard(context, _audioFolders.elementAt(index));
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_outlined),
            label: 'Folder',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music_outlined),
            label: 'Album',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box_outlined),
            label: 'Artist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            label: 'Genre',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        unselectedLabelStyle: const TextStyle(color: Colors.grey),
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pickDir(context),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget buildFolderCard(BuildContext context, FolderItem item) {
    return ListTile(
        title: Row(
          children: <Widget>[
            const Icon(Icons.library_music_outlined, size: 36),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.folder.replaceFirst('/sdcard/', ''),
              ),
            ),
            IconButton(
                icon: const Icon(Icons.play_circle_outline),
                iconSize: 30,
                onPressed: () {}),
            IconButton(
                icon: const Icon(Icons.delete_outline),
                iconSize: 30,
                onPressed: () {
                  _asyncDeleteConfirmDialog(context, item);
                }),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AudioListPage(folderItem : item),
            ),
          );
        });
  }
}
