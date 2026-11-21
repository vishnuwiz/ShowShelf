import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'cloud_store.dart';

/// Firestore implementation of [CloudStore], keyed by the signed-in user.
class FirestoreStore implements CloudStore {
  FirestoreStore(this.uid);

  final String uid;

  DocumentReference<Map<String, dynamic>> get _doc => FirebaseFirestore.instance.collection('users').doc(uid);

  /// Signs in anonymously and reuses the saved sign-in on later launches.
  /// Returns null when sign-in fails (for example offline on the very first
  /// launch), so the app keeps working locally and tries again next time.
  static Future<FirestoreStore?> connect() async {
    try {
      final auth = FirebaseAuth.instance;
      final user = auth.currentUser ?? (await auth.signInAnonymously()).user;
      return user == null ? null : FirestoreStore(user.uid);
    } catch (e) {
      debugPrint('ShowShelf: cloud sign-in failed: $e');
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>?> load() async => (await _doc.get()).data();

  @override
  Future<void> save(Map<String, dynamic> data) => _doc.set({...data, 'updatedAt': FieldValue.serverTimestamp()});
}
