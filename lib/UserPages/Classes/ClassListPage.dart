import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled/UserPages/Classes/class_model.dart';
import 'package:untitled/UserPages/Classes/AddClassPage.dart';
import 'package:untitled/UserPages/Classes/EditClassPage.dart';

class ClassListPage extends StatefulWidget {
  @override
  _ClassListPageState createState() => _ClassListPageState();
}

class _ClassListPageState extends State<ClassListPage> {
  final daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Classes'),
      ),
      body: ListView.builder(
        itemCount: daysOfWeek.length,
        itemBuilder: (context, index) {
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser!.uid)
                .collection('classes')
                .where('day', isEqualTo: daysOfWeek[index])
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              List<ClassModel> classes = snapshot.data!.docs.map((doc) {
                return ClassModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
              }).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      daysOfWeek[index],
                      style:
                      TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  classes.length > 0
                      ? Column(
                    children: classes.map((classItem) {
                      return ListTile(
                        title: Text(classItem.title),
                        subtitle: Text(
                            '${classItem.startTime.format(context)} - ${classItem.endTime.format(context)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditClassPage(
                                        classModel: classItem),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () async {
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(currentUser.uid)
                                    .collection('classes')
                                    .doc(classItem.id)
                                    .delete();
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  )
                      : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('No classes on ${daysOfWeek[index]}.'),
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddClassPage()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
