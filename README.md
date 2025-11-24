## 🎮 Gameplay Summary

Place plants on a 3×5 grid

Plants automatically shoot projectiles at zombies

Zombies walk horizontally toward the player’s house

Lose a life when a zombie reaches the house

Win by surviving the timer

After win/lose:

Restart with same difficulty


## 🎯 Overview

This project is a simplified reinterpretation of Plants vs. Zombies, built to demonstrate:

Flame game engine usage

Clean architecture & modular structure

Object-oriented game programming

Classic design patterns: State, Strategy, Object Pool, Observer

Flutter + Flame integration with overlays & BLoC state

Web deployment via GitHub Pages

Game Features

3×5 grid with tile-based placement

Shooter plants

Zombies walking across lanes

Projectiles & hit effects

Survival win timer

Player lives & lose condition

“Restart” & “Next Difficulty” flow

Basic sound effects & hit-flash feedback

## 🧱 Project Structure

This project uses a clean, modular folder architecture separating:

- Core game systems  
- Domain gameplay components  
- Flutter UI overlays  
- Reusable design patterns  

```text
lib/
  core/
    audio/                      # SFX manager
    events/                     # EventBus (Observer pattern)
    game/
      config/                   # Grid layout, game constants
      logic/                    # Spawners, wave controller, game over logic
    health/                     # Health + damage system
    patterns/
      state/                    # GameState (State pattern)
      object_pool/              # Pools for zombies/projectiles
      strategy/                 # (Reserved for movement strategies)

  domain/
    components/                 # Plant, Zombie, Projectile, Tile
    models/                     # PlantType, ZombieType

  game/
    pvz_game.dart               # Main Flame game class

  state_management/
    bloc/                       # BLoC for pause menu & overlays

  ui/
    hud/                        # Sun counter, lives, wave alerts
    overlays/                   # Pause overlay, Game Over panel
    widgets/                    # Flutter widgets like PlantBar

  main.dart                     # Entry point: GameWidget + overlays


## 🧩 Design Patterns Used
✔ State Pattern

Implementation:
lib/core/patterns/state/game_state.dart

Manages high-level game status (playing, won, lost).
GameOverController observes state changes and updates the UI.

✔ Strategy Pattern

Used inside Zombie to customize movement animations.

Implementation:
lib/domain/components/zombie.dart
(Strategy directory prepared: lib/core/patterns/strategy/)

Allows extending zombie movement behavior (zig-zag, fast walk, random walk, etc.)

✔ Object Pool Pattern

Reuses zombies and projectiles instead of constantly allocating new instances.

Implementation:

lib/core/patterns/object_pool/zombie_pool.dart

lib/core/patterns/object_pool/projectile_pool.dart

Usage:
ZombieSpawner, PvzGame, plant shooting logic.

✔ Observer (EventBus) Pattern

Decouples communication between systems.

Implementation:
lib/core/events/event_bus.dart

Used for cross-system events:

Health → GameState

Timer → Game Over

UI flash effects

Kill counters

etc.

