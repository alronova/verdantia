import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:verdantia/core/services/image_gen_service.dart';
import 'package:verdantia/core/utils/garden_utils.dart';
import 'package:verdantia/data/models/cooldown_model.dart';
import 'package:verdantia/features/garden/widgets/misc_widgets.dart';
import 'package:verdantia/features/onboarding/selected_plants_cubit.dart';
import 'package:verdantia/features/settings/bloc/user_cubit.dart';

class PlantActionScreen extends StatefulWidget {
  final PlantAction action;

  const PlantActionScreen({super.key, required this.action});

  @override
  State<PlantActionScreen> createState() => _PlantActionScreenState();
}

class _PlantActionScreenState extends State<PlantActionScreen> {
  final Map<String, DateTime> lastActionTimes = {};

  bool isOnCooldown(String plantName) {
    final lastTime = lastActionTimes[plantName];
    if (lastTime == null) return false;
    return DateTime.now().difference(lastTime).inHours < 5;
  }

  void handleActionSubmit(String plantName) async {
    if (widget.action == PlantAction.view) return;

    final isCooldown =
        await CooldownManager.isOnCooldown(plantName, widget.action);
    if (isCooldown) return;

    // Store cooldown timestamp
    await CooldownManager.setLastActionTime(plantName, widget.action);

    if (!mounted) return;
    final userCubit = context.read<UserCubit>();
    final user = userCubit.state;
    if (user != null) {
      userCubit.updateXp(user.xp + 10);
      userCubit.updateCoins(user.coins + 5);
    }

    setState(() {}); // To refresh cooldown state
  }

  @override
  Widget build(BuildContext context) {
    final selectedPlants = context.watch<SelectedPlantsCubit>().state;

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitleForAction(widget.action)),
      ),
      body: FutureBuilder<List<String>>(
        future: Future.wait(
          selectedPlants.map((name) => generatePlantSprite(name)).toList(),
        ),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final imagePaths = snapshot.data!;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: List.generate(imagePaths.length, (index) {
                  final path = imagePaths[index];
                  final plantName = selectedPlants[index];
                  final isDisabled = isOnCooldown(plantName);
                  final remaining = lastActionTimes[plantName] != null
                      ? Duration(hours: 5) -
                          DateTime.now().difference(lastActionTimes[plantName]!)
                      : null;

                  return FutureBuilder<bool>(
                    future:
                        CooldownManager.isOnCooldown(plantName, widget.action),
                    builder: (context, snapshot) {
                      final isDisabled = snapshot.data ?? false;

                      Duration? remaining;
                      if (isDisabled) {
                        CooldownManager.getLastActionTime(
                                plantName, widget.action)
                            .then((last) {
                          if (last != null) {
                            final diff = DateTime.now().difference(last);
                            setState(() {
                              remaining = Duration(hours: 5) - diff;
                            });
                          }
                        });
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          height: 70,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 255, 251, 217),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black, width: 1.5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Image.file(
                                File(path),
                                height: 40,
                                width: 40,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.image_not_supported),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    plantName[0].toUpperCase() +
                                        plantName.substring(1),
                                    style: pixelStyle.copyWith(fontSize: 20),
                                  ),
                                  const SizedBox(height: 2),
                                  Text('HP: 100'),
                                ],
                              ),
                              ElevatedButton.icon(
                                onPressed: isDisabled &&
                                        widget.action != PlantAction.view
                                    ? null
                                    : () => handleActionSubmit(plantName),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDisabled
                                      ? Colors.grey
                                      : const Color(0xffF3EFB1),
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(
                                        width: 1, color: Colors.black),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 16),
                                ),
                                icon: const Icon(Icons.check),
                                label: Text(
                                  isDisabled && remaining != null
                                      ? formatRemainingTime(remaining!)
                                      : getActionLabel(widget.action),
                                  style: GoogleFonts.pixelifySans(fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
          );
        },
      ),
    );
  }

  String formatRemainingTime(Duration duration) {
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60);
    return '${h}h ${m}m';
  }
}

String _getTitleForAction(PlantAction action) {
  switch (action) {
    case PlantAction.water:
      return "Water Plants";
    case PlantAction.sunlight:
      return "Give Sunlight";
    case PlantAction.fertilize:
      return "Fertilize Plants";
    case PlantAction.view:
      return "All Plants";
  }
}
