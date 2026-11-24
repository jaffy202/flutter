import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/diary_entry.dart';
import '../models/user_profile.dart';

class DiaryRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw StateError('No authenticated user');
    return user.uid;
  }

  DocumentReference<UserProfile> get _userDoc => _db
      .collection('users')
      .doc(_uid)
      .withConverter<UserProfile>(
        fromFirestore: UserProfile.fromFirestore,
        toFirestore: (profile, _) => profile.toFirestore(),
      );

  CollectionReference<DiaryEntry> get _entriesCol => _db
      .collection('users')
      .doc(_uid)
      .collection('entries')
      .withConverter<DiaryEntry>(
        fromFirestore: DiaryEntry.fromFirestore,
        toFirestore: (entry, _) => entry.toCreateMap(),
      );

  /// Create or initialize user profile upon sign-up
  Future<void> createUserProfile(User user, {String? displayName}) async {
    final profile = UserProfile(
      uid: user.uid,
      email: user.email ?? '',
      displayName: displayName ?? user.email?.split('@').first ?? 'Writer',
    );
    await _userDoc.set(profile, SetOptions(merge: true));
  }

  /// Real-time stream of entries sorted newest first
  Stream<List<DiaryEntry>> watchEntries({
    String? moodFilter,
    bool favoritesOnly = false,
  }) {
    Query<DiaryEntry> query = _entriesCol.orderBy('createdAt', descending: true);

    if (moodFilter != null) {
      query = query.where('mood', isEqualTo: moodFilter);
    }
    if (favoritesOnly) {
      query = query.where('isFavorite', isEqualTo: true);
    }

    return query.snapshots().map(
          (snap) => snap.docs.map((doc) => doc.data()).toList(),
        );
  }

  /// Create a new diary entry
  Future<void> addEntry(DiaryEntry entry) async {
    await _db
        .collection('users')
        .doc(_uid)
        .collection('entries')
        .add(entry.toCreateMap());
  }

  /// Update an existing diary entry without altering createdAt
  Future<void> updateEntry(DiaryEntry entry) async {
    await _db
        .collection('users')
        .doc(_uid)
        .collection('entries')
        .doc(entry.id)
        .update(entry.toUpdateMap());
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(String entryId, bool currentValue) async {
    await _db
        .collection('users')
        .doc(_uid)
        .collection('entries')
        .doc(entryId)
        .update({
      'isFavorite': !currentValue,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete an entry
  Future<void> deleteEntry(String entryId) async {
    await _entriesCol.doc(entryId).delete();
  }
}
