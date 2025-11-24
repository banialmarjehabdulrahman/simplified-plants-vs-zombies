🌱 Simplified Plants vs Zombies

A small tower-defense style game built with Flutter + Flame, created as a technical game challenge.

🕹 Live Demo (Web Build):
👉 https://banialmarjehabdulrahman.github.io/simplified-plants-vs-zombies/

🎯 Overview

This project is a simplified reinterpretation of Plants vs. Zombies, built to demonstrate:

Flame game engine usage

Clean architecture & modular structure

Object-oriented game programming

Multiple classic design patterns (State, Strategy, Object Pool, Observer)

Flutter + Flame integration with overlays & BLoC state

Web deployment via GitHub Pages

The game features:

A 3×5 grid

Plant placement

Zombies walking across lanes

Projectiles & hit effects

Win timer (survive for N seconds)

Player lives & lose condition

Post-game “Restart” & “Next Difficulty”

Basic SFX and visual feedback

🧱 Project Structure

This project uses a clean, modular folder architecture separating:

Core game systems

Domain gameplay components

Flutter UI overlays

Reusable design patterns

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

🧩 Design Patterns Used
✔ State Pattern

Implementation:
lib/core/patterns/state/game_state.dart

Manages high-level game status: playing, won, lost

GameOverController observes state changes and updates UI

✔ Strategy Pattern

Used inside Zombie to customize movement animations

Implemented in:
lib/domain/components/zombie.dart
(with a dedicated folder ready: lib/core/patterns/strategy/)

Easily extendable for different zombie movement behaviors

✔ Object Pool Pattern

Used to reuse zombies and projectiles instead of destroying/creating

Implementation:

lib/core/patterns/object_pool/zombie_pool.dart

lib/core/patterns/object_pool/projectile_pool.dart

Usage in ZombieSpawner, PvzGame, and projectile firing logic

✔ Observer (EventBus) Pattern

Implementation:
lib/core/events/event_bus.dart

Decouples systems:

Health → GameState

Timer → Game Over

UI flash effects, etc.

🎮 Gameplay Summary

Place plants on a 3×5 grid

Plants automatically shoot projectiles at zombies

Zombies walk horizontally toward the player’s house

Lose a life when a zombie reaches the house

Win by surviving the timer

After win/lose:

Restart with same difficulty

Or increase difficulty & continue
