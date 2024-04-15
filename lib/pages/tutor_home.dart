import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/pages/AuthService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'NavigationBar.dart';

class TutorHome extends StatefulWidget {
  const TutorHome({super.key});

  @override
  State<TutorHome> createState() => _State();
}

class _State extends State<TutorHome> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? docId = '';
  var user;
  int _selectedSubjectIndex = 0; // Independent index for subject list
  int _selectedBottomNavIndex = 0;
  final List<Map<String, dynamic>> subjects = [];
  AuthService authService = AuthService();
  StreamSubscription<DocumentSnapshot>? _userSubscription;

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
        padding: EdgeInsets.symmetric(horizontal: 12),
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
            BoxShadow(
                color: Colors.blue.shade100, spreadRadius: 3, blurRadius: 5)
          ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(subject['icon'],
                color: isSelected ? Colors.blue : Colors.grey),
            SizedBox(width: 8),
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

  Future fetchSubjects() async {
    try {
      QuerySnapshot subjectSnapshot = await _firestore.collection('subjects').get();
      setState(() {
        subjects.clear();
        for (var doc in subjectSnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          print(data);
          String subjectName = data['display name'];
          int iconCode = int.parse(data['icon'].substring(2), radix: 16);
          IconData iconData = IconData(iconCode, fontFamily: 'MaterialIcons');

          subjects.add({
            'title': subjectName,
            'icon': iconData, // Use IconData instead of a file path
          });
          print(subjects);
        }
        print(subjects);
      });
    } catch (e) {
      print(e);
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
    fetchSubjects();
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
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: 600),
              child: Wrap(
                direction: Axis.horizontal,
                children: List.generate(
                    subjects.length, (index) => buildSubjectCard(index)),
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
}
