import 'dart:async';

import 'package:alura_2/screens/name.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:alura_2/screens/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'components/theme.dart';

void main() {
  BlocOverrides.runZoned(
        () {
      runApp(BytebankApp());
    },
    blocObserver: LogObserver(),
  );
}

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//
//   if (kDebugMode) {
//     await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
//   } else {
//     await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
//     FirebaseCrashlytics.instance.setUserIdentifier('Sansão10');
//     FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
//   }
//   runZonedGuarded<Future<void>>(() async {
//         runApp(BytebankApp());
//   }, FirebaseCrashlytics.instance.recordError);
// }

class BytebankApp extends StatelessWidget {
  const BytebankApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: BytebankTheme,
      home: DashboardContainer(),
    );
  }
}

class LogObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    debugPrint('${bloc.runtimeType} > $change');
    super.onChange(bloc, change);
  }
}

