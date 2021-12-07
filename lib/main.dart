import 'dart:io';
import 'package:flutter/material.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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
  Brightness _brightness = Brightness.light;

  Brightness get brightness => _brightness;

  void setThemeBrightness(Brightness brightness) {
    setState(() {
      _brightness = brightness;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Time tag audio player',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.teal,
          accentColor: Colors.white,
          brightness: _brightness,
        ),
        buttonTheme: const ButtonThemeData(
          buttonColor: Colors.teal,
          textTheme: ButtonTextTheme.accent,
        ),
        toggleableActiveColor: Colors.teal,
        brightness: _brightness,
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
  Directory? rootPath;

  String? filePath;
  String? dirPath;

  FileTileSelectMode filePickerSelectMode = FileTileSelectMode.checkButton;

  Future<void> _pickDir(BuildContext context) async {
    rootPath = Directory("/sdcard");

    final status = await Permission.storage.request();
    String? path = await FilesystemPicker.open(
      title: 'Select audio folder',
      context: context,
      rootDirectory: rootPath!,
      fsType: FilesystemType.folder,
      pickText: 'Select this folder',
      folderIconColor: Colors.teal,
      requestPermission: () async =>
          await Permission.storage.request().isGranted,
    );

    setState(() {
      dirPath = path;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = MyApp.of(context);
    final List<String> entries = <String>['A', 'B', 'C'];
    final List<int> colorCodes = <int>[600, 500, 100];

    return Scaffold(
      body: Builder(
        builder: (context) => Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: entries.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  height: 50,
                  color: Colors.amber[colorCodes[index]],
                  child: Center(child: Text('Entry ${entries[index]}')),
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
