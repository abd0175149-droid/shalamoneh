import 'dart:io';

/// إعدادات البيئة — يقرأ من .env أو متغيرات النظام
class EnvConfig {
  static final Map<String, String> _env = {};

  /// تحميل ملف .env
  static Future<void> load([String path = '.env']) async {
    final file = File(path);
    if (await file.exists()) {
      final lines = await file.readAsLines();
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
        final idx = trimmed.indexOf('=');
        if (idx > 0) {
          final key = trimmed.substring(0, idx).trim();
          final value = trimmed.substring(idx + 1).trim();
          _env[key] = value;
        }
      }
    }
    print('✅ Loaded ${_env.length} env variables');
  }

  /// جلب متغير — الأولوية: System ENV > .env file
  static String get(String key, [String defaultValue = '']) {
    return Platform.environment[key] ?? _env[key] ?? defaultValue;
  }

  static int getInt(String key, [int defaultValue = 0]) {
    return int.tryParse(get(key)) ?? defaultValue;
  }

  static bool getBool(String key, [bool defaultValue = false]) {
    return get(key).toLowerCase() == 'true' || get(key) == '1';
  }

  // ─── Shortcuts ───
  static int get port => getInt('PORT', 8080);
  static String get host => get('HOST', '0.0.0.0');

  static String get dbHost => get('DB_HOST', 'localhost');
  static int get dbPort => getInt('DB_PORT', 5432);
  static String get dbName => get('DB_NAME', 'shalmoneh');
  static String get dbUser => get('DB_USER', 'shalmoneh_user');
  static String get dbPass => get('DB_PASS', '');

  static String get jwtSecret => get('JWT_SECRET', 'dev_secret_change_me');
  static int get jwtAccessExpiryHours => getInt('JWT_ACCESS_EXPIRY_HOURS', 24);
  static int get jwtRefreshExpiryDays => getInt('JWT_REFRESH_EXPIRY_DAYS', 90);

  static String get twilioSid => get('TWILIO_ACCOUNT_SID');
  static String get twilioToken => get('TWILIO_AUTH_TOKEN');
  static String get twilioFrom => get('TWILIO_FROM_NUMBER');
  static bool get isTwilioConfigured =>
      twilioSid.isNotEmpty && twilioToken.isNotEmpty;

  static String get adminPhone => get('ADMIN_PHONE', '+962799999999');
  static String get adminPin => get('ADMIN_PIN', '123456');
  static String get apiDomain => get('API_DOMAIN', 'localhost');
}
