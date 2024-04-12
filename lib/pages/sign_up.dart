import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  bool isStudent = true;
  static List<MultiSelectItem<String>> _items = [
    MultiSelectItem("math", "Mathematics"),
    MultiSelectItem("physics", "Physics"),
    MultiSelectItem("chemistry", "Chemistry"),
    MultiSelectItem("biology", "Biology"),
    MultiSelectItem("test", "Test")
  ];
  List<dynamic> _selectedSubjects = [];
  String? _first_name, _last_name, _email, _password, _password_conf;
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
            child: Column(
              children: [
                const SizedBox(height: 130),
                Image.asset(
                  'assets/logo.png',
                  width: 100,
                ),
                const Text(
                  'Sign Up',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
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
                    color: Colors.grey[300],
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
                        child: Text('Student', style: TextStyle(fontSize: 16)),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: Text('Tutor', style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40.0),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                // First Expanded
                                child: TextFormField(
                                  style: const TextStyle(color: Colors.white),
                                  validator: (input) =>
                                      input == null || input.isEmpty
                                          ? 'Enter first name'
                                          : null,
                                  onSaved: (input) => _first_name = input,
                                  decoration: const InputDecoration(
                                    labelText: 'First Name',
                                    labelStyle: TextStyle(color: Colors.white),
                                    prefixIcon: Icon(Icons.person,
                                        color: Colors
                                            .white), // Changed to person icon
                                    enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                  width:
                                      10), // Space between the TextFormFields
                              Expanded(
                                // Second Expanded
                                child: TextFormField(
                                  style: const TextStyle(color: Colors.white),
                                  validator: (input) =>
                                      input == null || input.isEmpty
                                          ? 'Enter last name'
                                          : null,
                                  onSaved: (input) => _last_name = input,
                                  decoration: const InputDecoration(
                                    labelText: 'Last Name',
                                    labelStyle: TextStyle(color: Colors.white),
                                    prefixIcon: Icon(Icons.person_outline,
                                        color: Colors
                                            .white), // Changed to person_outline icon
                                    enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            style: const TextStyle(color: Colors.white),
                            validator: (input) => input == null || input.isEmpty
                                ? 'Enter email'
                                : null,
                            onSaved: (input) => _email = input,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(color: Colors.white),
                              prefixIcon: Icon(Icons.email,
                                  color: Colors
                                      .white), // Changed to person_outline icon
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            style: const TextStyle(color: Colors.white),
                            validator: (input) => input == null || input.isEmpty
                                ? 'Password must at least 6 characters'
                                : null,
                            onSaved: (input) => _password = input,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              labelStyle: TextStyle(color: Colors.white),
                              prefixIcon: Icon(Icons.lock,
                                  color: Colors
                                      .white), // Changed to person_outline icon
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            style: const TextStyle(color: Colors.white),
                            onSaved: (input) => _password_conf = input,
                            decoration: const InputDecoration(
                              labelText: 'Confirm Password',
                              labelStyle: TextStyle(color: Colors.white),
                              prefixIcon: Icon(Icons.lock_outline,
                                  color: Colors
                                      .white), // Changed to person_outline icon
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (!isStudent)
                            MultiSelectDialogField(
                              items: _items,
                              title: const Text("Subjects"),
                              dialogHeight: 300,
                              selectedColor: Colors.blue,
                              decoration: BoxDecoration(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(4)),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1,
                                ),
                              ),
                              chipDisplay: MultiSelectChipDisplay(
                                  chipColor: Colors.blue,
                                  textStyle:
                                      const TextStyle(color: Colors.white)),
                              buttonIcon: const Icon(
                                Icons.arrow_downward,
                                color: Colors.white,
                              ),
                              buttonText: const Text(
                                "Select Subjects",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              onConfirm: (results) {
                                _selectedSubjects = results;
                              },
                            ),
                          const SizedBox(height: 20.0),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                // TODO implement signUp
                                print("First Name: $_first_name");
                                print("Last Name: $_last_name");
                                print("Email: $_email");
                                print("Password: $_password");
                                print("Subjects: $_selectedSubjects");
                              }
                            },
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      )),
                ),
                TextButton(
                    onPressed: () =>
                        {Navigator.pushReplacementNamed(context, '/login')},
                    child: const Text(
                      'Already have an account? Login',
                      style: TextStyle(color: Colors.white),
                    ))
              ],
            ),
          )
        ],
      ),
    );
  }
}
