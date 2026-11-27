# Technical foundation

## Scene layout
- `scenes/main.tscn`: temporary test environment and player instance.
- Future scenes should be separated into player, enemy, boss, arena, UI, and level scenes.

## Code organization
- Keep player movement independent from combat.
- Use reusable Resources for weapons, skills, enemies, and progression data.
- Prefer signals for communication between independent gameplay systems.
- Avoid large monolithic scripts.

## Android performance rules
- Use the Compatibility renderer.
- Keep real-time lights and shadow-casting lights limited.
- Prefer baked/static environment lighting where practical.
- Pool frequently spawned effects and projectiles.
- Profile on target hardware before increasing visual complexity.

## Next milestones
1. Verify project opens and the test scene runs in Godot 4.
2. Add camera follow and mobile touch controls.
3. Establish player animation and weapon attachment points.
4. Build a reusable combat foundation.
5. Add one enemy and one test arena before expanding content.
