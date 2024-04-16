import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/pages/AuthService.dart';
import 'package:final_project/pages/DBService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'NavigationBar.dart';
import 'SessionCard.dart';

class StudentHome extends StatefulWidget {
  const StudentHome({Key? key}) : super(key: key);

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DBService dbService = DBService();
  AuthService authService = AuthService();
  var user;
  var initTutors = false;
  String? docId;
  int _selectedSubjectIndex = 0;
  int _selectedBottomNavIndex = 0;
  List<Map<String, dynamic>> subjects = [];
  List<Map<String, dynamic>> tutors = [];
  List<Map<String, dynamic>> filteredTutors = [];
  List<Map<String, dynamic>> sessions = [];
  StreamSubscription? sessionsStreamSubscription;

  @override
  void initState() {
    super.initState();
    fetchUser();
    fetchSubjects();
    fetchTutors();
    listenToSessions();
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
    print(user);
    if (_auth.currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/login');
      });
      return const Scaffold();
    }

    if (user == null || tutors.isEmpty && !initTutors) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Welcome ${user?['first name']}!",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: _selectedBottomNavIndex == 1 ? calendarBody() : homeBody(),
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

  Widget homeBody() {
    return SingleChildScrollView(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          children: [
            Wrap(
                direction: Axis.horizontal,
                children:
                List.generate(subjects.length, buildSubjectCard)
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.0,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: filteredTutors.length,
              itemBuilder: (context, index) {
                return buildTutorCard(filteredTutors[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget calendarBody() {
    return Container(
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
                final tutorName = session['tutorName'] as String;
                final date = DateFormat.yMMMd().add_jm().format(
                    DateTime.fromMillisecondsSinceEpoch(
                        (session['date'] as Timestamp).millisecondsSinceEpoch
                    )
                );

                return SessionCard(
                    subject: subject,
                    name: tutorName,
                    date: date,
                    role: 'student'
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
    );
  }


  void fetchUser() async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(_auth.currentUser?.uid).get();
    user = doc.data();
  }

  Future<void> fetchTutors() async {
    QuerySnapshot col = await _firestore.collection('users').get();
    List<Map<String, dynamic>> fetchedTutors = [];
    for (var doc in col.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      if (data['role'] == 'tutor') {
        fetchedTutors.add(data);
      }
    }
    setState(() {
      tutors = fetchedTutors;
      filteredTutors = tutors;
      initTutors = true;
    });
  }

  Future<void> fetchSubjects() async {
    try {
      QuerySnapshot subjectSnapshot =
          await _firestore.collection('subjects').get();
      List<Map<String, dynamic>> fetchedSubjects = [{'title': 'All', 'icon': IconData(int.parse('e5f9', radix: 16), fontFamily: 'MaterialIcons')}];
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
          initTutors = true;
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
          print("Selected");
          _selectedSubjectIndex = index;
          print(index);
          filterTutorsBySubject(subjects[index]['title']);
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
                size: 24, color: isSelected ? Colors.blue : Colors.grey),
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

  Widget buildTutorCard(Map<String, dynamic> tutor) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage('assets/profile.webp'),
              backgroundColor: Colors.blue,
            ),
          ),
          Text(
            "${tutor['first name']} ${tutor['last name']}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(tutor['subjects'].join(', ') ?? 'No Specialization'),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () => showRegistrationDialog(tutor),
              child: const Text(
                "Register",
                style: TextStyle(color: Colors.white),
              ))
        ],
      ),
    );
  }

  void filterTutorsBySubject(String subject) {
    if (subject == 'All') {
      setState(() {
        filteredTutors = tutors;
      });
      return;
    }
    List<Map<String, dynamic>> currentTutors = [];
    for (Map<String, dynamic> tutor in tutors) {
      if (tutor['subjects'].contains(subject)) {
        currentTutors.add(tutor);
      }
    }
    print(filteredTutors);
    setState(() {
      filteredTutors = currentTutors;
    });
  }

  void showRegistrationDialog(Map<String, dynamic> tutor) {
    List<DropdownMenuItem<String>> subjects = [];
    for (String subject in tutor['subjects']) {
      subjects.add(DropdownMenuItem(
        value: subject,
        child: Text(subject, style: const TextStyle(fontSize: 14)),
      ));
    }
    showDialog(
        context: context,
        builder: (BuildContext context) {
          String? selectedSubject =
              subjects.isNotEmpty ? subjects[0].value : null;
          DateTime? selectedDate;
          TimeOfDay? selectedTime;
          bool showError = false;
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text("Register"),
              contentPadding: const EdgeInsets.all(10),
              content: Container(
                padding: const EdgeInsets.all(12),
                child: SingleChildScrollView(
                  child: ListBody(
                    children: [
                      const Text("Subject"),
                      DropdownButton<String>(
                        value: selectedSubject,
                        items: subjects,
                        onChanged: (String? value) {
                          setState(() {
                            selectedSubject = value;
                          });
                        },
                        isExpanded: true,
                        iconSize: 24,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.date_range),
                            onPressed: () async {
                              final DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2029),
                              );
                              if (pickedDate != null &&
                                  pickedDate != selectedDate) {
                                setState(() {
                                  selectedDate = pickedDate;
                                });
                              }
                            },
                          ),
                          if (selectedDate != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                  "Selected Date: ${selectedDate?.toIso8601String().substring(0, 10)}"),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.timer),
                            onPressed: () async {
                              final TimeOfDay? pickedTime =
                                  await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (pickedTime != null &&
                                  pickedTime != selectedTime) {
                                setState(() {
                                  selectedTime = pickedTime;
                                });
                              }
                            },
                          ),
                          if (selectedTime != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                  "Selected Time: ${selectedTime?.format(context)}"),
                            ),
                        ],
                      ),
                      if (showError)
                        const SizedBox(
                          height: 15,
                        ),
                      if (showError)
                        const Text(
                          "Please pick a date and time.",
                          style: TextStyle(color: Colors.red),
                        )
                    ],
                  ),
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => {
                    if (selectedTime == null || selectedDate == null)
                      {
                        setState(() {
                          showError = true;
                        })
                      }
                    else
                      {
                        setState(() {
                          showError = false;
                          register(selectedSubject!, selectedDate!, selectedTime!, tutor);
                        })
                      }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      )),
                  child: const Text(
                    "Confirm",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            );
          });
        });
  }

  void register(String subject, DateTime date, TimeOfDay time, Map<String, dynamic> tutor) async {
    try {
      DateTime dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      String? uid = _auth.currentUser?.uid;

      await dbService.bookSession(subject, dateTime, uid!, tutor['uid']);
      bookingResult(true);
    } catch (e) {
      bookingResult(false);
      print(e);
    }
  }

  void bookingResult(bool succeeded) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(succeeded ? Icons.check_circle : Icons.error, color: succeeded ? Colors.green : Colors.red),
              const SizedBox(width: 10),
              Text(succeeded ? "Successfully booked session!" : "Error occurred while trying to book session."),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

}
