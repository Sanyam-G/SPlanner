import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/Settings/Profile_Page.dart';
import 'login_page.dart';
import 'package:untitled/UserPages/Notes/NotesListPage.dart';
import 'package:untitled/UserPages/ToDo/To-Do_List_Page.dart';
import 'package:untitled/UserPages/Classes/ClassListPage.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const HomePage({required this.userData});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? _user;
  String? _username;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _getUserInfo();
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

  void NavigateToNotes() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteListPage()),
    );
  }

  void NavigateToToDo() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ToDoListPage(uid: _user!.uid)),
    );
  }

  void NavigateToClasses() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ClassListPage()),
    );
  }

  Future<void> _getUserInfo() async {
    try {
      final db = FirebaseFirestore.instance;
      final data = await db.collection('users').doc(_user?.uid).get();
      setState(() {
        _username = data.get('name') as String?;
      });
    } catch (e) {
      print('Error getting user info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome, ${_username ?? ''}!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Email: ${_user?.email ?? ''}',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: NavigateToNotes,
                child: Text('Notes'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: NavigateToToDo,
                child: Text('To-Do List'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: NavigateToClasses,
                child: Text('Classes'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
