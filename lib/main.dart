import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:senturionscaleg/Uteis/ScrollBehaviorPersonalizado.dart';

import 'Uteis/rotas.dart';
import 'Uteis/constantes.dart';
import 'firebase_options.dart';

void main() async {
  runApp(const MyApp());
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      scrollBehavior: ScrollBehaviorPersonalizado(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      // definindo lingua do data picker
      supportedLocales: const [Locale('pt', 'BR')],
      debugShowCheckedModeBanner: false,
      initialRoute: Constantes.rotaTelaSplash,
      onGenerateRoute: Rotas.generateRoute,
    );
  }
}
