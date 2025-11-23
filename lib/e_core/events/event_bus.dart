/// Simple, generic event bus for decoupled communication between systems.
///
/// This implements a basic Observer / Publish–Subscribe pattern:
///
/// - Producers call [emit] with an event object
/// - Consumers call [subscribe] with a callback that receives events of a type
///
/// Usage:
///
///   // 1) Somewhere central at app start (or just lazily):
///   final bus = EventBus.instance;
///
///   // 2) Subscribe to a specific event type:
///   final subscription = bus.subscribe<HealthEvent>((event) {
///     if (event is HealthDamagedEvent) {
///       // react to damage...
///     }
///   });
///
///   // 3) Emit events from producers:
///   bus.emit(HealthDamagedEvent(...));
///
///   // 4) When no longer interested (e.g., component removed):
///   subscription.cancel();
typedef EventCallback<T> = void Function(T event);

/// Handle that allows unsubscribing from the event bus.
class EventSubscription {
  EventSubscription._(this._onCancel);

  final void Function() _onCancel;

  /// Remove the listener associated with this subscription.
  void cancel() {
    _onCancel();
  }
}

class EventBus {
  EventBus._internal();

  /// Global singleton instance for convenience in a small game.
  /// If you ever want to go more advanced, you can inject this instead.
  static final EventBus instance = EventBus._internal();

  /// Map from event type to list of listeners.
  final Map<Type, List<Function>> _listeners = {};

  /// Subscribe to events of type [T].
  ///
  /// Returns an [EventSubscription] which you can use to unsubscribe later.
  EventSubscription subscribe<T>(EventCallback<T> listener) {
    final type = T;
    final listeners = _listeners.putIfAbsent(type, () => <Function>[]);
    listeners.add(listener);

    return EventSubscription._(() {
      listeners.remove(listener);
      // Clean up empty lists to avoid leaking types.
      if (listeners.isEmpty) {
        _listeners.remove(type);
      }
    });
  }

  /// Emit an event to all listeners subscribed to its type.
  ///
  /// Example:
  ///   EventBus.instance.emit(HealthDamagedEvent(...));
  void emit<T>(T event) {
    final type = T;
    final listeners = _listeners[type];
    if (listeners == null || listeners.isEmpty) return;

    // Iterate over a copy in case listeners modify subscriptions while handling.
    final snapshot = List<Function>.from(listeners);
    for (final listener in snapshot) {
      // We trust the registration to have correct types.
      (listener as EventCallback<T>).call(event);
    }
  }

  /// Remove all listeners for all event types.
  ///
  /// Use with care. Mostly useful for resetting between game sessions.
  void clearAllListeners() {
    _listeners.clear();
  }
}
