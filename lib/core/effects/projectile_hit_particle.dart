// lib/e_core/particles/projectile_hit_particle.dart
import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

/// Small particle burst when a projectile hits a zombie.
///
/// Visual goal:
/// - Short-lived (about 0.25s)
/// - A few small colored circles shooting outwards
/// - Slight fade over time
class ProjectileHitParticle extends ParticleSystemComponent {
  ProjectileHitParticle({
    required Vector2 worldPosition,
    Color color = const Color(0xFFFFF176), // light yellow by default
  }) : super(
         position: worldPosition,
         priority: 900, // above zombies/plants but below HUD
         particle: _buildParticle(color),
       );

  static Particle _buildParticle(Color color) {
    final random = math.Random();

    // Emit a small burst of particles in random directions.
    return Particle.generate(
      count: 12,
      lifespan: 0.25,
      generator: (i) {
        // Random direction unit vector
        final angle = random.nextDouble() * 2 * math.pi;
        final speed = 80 + random.nextDouble() * 80; // 80–160 px/s

        final vx = math.cos(angle) * speed;
        final vy = math.sin(angle) * speed;

        // Fade out over the lifespan
        return AcceleratedParticle(
          // initial position (local to the component position)
          position: Vector2.zero(),
          // constant velocity
          speed: Vector2(vx, vy),
          // no extra acceleration (gravity etc.)
          child: CircleParticle(
            radius: 2 + random.nextDouble() * 2,
            paint: Paint()
              ..color = color.withOpacity(0.9)
              ..style = PaintingStyle.fill,
          ),
        );
      },
    );
  }
}
