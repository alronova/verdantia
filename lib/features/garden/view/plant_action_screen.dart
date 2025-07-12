import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:verdantia/core/services/image_gen_service.dart';
import 'package:verdantia/core/utils/action_utils.dart';
import 'package:verdantia/core/utils/garden_utils.dart';
import 'package:verdantia/data/models/cooldown_model.dart';
import 'package:verdantia/features/garden/bloc/garden_bloc.dart';
import 'package:verdantia/features/garden/bloc/plot_bloc.dart';
import 'package:verdantia/features/garden/widgets/misc_widgets.dart';
import 'package:verdantia/features/garden/widgets/plant_action_tile.dart';
import 'package:verdantia/features/onboarding/selected_plants_cubit.dart';
import 'package:verdantia/features/plant_detail/bloc/plant_bloc.dart';
import 'package:verdantia/features/settings/bloc/user_cubit.dart';

class PlantActionScreen extends StatefulWidget {
  final PlantAction action;
  const PlantActionScreen({super.key, required this.action});

  @override
  State<PlantActionScreen> createState() => _PlantActionScreenState();
}

class _PlantActionScreenState extends State<PlantActionScreen> {
  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<PlantBloc>().add(FetchUserPlants(user.uid));
    }
  }

  void handleActionSubmit(String plantId, int plotIndex) async {
    if (widget.action == PlantAction.view) return;

    final isCooldown =
        await CooldownManager.isOnCooldown(plantId, widget.action);
    if (isCooldown) return;
    await CooldownManager.setLastActionTime(plantId, widget.action);

    if (!mounted) return;

    final userCubit = context.read<UserCubit>();
    final user = userCubit.state;
    if (user != null) {
      userCubit.updateXp(user.xp + 10);
      userCubit.updateCoins(user.coins + 5);
    }

    // 1. Send the action to the PlotBloc (individual plot's local state)
    final plotBloc = context.read<PlotBloc>();
    switch (widget.action) {
      case PlantAction.water:
        plotBloc.add(WaterPlot());
        break;
      case PlantAction.sunlight:
        plotBloc.add(SunlightPlot());
        break;
      case PlantAction.fertilize:
        plotBloc.add(FertilizePlot());
        break;
      default:
        break;
    }

    // 2. Also update the global GardenBloc (to persist in Firestore)
    final gardenBloc = context.read<GardenBloc>();
    final updatedPlot = plotBloc.state.plot;
    gardenBloc.add(UpdatePlot(updatedPlot));

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTitleForAction(widget.action)),
      ),
      body: BlocBuilder<PlantBloc, PlantState>(
        builder: (context, state) {
          if (state is PlantLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PlantLoaded) {
            final plants = state.plants;

            if (plants.isEmpty) {
              return const Center(child: Text("You have no plants yet."));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: plants.map((plant) {
                  final plantName = plant.plantName;
                  final plotIndex = plant.plotIndex;

                  return FutureBuilder<bool>(
                    future: CooldownManager.isOnCooldown(
                        plant.plantId, widget.action),
                    builder: (context, snapshot) {
                      final isDisabled = snapshot.data ?? false;

                      return FutureBuilder<String>(
                        future: generatePlantSprite(plantName),
                        builder: (context, snapshot) {
                          final path = snapshot.data;
                          final remainingFuture =
                              CooldownManager.getRemainingCooldown(
                            plant.plantId,
                            widget.action,
                          );

                          final gardenState = context.read<GardenBloc>().state;

                          if (gardenState is GardenLoaded) {
                            final plot = gardenState.plots.firstWhere(
                              (p) => p.index == plotIndex,
                              orElse: () =>
                                  throw Exception("Plot $plotIndex not found."),
                            );
                            final user = FirebaseAuth.instance.currentUser;

                            return BlocProvider<PlotBloc>(
                              create: (_) =>
                                  PlotBloc(plot: plot, uid: user!.uid),
                              child: Builder(builder: (localContext) {
                                return FutureBuilder<Duration?>(
                                  future: remainingFuture,
                                  builder: (context, snap) {
                                    final remaining = snap.data;

                                    return PlantActionTile(
                                      imagePath: path,
                                      plant: plant,
                                      isDisabled: isDisabled,
                                      remaining: remaining,
                                      action: widget.action,
                                      localContext: localContext,
                                    );
                                  },
                                );
                              }),
                            );
                          }
                          return const SizedBox();
                        },
                      );
                    },
                  );
                }).toList(),
              ),
            );
          } else if (state is PlantError) {
            return Center(child: Text(state.message));
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }
}
