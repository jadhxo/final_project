import 'package:final_project/pages/loading.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/edit_profile.dart';
import 'pages/student_home.dart';
import 'pages/tutor_home.dart';
import 'pages/profile.dart';
import 'pages/login.dart';
import 'pages/sign_up.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const Loading());
      case '/login':
        return MaterialPageRoute(builder: (_) => const Login());
      case '/signup':
        return MaterialPageRoute(builder: (_) => const SignUp());
      case '/student':
        return MaterialPageRoute(builder: (_) => const StudentHome());
      case '/tutor':
        return MaterialPageRoute(builder: (_) => const TutorHome());
      case '/profile':
        final args = settings.arguments as Map<String, dynamic>?; // Safely handle arguments
        if (args != null && args.containsKey('userId')) {
          return MaterialPageRoute(
            builder: (_) => Profile(userId: args['userId']),
          );
        } else {
          return MaterialPageRoute(builder: (_) => const Scaffold(body: Center(child: Text('User ID not provided'))));
        }
      case '/edit':
        final args = settings.arguments as Map<String, dynamic>?; // Safely handle arguments
        return MaterialPageRoute(
          builder: (_) => EditProfilePage(user: args ?? {}), // Pass arguments to EditProfilePage
        );
      default:
      // It's generally a good idea to handle undefined routes
        return MaterialPageRoute(builder: (_) => const Scaffold(body: Center(child: Text('Page not found'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Final Project',
      initialRoute: '/',
      onGenerateRoute: generateRoute,
    );
  }
}
