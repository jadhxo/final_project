import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DBService {

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> insertNotificationTo(String userId, String notificationText) async {
    await firestore.collection('users').doc(userId).collection('notifications').add({
      'text': notificationText,
      'read': false,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> bookSession(String subject, DateTime dateTime, String studentId, String tutorId) async {
    try {
      var firestore = FirebaseFirestore.instance;

      var studentDoc = await firestore.collection('users').doc(studentId).get();
      var tutorDoc = await firestore.collection('users').doc(tutorId).get();

      String studentName = '${studentDoc.data()?['first name'] ?? ''} ${studentDoc.data()?['last name'] ?? ''}'.trim();
      String tutorName = '${tutorDoc.data()?['first name'] ?? ''} ${tutorDoc.data()?['last name'] ?? ''}'.trim();

      Timestamp timestamp = Timestamp.fromDate(dateTime);
      String formattedDateTime = formatTimestamp(timestamp);

      await firestore.collection('users').doc(studentId).collection('sessions').add({
        'subject': subject,
        'date': timestamp,
        'tutor': tutorId,
        'tutorName': tutorName
      });

      await firestore.collection('users').doc(tutorId).collection('sessions').add({
        'subject': subject,
        'date': timestamp,
        'student': studentId,
        'studentName': studentName
      });

      await insertNotificationTo(studentId, "Successfully booked a session with $tutorName for $subject on $formattedDateTime.");
      await insertNotificationTo(tutorId, "$studentName booked a session with you for $subject on $formattedDateTime.");
    } catch (e) {
      rethrow;
    }
  }


  String formatTimestamp(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    DateFormat formatter = DateFormat('MMMM d, y \'at\' h:mm a');
    return formatter.format(date);
  }

  Future<List<Map<String, dynamic>>> fetchSessions(String uid) async {
    try {
      List<Map<String, dynamic>> sessions = [];
      CollectionReference collection = firestore.collection('users').doc(uid).collection('sessions');
      QuerySnapshot querySnapshot = await collection.get();
      for (var doc in querySnapshot.docs) {
        sessions.add(doc.data() as Map<String, dynamic>);
      }

      sessions.sort((a, b) {
        Timestamp aTimestamp = a['date'] as Timestamp;
        Timestamp bTimestamp = b['date'] as Timestamp;
        return aTimestamp.compareTo(bTimestamp);
      });

      return sessions;
    } catch (e) {
      print(e);
      return [];
    }
  }

}
