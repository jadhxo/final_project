class User {
  String? firstName, lastName, email, password;
  bool? isTutor;
  List<String>? subjects;

  User(
      {this.firstName,
      this.lastName,
      this.email,
      this.password,
      this.isTutor,
      this.subjects});

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'isTutor': isTutor,
      'subjects': subjects,
    };
  }
}
