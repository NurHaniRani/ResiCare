class News {
  final int? id;
  final String newsText;
  final String? newsDate;
  final String? newsTime;
  final int ownerId;

  News({
    this.id,
    required this.newsText,
    this.newsDate,
    this.newsTime,
    required this.ownerId,
  });

  factory News.fromMap(Map<String, dynamic> map) {
    return News(
      id: map['id'],
      newsText: map['newsText'],
      newsDate: map['newsDate'],
      newsTime: map['newsTime'],
      ownerId: map['ownerId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'newsText': newsText,
      'newsDate': newsDate,
      'newsTime': newsTime,
      'ownerId': ownerId,
    };
  }
}
