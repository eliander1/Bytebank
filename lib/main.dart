import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:alura_2/screens/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;


void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  if (kDebugMode) {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);

  } else {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    FirebaseCrashlytics.instance.setUserIdentifier('Sansão10');
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  }
  runZonedGuarded<Future<void>>(() async {
    runApp(BytebankApp());
  }, FirebaseCrashlytics.instance.recordError);


}

class BytebankApp extends StatelessWidget {
  const BytebankApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.green[900],
        appBarTheme: AppBarTheme(color: Colors.green[900]),
        colorScheme:
            ColorScheme.fromSwatch().copyWith(secondary: Colors.green[900]),
      ),
      home: Dashboard(),
    );
  }
}
