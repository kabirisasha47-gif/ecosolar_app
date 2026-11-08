import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ecosolar/core/theme.dart';
import 'package:ecosolar/routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark));
  runApp(const EcoSolarApp());
}

class EcoSolarApp extends StatelessWidget {
  const EcoSolarApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'EcoSolar',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        locale: const Locale('fa', 'IR'),
        supportedLocales: const [Locale('fa', 'IR')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        initialRoute: '/login',
        routes: appRoutes,
        builder: (c, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
      );
}
