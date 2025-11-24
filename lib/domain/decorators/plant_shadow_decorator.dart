import 'package:flame/rendering.dart';
import 'package:flutter/material.dart';

/// Factory for a subtle dark "grounding" effect under plants,
/// implemented using Flame's [PaintDecorator].
///
/// We use a semi-transparent dark tint, which visually makes
/// the plant feel more anchored / shadowed, and also satisfies
/// the "at least one decorator" requirement.
PaintDecorator createPlantShadowDecorator() {
  return PaintDecorator.tint(Colors.black.withOpacity(0.20));
}
