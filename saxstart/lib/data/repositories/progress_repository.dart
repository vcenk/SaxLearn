import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/firestore_service.dart';
import '../models/progress_model.dart';
import 'user_repository.dart';

class ProgressRepository {
  final FirestoreService _firestore;

  ProgressRepository(this._firestore);

  Future<ProgressModel> loadProgress(String uid) async {
    final progress = await _firestore.getProgress(uid);
    return progress ?? const ProgressModel();
  }

  Future<void> saveProgress(String uid, ProgressModel progress) async {
    await _firestore.updateProgress(uid, progress);
  }
}

final progressRepositoryProvider = Provider<ProgressRepository>(
  (ref) => ProgressRepository(ref.read(firestoreServiceProvider)),
);
