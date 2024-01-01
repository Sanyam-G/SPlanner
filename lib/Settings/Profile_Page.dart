import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../MainPages/homepage.dart';
import '../Settings/ChangePassword.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final TextEditingController _nameController;
  late String _name;
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  late final String _userId;

  @override
  void initState() {
    super.initState();
    _userId = _auth.currentUser!.uid;
    _name = _auth.currentUser?.displayName ?? '';
    _nameController = TextEditingController();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData =
    await _firestore.collection('users').doc(_userId).get();
    if (userData.exists) {
      final user = userData.data();
      setState(() {
        _name = user!['name'] as String;
        _nameController.text = _name;
      });
    }
  }

  void _changePassword() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChangePasswordPage()));
  }

  Future<void> _saveChanges() async {
    final userRef = _firestore.collection('users').doc(_userId);
    await userRef.update({
      'name': _nameController.text,
    });
    setState(() {
      _name = _nameController.text;
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage(userData: {
        'name': _nameController.text,
        'userId': _userId,
      })),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 50),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveChanges,
              child: Text('Save Changes'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
                onPressed: _changePassword,
                child: Text('Change Password')),
          ],
        ),
      ),
    );
  }
}
