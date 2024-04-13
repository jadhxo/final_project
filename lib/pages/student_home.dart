import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'NavigationBar.dart';

class StudentHome extends StatefulWidget {
  const StudentHome({super.key});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  int _selectedSubjectIndex = 0; // Independent index for subject list
  int _selectedBottomNavIndex = 0; // Independent index for bottom navigation

  final List<Map<String, dynamic>> subjects = [
    {
      'title': 'Biology',
      'icon': Icons.local_florist,
    },
    {
      'title': 'Physics',
      'icon': Icons.scatter_plot,
    },
    {
      'title': 'Chemistry',
      'icon': Icons.science,
    },
    // Add more subjects as needed
  ];

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
              ? [
            BoxShadow(
                color: Colors.blue.shade100, spreadRadius: 3, blurRadius: 5)
          ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(subject['icon'], size: 24,
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
            "Student Home Page!", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        actions: [
          TextButton(
            onPressed: () {
              // Action for "See all"
            },
            child: Text('See all', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
              subjects.length, (index) => buildSubjectCard(index)),
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