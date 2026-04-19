import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../services/database_service.dart';

/// Admin Controller — إحصائيات + إدارة منتجات + طلبات + مستخدمين
class AdminController {
  final DatabaseService db;
  AdminController(this.db);

  /// GET /api/admin/stats
  Future<Response> getStats(Request request) async {
    try {
      final stats = await db.getAdminStats();
      return _json({'success': true, 'data': stats});
    } catch (e) {
      return _json({'success': false, 'message': 'خطأ: $e'}, 500);
    }
  }

  /// GET /api/admin/orders?status=pending
  Future<Response> getOrders(Request request) async {
    try {
      final orders = await db.getAllOrders(
        status: request.url.queryParameters['status'],
      );
      return _json({'success': true, 'data': orders, 'count': orders.length});
    } catch (e) {
      return _json({'success': false, 'message': 'خطأ: $e'}, 500);
    }
  }

  /// PUT /api/admin/orders/:id/status
  Future<Response> updateOrderStatus(Request request, String id) async {
    try {
      final body = jsonDecode(await request.readAsString());
      final status = body['status'] as String?;
      if (status == null) {
        return _json({'success': false, 'message': 'الحالة مطلوبة'}, 400);
      }

      final validStatuses = ['pending', 'confirmed', 'preparing', 'ready', 'completed', 'cancelled'];
      if (!validStatuses.contains(status)) {
        return _json({'success': false, 'message': 'حالة غير صالحة'}, 400);
      }

      await db.updateOrderStatus(id, status);
      return _json({'success': true, 'message': 'تم تحديث الحالة'});
    } catch (e) {
      return _json({'success': false, 'message': 'خطأ: $e'}, 500);
    }
  }

  /// GET /api/admin/users
  Future<Response> getUsers(Request request) async {
    try {
      final users = await db.getAllUsers();
      return _json({'success': true, 'data': users, 'count': users.length});
    } catch (e) {
      return _json({'success': false, 'message': 'خطأ: $e'}, 500);
    }
  }

  /// GET /api/admin/products
  Future<Response> getProducts(Request request) async {
    try {
      final products = await db.getProducts(availableOnly: false);
      return _json({'success': true, 'data': products, 'count': products.length});
    } catch (e) {
      return _json({'success': false, 'message': 'خطأ: $e'}, 500);
    }
  }

  /// POST /api/admin/products
  Future<Response> createProduct(Request request) async {
    try {
      final body = jsonDecode(await request.readAsString());
      await db.createProduct(body);
      return _json({'success': true, 'message': 'تم إنشاء المنتج'}, 201);
    } catch (e) {
      return _json({'success': false, 'message': 'خطأ: $e'}, 500);
    }
  }

  /// PUT /api/admin/products/:id
  Future<Response> updateProduct(Request request, String id) async {
    try {
      final body = jsonDecode(await request.readAsString());
      await db.updateProduct(id, body);
      return _json({'success': true, 'message': 'تم تحديث المنتج'});
    } catch (e) {
      return _json({'success': false, 'message': 'خطأ: $e'}, 500);
    }
  }

  /// DELETE /api/admin/products/:id
  Future<Response> deleteProduct(Request request, String id) async {
    try {
      await db.deleteProduct(id);
      return _json({'success': true, 'message': 'تم حذف المنتج'});
    } catch (e) {
      return _json({'success': false, 'message': 'خطأ: $e'}, 500);
    }
  }

  /// GET /api/admin/categories
  Future<Response> getCategories(Request request) async {
    try {
      final categories = await db.getCategories(activeOnly: false);
      return _json({'success': true, 'data': categories});
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
