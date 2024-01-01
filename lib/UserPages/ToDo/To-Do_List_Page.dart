import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:untitled/UserPages/ToDo/ToDo.dart';
import 'EditToDoPage.dart';
import 'AddToDoPage.dart';

class ToDoListPage extends StatelessWidget {
  final String uid;

  ToDoListPage({required this.uid});

  @override
  Widget build(BuildContext context) {
    CollectionReference todosRef =
    FirebaseFirestore.instance.collection('users').doc(uid).collection('todos');

    return Scaffold(
      appBar: AppBar(
        title: Text('To-Do List'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: todosRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          List<ToDo> todos =
          snapshot.data!.docs.map((doc) => ToDo.fromSnapshot(doc)).toList();

          return ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index) {
              ToDo todo = todos[index];

              // Determine if the to-do item is overdue based on the due date/time and the current date/time
              bool isOverdue = !todo.completed &&
                  todo.dueDateTime.isBefore(DateTime.now());

              return ListTile(
                title: Text(
                  todo.title,
                  style: TextStyle(
                    decoration:
                    todo.completed ? TextDecoration.lineThrough : null,
                    color: isOverdue ? Colors.red : null,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      todo.description,
                      style: todo.completed
                          ? TextStyle(decoration: TextDecoration.lineThrough)
                          : null,
                    ),
                    if (todo.dueDateTime != null)
                      Text(
                        'Due: ${DateFormat.yMd().add_jm().format(todo.dueDateTime)}',
                        style: TextStyle(
                          color: isOverdue ? Colors.red : null,
                        ),
                      ),
                  ],
                ),
                trailing: Checkbox(
                  value: todo.completed,
                  onChanged: (value) {
                    todosRef
                        .doc(snapshot.data!.docs[index].id)
                        .update({'completed': value});
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditToDoPage(
                          uid: uid, todo: todo, todoIndex: index),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddToDoPage(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
