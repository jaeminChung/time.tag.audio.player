import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:time_tag_audio_player/select_folder_page.dart';

Future<void> main() async {
  await JustAudioBackground.init(
    androidNotificationChannelId:
        'com.jiosoft.time_tag_audio_player.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  runApp(const MyApp());
}

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
      debugShowCheckedModeBanner: false,
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
