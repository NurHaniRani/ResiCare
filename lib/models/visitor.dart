class Visitor {
  final int? id; // Make id nullable

  final String name;
  final String phoneNumber;
  final String dateArrive;
  String? timeArrive; // Make timeArrive nullable
  String? dateDepart; // Make dateDepart nullable
  String? timeDepart; // Make timeDepart nullable
  final int residentId;

  Visitor({
    this.id,
    required this.name,
    required this.phoneNumber,
    required this.dateArrive,
    this.timeArrive,
    this.dateDepart,
    this.timeDepart,
    required this.residentId,
  });

  // Add factory constructor to convert from Map
  factory Visitor.fromMap(Map<String, dynamic> map) {
    return Visitor(
      id: map['id'],
      name: map['name'],
      phoneNumber: map['phoneNumber'],
      dateArrive: map['dateArrive'],
      timeArrive: map['timeArrive'],
      dateDepart: map['dateDepart'],
      timeDepart: map['timeDepart'],
      residentId: map['residentId'],
    );
  }

  // Add a method to convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'dateArrive': dateArrive,
      'timeArrive': timeArrive,
      'dateDepart': dateDepart,
      'timeDepart': timeDepart,
      'residentId': residentId,
    };
  }
}
