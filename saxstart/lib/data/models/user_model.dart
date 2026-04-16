class UserModel {
  final String id;
  final String name;
  final String email;
  final String level;
  final String goal;
  final String instrument;
  final bool isPremium;
  final String reminderTime;
  final DateTime createdAt;
  final DateTime lastActiveAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.level,
    required this.goal,
    this.instrument = 'alto',
    this.isPremium = false,
    this.reminderTime = '18:00',
    required this.createdAt,
    required this.lastActiveAt,
  });

  UserModel copyWith({
    String? name,
    String? email,
    String? level,
    String? goal,
    bool? isPremium,
    String? reminderTime,
    DateTime? lastActiveAt,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      level: level ?? this.level,
      goal: goal ?? this.goal,
      instrument: instrument,
      isPremium: isPremium ?? this.isPremium,
      reminderTime: reminderTime ?? this.reminderTime,
      createdAt: createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'level': level,
      'goal': goal,
      'instrument': instrument,
      'isPremium': isPremium,
      'reminderTime': reminderTime,
      'createdAt': createdAt.toIso8601String(),
      'lastActiveAt': lastActiveAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      level: map['level'] as String,
      goal: map['goal'] as String,
      instrument: map['instrument'] as String? ?? 'alto',
      isPremium: map['isPremium'] as bool? ?? false,
      reminderTime: map['reminderTime'] as String? ?? '18:00',
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastActiveAt: DateTime.parse(map['lastActiveAt'] as String),
    );
  }
}
