import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/user_model.dart';
import '../../data/models/progress_model.dart';
import '../../data/models/practice_session_model.dart';
import '../../data/models/drill_result_model.dart';

/// Cloud Firestore service. Uses the schema defined in 04_DATABASE_SCHEMA.md.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // User operations -----------------------------------------------------------
  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection('users').doc(uid);

  Future<void> createUser(UserModel user) async {
    await _userDoc(user.id).set(user.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    final snap = await _userDoc(uid).get();
    if (!snap.exists) return null;
    final data = snap.data();
    if (data == null) return null;
    return UserModel.fromMap({...data, 'id': uid});
  }

  Future<void> updateUser(UserModel user) async {
    await _userDoc(user.id).update(user.toMap());
  }

  Stream<UserModel?> watchUser(String uid) {
    return _userDoc(uid).snapshots().map((snap) {
      if (!snap.exists) return null;
      final data = snap.data();
      if (data == null) return null;
      return UserModel.fromMap({...data, 'id': uid});
    });
  }

  // Progress operations -------------------------------------------------------
  DocumentReference<Map<String, dynamic>> _progressDoc(String uid) =>
      _userDoc(uid).collection('progress').doc('summary');

  Future<void> updateProgress(String uid, ProgressModel progress) async {
    await _progressDoc(uid).set(progress.toMap());
  }

  Future<ProgressModel?> getProgress(String uid) async {
    final snap = await _progressDoc(uid).get();
    if (!snap.exists) return null;
    final data = snap.data();
    if (data == null) return null;
    return ProgressModel.fromMap(data);
  }

  Stream<ProgressModel?> watchProgress(String uid) {
    return _progressDoc(uid).snapshots().map((snap) {
      if (!snap.exists) return null;
      final data = snap.data();
      if (data == null) return null;
      return ProgressModel.fromMap(data);
    });
  }

  // Session operations --------------------------------------------------------
  Future<void> saveSession(String uid, PracticeSessionModel session) async {
    await _userDoc(uid)
        .collection('sessions')
        .doc(session.id)
        .set(session.toMap());
  }

  // Drill score operations ----------------------------------------------------
  Future<void> saveDrillResult(String uid, DrillResultModel result) async {
    await _userDoc(uid).collection('drill_scores').add(result.toMap());
  }

  Future<List<DrillResultModel>> getDrillScores(String uid,
      {int limit = 50}) async {
    final snap = await _userDoc(uid)
        .collection('drill_scores')
        .orderBy('attemptedAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs
        .map((d) => DrillResultModel.fromMap(d.data()))
        .toList();
  }
}
