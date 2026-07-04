import 'package:flutter/material.dart';

/// Global navigator key so non-widget code (e.g. [ApiClient]) can drive
/// navigation — used to force the user back to login when their session
/// expires (HTTP 401) mid-session, from any screen.
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

/// Global messenger key so non-widget code can surface SnackBars (e.g. the
/// "session expired" notice on a 401) without needing a BuildContext.
final GlobalKey<ScaffoldMessengerState> appMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
