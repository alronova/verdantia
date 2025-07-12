import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:verdantia/features/garden/view/plant_action_screen.dart';
import 'package:verdantia/features/garden/view/view_action_screen.dart';

Future<void> initializeGardenIfNeeded() async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return;

  final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);
  final doc = await userDoc.get();

  final hasPlots =
      doc.data()?['plot'] != null && (doc.data()?['plot'] as List).isNotEmpty;

  if (!hasPlots) {
    final defaultPlots = List.generate(
        16,
        (i) => {
              'index': i,
              'unlocked': i == 0,
              'plantid': '',
              'lastWatered': Timestamp.now(),
            });

    await userDoc.set({
      'plot': defaultPlots,
      'coins': 0,
      'level': 0,
      'xp': 0,
      'uid': uid,
      'email': FirebaseAuth.instance.currentUser?.email ?? '',
      'username': '', // Set this somewhere else
    }, SetOptions(merge: true));
  }
}

// image loading functions
// getting all 19 plot sprites
Future<List<ui.Image>> loadAllPlotFrames() async {
  final List<ui.Image> frames = [];
  for (int i = 1; i <= 19; i++) {
    final data = await rootBundle.load('assets/ground/Grd_$i.png');
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    frames.add(frame.image);
  }
  return frames;
}

Future<List<ui.Image>> loadAllCanFrames() async {
  final List<ui.Image> frames = [];
  for (int i = 1; i <= 24; i++) {
    final data = await rootBundle.load('assets/watercan/WC_$i.png');
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    frames.add(frame.image);
  }
  return frames;
}

// make sure the plot sprite is loaded
// loads the image from the src and decodes it into a ui.Image
Future<ui.Image> loadPlotSprite() async {
  final data = await rootBundle.load('assets/ground/Grd_1.png');
  final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
  final frame = await codec.getNextFrame();
  return frame.image;
}

// hitbox utilities
// uses rhombus hitboxes
int? findTappedPlotIndex(
  Offset tapPosition,
  List<Offset> plotPositions,
  List<ui.Image> plotFrames,
) {
  for (int i = 0; i < plotPositions.length; i++) {
    if (isPointInsideDiamond(tapPosition, plotPositions[i], plotFrames[i])) {
      return i;
    }
  }
  return null;
}

bool isPointInsideDiamond(Offset point, Offset pos, ui.Image image) {
  const scale = 0.25;
  final width = image.width * scale;
  final height = image.height * scale;

  // Apply the same manual shift used when drawing
  final adjustedX = pos.dx - 40 + width / 2;
  final adjustedY = pos.dy - 45 + height / 1.6;

  final dx = (point.dx - adjustedX).abs();
  final dy = (point.dy - adjustedY).abs();

  final halfW = width / 2;
  final halfH = height / 6;

  return (dx / halfW + dy / halfH) <= 1;
}

Offset isoTilePosition(int row, int col, double tileWidth, double tileHeight) {
  double x = (col - row) * tileWidth / 2;
  double y = (col + row) * tileHeight / 2;
  return Offset(x, y);
}

// drawing helpers
// the drawing func - draws one image on canvas
void drawPlot(Canvas canvas, Offset position, ui.Image plotImage,
    {double scale = 0.25}) {
  final paint = Paint();
  final srcRect = Rect.fromLTWH(
      0, 0, plotImage.width.toDouble(), plotImage.height.toDouble());

  final dstRect = Rect.fromCenter(
    center: position,
    width: plotImage.width * scale,
    height: plotImage.height * scale,
  );

  canvas.drawImageRect(plotImage, srcRect, dstRect, paint);
}

Offset computeOffsetToCenter(List<Offset> positions, Size canvasSize) {
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
  final canvasCenter =
      Offset(canvasSize.width / 2 - 100, canvasSize.height / 2);

  return canvasCenter - gridCenter;
}

//
//
enum PlantAction { water, sunlight, fertilize, view }
