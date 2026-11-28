# Draeven character asset

The skinned model loader in `scripts/player/draeven_visual.gd` looks for:

`res://assets/characters/draeven/draeven_Apose.glb`

Place the supplied A-Pose GLB at that exact path. The T-Pose file is retained as a reference and is not used at runtime.

When the A-Pose file is present, DraevenVisual loads its Skeleton3D and AnimationPlayer, plays the imported idle/walk/combat clips, and attaches the active Soul Arms weapon socket to the `RightHand` bone. If the GLB is absent or cannot be imported, the existing procedural visual remains as a safe fallback.

Expected animation names:
- `idle-loop`, `walk-loop`, `run-loop`
- `attack_light`, `attack_heavy`, `combo`, `finisher`
- `dodge`, `hit_reaction`, `weapon_switch`, `death`, `victory`

The A-Pose source supplied for integration contains 58 joints, two skinned mesh nodes, eight materials, and twelve animation clips. Verify the imported model in Godot before treating the rig as production-ready.
