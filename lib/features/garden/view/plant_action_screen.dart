import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:verdantia/core/utils/garden_utils.dart';
import 'package:verdantia/features/garden/widgets/misc_widgets.dart';

class PlantActionScreen extends StatelessWidget {
  final PlantAction action;

  const PlantActionScreen({super.key, required this.action});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getTitleForAction(action),
          style: GoogleFonts.pixelifySans(),
        ),
      ),
      body: Container(
        height: 100,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 238, 236, 208),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Garden Health",
                style: pixelStyle,
              ),
              Text(
                "89%",
                style: pixelStyle,
              ),
            ],
          ),
        ),
      ),
      // FutureBuilder(
      //   future: _loadPlants(),
      //   builder: (context, snapshot) {
      //     if (!snapshot.hasData) return CircularProgressIndicator();

      //     final plants = snapshot.data!;
      //     return ListView.builder(
      //       itemCount: plants.length,
      //       itemBuilder: (context, index) {
      //         final plant = plants[index];
      //         return ListTile(
      //           title: Text(plant.name),
      //           trailing: _getActionButton(plant),
      //         );
      //       },
      //     );
      //   },
      // ),
    );
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
