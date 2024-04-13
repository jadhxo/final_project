import 'package:final_project/pages/AuthService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_auth.currentUser != null) {
        fetchUserDataAndNavigate();
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }


  Future<void> fetchUserDataAndNavigate() async {
    try {
      User user = _auth.currentUser!;
      var userDocument = await authService.fetchUserByUid(user.uid);
      if (userDocument.isNotEmpty) {
        String role = userDocument['role'];
        String route = role == 'tutor' ? '/tutor' : '/student';
        Navigator.pushReplacementNamed(context, route);
      } else {
        print("User not found in database");
        // Optionally handle user not found, e.g., log out or redirect to a sign-up page
      }
    } catch (e) {
      print("Error fetching user data: $e");
      // Handle errors, such as network issues
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
