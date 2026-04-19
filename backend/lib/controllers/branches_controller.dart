import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../services/database_service.dart';

/// Branches Controller — الفروع
class BranchesController {
  final DatabaseService db;
  BranchesController(this.db);

  /// GET /api/branches?city=عمان
  Future<Response> getBranches(Request request) async {
    final branches = await db.getBranches(
      city: request.url.queryParameters['city'],
    );
    return _json({'success': true, 'data': branches, 'count': branches.length});
  }

  /// GET /api/branches/:id
  Future<Response> getBranchById(Request request, String id) async {
    final branch = await db.getBranchById(id);
    if (branch == null) {
      return _json({'success': false, 'message': 'فرع غير موجود'}, 404);
    }
    return _json({'success': true, 'data': branch});
  }

  Response _json(Map<String, dynamic> data, [int status = 200]) {
    return Response(status,
        body: jsonEncode(data),
        headers: {'content-type': 'application/json; charset=utf-8'});
  }
}
