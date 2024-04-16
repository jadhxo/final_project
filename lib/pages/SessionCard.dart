import 'package:flutter/material.dart';

class SessionCard extends StatelessWidget {
  final String subject;
  final String name;
  final String date;
  final String role;

  const SessionCard({
    Key? key,
    required this.subject,
    required this.name,
    required this.date,
    required this.role,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              subject,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '${role == 'tutor' ? 'Student:' : 'Tutor'} $name',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Date: $date',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
