import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final String themePreference;
  final DateTime? createdAt;

  UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    this.themePreference = 'indigo',
    this.createdAt,
  });

  factory UserProfile.fromFirestore(
    DocumentSnapshot snapshot,
    SnapshotOptions? options,
  ) {
    final data = (snapshot.data() as Map<String, dynamic>?) ?? {};
    return UserProfile(
      uid: snapshot.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      themePreference: data['themePreference'] ?? 'indigo',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'themePreference': themePreference,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}