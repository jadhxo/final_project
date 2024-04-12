import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TutorHome extends StatefulWidget {
  const TutorHome({super.key});

  @override
  State<TutorHome> createState() => _State();
}

class _State extends State<TutorHome> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  signOut() {
    try {
      _auth.signOut();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_auth.currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/login');
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Tutor Home Page!",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        actions: [
          ElevatedButton(onPressed: () => {signOut()}, child: Text("Sign Out"))
        ],
      ),
    );
  }
}
