import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/UserPages/Notes/NoteEditPage.dart';

import 'note.dart';
import 'notes_service.dart';
import 'AddNotePage.dart';

class NoteListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
      ),
      body: StreamProvider<List<Note>>(
        create: (BuildContext context) =>
        Provider.of<NotesService>(context, listen: false).notesStream,
        initialData: [],
        child: Consumer<List<Note>>(
          builder: (context, notes, child) {
            if (notes.isEmpty) {
              return Center(
                child: Text('No notes found'),
              );
            }
            return ListView.builder(
              itemCount: notes.length,
              itemBuilder: (BuildContext context, int index) {
                final note = notes[index];
                return ListTile(
                  title: Text(note.title),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    NoteEditPage(note: note,),
                              )
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          await Provider.of<NotesService>(context, listen: false)
                              .deleteNote(note.id!, context);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddNotePage()));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
