import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/pages/AuthService.dart';
import 'package:final_project/pages/DBService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'NavigationBar.dart';
import 'SessionCard.dart';

class TutorHome extends StatefulWidget {
  const TutorHome({super.key});

  @override
  State<TutorHome> createState() => _State();
}

class _State extends State<TutorHome> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DBService dbService = DBService();
  String? docId = '';
  var user;
  int _selectedSubjectIndex = 0;
  int _selectedBottomNavIndex = 0;
  final List<Map<String, dynamic>> subjects = [];
  List<Map<String, dynamic>> sessions = [];
  AuthService authService = AuthService();
  StreamSubscription? userSubscription;
  StreamSubscription? sessionsStreamSubscription;


  @override
  void initState() {
    super.initState();
    fetchUser();
    fetchSubjects();
    fetchSessions();
  }

  void dispose() {
    sessionsStreamSubscription?.cancel();
    super.dispose();
  }

  void listenToSessions() {
    String uid = _auth.currentUser!.uid;
    sessionsStreamSubscription = _firestore.collection('users').doc(uid).collection('sessions')
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      List<Map<String, dynamic>> updatedSessions = [];
      print(snapshot.docs);
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        updatedSessions.add(data);
      }

      if (mounted) {
        setState(() {
          sessions = updatedSessions;
        });
      }
    }, onError: (error) {
      print("Error listening to session updates: $error");
    });
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
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Welcome ${user['first name']}!",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Center(
              child: Text(
                "Upcoming Sessions",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            sessions.isNotEmpty
                ? Expanded(
              child: ListView.builder(
                itemCount: sessions.length,
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  final subject = session['subject'] as String;
                  final tutorName = session['studentName'] as String;
                  final date = DateFormat.yMMMd().add_jm().format(
                      DateTime.fromMillisecondsSinceEpoch(
                          (session['date'] as Timestamp).millisecondsSinceEpoch
                      )
                  );

                  return SessionCard(
                      subject: subject,
                      name: tutorName,
                      date: date,
                      role: 'tutor'
                  );
                },
              ),
            )
                : const Center(
              child: Text(
                "No upcoming sessions.",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedBottomNavIndex,
        onItemSelected: (index) {
          setState(() {
            _selectedBottomNavIndex = index;
          });
        },
      ),
    );
  }

  Widget buildSubjectCard(int index) {
    var subject = subjects[index];
    bool isSelected = _selectedSubjectIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSubjectIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: Colors.blue.shade100,
                      spreadRadius: 3,
                      blurRadius: 5)
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(subject['icon'],
                color: isSelected ? Colors.blue : Colors.grey),
            const SizedBox(width: 8),
            Text(
              subject['title'],
              style: TextStyle(color: isSelected ? Colors.blue : Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void fetchUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      docId = await authService.getDocumentIdByUid(user.uid);
      userSubscription = authService.getUserStream(docId!).listen(
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

  Future fetchSubjects() async {
    try {
      QuerySnapshot subjectSnapshot =
          await _firestore.collection('subjects').get();
      setState(() {
        subjects.clear();
        for (var doc in subjectSnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          String subjectName = data['display name'];
          int iconCode = int.parse(data['icon'].substring(2), radix: 16);
          IconData iconData = IconData(iconCode, fontFamily: 'MaterialIcons');

          subjects.add({
            'title': subjectName,
            'icon': iconData,
          });
        }
      });
    } catch (e) {
      print(e);
    }
  }

  void fetchSessions() async {
    try {
      String uid = (_auth.currentUser?.uid)!;
      var data = await dbService.fetchSessions(uid);
      setState(() {
        sessions = data;
      });
      print(sessions);
    } catch (e) {
      print(e);
    }
  }
}
