import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'landing_page.dart'; // Make sure this matches your file name
import 'login_page.dart'; // Make sure this matches your file name

void main() async {
  // Ensure the Flutter engine is initialized before calling Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  try {
    // Attempt to initialize Firebase
    await Firebase.initializeApp();
    print("====================================");
    print("FIREBASE INITIALIZED SUCCESSFULLY!");
    print("====================================");
  } catch (e) {
    // If it fails, print the error but don't crash the app
    print("====================================");
    print("FIREBASE FAILED TO INITIALIZE:");
    print(e.toString());
    print("====================================");
  }

  // Run the app no matter what
  runApp(const MyApp());
}

// 2. Uncommented this crucial MaterialApp wrapper
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QualiMeat',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: const Color(0xFF00E676),
        useMaterial3: true,
      ),
      // 3. This tells the app to load your WelcomeScreen first
      home: const WelcomeScreen(),
    );
  }
}