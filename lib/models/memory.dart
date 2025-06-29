class Memory {
  final String id;
  final String title;
  final String notes;
  final DateTime date;
  final List<String> media;
  final String? url;

  Memory({
    required this.id,
    required this.title,
    required this.notes,
    required this.date,
    required this.media,
    this.url,
  });

  factory Memory.fromJson(Map<String, dynamic> json) {
    return Memory(
      id: json['_id'],
      title: json['title'],
      notes: json['notes'],
      date: DateTime.parse(json['date']),
      media: List<String>.from(json['media']),
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'notes': notes,
      'date': date.toIso8601String(),
      'media': media,
    };
  }
}