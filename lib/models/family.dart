class Family {
  final int? id;
  final String name;
  final String phoneNumber;
  final String category;
  final int userId; // ID of the user this family belongs to

  Family({
    this.id,
    required this.name,
    required this.phoneNumber,
    required this.category,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'category': category,
      'residentId': userId,
    };
  }

  // Named constructor to create a Family object from a map
  Family.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'],
        phoneNumber = map['phoneNumber'],
        category = map['category'],
        userId = map['residentId'];
}

