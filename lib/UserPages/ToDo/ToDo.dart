import 'package:cloud_firestore/cloud_firestore.dart';

class ToDo {
  String id;
  String title;
  String description;
  bool completed;
  DateTime createdAt;
  DateTime dueDateTime;

  ToDo({
    required this.id,
    required this.title,
    required this.description,
    required this.completed,
    required this.createdAt,
    required this.dueDateTime,
  });

  factory ToDo.fromSnapshot(DocumentSnapshot snapshot) {
    return ToDo(
      id: snapshot.id,
      title: snapshot['title'],
      description: snapshot['description'],
      completed: snapshot['completed'],
      createdAt: snapshot['createdAt'].toDate(),
      dueDateTime: snapshot['dueDateTime'].toDate(),
    );
  }
}
