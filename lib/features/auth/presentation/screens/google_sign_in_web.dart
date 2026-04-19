import 'dart:async';
import 'dart:js_util' show allowInterop;
import 'dart:js' as js;

/// Google Sign-In Web — أبسط طريقة ممكنة
/// يستدعي startGoogleSignIn(onSuccess, onError) المعرّفة في index.html
Future<String?> callGoogleOneTapWeb() async {
  final completer = Completer<String?>();

  // Success callback — dynamic لتجنب type cast errors
  final onSuccess = allowInterop((dynamic credential) {
    print('✅ Dart received credential');
    if (!completer.isCompleted) {
      final token = credential?.toString();
      completer.complete(token);
    }
  });

  // Error callback — dynamic لتجنب type cast errors
  final onError = allowInterop((dynamic error) {
    print('⚠️ Google Sign-In error: $error');
    if (!completer.isCompleted) {
      completer.complete(null);
    }
  });

  try {
    // تحقق من وجود الدالة
    final hasFunc = js.context.hasProperty('startGoogleSignIn');
    if (hasFunc != true) {
      print('❌ startGoogleSignIn not found in window');
      return null;
    }

    // استدعاء JS function مع callbacks
    js.context.callMethod('startGoogleSignIn', [onSuccess, onError]);
  } catch (e) {
    print('❌ callMethod error: $e');
    if (!completer.isCompleted) {
      completer.complete(null);
    }
  }

  return completer.future.timeout(
    const Duration(seconds: 60),
    onTimeout: () {
      print('⏰ Timeout — no Google response');
      return null;
    },
  );
}
