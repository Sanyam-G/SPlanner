import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/MainPages/homepage.dart';
import 'package:untitled/MainPages/login_page.dart';
import 'package:untitled/MainPages/register_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/auth_provider.dart';
import 'package:untitled/UserPages/Notes/notes_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Provider.debugCheckInvalidValueType = null;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        Provider<NotesService>(
          create: (_) => NotesService(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Firebase Authentication',
        theme: ThemeData.dark(),
        debugShowCheckedModeBanner: false,
        home: AuthWrapper(),
        routes: {
          '/register': (context) => RegisterPage(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    checkCurrentUser();

  }

  Future<void> checkCurrentUser() async {
    await Future.delayed(Duration(seconds: 2)); // simulate a delay for testing
    final auth = Provider.of<AuthProvider>(context, listen: false);
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      //await auth.setUser(user);
      //addUserToDatabase(user);
    }
    setState(() {
      _isLoading = false;
    });
  }

  void addUserToDatabase(User user) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    if (user.displayName != null) {
      firestore.collection("users").doc(user.uid).set({
        "name": user.displayName,
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (auth.isLoggedIn()) {
      return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(auth.getUser()?.uid)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(),
              );
            default:
              final userData = snapshot.data!.data() as Map<String, dynamic>;
              return HomePage(userData: userData);
          }
        },
      );
    } else {
      return LoginPage();
    }
  }
}
