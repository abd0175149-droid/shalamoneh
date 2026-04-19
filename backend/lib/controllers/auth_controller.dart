import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shelf/shelf.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import '../config/env_config.dart';
import '../services/database_service.dart';
import '../services/sms_service.dart';

/// Auth Controller — OTP + JWT (Access + Refresh) + Profile
class AuthController {
  final DatabaseService db;
  AuthController(this.db);

  /// POST /api/auth/send-otp
  Future<Response> sendOtp(Request request) async {
    try {
      final body = jsonDecode(await request.readAsString());
      final phone = body['phone'] as String?;

      if (phone == null || phone.isEmpty) {
        return _json({'success': false, 'message': 'رقم الهاتف مطلوب'}, 400);
      }

      // توليد OTP وتخزينه
      final otp = await db.storeOtp(phone);

      // إرسال SMS
      await SmsService.sendOtp(phone, otp);

      final responseData = <String, dynamic>{
        'phone': phone,
        'expires_in_seconds': 300,
      };

      // في التطوير فقط — أظهر OTP في response
      if (!EnvConfig.isTwilioConfigured) {
        responseData['otp'] = otp; // ⚠️ للتطوير فقط!
      }

      return _json({
        'success': true,
        'message': 'تم إرسال رمز التحقق',
        'data': responseData,
      });
    } catch (e) {
      return _json({'success': false, 'message': 'خطأ: $e'}, 500);
    }
  }

  /// POST /api/auth/verify-otp
  Future<Response> verifyOtp(Request request) async {
    try {
      final body = jsonDecode(await request.readAsString());
      final phone = body['phone'] as String?;
      final otp = body['otp'] as String?;

      if (phone == null || otp == null) {
        return _json({'success': false, 'message': 'الرقم والرمز مطلوبان'}, 400);
      }

      if (!(await db.verifyOtp(phone, otp))) {
        return _json({'success': false, 'message': 'رمز التحقق غير صحيح أو منتهي'}, 401);
      }

      // البحث عن المستخدم أو إنشاؤه
      var user = await db.getUserByPhone(phone);
      final isNewUser = user == null;
      user ??= await db.createUser(phone);

      final userId = user['id'].toString();

      // Access Token (قصير الأمد)
      final accessJwt = JWT({'user_id': userId, 'phone': phone, 'type': 'access'});
      final accessToken = accessJwt.sign(
        SecretKey(EnvConfig.jwtSecret),
        expiresIn: Duration(hours: EnvConfig.jwtAccessExpiryHours),
      );

      // Refresh Token (طويل الأمد)
      final refreshJwt = JWT({'user_id': userId, 'type': 'refresh'});
      final refreshToken = refreshJwt.sign(
        SecretKey(EnvConfig.jwtSecret),
        expiresIn: Duration(days: EnvConfig.jwtRefreshExpiryDays),
      );

      await db.storeRefreshToken(userId, refreshToken);

      return _json({
        'success': true,
        'message': 'تم التحقق بنجاح',
        'data': {
          'access_token': accessToken,
          'refresh_token': refreshToken,
          'user': _sanitizeUser(user),
          'is_new_user': isNewUser,
        }
      });
    } catch (e) {
      return _json({'success': false, 'message': 'خطأ: $e'}, 500);
    }
  }

  /// POST /api/auth/refresh-token
  Future<Response> refreshToken(Request request) async {
    try {
      final body = jsonDecode(await request.readAsString());
      final token = body['refresh_token'] as String?;
      if (token == null) {
        return _json({'success': false, 'message': 'Refresh token مطلوب'}, 400);
      }

      // تحقق من صلاحية JWT
      try {
        JWT.verify(token, SecretKey(EnvConfig.jwtSecret));
      } catch (_) {
        return _json({'success': false, 'message': 'Token منتهي الصلاحية'}, 401);
      }

      // تحقق من DB
      final userId = await db.validateRefreshToken(token);
      if (userId == null) {
        return _json({'success': false, 'message': 'Token غير صالح'}, 401);
      }

      final user = await db.getUserById(userId);
      if (user == null) {
        return _json({'success': false, 'message': 'مستخدم غير موجود'}, 404);
      }

      // إبطال القديم + إصدار جديد
      await db.revokeRefreshToken(token);

      final newAccessJwt = JWT({'user_id': userId, 'phone': user['phone'], 'type': 'access'});
      final newAccessToken = newAccessJwt.sign(
        SecretKey(EnvConfig.jwtSecret),
        expiresIn: Duration(hours: EnvConfig.jwtAccessExpiryHours),
      );

      final newRefreshJwt = JWT({'user_id': userId, 'type': 'refresh'});
      final newRefreshToken = newRefreshJwt.sign(
        SecretKey(EnvConfig.jwtSecret),
        expiresIn: Duration(days: EnvConfig.jwtRefreshExpiryDays),
      );

      await db.storeRefreshToken(userId, newRefreshToken);

      return _json({
        'success': true,
        'data': {
          'access_token': newAccessToken,
          'refresh_token': newRefreshToken,
          'user': _sanitizeUser(user),
        }
      });
    } catch (e) {
      return _json({'success': false, 'message': 'خطأ: $e'}, 500);
    }
  }

