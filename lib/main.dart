import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: true,
        body: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('../assets/background.webp'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            LoginPage(),
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String? _email, _password;
  bool _keepLoggedIn = false;
  bool isStudent = true; // Initial value for toggle

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
                child: Column(
                  children: [
                    Image.asset(
                      '../assets/logo.png',
                      height: 100.0,
                    ),
                    Text(
                      'Login or Register',
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
                margin: EdgeInsets.only(top: 20.0),
                child: ToggleButtons(
                  borderColor: Colors.white,
                  fillColor: Colors.blue,
                  borderWidth: 2,
                  selectedBorderColor: Colors.white,
                  selectedColor: Colors.white,
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(30),
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text('Student', style: TextStyle(fontSize: 16)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text('Tutor', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                  onPressed: (int index) {
                    setState(() {
                      isStudent = index == 0;
                    });
                  },
                  isSelected: [isStudent, !isStudent],
                ),
              ),
              SizedBox(height: 40.0),
              TextFormField(
                style: TextStyle(color: Colors.white),
                validator: (input) => input == null || input.isEmpty ? 'Please type an email' : null,
                onSaved: (input) => _email = input,
                decoration: InputDecoration(
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
              SizedBox(height: 20.0),
              TextFormField(
                style: TextStyle(color: Colors.white),
                validator: (input) => input == null || input.length < 6 ? 'Password must be at least 6 characters' : null,
                onSaved: (input) => _password = input,
                decoration: InputDecoration(
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
                  Text(
                    'Keep me logged in',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      // Perform login logic here
                    }
                  },
                  child: Text('Login'),
                ),
              ),
              SizedBox(height: 20.0),
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
                    child: Text(
                      'Forgot password',
                      style: TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  Text(' | ', style: TextStyle(color: Colors.white)),
                  TextButton(
                    onPressed: () {
                      // TODO: Implement Create Account Functionality
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
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
    );
  }
}//akhmednasserr
