import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StudentHome extends StatefulWidget {
  const StudentHome({super.key});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Example list of subjects, replace with your actual data
  final List<Map<String, dynamic>> subjects = [
    {
      'title': 'Maths',
      'color': Colors.orange,
      'icon': Icons.calculate, // replace with your own icons
    },
    {
      'title': 'Science',
      'color': Colors.lightBlue,
      'icon': Icons.science, // replace with your own icons
    },
    {
      'title': 'English',
      'color': Colors.purple,
      'icon': Icons.menu_book, // replace with your own icons
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

  Widget buildSubjectCard(Map<String, dynamic> subject) {
    return Card(
      color: subject['color'],
      child: Container(
        width: 120,
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(subject['icon'], size: 40),
            SizedBox(height: 10),
            Text(subject['title']),
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

    return DefaultTabController(
      length: 3, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Student Home Page!",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
          bottom: TabBar(
            tabs: [
              Tab(text: 'All'),
              Tab(icon: Icon(Icons.near_me), text: 'Nearby'),
              Tab(icon: Icon(Icons.star), text: 'Popular'),
            ],
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text(_auth.currentUser?.displayName ?? 'Student Name'),
                accountEmail: Text(_auth.currentUser?.email ?? 'student@example.com'),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: _auth.currentUser?.photoURL != null
                      ? NetworkImage(_auth.currentUser!.photoURL!)
                      : AssetImage('assets/default_image.png') as ImageProvider,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
              ),
              ListTile(
                leading: Icon(Icons.home),
                title: Text('Home'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Logout'),
                onTap: signOut,
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Column(
              children: [
                SizedBox(
                  height: 120, // Adjust the height to fit your design
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: subjects.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: EdgeInsets.all(8.0),
                        child: buildSubjectCard(subjects[index]),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: Center(child: Text('')),
                ),
              ],
            ),
            Center(child: Text('Nearby Tab Content')),
            Center(child: Text('Popular Tab Content')),
          ],
        ),
      ),
    );
  }
}
