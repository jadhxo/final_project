import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/pages/AuthService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TutorHome extends StatefulWidget {
  const TutorHome({super.key});

  @override
  State<TutorHome> createState() => _State();
}

class _State extends State<TutorHome> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? docId = '';
  var user;
  AuthService authService = AuthService();
  StreamSubscription<DocumentSnapshot>? _userSubscription;
  signOut() {
    try {
      _auth.signOut();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      print(e);
    }
  }



  void fetchUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      docId = await authService.getDocumentIdByUid(user.uid);
      _userSubscription = authService.getUserStream(docId!).listen(
            (snapshot) {
          if (snapshot.exists) {
            setState(() {
              this.user = snapshot.data();
            });
          } else {
            print("No user data available");
          }
        },
        onError: (error) => print("Error listening to user updates: $error"),
      );
    }
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }


  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    if (_auth.currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/login');
      });
      return const Scaffold();
    }
    if (user == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            "Welcome ${user['first name']}!",
            style: TextStyle(color: Colors.white),
          ),
          bottom: TabBar(
            tabs: [
              Tab(
                text: 'All',

              ),
              Tab(text: 'My Reviews',)
            ],
          ),
          backgroundColor: Colors.blue,
          actions: [
            ElevatedButton(
                onPressed: () => {
                Navigator.pushNamed(context, '/profile', arguments: {'userId': _auth.currentUser!.uid, 'docId': docId})
            },
                child: const Text(
                  "View Profile",
                  style: TextStyle(color: Colors.blue),
                )),
            const SizedBox(
              width: 10,
            ),
            ElevatedButton(
                onPressed: () => {signOut()},
                child: const Text(
                  "Sign Out",
                  style: TextStyle(color: Colors.blue),
                ))
          ],
        ),
      ),
    );
  }
}
