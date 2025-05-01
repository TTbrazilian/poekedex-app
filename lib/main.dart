import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pokedex/theme/theme_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pokedex/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDS7ovfAl9YvT1lQkCl6KYqg7AZzLdfznA",
      authDomain: "pokedex-app-3ee92.firebaseapp.com",
      projectId: "pokedex-app-3ee92",
      storageBucket: "pokedex-app-3ee92.appspot.com",
      messagingSenderId: "71709224349",
      appId: "1:71709224349:web:07a755833c9fa2688ad374",
    ),
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeManager(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context, listen: true);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeManager.isDark ? ThemeMode.dark : ThemeMode.light,
      home: const LoginPage(),
    );
  }
}
