import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env_config.dart';

/// خدمة SMS — Twilio
/// في التطوير: يطبع OTP في Console
/// في الإنتاج: يرسل عبر Twilio API
class SmsService {
  /// إرسال OTP عبر SMS
  static Future<bool> sendOtp(String phone, String otp) async {
    if (!EnvConfig.isTwilioConfigured) {
      // وضع تطويري — طباعة فقط
      print('📱 [DEV] OTP for $phone: $otp');
      return true;
    }

    // إرسال حقيقي عبر Twilio
    try {
      final url = Uri.parse(
        'https://api.twilio.com/2010-04-01/Accounts/${EnvConfig.twilioSid}/Messages.json',
      );

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('${EnvConfig.twilioSid}:${EnvConfig.twilioToken}'))}',
        },
        body: {
          'From': EnvConfig.twilioFrom,
          'To': phone,
          'Body': 'رمز التحقق الخاص بك في شلمونة: $otp\n'
              'Shalmoneh verification code: $otp\n'
              'صالح لمدة 5 دقائق.',
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('✅ SMS sent to $phone');
        return true;
      } else {
        print('❌ SMS failed: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ SMS error: $e');
      return false;
    }
  }
}
