import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import '../config/env_config.dart';
import '../services/database_service.dart';

/// Auth Middleware — يتحقق من JWT ويضيف x-user-id للـ request
Middleware authMiddleware(DatabaseService db) {
  return (Handler innerHandler) {
    return (Request request) async {
      final authHeader = request.headers['authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response(401,
            body: jsonEncode({'success': false, 'message': 'التوكن مطلوب'}),
            headers: {'content-type': 'application/json; charset=utf-8'});
      }

      final token = authHeader.substring(7);

      try {
        final jwt = JWT.verify(token, SecretKey(EnvConfig.jwtSecret));
        final payload = jwt.payload as Map<String, dynamic>;
        final userId = payload['user_id'] as String;
        final type = payload['type'] as String?;

        // تأكد إنه access token وليس refresh
        if (type != null && type != 'access') {
          return Response(401,
              body: jsonEncode({'success': false, 'message': 'نوع التوكن غير صحيح'}),
              headers: {'content-type': 'application/json; charset=utf-8'});
        }

        // تحقق من وجود المستخدم
        final user = await db.getUserById(userId);
        if (user == null) {
          return Response(401,
              body: jsonEncode({'success': false, 'message': 'مستخدم غير موجود'}),
              headers: {'content-type': 'application/json; charset=utf-8'});
        }

        // أضف userId للـ headers
        final updatedRequest = request.change(headers: {
          'x-user-id': userId,
        });

        return innerHandler(updatedRequest);
      } on JWTExpiredException {
        return Response(401,
            body: jsonEncode({'success': false, 'message': 'التوكن منتهي الصلاحية', 'code': 'TOKEN_EXPIRED'}),
            headers: {'content-type': 'application/json; charset=utf-8'});
      } catch (e) {
        return Response(401,
            body: jsonEncode({'success': false, 'message': 'التوكن غير صالح'}),
            headers: {'content-type': 'application/json; charset=utf-8'});
      }
    };
  };
}

/// Admin Middleware — يتحقق من صلاحيات الأدمن
Middleware adminMiddleware(DatabaseService db) {
  return (Handler innerHandler) {
    return (Request request) async {
      final userId = request.headers['x-user-id'];
      if (userId == null) {
        return Response(401,
            body: jsonEncode({'success': false, 'message': 'غير مصرح'}),
            headers: {'content-type': 'application/json; charset=utf-8'});
      }

      final user = await db.getUserById(userId);
      if (user == null || user['is_admin'] != true) {
        return Response(403,
            body: jsonEncode({'success': false, 'message': 'غير مسموح — صلاحيات أدمن مطلوبة'}),
            headers: {'content-type': 'application/json; charset=utf-8'});
      }

      return innerHandler(request);
    };
  };
}
