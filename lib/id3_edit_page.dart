import 'package:flutter/material.dart';

import 'audio_file.dart';

class Id3EditPage extends StatefulWidget {
  final AudioFile audioFile;
  const Id3EditPage({Key? key, required this.audioFile}) : super(key: key);

  @override
  _Id3EditPageState createState() => _Id3EditPageState();
}

class _Id3EditPageState extends State<Id3EditPage> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final genreController = TextEditingController();
  final albumController = TextEditingController();
  final artistController = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      titleController.text = widget.audioFile.title;
      albumController.text = widget.audioFile.album;
      artistController.text = widget.audioFile.artist;
      genreController.text = widget.audioFile.genre;
      descriptionController.text = widget.audioFile.comment;
    });
  }

  Future<void> _writeTags(BuildContext context) async {
    widget.audioFile.writeTags(
        title: titleController.text,
        album: albumController.text,
        artist: artistController.text,
        genre: genreController.text,
        comment: descriptionController.text);

    const snackBar = SnackBar(
      content: Text('Saved!'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void dispose() {
    titleController.dispose();
    albumController.dispose();
    artistController.dispose();
    genreController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Id3 Tag'), actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.save_alt),
          tooltip: 'Save ID3 Tag',
          onPressed: () {
            _writeTags(context);
          },
        )
      ]),
      body: Form(
        key: _formKey,
        child: Scrollbar(
          child: Align(
            alignment: Alignment.topCenter,
            child: Card(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ...[
                        TextFormField(
                          decoration: const InputDecoration(
                            filled: true,
                            hintText: 'Enter a title...',
                            labelText: 'Title',
                          ),
                          controller: titleController,
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            filled: true,
                            hintText: 'Enter a album...',
                            labelText: 'Album',
                          ),
                          controller: albumController,
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            filled: true,
                            hintText: 'Enter a artist...',
                            labelText: 'Artist',
                          ),
                          controller: artistController,
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            filled: true,
                            hintText: 'Enter a genre...',
                            labelText: 'Genre',
                          ),
                          controller: genreController,
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            filled: true,
                            hintText:
                                '''Enter a time tag play list...\n00:00 Intro\n01:15 Audio01''',
                            labelText: 'Description',
                          ),
                          controller: descriptionController,
                          maxLines: 10,
                        ),
                      ].expand(
                        (widget) => [
                          widget,
                          const SizedBox(
                            height: 24,
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
