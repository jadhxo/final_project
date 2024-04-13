import 'package:final_project/pages/AuthService.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> user;

  EditProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _first_nameController;
  late TextEditingController _last_nameController;
  late TextEditingController _bioController;

  AuthService authService = AuthService();
  List<String> _selectedSubjects = [];
  final List<MultiSelectItem<String>> _items = [
    MultiSelectItem("math", "Mathematics"),
    MultiSelectItem("physics", "Physics"),
    MultiSelectItem("chemistry", "Chemistry"),
    MultiSelectItem("biology", "Biology"),
    // Add more subjects as needed
  ];

  @override
  void initState() {
    super.initState();
    _first_nameController =
        TextEditingController(text: '${widget.user['first name']}');
    _last_nameController =
        TextEditingController(text: '${widget.user['last name']}');
    _bioController = TextEditingController(text: widget.user['bio']);
    _selectedSubjects = List<String>.from(widget.user['subjects'] ?? []);
  }

  @override
  void dispose() {
    _first_nameController.dispose();
    _last_nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _updateProfile() async {
    String? id = await AuthService().getDocumentIdByUid(widget.user['uid']);
    if (_formKey.currentState!.validate()) {
      FirebaseFirestore.instance.collection('users').doc(id!).update({
        'first name': _first_nameController.text,
        'last name': _last_nameController.text,
        'bio': _bioController.text,
        'subjects': _selectedSubjects,
      }).then((_) {
        Navigator.pop(context);
      }).catchError((error) {
        print('Error updating profile: $error');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title:
            const Text('Edit Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.webp'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: <Widget>[
                TextFormField(
                  controller: _first_nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _last_nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your last name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _bioController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Bio',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (widget.user['role'] == 'tutor') MultiSelectDialogField(
                  items: _items,
                  initialValue: _selectedSubjects,
                  title: const Text("Subjects"),
                  selectedColor: Colors.blue,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    border: Border.all(
                      color: Colors.white,
                      width: 1,
                    ),
                  ),
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
                    _selectedSubjects = List<String>.from(results);
                  },
                ),
                const SizedBox(
                  height: 24,
                ),
                ElevatedButton(
                  onPressed: _updateProfile,
                  child: const Text('Save Changes',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors
                        .blue, // Deprecated, use `backgroundColor` instead
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
