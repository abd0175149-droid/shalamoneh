import 'dart:async';
import 'dart:js' as js;
import 'dart:js_util' show allowInterop;

/// Google Sign-In Web — استدعاء GIS One Tap عبر JavaScript
/// يستخدم allowInterop بدل JsFunction.withThis لتجنب null check errors
Future<String?> callGoogleOneTapWeb() async {
  final completer = Completer<String?>();

  // تعريف callbacks على window باستخدام allowInterop (أكثر أماناً)
  js.context['_dartGoogleCallback'] = allowInterop((dynamic credential) {
    if (!completer.isCompleted) {
      completer.complete(credential?.toString());
    }
  });

  js.context['_dartGoogleError'] = allowInterop((dynamic error) {
    if (!completer.isCompleted) {
      print('Google One Tap error: $error');
      completer.complete(null);
    }
  });

  // استدعاء GIS مباشرة
  try {
    js.context.callMethod('eval', ['''
      (function() {
        try {
          if (!window.google || !google.accounts || !google.accounts.id) {
            console.error("GIS not loaded yet — waiting...");
            window._dartGoogleError("GIS not loaded");
            return;
          }
          google.accounts.id.initialize({
            client_id: "13399553146-5cj2lbtq691ompj8sejjfm4qk2eqk0t5.apps.googleusercontent.com",
            callback: function(response) {
              console.log("GIS credential received!");
              window._dartGoogleCallback(response.credential);
            },
            auto_select: false
          });
          google.accounts.id.prompt(function(notification) {
            if (notification.isNotDisplayed()) {
              var reason = notification.getNotDisplayedReason();
              console.log("One Tap not displayed:", reason);
              window._dartGoogleError("not_displayed: " + reason);
            } else if (notification.isSkippedMoment()) {
              var reason = notification.getSkippedReason();
              console.log("One Tap skipped:", reason);
              window._dartGoogleError("skipped: " + reason);
            }
            // لا شيء إذا isDisplayMoment — ننتظر اختيار المستخدم
          });
        } catch(e) {
          console.error("GIS error:", e);
          window._dartGoogleError(e.toString());
        }
      })();
    ''']);
  } catch (e) {
    if (!completer.isCompleted) {
      completer.complete(null);
    }
  }

  // انتظار callback (مع timeout 60 ثانية)
  return completer.future.timeout(
    const Duration(seconds: 60),
    onTimeout: () => null,
  );
}
