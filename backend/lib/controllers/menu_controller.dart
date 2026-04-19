import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../services/database_service.dart';

/// Menu Controller — Categories + Products + Search (من PostgreSQL)
class MenuController {
  final DatabaseService db;
  MenuController(this.db);

  /// GET /api/categories
  Future<Response> getCategories(Request request) async {
    final categories = await db.getCategories();
    return _json({'success': true, 'data': categories});
  }

  /// GET /api/products?category=cat1&search=برتقال&popular=true
  Future<Response> getProducts(Request request) async {
    try {
      final products = await db.getProducts(
        categoryId: request.url.queryParameters['category'],
        search: request.url.queryParameters['search'],
        popular: request.url.queryParameters['popular'] == 'true',
      );
      return _json({'success': true, 'data': products, 'count': products.length});
    } catch (e) {
      return _json({'success': false, 'message': 'خطأ: $e'}, 500);
    }
  }

  /// GET /api/products/:id
  Future<Response> getProductById(Request request, String id) async {
    final product = await db.getProductById(id);
    if (product == null) {
      return _json({'success': false, 'message': 'منتج غير موجود'}, 404);
    }
    return _json({'success': true, 'data': product});
  }

  Response _json(Map<String, dynamic> data, [int status = 200]) {
    return Response(status,
        body: jsonEncode(data),
        headers: {'content-type': 'application/json; charset=utf-8'});
  }
}
