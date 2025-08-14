class Note {
  final int? id;
  final String title;
  final String content;
  final DateTime createdTime;

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.createdTime,
  });

  // Notu Map'e çevir (veritabanı için)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdTime': createdTime.toIso8601String(),
    };
  }

  // Map'ten Note nesnesi üret
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      createdTime: DateTime.parse(map['createdTime']),
    );
  }

  Note copyWith({
  int? id,
  String? title,
  String? content,
  DateTime? createdTime,
}) {
  return Note(
    id: id ?? this.id,
    title: title ?? this.title,
    content: content ?? this.content,
    createdTime: createdTime ?? this.createdTime,
  );
}


}
