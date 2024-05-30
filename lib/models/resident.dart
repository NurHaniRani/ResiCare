class Resident {
  final int? id; // nullable because it's auto-incremented and won't be set until inserted into the database
  final String name;
  final String phoneNumber;
  final String email;
  final String password;
  final String unitNumber;
  final String userType;
  String? imageUrl; // nullable imageUrl

  Resident({
    this.id,
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.password,
    required this.unitNumber,
    required this.userType,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id, // id will be null if not set (e.g., when inserting)
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'password': password,
      'unitNumber': unitNumber,
      'userType': userType,
      'imageUrl': imageUrl,
    };
  }

  // Named constructor to create a Resident object from a map
  Resident.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'],
        phoneNumber = map['phoneNumber'],
        email = map['email'],
        password = map['password'],
        unitNumber = map['unitNumber'],
        userType = map['userType'],
        imageUrl = map['imageUrl'];
}
