import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:audiotagger/audiotagger.dart';
import 'package:audiotagger/models/tag.dart';
import 'package:flutter/material.dart';

class AudioTag {
  late final FileSystemEntity file;
  late Tag tag;
  Image? artwork;
  static final Audiotagger tagger = Audiotagger();
  final List<Map<String, dynamic>> audioList = [];

  AudioTag(FileSystemEntity audioFile) {
    file = audioFile;
    _readFile();
  }

  Future<void> _readFile() async {
    tag = await tagger.readTags(path: file.path) ?? Tag();
    Uint8List? memory = await tagger.readArtwork(path: file.path);
    artwork = memory != null ? Image.memory(memory) : null;
  }

  static Future<AudioTag> of(FileSystemEntity file) {
    Future<AudioTag> tag = Future(() {
      return AudioTag(file);
    });
    return tag;
  }

  get artworkImageProvider => artwork?.image ?? const AssetImage('img/pic-1.png');
  get audioPath => file.path;
  get title => tag.title;
  get artist => tag.artist;

  void parseAudioList() {
    RegExp regExp =
    RegExp(r'(\d{1,2}:\d{1,2}(:\d{1,2})?)[ \t]+(.+)$', multiLine: true);

    String comment = tag.comment ?? '';
    Iterable<RegExpMatch> allMatches = regExp.allMatches(comment);

    audioList.clear();
    for (var m in allMatches) {
      final time = m.group(1);
      final title = m.group(3);
      audioList.add({'time': calcSecond(time ?? '0'), 'title': title});
    }
  }

  int calcSecond(String time) {
    List<String> times = time.split(':');
    int second = 0;
    int length = times.length;
    for (int i = 0; i < length; i++) {
      second = second + int.parse(times[i]) * pow(60, length - i - 1).toInt();
    }

    return second;
  }


  Future<bool?> writeTags(
      {String? title,
      String? artist,
      String? album,
      String? albumArtist,
      String? year,
      String? genre,
      String? diskNumber,
      String? diskTotal,
      String? trackNumber,
      String? trackTotal,
      String? lyrics,
      String? comment}) async {
    tag.title = title ?? tag.title;
    tag.artist = artist ?? tag.artist;
    tag.album = album ?? tag.album;
    tag.albumArtist = albumArtist ?? tag.albumArtist;
    tag.year = year ?? tag.year;
    tag.genre = genre ?? tag.genre;
    tag.discNumber = diskNumber ?? tag.discNumber;
    tag.discTotal = diskTotal ?? tag.discTotal;
    tag.trackNumber = trackNumber ?? tag.trackNumber;
    tag.trackTotal = trackTotal ?? tag.trackTotal;
    tag.lyrics = lyrics ?? tag.lyrics;
    tag.comment = comment ?? tag.comment;

    return await tagger.writeTags(
      path: file.path,
      tag: tag,
    );
  }
}
