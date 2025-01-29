class StudentUser {
  final String uid;
  final String email;
  final String index;
  final String password;

  StudentUser({
    required this.uid,
    required this.email,
    required this.index,
    required this.password,
  });

  // Add this method to convert the object to a JSON map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'index': index,
      // Be cautious about storing passwords
    };
  }

  // Optionally, add a fromJson factory constructor for reading from Firestore
  factory StudentUser.fromJson(Map<String, dynamic> json) {
    return StudentUser(
      uid: json['uid'],
      email: json['email'],
      index: json['index'],
      password: '', // Be careful with password handling
    );
  }
}