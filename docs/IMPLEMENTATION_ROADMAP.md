# AETHERION — Implementation Roadmap

## Implemented foundation

- Draeven third-person scene with a placeholder body, named skeleton hierarchy, right-hand BoneAttachment3D, WeaponSocket, and third-person camera.
- Separate camera-relative player movement controller.
- Player melee controller with light/heavy attacks using a short-range physics shape query.
- Player dodge movement with a brief invulnerability window.
- Reusable CombatComponent for health, damage, healing, and defeat signals.
- Enemy state flow: idle, chase, attack windup, recovery, and dead.
- Enemy attacks recheck distance when the windup ends, so a player who moves away can avoid the hit.
- Three enemy stat archetypes: Ashen Raider, Ashen Brute, and Ashen Stalker.
- Boss controller with three health-threshold phases. Later phases increase movement speed and attack damage while reducing attack windup and cooldown.
- EncounterDirector supports regular waves followed by a dedicated final boss wave.
- Main scene is configured as a small combat test: three regular enemies, then one boss.

## Current keyboard test controls

| Key | Action |
|---|---|
| W / A / S / D | Move |
| J | Light attack |
| K | Heavy attack |
| Space | Dodge |

## Enemy archetype profiles

- **Ashen Raider:** fast movement, lighter hits, short windup.
- **Ashen Brute:** slow movement, high health and damage, long windup and recovery.
- **Ashen Stalker:** faster pursuit and longer detection range, balanced damage.

These are gameplay stat profiles using the shared placeholder enemy scene. They do not yet have unique meshes, animation sets, or bespoke attack logic.

## Planned campaign bosses

1. Severin Kael — Eldoria.
2. The Ancient Stag — Sylvaris.
3. The Iron Colossus — Drakmor.
4. The Eternal Warden — Frostveil.
5. The Abyssal Sovereign — Thalassor.
6. The Grave Monarch — Nethrum.
7. The Hollow King's Champion — Aetherium.
8. Vaelgor — final encounter.

## Next implementation passes

1. Open and validate the project in Godot 4.3; this repository pass has not yet been run through the Godot editor or headless parser.
2. Add a proper humanoid rig, skinned model, animation clips, and weapon attachment alignment.
3. Replace the current sphere-query melee with animation-timed hitboxes/hurtboxes and real combo timing.
4. Give each enemy archetype distinct behavior and give each campaign boss bespoke attacks, telegraphs, and phase mechanics.
5. Add a combat HUD, touch controls, save data, audio, and Android profiling.

## Scope notes

This is an expanding gameplay foundation, not a finished playable build. Character and enemy visuals remain placeholders. The skeleton is a named hierarchy scaffold, not a finished skinned rig. There are no final animation clips, boss-specific movesets, loot progression, touch controls, save system, or Android APK yet. Godot runtime validation is still pending because no Godot executable was available during this implementation pass.
