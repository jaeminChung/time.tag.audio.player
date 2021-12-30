import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:audiotagger/audiotagger.dart';
import 'package:audiotagger/models/tag.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class AudioFile {
  final FileSystemEntity file;
  Tag tag;
  Image artwork;
  static final Audiotagger tagger = Audiotagger();
  final List<Map<String, dynamic>> audioList = [];

  AudioFile(this.file, this.tag, this.artwork);

  static Future<AudioFile> of(FileSystemEntity file) async {
    Tag tag = await tagger.readTags(path: file.path) ?? Tag();
    Uint8List? memory = await tagger.readArtwork(path: file.path);
    Image artwork =
        memory != null ? Image.memory(memory) : Image.asset('img/pic-1.png');

    AudioFile result = AudioFile(file, tag, artwork);

    return result;
  }

  get artworkImageProvider => artwork.image;
  get audioPath => file.path;
  get title => tag.title;
  get artist => tag.artist;
  get comment => tag.comment;
  get album => tag.album;
  get genre => tag.genre;

  ConcatenatingAudioSource createPlayList() {
    List<AudioSource> audioSource = [];

    RegExp regExp =
        RegExp(r'(\d{1,2}:\d{1,2}(:\d{1,2})?)[ \t]+(.+)$', multiLine: true);

    String comment = tag.comment ?? '';
    Iterable<RegExpMatch> allMatches = regExp.allMatches(comment);

    UriAudioSource uriAudioSource = AudioSource.uri(Uri.parse(audioPath));
    int start = 0;
    int end = 0;
    String title = '';
    for (var m in allMatches) {
      final time = m.group(1) ?? '0';
      int end = calcSecond(time);

      if (start < end) {
        audioSource.add(ClippingAudioSource(
          child: uriAudioSource,
          start: Duration(seconds: start),
          end: Duration(seconds: end),
          tag: MediaItem(id: start.toString(), title: title, album: album, artist: artist),
        ));
      }
      title = m.group(3) ?? this.title;
      start = end;
    }
    audioSource.add(ClippingAudioSource(
      child: uriAudioSource,
      start: Duration(seconds: start),
      tag: MediaItem(
          id: start.toString(),
          title: title == '' ? this.title : title,
          album: album),
    ));

    return ConcatenatingAudioSource(
      children: audioSource,
    );
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

  Map<String, dynamic> getPreviousAudio(int currTime) {
    for (int i = audioList.length; i > 0; i--) {
      Map<String, dynamic> audio = audioList[i - 1];
      if (audio['time'] < currTime) {
        return audio;
      }
    }
    return audioList[0];
  }

  Map<String, dynamic> getNextAudio(int currTime) {
    for (int i = 0; i < audioList.length; i++) {
      Map<String, dynamic> audio = audioList[i];
      if (audio['time'] > currTime) {
        return audio;
      }
    }
    return audioList.last;
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
