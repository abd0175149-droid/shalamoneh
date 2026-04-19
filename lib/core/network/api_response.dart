/// نموذج استجابة API الموحد
/// يغلّف كل الاستجابات بنفس الشكل
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;
  final ApiError? error;

  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
    this.error,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    final rawData = json['data'];
    return ApiResponse(
      success: json['success'] as bool? ?? false,
      data: rawData != null && fromJsonT != null
          ? fromJsonT(rawData)
          : rawData as T?,
      message: json['message'] as String?,
      statusCode: json['status_code'] as int?,
      error: json['error'] != null
          ? ApiError.fromJson(json['error'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// تفاصيل الخطأ
class ApiError {
  final String code;
  final String message;
  final Map<String, dynamic>? details;

  const ApiError({
    required this.code,
    required this.message,
    this.details,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'] as String? ?? 'UNKNOWN',
      message: json['message'] as String? ?? 'حدث خطأ غير معروف',
      details: json['details'] as Map<String, dynamic>?,
    );
  }
}
