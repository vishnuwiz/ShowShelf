import 'package:cloud_firestore/cloud_firestore.dart';

import 'cloud_store.dart';

/// Firestore implementation of [CloudStore], keyed by the signed-in user.
class FirestoreStore implements CloudStore {
  FirestoreStore(this.uid);

  final String uid;

  DocumentReference<Map<String, dynamic>> get _doc => FirebaseFirestore.instance.collection('users').doc(uid);

  @override
  Future<Map<String, dynamic>?> load() async => (await _doc.get()).data();

  @override
  Future<void> save(Map<String, dynamic> data) => _doc.set({...data, 'updatedAt': FieldValue.serverTimestamp()});
}
