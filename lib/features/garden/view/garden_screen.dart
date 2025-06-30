import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:verdantia/data/models/plot_model.dart';
import 'package:verdantia/features/garden/bloc/garden_bloc.dart';
import 'package:verdantia/features/garden/bloc/plotgrid_cubit.dart';

import '../../../core/utils/garden_utils.dart';

class GardenScreen extends StatefulWidget {
  const GardenScreen({super.key});

  @override
  State<GardenScreen> createState() => _GardenScreenState();
}

class _GardenScreenState extends State<GardenScreen> {
  List<ui.Image>? plotFrames;

  @override
  void initState() {
    super.initState();

    loadAllPlotFrames().then((frames) {
      setState(() {
        plotFrames = frames;
      });
    });

    context.read<GardenBloc>().add(LoadGarden());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GardenBloc, GardenState>(
      listener: (context, state) {
        if (state is GardenLoaded) {
          context.read<PlotsCubit>().setPlots(state.plots);
        }
      },
      child: BlocBuilder<PlotsCubit, List<Plot>>(builder: (context, plots) {
        if (plots.isEmpty || plotFrames == null) {
          return Center(child: CircularProgressIndicator());
        }

        final tileWidth = 70.0; // or the actual sprite width
        final tileHeight = 28.0; // or half of height if isometric

        final plotPositions = <Offset>[];
        for (int row = 0; row < 4; row++) {
          for (int col = 0; col < 4; col++) {
            plotPositions.add(isoTilePosition(row, col, tileWidth, tileHeight));
          }
        }
        return GestureDetector(
            onTapDown: (details) {
              final tap = details.localPosition;
              final index = findTappedPlotIndex(
                tap,
                plotPositions,
                plotFrames!,
              );

              if (index != null) {
                context.read<PlotsCubit>().waterPlot(index);

                // also update in firestore via gardenbloc
                final plot = context.read<PlotsCubit>().getByIndex(index);

                final updatedPlot = plot.copyWith(lastWatered: DateTime.now());
                context.read<GardenBloc>().add(UpdatePlot(updatedPlot));
              }
            },
            child: CustomPaint(
              painter: GardenPainter(
                  plots: plots,
                  positions: plotPositions,
                  plotFrames: plotFrames!),
            ));
      }),
    );
  }
}

class GardenPainter extends CustomPainter {
  final List<Plot> plots;
  final List<Offset> positions;
  final List<ui.Image> plotFrames;
  final bool showHitboxes;

  GardenPainter({
    super.repaint,
    required this.plots,
    required this.positions,
    required this.plotFrames,
    this.showHitboxes = true, // Toggle to false in production
  });

  @override
  void paint(Canvas canvas, Size size) {
    final now = DateTime.now();

    for (int i = 0; i < plots.length; i++) {
      final plot = plots[i];
      final pos = positions[i];

      // Water level calculation
      int frameIndex = 0;
      if (plot.lastWatered != null) {
        final elapsed = now.difference(plot.lastWatered!).inSeconds;
        final percent = (elapsed / (12 * 60 * 60)).clamp(0, 1.0);
        frameIndex = ((1 - percent) * 18).floor();
      }

      final image = plotFrames[frameIndex];

      // Draw the tile sprite
      drawPlot(canvas, pos, image);

      if (showHitboxes) {
        _drawDiamondHitbox(canvas, pos, image);
      }
    }
  }

  void _drawDiamondHitbox(Canvas canvas, Offset pos, ui.Image image) {
    const scale = 0.25;
    final width = image.width * scale;
    final height = image.height * scale;

    final centerX = pos.dx + width / 2;
    final centerY = pos.dy + height / 1.6;

    final halfW = width / 2;
    final halfH = height / 6;

    final diamondPath = Path()
      ..moveTo(centerX, centerY - halfH) // top
      ..lineTo(centerX + halfW, centerY) // right
      ..lineTo(centerX, centerY + halfH) // bottom
      ..lineTo(centerX - halfW, centerY) // left
      ..close();

    canvas.drawPath(
      diamondPath,
      Paint()
        ..color = Colors.blue.withAlpha(50)
        ..style = PaintingStyle.fill,
    );

    canvas.drawPath(
      diamondPath,
      Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
