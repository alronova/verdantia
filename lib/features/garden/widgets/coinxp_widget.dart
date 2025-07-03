import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class XPBar extends StatelessWidget {
  final int currentXp;
  final int currentLevel;

  const XPBar({
    super.key,
    required this.currentXp,
    required this.currentLevel,
  });

  int _xpForLevel(int level) => 100 * level * level;

  @override
  Widget build(BuildContext context) {
    final int xpThisLevel = _xpForLevel(currentLevel);
    final int xpNextLevel = _xpForLevel(currentLevel + 1);
    final int xpNeeded = xpNextLevel - xpThisLevel;
    final int xpEarned = currentXp - xpThisLevel;

    final double progress = xpNeeded == 0 ? 1.0 : xpEarned / xpNeeded;

    return Container(
      height: 20,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 1),
        color: const Color(0xFFFFFFFF), // background bar color
      ),
      child: Stack(
        children: [
          FractionallySizedBox(
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFF8EBD9D), // fill color
              ),
            ),
          ),
          Center(
            child: Text(
              'XP: $currentXp',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HeaderBar extends StatelessWidget {
  final int coins;
  final int currentXp;
  final int currentLevel;

  const HeaderBar({
    super.key,
    required this.coins,
    required this.currentXp,
    required this.currentLevel,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Coins section
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2C5652),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.zero,
              bottomLeft: Radius.zero,
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            border: Border.all(color: Colors.white, width: 2),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                constraints: const BoxConstraints(minWidth: 40),
                padding: const EdgeInsets.symmetric(horizontal: 6),
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  coins.toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Image.asset(
                'assets/new/coin.png',
                height: 25,
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // XP Section
        Expanded(
          child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2C5652),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.zero,
                  bottomRight: Radius.zero,
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
                border: Border.all(color: Colors.white, width: 2),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Level $currentLevel",
                    style: GoogleFonts.pixelifySans(
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: XPBar(
                      currentXp: currentXp,
                      currentLevel: currentLevel,
                    ),
                  ),
                ],
              )),
        ),
      ],
    );
  }
}
