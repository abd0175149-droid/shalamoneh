/// نموذج بيانات المستخدم
class UserModel {
  final String id;
  final String? phone;
  final String? name;
  final String? email;
  final DateTime? birthDate;
  final String? avatarUrl;
  final String level; // bronze, silver, gold, platinum
  final int points;
  final DateTime createdAt;

  UserModel({
    required this.id,
    this.phone,
    this.name,
    this.email,
    this.birthDate,
    this.avatarUrl,
    this.level = 'bronze',
    this.points = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      phone: json['phone'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      birthDate: json['birth_date'] != null
          ? DateTime.tryParse(json['birth_date'].toString())
          : null,
      avatarUrl: json['avatar_url'] as String?,
      level: json['level'] as String? ?? 'bronze',
      points: json['points'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? (DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'phone': phone,
        'name': name,
        'email': email,
        'birth_date': birthDate?.toIso8601String(),
        'avatar_url': avatarUrl,
        'level': level,
        'points': points,
        'created_at': createdAt.toIso8601String(),
      };

  UserModel copyWith({
    String? name,
    String? email,
    DateTime? birthDate,
    String? avatarUrl,
    String? level,
    int? points,
  }) {
    return UserModel(
      id: id,
      phone: phone,
      name: name ?? this.name,
      email: email ?? this.email,
      birthDate: birthDate ?? this.birthDate,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      level: level ?? this.level,
      points: points ?? this.points,
      createdAt: createdAt,
    );
  }
}
