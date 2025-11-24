import '../patterns/observer/event_bus.dart';
import 'damageable.dart';
import 'health_events.dart';
import 'hit_invulnerability.dart';

/// Callback when health value changes.
typedef HealthChangedCallback = void Function(int previous, int current);

/// Callback when this entity dies.
typedef DeathCallback = void Function();

/// Reusable health logic that any entity (plant, zombie, etc.)
/// can use via composition.
///
/// Example usage inside a Plant or Zombie:
///   final health = HealthComponent(
///     owner: this,
///     maxHealth: 100,
///     onDeath: _handleDeath,
///     invulnerability: HitInvulnerability(duration: 0.2), // optional
///   );
///
///   // When hit by something:
///   health.applyDamage(20);
class HealthComponent implements Damageable {
  HealthComponent({
    required this.owner,
    required int maxHealth,
    int? currentHealth,
    this.onHealthChanged,
    this.onDeath,
    this.invulnerability,
  }) : assert(maxHealth > 0, 'maxHealth must be > 0'),
       _maxHealth = maxHealth,
       _currentHealth = currentHealth ?? maxHealth {
    // Clamp initial health
    if (_currentHealth > _maxHealth) {
      _currentHealth = _maxHealth;
    } else if (_currentHealth < 0) {
      _currentHealth = 0;
    }
  }

  /// The game object that owns this health component
  /// (typically a Plant or Zombie instance).
  final Object owner;

  int _maxHealth;
  int _currentHealth;

  /// Optional callback whenever health changes (damage or heal).
  final HealthChangedCallback? onHealthChanged;

  /// Optional callback when health reaches zero for the first time.
  final DeathCallback? onDeath;

  /// Optional shared invulnerability helper.
  ///
  /// If set, damage is ignored while [invulnerability.isActive] is true.
  /// On a successful hit, [invulnerability.trigger] is called.
  final HitInvulnerability? invulnerability;

  bool _hasDied = false;

  // ---- Damageable implementation ----

  @override
  int get maxHealth => _maxHealth;

  @override
  int get currentHealth => _currentHealth;

  @override
  bool get isDead => _currentHealth <= 0;

  @override
  void applyDamage(int amount) {
    if (amount <= 0) return; // ignore non-positive damage
    if (isDead) return; // already dead, ignore further damage

    // If we have invulnerability and it's active, ignore this hit.
    if (invulnerability != null && !invulnerability!.canTakeHit) {
      return;
    }

    final previous = _currentHealth;
    _currentHealth -= amount;

    if (_currentHealth < 0) {
      _currentHealth = 0;
    }

    _notifyHealthChanged(previous, _currentHealth);

    // Emit a HealthDamagedEvent through the global EventBus.
    EventBus.instance.emit<HealthEvent>(
      HealthDamagedEvent(
        source: owner,
        previousHealth: previous,
        currentHealth: _currentHealth,
        damageAmount: amount,
      ),
    );

    // Start i-frame period if configured.
    invulnerability?.trigger();

    if (_currentHealth == 0) {
      _handleDeath();
    }
  }

  @override
  void heal(int amount) {
    if (amount <= 0) return; // ignore non-positive heal
    if (isDead) return; // dead entities cannot be healed (by default)

    final previous = _currentHealth;
    _currentHealth += amount;

    if (_currentHealth > _maxHealth) {
      _currentHealth = _maxHealth;
    }

    _notifyHealthChanged(previous, _currentHealth);

    // Emit a HealthHealedEvent.
    EventBus.instance.emit<HealthEvent>(
      HealthHealedEvent(
        source: owner,
        previousHealth: previous,
        currentHealth: _currentHealth,
        healAmount: amount,
      ),
    );
  }

  @override
  void kill() {
    if (isDead) return;

    final previous = _currentHealth;
    _currentHealth = 0;

    _notifyHealthChanged(previous, _currentHealth);

    _handleDeath();
  }

  // ---- Extra helpers for future use (pooling, upgrades, etc.) ----

  /// Reset this component back to "fresh" state.
  /// Useful when reusing entities from an object pool.
  void reset({int? maxHealth, int? currentHealth}) {
    _hasDied = false;

    if (maxHealth != null) {
      assert(maxHealth > 0, 'maxHealth must be > 0');
      _maxHealth = maxHealth;
    }

    final previous = _currentHealth;
    _currentHealth = currentHealth ?? _maxHealth;

    if (_currentHealth > _maxHealth) {
      _currentHealth = _maxHealth;
    } else if (_currentHealth < 0) {
      _currentHealth = 0;
    }

    invulnerability?.reset();

    if (previous != _currentHealth) {
      _notifyHealthChanged(previous, _currentHealth);
      // We treat reset as a hard state set (no events beyond this).
    }
  }

  /// Tick any time-based features like invulnerability.
  ///
  /// Call this once per frame from the owning entity's update().
  void update(double dt) {
    invulnerability?.update(dt);
  }

  // ---- Internal helpers ----

  void _notifyHealthChanged(int previous, int current) {
    if (previous == current) return;
    onHealthChanged?.call(previous, current);
  }

  void _handleDeath() {
    if (_hasDied) return; // ensure death is only processed once
    _hasDied = true;

    // Emit a high-level "entity died" event.
    EventBus.instance.emit<HealthEvent>(EntityDiedEvent(source: owner));

    onDeath?.call();
  }
}
