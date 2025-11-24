import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

/// A short-lived explosion effect when a zombie hits a plant.
///
/// Uses Flame Effects (ScaleEffect) + Flame Particles.
class ZombieExplosionEffect extends PositionComponent {
  ZombieExplosionEffect({required Vector2 worldPosition})
    : super(
        position: worldPosition.clone(),
        size: Vector2.all(32),
        anchor: Anchor.center,
        priority: 950, // on top of plants & zombies
      );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Core explosion circle.
    final core = CircleComponent(
      radius: size.x / 2,
      paint: Paint()..color = Colors.orange.withOpacity(0.9),
      anchor: Anchor.center,
    );
    add(core);

    // Scale up quickly using a Flame Effect.
    add(
      ScaleEffect.to(
        Vector2.all(2.0),
        EffectController(duration: 0.2, curve: Curves.easeOut),
      ),
    );

    // Add a quick particle burst.
    final particles = ParticleSystemComponent(
      position: Vector2.zero(),
      particle: Particle.generate(
        count: 14,
        lifespan: 0.25,
        generator: (i) {
          return CircleParticle(
            radius: 2,
            paint: Paint()
              ..color = i.isEven ? Colors.redAccent : Colors.yellowAccent,
            lifespan: 0.25,
          );
        },
      ),
    );
    add(particles);

    // Remove the whole effect after a short time.
    add(
      TimerComponent(
        period: 0.3,
        repeat: false,
        onTick: () => removeFromParent(),
      ),
    );
  }
}
