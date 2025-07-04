import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:verdantia/features/onboarding/selected_plants_cubit.dart';
import 'package:verdantia/features/settings/bloc/user_cubit.dart';

class ViewActionScreen extends StatelessWidget {
  const ViewActionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedPlants = context.watch<SelectedPlantsCubit>().state;
    final user = context.watch<UserCubit>().state;
    final userCubit = context.read<UserCubit>();
    final plantCubit = context.read<SelectedPlantsCubit>();

    return Scaffold(
      appBar: AppBar(title: const Text('Your Garden')),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: 16,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          final isUnlocked = index < selectedPlants.length;

          if (isUnlocked) {
            final plantName = selectedPlants[index];
            return Container(
              decoration: BoxDecoration(
                color: const Color(0xffFFFBD9),
                border: Border.all(color: Colors.black, width: 1.5),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              padding: const EdgeInsets.all(6),
              child: Text(
                plantName[0].toUpperCase() + plantName.substring(1),
                style: GoogleFonts.pixelifySans(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            );
          } else {
            return Container(
              decoration: BoxDecoration(
                color: const Color(0xffE8E8E8),
                border: Border.all(color: Colors.black, width: 1.5),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Plot ${index + 1}",
                      style: GoogleFonts.pixelifySans(fontSize: 12)),
                  const SizedBox(height: 0),
                  ElevatedButton(
                    onPressed:
                        (user != null && user.coins >= 100) ? () {} : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow[200],
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                        side: const BorderSide(color: Colors.black),
                      ),
                    ),
                    child: Text("Buy (100)",
                        style: GoogleFonts.pixelifySans(fontSize: 10)),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
