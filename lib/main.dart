import 'package:brainfood/firebase_options.dart';
import 'package:brainfood/providers/user_provider.dart';
import 'package:brainfood/utils/auth_state_listener.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'brainfood',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            fontFamily: 'Montserrat',
            colorScheme: const ColorScheme.light(
              primary: Colors.white,
              onPrimary: Colors.black87,
              onSecondary: Colors.black87,
              secondary: Color.fromRGBO(149, 117, 205, 1),
            ),
            textSelectionTheme: const TextSelectionThemeData(
              cursorColor: Colors.black,
              selectionColor: Color.fromRGBO(149, 117, 205, 0.4),
              selectionHandleColor: Color.fromRGBO(149, 117, 205, 1),
            )),
        initialRoute: '/secondroute',
        routes: {
          '/root': (context) => const MyApp(),
          '/secondroute': (context) => const AuthStateListener(),
        },
      ),
    );
  }
}
