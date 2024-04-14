import 'dart:async';

import 'package:final_project/pages/AuthService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  AuthService authService = AuthService();
  String error = "";
  String? _email, _password;
  bool _keepLoggedIn = false;
  bool isStudent = true;

  Future login() async {
    try {
      String role = isStudent ? 'student' : 'tutor';
      await authService.loginUser(_email!, _password!, role);
      String route = isStudent ? '/student' : '/tutor';
      Navigator.pushReplacementNamed(context, route);
    } catch (e) {
      setState(() {
        error = "Incorrect email/password";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.webp'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.1),
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/logo.png',
                            height: 100.0,
                          ),
                          const Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(top: 20.0),
                      child: ToggleButtons(
                        borderColor: Colors.white,
                        fillColor: Colors.blue,
                        borderWidth: 2,
                        selectedBorderColor: Colors.white,
                        selectedColor: Colors.white,
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(30),
                        onPressed: (int index) {
                          setState(() {
                            isStudent = index == 0;
                          });
                        },
                        isSelected: [isStudent, !isStudent],
                        children: const <Widget>[
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 32),
                            child:
                                Text('Student', style: TextStyle(fontSize: 16)),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 32),
                            child:
                                Text('Tutor', style: TextStyle(fontSize: 16)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40.0),
                    TextFormField(
                      style: const TextStyle(color: Colors.white),
                      validator: (input) => input == null || input.isEmpty
                          ? 'Please type an email'
                          : null,
                      onSaved: (input) => _email = input,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.white),
                        prefixIcon: Icon(Icons.email, color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    TextFormField(
                      style: const TextStyle(color: Colors.white),
                      validator: (input) => input == null || input.length < 6
                          ? 'Password must be at least 6 characters'
                          : null,
                      onSaved: (input) => _password = input,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Colors.white),
                        prefixIcon: Icon(Icons.lock, color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      obscureText: true,
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: _keepLoggedIn,
                          onChanged: (bool? value) {
                            setState(() {
                              _keepLoggedIn = value ?? false;
                            });
                          },
                          checkColor: Colors.white,
                          activeColor: Colors.blue,
                        ),
                        const Text(
                          'Keep me logged in',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            login();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue),
                        child: const Text(
                          'Login',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    Center(
                        child: Text(
                      error,
                      style: TextStyle(color: Colors.red),
                    )),
                    const SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        TextButton(
                          onPressed: () {
                            // TODO: Implement Forgot Password Functionality
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Forgot password',
                            style: TextStyle(
                              color: Colors.white,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        const Text(' | ',
                            style: TextStyle(color: Colors.white)),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/signup');
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Create Account',
                            style: TextStyle(
                              color: Colors.white,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
