class Complaint {
  int? id; // id can be null
  String complaintText;
  String status;
  String category;
  int userId;

  Complaint({
    this.id,
    required this.complaintText,
    required this.status,
    required this.category,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'complaintText': complaintText,
      'status': status,
      'category': category,
      'userId': userId,
    };
  }

  factory Complaint.fromMap(Map<String, dynamic> map) {
    return Complaint(
      id: map['id'],
      complaintText: map['complaintText'],
      status: map['status'],
      category: map['category'],
      userId: map['userId'],
    );
  }
}

