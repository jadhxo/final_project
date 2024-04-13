import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signUpUser(UserDB user, String password) async {
    UserCredential userAuth = await _auth.createUserWithEmailAndPassword(email: user.email!, password: password);
    user.uid = userAuth.user?.uid;
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<void> loginUser(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUserEmail(String newEmail) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await user.verifyBeforeUpdateEmail(newEmail);
        await _firestore.collection('users').doc(user.uid).update({
          'email': newEmail,
        });
      } on FirebaseAuthException catch (e) {
        print('Error updating email: ${e.message}');
        rethrow;
      }
    }
  }

  // In AuthService
  Future<Map<String, dynamic>> fetchUserByUid(String uid) async {
    try {
      String? id = await getDocumentIdByUid(uid);
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(id!).get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      } else {
        return {};
      }
    } catch (e) {
      print("Error fetching user data: $e");
      throw Exception('Failed to load user data');
    }
  }


  // AuthService class modification
  Stream<DocumentSnapshot> getUserStream(String userId) {
    return _firestore.collection('users').doc(userId).snapshots();
  }

  Stream<List<DocumentSnapshot>> getUser(String userId) {
    // This returns a stream of query snapshots
    return _firestore.collection('users')
        .where('uid', isEqualTo: userId)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs);
  }

  Future<String?> getDocumentIdByUid(String userId) async {
    try {
      var querySnapshot = await _firestore.collection('users')
          .where('uid', isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      } else {
        return null;
      }
    } catch (e) {
      print("Failed to fetch document ID: $e");
      return null;  // Return null in case of any errors
    }
  }



}
