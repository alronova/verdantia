import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:verdantia/core/utils/garden_utils.dart';

String getTitleForAction(PlantAction action) {
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

String getActionLabel(PlantAction action) {
  switch (action) {
    case PlantAction.water:
      return "Water";
    case PlantAction.sunlight:
      return "Sunlight";
    case PlantAction.fertilize:
      return "Fertilize";
    case PlantAction.view:
      return "All Plants";
  }
}

String formatRemainingTime(Duration duration) {
  final h = duration.inHours;
  final m = duration.inMinutes.remainder(60);
  return '${h}h ${m}m';
}

String capitalize(String s) =>
    s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : s;

void openPlantActionScreen(BuildContext context, PlantAction action) {
  context.push('/plant-action/${action.name}');
}

void openViewActionScreen(BuildContext context) {
  context.push('/view-action');
}
