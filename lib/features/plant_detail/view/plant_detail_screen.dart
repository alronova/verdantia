import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:verdantia/core/services/image_gen_service.dart';
import 'package:verdantia/features/garden/widgets/misc_widgets.dart';

import '../bloc/plant_bloc.dart';

class PlantDetailScreen extends StatefulWidget {
  final int plotIndex;

  const PlantDetailScreen({super.key, required this.plotIndex});

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<PlantBloc>().add(FetchUserPlants(user.uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Image.asset(
              'assets/new/garden.png',
              fit: BoxFit.cover,
            ),
          ),
          BlocBuilder<PlantBloc, PlantState>(
            builder: (context, state) {
              if (state is PlantLoading || state is PlantInitial) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is PlantError) {
                return Center(child: Text('Error: ${state.message}'));
              } else if (state is PlantLoaded) {
                final plant = state.plants.firstWhere(
                  (p) => p.plotIndex == widget.plotIndex,
                );
                final spriteFuture = generatePlantSpriteFromPlant(plant);
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  child: Column(
                    children: [
                      newContainer(
                        child: FutureBuilder<String>(
                          future: spriteFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const SizedBox(
                                height: 300,
                                width: double.infinity,
                                child:
                                    Center(child: CircularProgressIndicator()),
                              );
                            } else if (snapshot.hasError) {
                              return SizedBox(
                                height: 300,
                                width: double.infinity,
                                child: Center(
                                    child: Text('❌ Failed to load image')),
                              );
                            } else {
                              return Image.file(
                                File(snapshot.data!),
                                height: 300,
                                width: double.infinity,
                                fit: BoxFit.contain,
                              );
                            }
                          },
                        ),
                      ),
                      Text(
                        plant.plantName[0].toUpperCase() +
                            plant.plantName.substring(1),
                        style: pixelStyle.copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 10),
                      infoBox(text: "HP", info: plant.hp.toString()),
                      const SizedBox(height: 10),
                      infoBox(text: "Age", info: plant.age.toString()),
                      const SizedBox(height: 10),
                      infoBox(
                          text: "Disease",
                          info: (plant.disease == "" ? "None" : plant.disease)),
                      const SizedBox(height: 10),
                      infoBox(
                          text: "Disease Intensity",
                          info: plant.diseaseIntensity.toString()),
                    ],
                  ),
                );
              } else {
                return const Center(child: Text('Unexpected state'));
              }
            },
          ),
        ],
      ),
    );
  }
}
