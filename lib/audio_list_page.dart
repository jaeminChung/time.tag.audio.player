import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AudioListPage extends StatefulWidget {
  const AudioListPage({Key? key}) : super(key: key);

  @override
  _AudioListPageState createState() => _AudioListPageState();
}

class _AudioListPageState extends State<AudioListPage> {
  final List _sample = ['A', 'B', 'C'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select audio')),
      body: ListView.builder(
              itemCount: _sample.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_sample[index]),
                );
              },
            ),
    );
  }
}
