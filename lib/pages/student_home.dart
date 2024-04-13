import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'NavigationBar.dart'; // Assuming this is the path to your custom navigation bar file

class StudentHome extends StatefulWidget {
  const StudentHome({Key? key}) : super(key: key);

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? user; // To store user data
  String? docId; // To store user document ID for further reference

  int _selectedSubjectIndex = 0;
  int _selectedBottomNavIndex = 0;
  List<Map<String, dynamic>> subjects = [];

  @override
  void initState() {
    super.initState();
    fetchUser();
    fetchSubjects();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchUser() async {
    // Implement fetchUser logic to set user data and docId
  }

  Future<void> fetchSubjects() async {
    try {
      QuerySnapshot subjectSnapshot = await _firestore.collection('subjects').get();
      List<Map<String, dynamic>> fetchedSubjects = [];
      for (var doc in subjectSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String subjectName = data['display name'];
        int iconCode = int.parse(data['icon'].substring(2), radix: 16);
        IconData iconData = IconData(iconCode, fontFamily: 'MaterialIcons');

        fetchedSubjects.add({
          'title': subjectName,
          'icon': iconData,
        });
      }
      if (mounted) {
        setState(() {
          subjects = fetchedSubjects;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void signOut() async {
    try {
      await _auth.signOut();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      print(e);
    }
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
        padding: EdgeInsets.symmetric(horizontal: 12),
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.blue.shade100, spreadRadius: 3, blurRadius: 5)]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(subject['icon'], size: 24, color: isSelected ? Colors.blue : Colors.grey),
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
          "Welcome ${user?['first name']}!",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/profile', arguments: {'userId': _auth.currentUser!.uid, 'docId': docId});
            },
            child: const Text(
              "View Profile",
              style: TextStyle(color: Colors.blue),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white, // Corrected background color
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: signOut,
            child: const Text(
              "Sign Out",
              style: TextStyle(color: Colors.blue),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white, // Corrected background color
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          constraints: BoxConstraints(maxWidth: 600),
          child: Wrap(
            direction: Axis.horizontal,
            children: List.generate(subjects.length, buildSubjectCard),
          ),
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
