/*
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login/login.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: 'AIzaSyBoR7S1-5tR_G6UZYy7e4dJUeBiYcWv2yg',
        appId: 'accproject-3178e',
        messagingSenderId: '199215746729',
        projectId: 'accproject-3178e',
        storageBucket: 'accproject-3178e.appspot.com',
      )
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
          brightness: Brightness.light,
          primary: Colors.white, // Set the primary color to white
          onPrimary: Colors.black, // Set the onPrimary color to black for contrast
          secondary: Colors.grey, // Customize other colors as needed
          onSecondary: Colors.black,
          surface: Colors.white,
          onSurface: Colors.black,
          error: Colors.red,
          onError: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: LoginPage(),
    );
  }
}

*/
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Authfuction/authcontroller.dart';
import 'login/login.dart';

Future<void> main() async {
  // Register AuthController


  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyBoR7S1-5tR_G6UZYy7e4dJUeBiYcWv2yg',
        appId: 'accproject-3178e',
        messagingSenderId: '199215746729',
        projectId: 'accproject-3178e',
        storageBucket: 'accproject-3178e.appspot.com',
      )
  );
  Get.put(AuthController());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home:  LoginPage(), // Set initial page
    );
  }
}
