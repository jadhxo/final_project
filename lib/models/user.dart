class UserDB {
  String? uid, firstName, lastName, email, bio;
  bool? isTutor;
  List<dynamic>? subjects;

  UserDB(
      {this.uid,
        this.firstName,
      this.lastName,
      this.email,
        this.bio,
      this.isTutor,
      this.subjects});

  Map<String, dynamic> toMap() {
    String role = isTutor! ? 'tutor' : 'student';
    return {
      'uid': uid,
      'first name': firstName,
      'last name': lastName,
      'email': email,
      'bio': bio,
      'role': role,
      'subjects': subjects,
    };
  }
}
