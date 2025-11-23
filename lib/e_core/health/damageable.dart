/// Anything in the game that can take damage and be destroyed
/// should conform to this interface (directly or via composition).
abstract class Damageable {
  /// Maximum health this entity can ever have.
  int get maxHealth;

  /// Current health value (0..maxHealth).
  int get currentHealth;

  /// Convenience flag: true when currentHealth <= 0.
  bool get isDead;

  /// Apply damage to this entity.
  ///
  /// Implementations should:
  /// - Clamp health to 0 (never negative)
  /// - Trigger any "on damaged" events / callbacks
  /// - Trigger death handling if health reaches 0
  void applyDamage(int amount);

  /// Restore health to this entity.
  ///
  /// Implementations should:
  /// - Clamp health to maxHealth (never above)
  /// - Optionally trigger a "on healed" event if needed
  void heal(int amount);

  /// Force this entity into a dead state immediately.
  ///
  /// Useful for things like instant-kill effects, despawning,
  /// or when health reaches 0 and you want explicit logic.
  void kill();
}
