class TeacherModel {
  String name;
  String coursetitle;
  String createdAt;
  String phoneNumber;
  String uid;

  TeacherModel({
    required this.name,
    required this.coursetitle,
    required this.createdAt,
    required this.phoneNumber,
    required this.uid,
  });

// from server
  factory TeacherModel.fromMap(Map<String, dynamic> map) {
    return TeacherModel(
      name: map['name'] ?? '',
      coursetitle: map['coursetitle'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      createdAt: map['createdAt'] ?? '',
      uid: map['uid'] ?? '',
    );
  }

  // to server
  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "coursetitle": coursetitle,
      "phoneNumber": phoneNumber,
      "uid": uid,
      "createdAt": createdAt,
    };
  }
}
