import 'dart:io';
import 'package:flutter/material.dart';
import 'pages/splash_page.dart';
import 'pages/login_page.dart';
import 'pages/admin/adminHome.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const ListrikApp());
}

class ListrikApp extends StatelessWidget {
  const ListrikApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Enerlytix',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Poppins'),

      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashPage(),
        '/login': (context) => LoginPage(),
        '/adminHome': (context) => HomeAdminPage(),
      },
    );
  }
}
