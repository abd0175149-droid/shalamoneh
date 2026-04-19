import 'dart:async';
import 'dart:js' as js;
import 'dart:js_util' show allowInterop;

/// Google Sign-In Web — استدعاء GIS One Tap مباشرة بدون eval
/// يستخدم dart:js لاستدعاء google.accounts.id مباشرة
Future<String?> callGoogleOneTapWeb() async {
  final completer = Completer<String?>();

  try {
    // تحقق من تحميل GIS
    final google = js.context['google'];
    if (google == null) {
      print('❌ GIS not loaded: window.google is null');
      return null;
    }

    final accounts = (google as js.JsObject)['accounts'];
    if (accounts == null) {
      print('❌ GIS not loaded: google.accounts is null');
      return null;
    }

    final id = (accounts as js.JsObject)['id'];
    if (id == null) {
      print('❌ GIS not loaded: google.accounts.id is null');
      return null;
    }

    final gisId = id as js.JsObject;

    // Callback عند نجاح المصادقة
    final credentialCallback = allowInterop((dynamic response) {
      try {
        final jsResponse = response as js.JsObject;
        final credential = jsResponse['credential'];
        print('✅ GIS credential received!');
        if (!completer.isCompleted) {
          completer.complete(credential?.toString());
        }
      } catch (e) {
        print('❌ Credential callback error: $e');
        if (!completer.isCompleted) {
          completer.complete(null);
        }
      }
    });

    // تهيئة GIS
    gisId.callMethod('initialize', [
      js.JsObject.jsify({
        'client_id': '13399553146-5cj2lbtq691ompj8sejjfm4qk2eqk0t5.apps.googleusercontent.com',
        'callback': credentialCallback,
        'auto_select': false,
      }),
    ]);

    // Callback لحالة العرض
    final promptCallback = allowInterop((dynamic notification) {
      try {
        final n = notification as js.JsObject;

        // تحقق من isNotDisplayed
        final isNotDisplayed = n.callMethod('isNotDisplayed', []) as bool;
        if (isNotDisplayed) {
          final reason = n.callMethod('getNotDisplayedReason', []);
          print('⚠️ One Tap not displayed: $reason');
          if (!completer.isCompleted) {
            completer.complete(null);
          }
          return;
        }

        // تحقق من isSkippedMoment
        final isSkipped = n.callMethod('isSkippedMoment', []) as bool;
        if (isSkipped) {
          final reason = n.callMethod('getSkippedReason', []);
          print('⚠️ One Tap skipped: $reason');
          if (!completer.isCompleted) {
            completer.complete(null);
          }
          return;
        }

        // isDisplayMoment — ننتظر اختيار المستخدم
        print('👁️ One Tap is displayed, waiting for user...');
      } catch (e) {
        print('❌ Prompt callback error: $e');
        if (!completer.isCompleted) {
          completer.complete(null);
        }
      }
    });

    // عرض One Tap
    gisId.callMethod('prompt', [promptCallback]);

  } catch (e) {
    print('❌ GIS initialization error: $e');
    if (!completer.isCompleted) {
      completer.complete(null);
    }
  }

  // انتظار callback (مع timeout 60 ثانية)
  return completer.future.timeout(
    const Duration(seconds: 60),
    onTimeout: () {
      print('⏰ GIS timeout — no response in 60 seconds');
      return null;
    },
  );
}
