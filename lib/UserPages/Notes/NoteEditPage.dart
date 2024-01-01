import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/UserPages/Notes/NotesListPage.dart';

import 'notes_service.dart';
import 'note.dart';

class NoteEditPage extends StatefulWidget {
  final Note note;

  NoteEditPage({required this.note});

  @override
  _NoteEditPageState createState() => _NoteEditPageState();
}

class _NoteEditPageState extends State<NoteEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.note.title;
    _contentController.text = widget.note.content;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notesService = Provider.of<NotesService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Note'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Title',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _contentController,
              decoration: InputDecoration(
                hintText: 'Content',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some content';
                }
                return null;
              },
            ),
            SizedBox(height: 20.0),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final updatedNote = Note(
                      id: widget.note.id,
                      title: _titleController.text.trim(),
                      content: _contentController.text.trim(),
                      timestamp: widget.note.timestamp,
                    );
                    await notesService.updateNote(
                        updatedNote.id as String, updatedNote.title, updatedNote.content);
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => NoteListPage()));
                  }
                },
                child: Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
