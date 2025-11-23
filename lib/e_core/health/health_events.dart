/// Base type for all health-related events.
///
/// Concrete event types:
/// - [HealthDamagedEvent]
/// - [HealthHealedEvent]
/// - [EntityDiedEvent]
abstract class HealthEvent {
  const HealthEvent({required this.source});

  /// The object whose health changed or who died.
  ///
  /// Typically a Plant, Zombie, or something that wraps a HealthComponent.
  final Object source;
}

/// Fired whenever an entity takes damage.
///
/// Example usage:
///   final event = HealthDamagedEvent(
///     source: this,
///     previousHealth: 80,
///     currentHealth: 50,
///     damageAmount: 30,
///   );
class HealthDamagedEvent extends HealthEvent {
  const HealthDamagedEvent({
    required super.source,
    required this.previousHealth,
    required this.currentHealth,
    required this.damageAmount,
  });

  /// Health value before damage was applied.
  final int previousHealth;

  /// Health value after damage was applied (clamped to >= 0).
  final int currentHealth;

  /// The amount of damage that was attempted/applied.
  final int damageAmount;

  /// Convenience flag: true if this damage reduced health to zero.
  bool get wasLethal => currentHealth <= 0;
}

/// Fired whenever an entity is healed.
///
/// Not strictly required for basic PvZ, but useful for future plants,
/// buffs, or support mechanics.
class HealthHealedEvent extends HealthEvent {
  const HealthHealedEvent({
    required super.source,
    required this.previousHealth,
    required this.currentHealth,
    required this.healAmount,
  });

  /// Health value before healing.
  final int previousHealth;

  /// Health value after healing (clamped to <= maxHealth by the health logic).
  final int currentHealth;

  /// The requested heal amount.
  final int healAmount;
}

/// Fired when an entity's health reaches zero and it is considered dead.
///
/// Note: this is a *semantic* event for game systems (waves, scores, etc.),
/// not the same as just "health changed to 0".
class EntityDiedEvent extends HealthEvent {
  const EntityDiedEvent({required super.source});
}

/// Signature for any function that wants to listen to health events.
typedef HealthEventListener = void Function(HealthEvent event);
