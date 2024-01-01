import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'note.dart';



class NotesService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Note>? _notes;

  List<Note>? get notes => _notes;

  Stream<List<Note>> get notesStream => _firestore
      .collection('users')
      .doc(_auth.currentUser!.uid)
      .collection('notes')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((querySnapshot) => querySnapshot.docs
      .map((doc) => Note(
    id: doc.id,
    title: doc['title'],
    content: doc['content'],
    timestamp: doc['timestamp'].toDate(),
  ))
      .toList());


  Future<void> loadNotes() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final notesCollection =
      _firestore.collection('users').doc(currentUser.uid).collection('notes');
      final querySnapshot =
      await notesCollection.orderBy('timestamp', descending: true).get();
      _notes = querySnapshot.docs
          .map((doc) => Note(
        id: doc.id,
        title: doc['title'],
        content: doc['content'],
        timestamp: doc['timestamp'].toDate(),
      ))
          .toList();
      notifyListeners();
    }
  }

  Future<void> createNote(String title, String content) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final notesCollection =
      _firestore.collection('users').doc(currentUser.uid).collection('notes');
      await notesCollection.add({
        'title': title,
        'content': content,
        'timestamp': DateTime.now(),
      });
      await loadNotes();
    }
  }

  Future<void> updateNote(
      String id, String title, String content) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final notesCollection =
      _firestore.collection('users').doc(currentUser.uid).collection('notes');
      await notesCollection.doc(id).update({
        'title': title,
        'content': content,
      });
      await loadNotes();
    }
  }

  Future<void> deleteNote(
      String id, BuildContext context) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final notesCollection =
      _firestore.collection('users').doc(currentUser.uid).collection('notes');

      bool confirmed = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Are you sure you want to delete this note?"),
            actions: [
              TextButton(
                child: Text("Cancel"),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: Text("Yes"),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          );
        },
      );
      if (confirmed == true) {
        await notesCollection.doc(id).delete();
        await loadNotes();
      }
    }
  }
}
