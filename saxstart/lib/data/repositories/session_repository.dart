import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/firestore_service.dart';
import '../models/practice_session_model.dart';
import '../models/drill_result_model.dart';
import 'user_repository.dart';

class SessionRepository {
  final FirestoreService _firestore;

  SessionRepository(this._firestore);

  Future<void> saveSession(String uid, PracticeSessionModel session) async {
    await _firestore.saveSession(uid, session);
  }

  Future<void> saveDrillResult(String uid, DrillResultModel result) async {
    await _firestore.saveDrillResult(uid, result);
  }

  Future<List<DrillResultModel>> getDrillScores(String uid) async {
    return _firestore.getDrillScores(uid);
  }
}

final sessionRepositoryProvider = Provider<SessionRepository>(
  (ref) => SessionRepository(ref.read(firestoreServiceProvider)),
);
