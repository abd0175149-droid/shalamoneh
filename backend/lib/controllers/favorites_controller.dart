import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../services/database_service.dart';

/// Favorites Controller — CRUD مفضلات (مُتزامنة مع السيرفر)
class FavoritesController {
  final DatabaseService db;
  FavoritesController(this.db);

  /// GET /api/favorites
  Future<Response> getFavorites(Request request) async {
    final userId = request.headers['x-user-id']!;
    final favorites = await db.getFavorites(userId);
    return _json({'success': true, 'data': favorites, 'count': favorites.length});
  }

  /// GET /api/favorites/ids
  Future<Response> getFavoriteIds(Request request) async {
    final userId = request.headers['x-user-id']!;
    final ids = await db.getFavoriteIds(userId);
    return _json({'success': true, 'data': ids});
  }

  /// POST /api/favorites
  Future<Response> addFavorite(Request request) async {
    try {
      final userId = request.headers['x-user-id']!;
      final body = jsonDecode(await request.readAsString());
      final productId = body['product_id'] as String?;

      if (productId == null) {
        return _json({'success': false, 'message': 'product_id مطلوب'}, 400);
      }

      await db.addFavorite(userId, productId);
      return _json({'success': true, 'message': 'تمت الإضافة للمفضلات ❤️'}, 201);
    } catch (e) {
      return _json({'success': false, 'message': 'خطأ: $e'}, 500);
    }
  }

  /// DELETE /api/favorites/:productId
  Future<Response> removeFavorite(Request request, String productId) async {
    try {
      final userId = request.headers['x-user-id']!;
      await db.removeFavorite(userId, productId);
      return _json({'success': true, 'message': 'تمت الإزالة من المفضلات'});
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
