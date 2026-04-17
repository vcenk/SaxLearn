import '../../data/models/user_model.dart';
import '../../data/models/progress_model.dart';
import '../../data/models/practice_session_model.dart';
import '../../data/models/drill_result_model.dart';

/// Firestore service abstraction
/// TODO: Replace with real Cloud Firestore when Firebase is configured
class FirestoreService {
  // In-memory storage for development
  final Map<String, Map<String, dynamic>> _users = {};
  final Map<String, Map<String, dynamic>> _progress = {};
  final Map<String, List<Map<String, dynamic>>> _sessions = {};
  final Map<String, List<Map<String, dynamic>>> _drillScores = {};

  // User operations
  Future<void> createUser(UserModel user) async {
    _users[user.id] = user.toMap();
  }

  Future<UserModel?> getUser(String uid) async {
    final data = _users[uid];
    if (data == null) return null;
    return UserModel.fromMap(data);
  }

  Future<void> updateUser(UserModel user) async {
    _users[user.id] = user.toMap();
  }

  // Progress operations
  Future<void> updateProgress(String uid, ProgressModel progress) async {
    _progress[uid] = progress.toMap();
  }

  Future<ProgressModel?> getProgress(String uid) async {
    final data = _progress[uid];
    if (data == null) return null;
    return ProgressModel.fromMap(data);
  }

  // Session operations
  Future<void> saveSession(String uid, PracticeSessionModel session) async {
    _sessions.putIfAbsent(uid, () => []);
    _sessions[uid]!.add(session.toMap());
  }

  // Drill score operations
  Future<void> saveDrillResult(String uid, DrillResultModel result) async {
    _drillScores.putIfAbsent(uid, () => []);
    _drillScores[uid]!.add(result.toMap());
  }

  Future<List<DrillResultModel>> getDrillScores(String uid) async {
    final data = _drillScores[uid];
    if (data == null) return [];
    return data.map((d) => DrillResultModel.fromMap(d)).toList();
  }
}
