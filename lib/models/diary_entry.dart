import 'package:cloud_firestore/cloud_firestore.dart';

class DiaryEntry {
  final String id;
  final String title;
  final String content;
  final String mood;
  final List<String> tags;
  final bool isFavorite;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DiaryEntry({
    this.id = '',
    required this.title,
    required this.content,
    required this.mood,
    this.tags = const [],
    this.isFavorite = false,
    this.createdAt,
    this.updatedAt,
  });

  factory DiaryEntry.fromFirestore(
    DocumentSnapshot snapshot,
    SnapshotOptions? options,
  ) {
    final data = (snapshot.data() as Map<String, dynamic>?) ?? {};
    return DiaryEntry(
      id: snapshot.id,
      title: data['title'] ?? 'Untitled',
      content: data['content'] ?? '',
      mood: data['mood'] ?? '😊',
      tags: List<String>.from(data['tags'] ?? []),
      isFavorite: data['isFavorite'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'title': title,
      'content': content,
      'mood': mood,
      'tags': tags,
      'isFavorite': isFavorite,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'title': title,
      'content': content,
      'mood': mood,
      'tags': tags,
      'isFavorite': isFavorite,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}