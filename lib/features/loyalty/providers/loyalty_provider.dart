import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider لنقاط الولاء
final loyaltyProvider = NotifierProvider<LoyaltyNotifier, LoyaltyState>(
  LoyaltyNotifier.new,
);

class LoyaltyState {
  final int currentPoints;
  final int totalEarned;
  final int totalRedeemed;
  final String level;
  final int pointsToNextLevel;
  final int pointsForFreeeDrink;
  final List<LoyaltyTransaction> transactions;

  const LoyaltyState({
    this.currentPoints = 67,
    this.totalEarned = 234,
    this.totalRedeemed = 167,
    this.level = 'برونزي',
    this.pointsToNextLevel = 33,
    this.pointsForFreeeDrink = 100,
    this.transactions = const [],
  });

  double get progress => currentPoints / pointsForFreeeDrink;

  LoyaltyState copyWith({
    int? currentPoints,
    int? totalEarned,
    int? totalRedeemed,
    String? level,
    int? pointsToNextLevel,
    List<LoyaltyTransaction>? transactions,
  }) {
    return LoyaltyState(
      currentPoints: currentPoints ?? this.currentPoints,
      totalEarned: totalEarned ?? this.totalEarned,
      totalRedeemed: totalRedeemed ?? this.totalRedeemed,
      level: level ?? this.level,
      pointsToNextLevel: pointsToNextLevel ?? this.pointsToNextLevel,
      transactions: transactions ?? this.transactions,
    );
  }
}

class LoyaltyTransaction {
  final String id;
  final String description;
  final int points;
  final bool isEarned; // true = كسب، false = استبدال
  final DateTime date;

  const LoyaltyTransaction({
    required this.id,
    required this.description,
    required this.points,
    required this.isEarned,
    required this.date,
  });
}

class LoyaltyNotifier extends Notifier<LoyaltyState> {
  @override
  LoyaltyState build() {
    return LoyaltyState(
      transactions: [
        LoyaltyTransaction(
          id: '1', description: 'طلب كوكتيل شلمونة',
          points: 12, isEarned: true,
          date: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        LoyaltyTransaction(
          id: '2', description: 'طلب عصير برتقال + مانجو',
          points: 8, isEarned: true,
          date: DateTime.now().subtract(const Duration(days: 1)),
        ),
        LoyaltyTransaction(
          id: '3', description: 'استبدال مشروب مجاني',
          points: 100, isEarned: false,
          date: DateTime.now().subtract(const Duration(days: 3)),
        ),
        LoyaltyTransaction(
          id: '4', description: 'طلب سحلب + وافل',
          points: 15, isEarned: true,
          date: DateTime.now().subtract(const Duration(days: 5)),
        ),
        LoyaltyTransaction(
          id: '5', description: 'مكافأة تسجيل جديد',
          points: 50, isEarned: true,
          date: DateTime.now().subtract(const Duration(days: 7)),
        ),
      ],
    );
  }

  /// إضافة نقاط (عند الشراء)
  void addPoints(int points, String description) {
    state = state.copyWith(
      currentPoints: state.currentPoints + points,
      totalEarned: state.totalEarned + points,
      transactions: [
        LoyaltyTransaction(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          description: description,
          points: points,
          isEarned: true,
          date: DateTime.now(),
        ),
        ...state.transactions,
      ],
    );
  }

  /// استبدال نقاط (مشروب مجاني)
  bool redeemPoints(int points) {
    if (state.currentPoints < points) return false;
    state = state.copyWith(
      currentPoints: state.currentPoints - points,
      totalRedeemed: state.totalRedeemed + points,
      transactions: [
        LoyaltyTransaction(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          description: 'استبدال مشروب مجاني',
          points: points,
          isEarned: false,
          date: DateTime.now(),
        ),
        ...state.transactions,
      ],
    );
    return true;
  }
}
