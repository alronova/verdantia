import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:verdantia/core/utils/action_utils.dart';
import 'package:verdantia/core/utils/garden_utils.dart';
import 'package:verdantia/data/models/cooldown_model.dart';
import 'package:verdantia/data/models/plant_model.dart';
import 'package:verdantia/features/garden/bloc/garden_bloc.dart';
import 'package:verdantia/features/garden/bloc/plot_bloc.dart';
import 'package:verdantia/features/garden/view/plant_action_screen.dart';
import 'package:verdantia/features/garden/widgets/misc_widgets.dart';
import 'package:verdantia/features/settings/bloc/user_cubit.dart';

class PlantActionTile extends StatelessWidget {
  final String? imagePath;
  final Plant plant;
  final bool isDisabled;
  final Duration? remaining;
  final PlantAction action;
  final BuildContext localContext;

  const PlantActionTile({
    super.key,
    required this.imagePath,
    required this.plant,
    required this.isDisabled,
    required this.remaining,
    required this.action,
    required this.localContext,
  });

  @override
  Widget build(BuildContext context) {
    final plotBloc = localContext.read<PlotBloc>();
    final gardenBloc = localContext.read<GardenBloc>();
    final userCubit = localContext.read<UserCubit>();

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
            imagePath != null
                ? Image.file(
                    File(imagePath!),
                    height: 40,
                    width: 40,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.image_not_supported),
                  )
                : const SizedBox(width: 40, height: 40),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  capitalize(plant.plantName),
                  style: pixelStyle.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 2),
                Text('HP: ${plant.hp}'),
              ],
            ),
            ElevatedButton.icon(
              onPressed: isDisabled && action != PlantAction.view
                  ? null
                  : () async {
                      if (action == PlantAction.view) return;

                      final isCooldown = await CooldownManager.isOnCooldown(
                          plant.plantId, action);
                      print(
                          'Cooldown for ${plant.plantId} & $action: $isCooldown');
                      if (isCooldown) return;

                      await CooldownManager.setLastActionTime(
                          plant.plantId, action);

                      if (!context.mounted) return;

                      final user = userCubit.state;
                      if (user != null) {
                        userCubit.updateXp(10);
                        userCubit.updateCoins(user.coins + 5);
                      }

                      switch (action) {
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

                      gardenBloc.add(UpdatePlot(plotBloc.state.plot));
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isDisabled ? Colors.grey : const Color(0xffF3EFB1),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(width: 1, color: Colors.black),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              icon: const Icon(Icons.check),
              label: Text(
                isDisabled && remaining != null
                    ? formatRemainingTime(remaining!)
                    : getActionLabel(action),
                style: GoogleFonts.pixelifySans(fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
