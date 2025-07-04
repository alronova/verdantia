import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:verdantia/data/models/plot_model.dart';
import 'package:verdantia/data/models/user_model.dart';
import 'package:verdantia/features/garden/bloc/garden_bloc.dart';
import 'package:verdantia/features/garden/bloc/plotgrid_cubit.dart';
import 'package:verdantia/features/garden/widgets/coinxp_widget.dart';
import 'package:verdantia/features/garden/widgets/misc_widgets.dart';
import 'package:verdantia/features/onboarding/selected_plants_cubit.dart';
import 'package:verdantia/features/settings/bloc/user_cubit.dart';

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
  // final Duration _lastElapsed = Duration.zero;

  // initState
  @override
  void initState() {
    super.initState();

    // load all plot frames
    loadAllPlotFrames().then((frames) {
      setState(() {
        plotFrames = frames;
      });
    });
    // load all can frames
    loadAllCanFrames().then((frames) {
      setState(() {
        canFrames = frames;
      });
    });

    // tell gardenbloc to load the garden into gardenloaded state
    // from firestore
    context.read<GardenBloc>().add(LoadGarden());

    // create an animation controller for the plot
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10000),
    );

    _controller.repeat();
  }

  @override
  void dispose() {
    // must dispose the animation controller or itll cause the app to hang while switching screens
    _controller.dispose(); // <--- Must dispose
    super.dispose();
  }

  // ----------------------- WIDGETS --------------------------
  @override
  Widget build(BuildContext context) {
    final selectedPlants = context.watch<SelectedPlantsCubit>().state;
    // final screen = MediaQuery.of(context).size;
    // listens to gardenstate
    return Stack(
      children: [
        // background
        Positioned.fill(
          child: Image.asset(
            'assets/new/garden.png',
            fit: BoxFit.cover,
          ),
        ),
        BlocBuilder<UserCubit, AppUser?>(
          builder: (context, user) {
            if (user == null) return SizedBox();

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
              child: Column(
                children: [
                  // xp and coins bar
                  HeaderBar(
                    coins: user.coins,
                    currentXp: user.xp,
                    currentLevel: user.level,
                  ),

                  //
                  BlocListener<GardenBloc, GardenState>(
                    listener: (context, state) {
                      if (state is GardenLoaded) {
                        context.read<PlotsCubit>().setPlots(state.plots);
                      }
                    },

                    // garden plots
                    child: BlocBuilder<PlotsCubit, List<Plot>>(
                      builder: (context, plots) {
                        if (plots.isEmpty || plotFrames == null) {
                          return Center(child: CircularProgressIndicator());
                        }

                        final tileWidth = 70.0; // or the actual sprite width
                        final tileHeight =
                            28.0; // or half of height if isometric

                        // isometric plot positions
                        final plotPositions = <Offset>[];
                        for (int row = 0; row < 4; row++) {
                          for (int col = 0; col < 4; col++) {
                            plotPositions.add(isoTilePosition(
                                row, col, tileWidth, tileHeight));
                          }
                        }

                        final canvasSize = const Size(
                            500, 400); // same as your CustomPaint size
                        final offsetToCenter =
                            computeOffsetToCenter(plotPositions, canvasSize);
                        final offsetPlotPositions = plotPositions
                            .map((p) => p + offsetToCenter)
                            .toList();

                        // gesture detector to find the index of the plot that was tapped
                        return Column(
                          children: [
                            SizedBox(height: 20),
                            Container(
                              decoration: BoxDecoration(
                                color:
                                    const ui.Color.fromARGB(255, 238, 236, 208),
                                borderRadius: BorderRadius.circular(20),
                                border:
                                    Border.all(color: Colors.black, width: 2),
                              ),
                              child: Center(
                                child: CustomPaint(
                                  painter: GardenPainter(
                                    repaint: _controller,
                                    plots: plots,
                                    positions: offsetPlotPositions,
                                    plotFrames: plotFrames!,
                                  ),
                                  size: Size(500, 400),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Container(
                              decoration: BoxDecoration(
                                color:
                                    const ui.Color.fromARGB(255, 238, 236, 208),
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: Colors.black, width: 2),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Total plants",
                                      style: pixelStyle,
                                    ),
                                    Text(
                                      "2",
                                      style: pixelStyle,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Container(
                              decoration: BoxDecoration(
                                color:
                                    const ui.Color.fromARGB(255, 238, 236, 208),
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: Colors.black, width: 2),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Garden Health",
                                      style: pixelStyle,
                                    ),
                                    Text(
                                      "100%",
                                      style: pixelStyle,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                actionButton(
                                    "Water",
                                    () => openPlantActionScreen(
                                        context, PlantAction.water)),
                                actionButton(
                                    "Sun",
                                    () => openPlantActionScreen(
                                        context, PlantAction.sunlight)),
                                actionButton(
                                    "Fertilize",
                                    () => openPlantActionScreen(
                                        context, PlantAction.fertilize)),
                                actionButton("View",
                                    () => openViewActionScreen(context)),
                              ],
                            )
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
// ----------------------- WIDGETS --------------------------

// custom painter child class
class GardenPainter extends CustomPainter {
  final List<Plot> plots;
  final List<Offset> positions;
  final List<ui.Image> plotFrames;
  // final List<AnimatedObject> animatedObjects;
  final bool showHitboxes;

  GardenPainter({
    super.repaint,
    required this.plots,
    required this.positions,
    required this.plotFrames,
    // required this.animatedObjects,
    this.showHitboxes = false,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final now = DateTime.now();

    // --- Grid centering ---
    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (final pos in positions) {
      if (pos.dx < minX) minX = pos.dx;
      if (pos.dx > maxX) maxX = pos.dx;
      if (pos.dy < minY) minY = pos.dy;
      if (pos.dy > maxY) maxY = pos.dy;
    }

    final gridCenter = Offset((minX + maxX) / 2, (minY + maxY) / 2);
    final canvasCenter = Offset(size.width / 2, size.height / 2);
    final offsetToCenter = canvasCenter - gridCenter;

    canvas.save();
    canvas.translate(offsetToCenter.dx, offsetToCenter.dy);

    // --- Draw plots ---
    for (int i = 0; i < plots.length; i++) {
      final plot = plots[i];
      final pos = positions[i];

      int frameIndex = 0;
      if (plot.lastWatered != null) {
        final elapsed = now.difference(plot.lastWatered!).inSeconds;
        final percent = (elapsed / (12 * 60 * 60)).clamp(0, 1.0);
        frameIndex = ((1 - percent) * 18).floor();
      }

      final image = plotFrames[frameIndex];
      drawPlot(canvas, pos, image);

      if (showHitboxes) {
        _drawDiamondHitbox(canvas, pos, image);
      }
    }

    canvas.restore();
  }

  // function to draw diamond shaped hitboxes for the garden plots
  void _drawDiamondHitbox(Canvas canvas, Offset pos, ui.Image image) {
    const scale = 0.25;
    final width = image.width * scale;
    final height = image.height * scale;

    final centerX = pos.dx - 40 + width / 2;
    final centerY = pos.dy - 45 + height / 1.6;

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
