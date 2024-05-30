class Reserve {
  int? id;
  int hallId;
  int ownerId;
  String dateReserved;
  String reason;
  String status;

  Reserve({
    this.id,
    required this.hallId,
    required this.ownerId,
    required this.dateReserved,
    required this.reason,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hallId': hallId,
      'ownerId': ownerId,
      'dateReserved': dateReserved,
      'reason': reason,
      'status': status,
    };
  }

  factory Reserve.fromMap(Map<String, dynamic> map) {
    return Reserve(
      id: map['id'],
      hallId: map['hallId'],
      ownerId: map['ownerId'],
      dateReserved: map['dateReserved'],
      reason: map['reason'],
      status: map['status'],
    );
  }
}
