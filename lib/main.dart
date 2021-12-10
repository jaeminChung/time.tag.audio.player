import 'package:flutter/material.dart';
import 'package:time_tag_audio_player/select_folder_page.dart';

import 'audio_list_page.dart';

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
      initialRoute: '/',
      routes: {"/AudioList" : (screenContext) => const AudioListPage()},
      home: const SelectFolderPage(),
    );
  }
}


