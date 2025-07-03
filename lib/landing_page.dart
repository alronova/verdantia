import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

TextStyle headingStyle = GoogleFonts.pixelifySans(
  fontSize: 40,
  fontWeight: FontWeight.bold,
);

TextStyle descStyle = TextStyle(
    fontSize: 16,
    height: 1.25,
    fontWeight: FontWeight.w400,
    color: Colors.grey[800]);
TextStyle buttonStyle = TextStyle(fontSize: 20);

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/new/auth.png', // Replace with your image path
              fit: BoxFit.cover, // Makes image fill the screen
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        "VERDANTIA",
                        style: headingStyle,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "grow a little green joy",
                        textAlign: TextAlign.center,
                        style: descStyle,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          context.go('/signup');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFFB9CBB3), // soft greenish button
                          foregroundColor:
                              const Color(0xFF2C5E3B), // dark green text
                          shadowColor: Colors.black26,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 100),
                        ),
                        child: const Text("Signup"),
                      ),
                      SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: () {
                          context.go('/login');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFFB9CBB3), // soft greenish button
                          foregroundColor:
                              const Color(0xFF2C5E3B), // dark green text
                          shadowColor: Colors.black26,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 100),
                        ),
                        child: const Text("Login"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
