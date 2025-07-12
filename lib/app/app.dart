import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:verdantia/features/botanica/botanica_screen.dart';
import 'package:verdantia/features/chat/chat_screen.dart';
import 'package:verdantia/features/garden/view/garden_screen.dart';
import 'package:verdantia/features/settings/view/settings_screen.dart';
import './router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Verdantia',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        textTheme: GoogleFonts.kodeMonoTextTheme(),
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    GardenScreen(),
    BotanicaScreen(),
    ChatScreen(),
    SettingsScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white, // Explicit background
        selectedItemColor: Colors.green, // or any visible color
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grass),
            label: 'Garden',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Botanica',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
