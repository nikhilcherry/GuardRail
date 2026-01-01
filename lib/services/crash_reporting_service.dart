import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// A service to abstract crash reporting using Sentry.
class CrashReportingService {
  static final CrashReportingService _instance = CrashReportingService._internal();

  factory CrashReportingService() {
    return _instance;
  }

  CrashReportingService._internal();

  /// Initialize the crash reporting service.
  /// [dsn] is optional. If not provided, Sentry will not send events but the SDK will be initialized.
  Future<void> init({String? dsn}) async {
    if (kDebugMode) {
      debugPrint('[INFO] Initializing CrashReportingService...');
    }

    await SentryFlutter.init(
      (options) {
        options.dsn = dsn ?? 'https://examplePublicKey@o0.ingest.sentry.io/0';
        options.tracesSampleRate = 1.0;
        options.debug = kDebugMode;
      },
    );
  }

  /// Records an error to the crash reporting service.
  Future<void> recordError(dynamic exception, StackTrace? stack, {dynamic reason}) async {
    if (kDebugMode) {
      debugPrint('[ERROR] Reporting crash: $reason');
      debugPrint('Exception: $exception');
      if (stack != null) debugPrint('Stack: $stack');
    }

    if (!kDebugMode) {
       await Sentry.captureException(
        exception,
        stackTrace: stack,
        hint: Hint.withMap({'reason': reason}),
      );
    }
  }
}
