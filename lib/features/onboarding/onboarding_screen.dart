import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:verdantia/core/services/image_gen_service.dart';
import 'package:verdantia/core/services/plant_service.dart';
import 'package:verdantia/features/onboarding/selected_plants_cubit.dart';
import 'package:uuid/uuid.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final List<String> plantNames = [
    'oak',
    'pine',
    'birch',
    'willow',
    'palm',
    'maple'
  ];

  Map<String, String> plants = {
    'oak': '',
    'pine': '',
    'birch': '',
    'willow': '',
    'palm': '',
    'maple': ''
  };

  bool isLoading = true;
  Set<int> selectedIndexes = {};

  @override
  void initState() {
    super.initState();
    generateAllSprites();
  }

  Future<void> generateAllSprites() async {
    for (var name in plantNames) {
      final spritePath = await generatePlantSprite(name);
      plants[name] = spritePath;
    }
    setState(() {
      isLoading = false;
    });
  }

  void toggleSelection(int index) {
    setState(() {
      if (selectedIndexes.contains(index)) {
        selectedIndexes.remove(index);
      } else if (selectedIndexes.length < 2) {
        selectedIndexes.add(index);
      }
    });
  }

  void _handleSubmit() async {
    final selectedPlantNames =
        selectedIndexes.map((index) => plantNames[index]).toList();

    // context.read<SelectedPlantsCubit>().selectPlants(selectedPlantNames);

    final userId = FirebaseAuth.instance.currentUser!.uid;
    final plantService = PlantService();
    final uuid = Uuid();

    for (int i = 0; i < selectedPlantNames.length; i++) {
      final plantName = selectedPlantNames[i];

      await plantService.createUserPlant(
        userId: userId,
        plantId: uuid.v4(), // <-- Unique plant instance ID
        plantName: plantName,
        age: 10,
        hp: 5,
        disease: "",
        diseaseIntensity: 0,
        plotIndex: i,
      );
    }
    if (!mounted) return;
    context.go('/garden');
  }

  bool isButtonEnabled() => selectedIndexes.length == 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/new/startgrowing.png', // replace with your background path
              fit: BoxFit.cover,
            ),
          ),

          // Foreground content
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    'START GROWING',
                    style: GoogleFonts.pixelifySans(
                      fontSize: 30,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('🌱 Select two plants of your choice…'),
                  const SizedBox(height: 12),

                  // Container(
                  //   width: double.infinity,
                  //   padding: const EdgeInsets.symmetric(vertical: 16),
                  //   decoration: BoxDecoration(
                  //     color: const Color(0xffE8E6B9),
                  //     borderRadius: BorderRadius.circular(12),
                  //     border: Border.all(color: Colors.black, width: 1),
                  //   ),
                  //   child: Center(
                  //     child: Text(
                  //       'Customize',
                  //       style: GoogleFonts.dmMono(
                  //         fontSize: 14,
                  //         color: Colors.black87,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(height: 16),

                  // grid of plant boxes
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Expanded(
                          child: GridView.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1,
                            children: List.generate(plantNames.length, (index) {
                              final plant = plantNames[index];
                              final imagePath = plants[plant]!;

                              return SelectablePlantBox(
                                isSelected: selectedIndexes.contains(index),
                                onTap: () => toggleSelection(index),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (imagePath.isNotEmpty)
                                      Image.file(
                                        File(imagePath),
                                        height: 60,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(
                                                Icons.image_not_supported),
                                      )
                                    else
                                      const Icon(Icons.hourglass_empty),
                                    const SizedBox(height: 8),
                                    Text(plant[0].toUpperCase() +
                                        plant.substring(1)),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ),

                  const SizedBox(height: 12),

                  // start planting button
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton.icon(
                      onPressed: isButtonEnabled() ? _handleSubmit : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffF3EFB1),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(width: 1, color: Colors.black),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                      ),
                      label: Text(
                        'Start Planting!',
                        style: GoogleFonts.pixelifySans(fontSize: 15),
                      ),
                    ),
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

// selectable plant box
class SelectablePlantBox extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? child;

  const SelectablePlantBox({
    Key? key,
    required this.isSelected,
    required this.onTap,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xffD2DBA7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.black,
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            if (child != null) Center(child: child!),
            const Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.all(6.0),
                child: SizedBox(
                  height: 6,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0xffEFF3D5),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ),
                ),
              ),
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Icon(Icons.check_circle, color: Colors.green),
              ),
          ],
        ),
      ),
    );
  }
}
