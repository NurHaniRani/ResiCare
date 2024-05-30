class Hall {
  int? id; // Make id nullable
  String name;
  String status;

  Hall({
    this.id,
    required this.name,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'status': status,
    };
  }

  factory Hall.fromMap(Map<String, dynamic> map) {
    return Hall(
      id: map['id'],
      name: map['name'],
      status: map['status'],
    );
  }
}