  /// GET /api/auth/profile
  Future<Response> getProfile(Request request) async {
    final userId = request.headers['x-user-id'];
    if (userId == null) return _json({'success': false, 'message': 'غير مصرح'}, 401);

    final user = await db.getUserById(userId);
    if (user == null) return _json({'success': false, 'message': 'مستخدم غير موجود'}, 404);

    final loyalty = await db.getLoyaltyBalance(userId);

    return _json({
      'success': true,
      'data': {
        ..._sanitizeUser(user),
        'loyalty': loyalty,
      }
    });
  }

  /// PUT /api/auth/profile
  Future<Response> updateProfile(Request request) async {
    try {
      final userId = request.headers['x-user-id'];
      if (userId == null) return _json({'success': false, 'message': 'غير مصرح'}, 401);

      final body = jsonDecode(await request.readAsString());
      await db.updateUser(userId, body);

      final user = await db.getUserById(userId);
      return _json({'success': true, 'message': 'تم التحديث', 'data': _sanitizeUser(user!)});
    } catch (e) {
      return _json({'success': false, 'message': 'خطأ: $e'}, 500);
    }
  }

  /// POST /api/auth/logout
  Future<Response> logout(Request request) async {
    try {
      final userId = request.headers['x-user-id'];
      if (userId != null) {
        await db.revokeAllUserTokens(userId);
      }
      return _json({'success': true, 'message': 'تم تسجيل الخروج'});
    } catch (e) {
      return _json({'success': false, 'message': 'خطأ: $e'}, 500);
    }
  }

  /// POST /api/auth/google
  /// يدعم: id_token (موبايل) أو access_token (ويب)
  Future<Response> signInWithGoogle(Request request) async {
    try {
      final body = jsonDecode(await request.readAsString());
      final idToken = body['id_token'] as String?;
      final accessToken = body['access_token'] as String?;

      String? googleId;
      String? email;
      String? name;
      String? picture;

      if (idToken != null && idToken.isNotEmpty) {
        // ─── مسار الموبايل: التحقق من ID Token ───
        final googleResponse = await http.get(
          Uri.parse('https://oauth2.googleapis.com/tokeninfo?id_token=$idToken'),
        );

        if (googleResponse.statusCode != 200) {
          return _json({'success': false, 'message': 'Google Token غير صالح'}, 401);
        }

        final googleData = jsonDecode(googleResponse.body) as Map<String, dynamic>;
        googleId = googleData['sub'] as String?;
        email = googleData['email'] as String?;
        name = googleData['name'] as String?;
        picture = googleData['picture'] as String?;

      } else if (accessToken != null && accessToken.isNotEmpty) {
        // ─── مسار الويب: التحقق من Access Token ───
        final userinfoResponse = await http.get(
          Uri.parse('https://www.googleapis.com/oauth2/v3/userinfo'),
          headers: {'Authorization': 'Bearer $accessToken'},
        );

        if (userinfoResponse.statusCode == 200) {
          final userinfo = jsonDecode(userinfoResponse.body) as Map<String, dynamic>;
          googleId = userinfo['sub'] as String?;
          email = userinfo['email'] as String?;
          name = userinfo['name'] as String?;
          picture = userinfo['picture'] as String?;
        } else {
          // Fallback: استخدام البيانات المرسلة من الـ Frontend
          email = body['email'] as String?;
          name = body['name'] as String?;
          picture = body['avatar_url'] as String?;
          googleId = email; // استخدام الإيميل كمعرف
        }

      } else {
        return _json({'success': false, 'message': 'Google Token مطلوب'}, 400);
      }

      if (googleId == null || email == null) {
        return _json({'success': false, 'message': 'بيانات Google غير كاملة'}, 400);
      }

      // البحث عن المستخدم بـ google_id أو إنشائه
      var user = await db.getUserByGoogleId(googleId);
      final isNewUser = user == null;

      if (user == null) {
        user = await db.createGoogleUser(
          googleId: googleId,
          email: email,
          name: name,
          avatarUrl: picture,
        );
      }

      final userId = user['id'].toString();

      // إصدار JWT tokens
      final accessJwt = JWT({'user_id': userId, 'email': email, 'type': 'access'});
      final jwtAccessToken = accessJwt.sign(
        SecretKey(EnvConfig.jwtSecret),
        expiresIn: Duration(hours: EnvConfig.jwtAccessExpiryHours),
      );

      final refreshJwt = JWT({'user_id': userId, 'type': 'refresh'});
      final refreshToken = refreshJwt.sign(
        SecretKey(EnvConfig.jwtSecret),
        expiresIn: Duration(days: EnvConfig.jwtRefreshExpiryDays),
      );

      await db.storeRefreshToken(userId, refreshToken);

      return _json({
        'success': true,
        'message': isNewUser ? 'تم إنشاء حسابك بنجاح' : 'مرحباً بعودتك',
        'data': {
          'access_token': jwtAccessToken,
          'refresh_token': refreshToken,
          'user': _sanitizeUser(user),
          'is_new_user': isNewUser,
        }
      });
    } catch (e) {
      return _json({'success': false, 'message': 'خطأ في تسجيل Google: $e'}, 500);
    }
  }

  Map<String, dynamic> _sanitizeUser(Map<String, dynamic> user) {
    final clean = Map<String, dynamic>.from(user);
    clean.remove('is_admin');
    return clean;
  }

  Response _json(Map<String, dynamic> data, [int status = 200]) {
    return Response(status,
        body: jsonEncode(data),
        headers: {'content-type': 'application/json; charset=utf-8'});
  }
}
