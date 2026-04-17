import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/firestore_service.dart';
import '../models/user_model.dart';

class UserRepository {
  final FirestoreService _firestore;

  UserRepository(this._firestore);

  Future<UserModel?> getUser(String uid) async {
    return _firestore.getUser(uid);
  }

  Future<void> createUser(UserModel user) async {
    await _firestore.createUser(user);
  }

  Future<void> updateUser(UserModel user) async {
    await _firestore.updateUser(user);
  }

  Future<UserModel> getOrCreateUser({
    required String uid,
    required String email,
    required String name,
    required String level,
    required String goal,
  }) async {
    final existing = await getUser(uid);
    if (existing != null) return existing;

    final user = UserModel(
      id: uid,
      name: name,
      email: email,
      level: level,
      goal: goal,
      createdAt: DateTime.now(),
      lastActiveAt: DateTime.now(),
    );
    await createUser(user);
    return user;
  }
}

final firestoreServiceProvider = Provider<FirestoreService>(
  (ref) => FirestoreService(),
);

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepository(ref.read(firestoreServiceProvider)),
);
