# AETHERION — Implementation Roadmap

## Implemented foundation

- Draeven third-person scene with a procedural articulated character model, silver hair, dark-blue coat, silver armor accents, a right-hand weapon socket, and third-person camera.
- Separate camera-relative player movement controller.
- Player melee controller with light/heavy attacks, a three-hit combo chain, short input buffering, and hit timing aligned to the attack animation.
- Player dodge movement with a brief invulnerability window and a matching body pose.
- Lightweight combo VFX: three differently angled slash arcs, a brighter echoed slash on the third hit, impact flashes, short spark streaks, and a ground shock ring on a successful heavy hit.
- Procedural character motion for idle breathing, walk cycle, light/heavy attack swings, and dodge lean. The sword is parented to the right hand pivot.
- Reusable CombatComponent for health, damage, healing, and defeat signals.
- Enemy state flow: idle, chase, attack windup, recovery, and dead.
- Enemy attacks show a ground warning ring during windup and recheck distance when the windup ends, so a player who moves away can avoid the hit.
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

## Combo visual effects

- Light combo hits use pale blue-white slash arcs that change angle per hit.
- The third light hit adds a second, softer echo arc.
- Confirmed hits spawn a brief impact flash and a small burst of directional sparks.
- Heavy attacks use a larger, brighter arc; a successful heavy hit adds an expanding ground shock ring.
- Effects are short-lived mesh effects rather than persistent particle systems to keep the Android rendering cost controlled.

## Enemy archetype profiles

- **Ashen Raider:** fast movement, lighter hits, short windup.
- **Ashen Brute:** slow movement, high health and damage, long windup and recovery.
- **Ashen Stalker:** faster pursuit and longer detection range, balanced damage.

These are gameplay stat profiles using the shared placeholder enemy scene. They do not yet have unique meshes, animation sets, or bespoke attack logic.

## Current focus

Draeven's model, animation feel, weapon alignment, combo timing, and movement are the active implementation focus. The main scene is currently a Draeven-only sandbox; enemy and boss encounter work is intentionally deferred.

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
2. Refine the procedural character proportions, coat silhouette, face, hair, and sword grip; replace the procedural model with a skinned production model when assets are ready.
3. Improve attack animation variety, hit windows, movement blending, and weapon trails.
4. Add mobile touch controls and profile the character sandbox on target Android hardware.
5. Resume enemy and boss implementation only after Draeven's foundation is approved.

## Scope notes

This is an expanding gameplay foundation, not a finished playable build. Draeven currently uses a procedural primitive-based model and code-driven motion, not a final skinned production asset or imported animation clips. Enemy and boss work is deferred. There are no touch controls, save system, or Android APK yet. Godot runtime validation is still pending because no Godot executable was available during this implementation pass.
