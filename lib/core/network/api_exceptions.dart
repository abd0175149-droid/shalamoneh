/// أخطاء الشبكة — مع رسائل عربية واضحة
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;

  const ApiException({
    required this.message,
    this.statusCode,
    this.code,
  });

  @override
  String toString() => 'ApiException($statusCode): $message';

  // ══════════════════════════════════════════
  //  أنواع الأخطاء الشائعة
  // ══════════════════════════════════════════

  /// لا يوجد اتصال بالإنترنت
  factory ApiException.noInternet() => const ApiException(
        message: 'لا يوجد اتصال بالإنترنت. تحقق من الشبكة وأعد المحاولة.',
        code: 'NO_INTERNET',
      );

  /// انتهت صلاحية الجلسة
  factory ApiException.unauthorized() => const ApiException(
        message: 'انتهت صلاحية الجلسة. سجّل الدخول مجدداً.',
        statusCode: 401,
        code: 'UNAUTHORIZED',
      );

  /// محظور
  factory ApiException.forbidden() => const ApiException(
        message: 'لا تملك صلاحية لهذا الإجراء.',
        statusCode: 403,
        code: 'FORBIDDEN',
      );

  /// غير موجود
  factory ApiException.notFound() => const ApiException(
        message: 'المحتوى المطلوب غير موجود.',
        statusCode: 404,
        code: 'NOT_FOUND',
      );

  /// خطأ في السيرفر
  factory ApiException.serverError() => const ApiException(
        message: 'حدث خطأ في السيرفر. حاول لاحقاً.',
        statusCode: 500,
        code: 'SERVER_ERROR',
      );

  /// انتهت مهلة الاتصال
  factory ApiException.timeout() => const ApiException(
        message: 'انتهت مهلة الاتصال. حاول مجدداً.',
        code: 'TIMEOUT',
      );

  /// خطأ غير معروف
  factory ApiException.unknown([String? msg]) => ApiException(
        message: msg ?? 'حدث خطأ غير متوقع. حاول لاحقاً.',
        code: 'UNKNOWN',
      );

  /// من كود HTTP
  factory ApiException.fromStatusCode(int statusCode, [String? msg]) {
    switch (statusCode) {
      case 400:
        return ApiException(
          message: msg ?? 'طلب غير صالح.',
          statusCode: 400,
          code: 'BAD_REQUEST',
        );
      case 401:
        return ApiException.unauthorized();
      case 403:
        return ApiException.forbidden();
      case 404:
        return ApiException.notFound();
      case 422:
        return ApiException(
          message: msg ?? 'بيانات غير صالحة.',
          statusCode: 422,
          code: 'VALIDATION_ERROR',
        );
      case 429:
        return const ApiException(
          message: 'طلبات كثيرة. انتظر قليلاً.',
          statusCode: 429,
          code: 'RATE_LIMITED',
        );
      default:
        if (statusCode >= 500) return ApiException.serverError();
        return ApiException.unknown(msg);
    }
  }
}
