import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../services/database_service.dart';

/// Orders Controller — إنشاء + تاريخ + تفاصيل (حساب سيرفري)
class OrdersController {
  final DatabaseService db;
  OrdersController(this.db);

  /// POST /api/orders
  Future<Response> createOrder(Request request) async {
    try {
      final userId = request.headers['x-user-id']!;
      final body = jsonDecode(await request.readAsString());

      final items = List<Map<String, dynamic>>.from(body['items'] ?? []);
      if (items.isEmpty) {
        return _json({'success': false, 'message': 'يجب إضافة منتج واحد على الأقل'}, 400);
      }

      final branchId = body['branch_id'] as String?;
      if (branchId == null) {
        return _json({'success': false, 'message': 'الفرع مطلوب'}, 400);
      }

      final order = await db.createOrder(
        userId: userId,
        branchId: branchId,
        orderType: body['order_type'] ?? 'pickup',
        items: items,
        notes: body['notes'],
      );

      return _json({
        'success': true,
        'message': 'تم تأكيد الطلب بنجاح! 🎉',
        'data': order,
      }, 201);
    } catch (e) {
      return _json({'success': false, 'message': 'خطأ: $e'}, 500);
    }
  }

  /// GET /api/orders
  Future<Response> getOrders(Request request) async {
    final userId = request.headers['x-user-id']!;
    final orders = await db.getOrdersByUser(userId);
    return _json({'success': true, 'data': orders, 'count': orders.length});
  }

  /// GET /api/orders/:id
  Future<Response> getOrderById(Request request, String id) async {
    final userId = request.headers['x-user-id']!;
    final order = await db.getOrderById(id, userId);
    if (order == null) {
      return _json({'success': false, 'message': 'طلب غير موجود'}, 404);
    }
    return _json({'success': true, 'data': order});
  }

  Response _json(Map<String, dynamic> data, [int status = 200]) {
    return Response(status,
        body: jsonEncode(data),
        headers: {'content-type': 'application/json; charset=utf-8'});
  }
}
