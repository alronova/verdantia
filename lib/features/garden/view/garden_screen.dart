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

class _GardenScreenState extends State<GardenScreen>
    with TickerProviderStateMixin {
  List<ui.Image>? plotFrames;
  List<ui.Image>? canFrames;
  late final AnimationController _controller;
  final List<AnimatedObject> activeAnimations = [];
  Duration _lastElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();

    loadAllPlotFrames().then((frames) {
      setState(() {
        plotFrames = frames;
      });
    });

    loadAllCanFrames().then((frames) {
      setState(() {
        canFrames = frames;
      });
    });

    context.read<GardenBloc>().add(LoadGarden());
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10000),
    );

    _controller.addListener(() {
      setState(() {
        activeAnimations.removeWhere((anim) => anim.isDone);
      });
    });

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose(); // <--- Must dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GardenBloc, GardenState>(
      listener: (context, state) {
        if (state is GardenLoaded) {
          context.read<PlotsCubit>().setPlots(state.plots);
        }
      },
      child: BlocBuilder<PlotsCubit, List<Plot>>(
        builder: (context, plots) {
          if (plots.isEmpty || plotFrames == null) {
            return Center(child: CircularProgressIndicator());
          }

          final tileWidth = 70.0; // or the actual sprite width
          final tileHeight = 28.0; // or half of height if isometric

          final plotPositions = <Offset>[];
          for (int row = 0; row < 4; row++) {
            for (int col = 0; col < 4; col++) {
              plotPositions
                  .add(isoTilePosition(row, col, tileWidth, tileHeight));
            }
          }
          return GestureDetector(
            onTapDown: (details) {
              final box = context.findRenderObject() as RenderBox;
              final localTap = box.globalToLocal(details.globalPosition);

              // Center offset (same as what Center applies)
              final gardenOffset = Offset(
                (box.size.width - 400) / 2,
                (box.size.height - 400) / 2,
              );

              final tap = localTap - gardenOffset;

              final index =
                  findTappedPlotIndex(tap, plotPositions, plotFrames!);

              if (index != null) {
                final adjustedTap =
                    tap.translate(-45, -35); // optional position adjustment
                activeAnimations.add(WateringCanAnimation(
                  frames: canFrames!,
                  position: adjustedTap,
                ));

                context.read<PlotsCubit>().waterPlot(index);

                final plot = context.read<PlotsCubit>().getByIndex(index);
                final updatedPlot = plot.copyWith(lastWatered: DateTime.now());
                context.read<GardenBloc>().add(UpdatePlot(updatedPlot));
              }
            },
            child: Center(
              child: CustomPaint(
                painter: GardenPainter(
                  repaint: _controller,
                  plots: plots,
                  positions: plotPositions,
                  plotFrames: plotFrames!,
                  animatedObjects: activeAnimations, // ✅ Pass here
                ),
                size: Size(400, 400),
              ),
            ),
          );
        },
      ),
    );
  }
}

class GardenPainter extends CustomPainter {
  final List<Plot> plots;
  final List<Offset> positions;
  final List<ui.Image> plotFrames;
  final List<AnimatedObject> animatedObjects;
  final bool showHitboxes;

  GardenPainter({
    super.repaint,
    required this.plots,
    required this.positions,
    required this.plotFrames,
    required this.animatedObjects,
    this.showHitboxes = false,
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

    for (final anim in animatedObjects) {
      anim.paint(canvas);
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

abstract class AnimatedObject {
  late bool isDone;
  void update(Duration delta);
  void paint(Canvas canvas);
}

class WateringCanAnimation extends AnimatedObject {
  final List<ui.Image> frames;
  final Offset position;
  final double duration = 1.5; // seconds

  late final Stopwatch _stopwatch;
  bool _isDone = false;

  WateringCanAnimation({
    required this.frames,
    required this.position,
  }) {
    _stopwatch = Stopwatch()..start();
  }

  @override
  bool get isDone {
    return _stopwatch.elapsed.inMilliseconds / 1000.0 > duration;
  }

  @override
  void update(Duration delta) {
    // nothing needed here anymore
  }

  @override
  void paint(Canvas canvas) {
    final time = _stopwatch.elapsed.inMilliseconds / 1000.0;
    final t = (time / duration).clamp(0.0, 1.0);

    int frameIndex = (t * frames.length).floor();
    frameIndex = frameIndex.clamp(0, frames.length - 1);

    final image = frames[frameIndex];
    final paint = Paint();
    final dst = Rect.fromLTWH(
      position.dx,
      position.dy,
      image.width * 0.25,
      image.height * 0.25,
    );
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      dst,
      paint,
    );
  }
}
