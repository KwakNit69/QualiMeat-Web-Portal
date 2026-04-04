import 'package:flutter/material.dart';

import 'login_page.dart';

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'QualiMeat',
//       theme: ThemeData(
//         scaffoldBackgroundColor: Colors.white,
//         primaryColor: const Color(0xFF00E676),
//         useMaterial3: true,
//       ),
//       home: const WelcomeScreen(),
//     );
//   }
// }

// ================= WELCOME SCREEN =================

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Defining the specific colors from the design
    final Color primaryGreen = const Color(0xFF00E676);
    final Color darkText = const Color(0xFF101010);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 1),

              // 1. Header Text
              Text(
                "WELCOME",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: darkText,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "to",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: darkText,
                ),
              ),

              const Spacer(flex: 1),

              // 2. Custom Logo Widget
              const ShieldLogo(),

              const Spacer(flex: 1),

              // 3. App Name
              Text(
                "QualiMeat",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: darkText,
                ),
              ),
              const SizedBox(height: 15),
              // 4. Subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  "Your quality meat checker at your fingertips",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const Spacer(flex: 3),

              // 5. "Get Started" Button (UPDATED WITH NAVIGATION)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to LoginPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Get Started",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 6. Login Footer (UPDATED WITH NAVIGATION)
              GestureDetector(
                onTap: () {
                  // Navigate to LoginPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: RichText(
                  text: TextSpan(
                    text: "Already have an account? ",
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(
                        text: "Log In",
                        style: TextStyle(
                          color: primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= CUSTOM LOGO WIDGET =================

class ShieldLogo extends StatelessWidget {
  const ShieldLogo({super.key});

  @override
  Widget build(BuildContext context) {
    const Color logoGreen = Color(0xFF00E676);

    return SizedBox(
      height: 160,
      width: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 150,
            width: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: logoGreen.withOpacity(0.05),
            ),
          ),
          Container(
            height: 110,
            width: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: logoGreen.withOpacity(0.15),
              border: Border.all(
                color: logoGreen.withOpacity(0.3),
                width: 1.5,
              ),
            ),
          ),
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: logoGreen,
              boxShadow: [
                BoxShadow(
                  color: logoGreen.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.gpp_good_rounded,
              size: 40,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}