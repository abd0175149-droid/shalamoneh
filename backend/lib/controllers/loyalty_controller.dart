import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../services/database_service.dart';

/// Loyalty Controller — رصيد + سجل + استبدال
class LoyaltyController {
  final DatabaseService db;
  LoyaltyController(this.db);

  /// GET /api/loyalty/balance
  Future<Response> getBalance(Request request) async {
    final userId = request.headers['x-user-id']!;
    final balance = await db.getLoyaltyBalance(userId);
    return _json({'success': true, 'data': balance});
  }

  /// GET /api/loyalty/transactions
  Future<Response> getTransactions(Request request) async {
    final userId = request.headers['x-user-id']!;
    final transactions = await db.getLoyaltyTransactions(userId);
    return _json({'success': true, 'data': transactions, 'count': transactions.length});
  }

  /// POST /api/loyalty/redeem
  Future<Response> redeem(Request request) async {
    try {
      final userId = request.headers['x-user-id']!;
      final body = jsonDecode(await request.readAsString());
      final points = body['points'] as int?;

      if (points == null || points <= 0) {
        return _json({'success': false, 'message': 'عدد النقاط غير صالح'}, 400);
      }
      if (points < 50) {
        return _json({'success': false, 'message': 'الحد الأدنى للاستبدال 50 نقطة'}, 400);
      }

      final success = await db.redeemPoints(userId, points);
      if (!success) {
        return _json({'success': false, 'message': 'رصيدك غير كافي'}, 400);
      }

      final newBalance = await db.getLoyaltyBalance(userId);
      return _json({
        'success': true,
        'message': 'تم استبدال $points نقطة بنجاح! 🎁',
        'data': newBalance,
      });
    } catch (e) {
      return _json({'success': false, 'message': 'خطأ: $e'}, 500);
    }
  }

  Response _json(Map<String, dynamic> data, [int status = 200]) {
    return Response(status,
        body: jsonEncode(data),
        headers: {'content-type': 'application/json; charset=utf-8'});
  }
}
