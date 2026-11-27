# AETHERION — Implementation Roadmap

## Current foundation pass
- Draeven character scene with placeholder body, named skeleton hierarchy, right-hand BoneAttachment3D, WeaponSocket, and third-person camera.
- Separate player movement controller.
- Reusable CombatComponent for health, damage, healing, and defeat signals.
- Reusable enemy controller with idle, chase, attack, recover, and dead states.
- Boss controller with three health-threshold phases.
- EncounterDirector for sequential arena waves.

## Enemy and boss content plan
The base scenes are templates, not final enemy content. Each enemy variant will be a child scene with its own mesh, animation, stats, attack timings, and behavior profile.

Planned campaign bosses:
1. Severin Kael — Eldoria.
2. The Ancient Stag — Sylvaris.
3. The Iron Colossus — Drakmor.
4. The Eternal Warden — Frostveil.
5. The Abyssal Sovereign — Thalassor.
6. The Grave Monarch — Nethrum.
7. The Hollow King's Champion — Aetherium.
8. Vaelgor — final encounter.

## Next implementation passes
1. Verify all scenes and scripts in the Godot editor.
2. Add animation state machine and proper humanoid rig/skin.
3. Add hitbox/hurtbox combat with telegraphed attacks and dodge windows.
4. Add distinct enemy archetypes and boss-specific phase patterns.
5. Add touch controls, UI, save data, and Android profiling.

## Scope notes
This pass is a playable architecture scaffold. It does not yet contain final character art, animation clips, complete enemy attacks, unique boss movesets, loot, or an Android APK. The named bosses are documented as planned content; the boss base controller is shared infrastructure.
