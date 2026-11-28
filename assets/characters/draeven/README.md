# Draeven character asset

The skinned model loader in `scripts/player/draeven_visual.gd` looks for:

`res://assets/characters/draeven/draeven_Apose.glb`

Place the supplied A-Pose GLB at that exact path. The T-Pose file is retained as a reference and is not used at runtime.

When the A-Pose file is present, DraevenVisual loads its Skeleton3D and AnimationPlayer, plays the imported idle/walk/combat clips, and attaches the active Soul Arms weapon socket to the `RightHand` bone. If the GLB is absent or cannot be imported, the existing procedural visual remains as a safe fallback.

Expected animation names:
- `idle-loop`, `walk-loop`, `run-loop`
- `attack_light`, `attack_heavy`, `combo`, `finisher`
- `dodge`, `hit_reaction`, `weapon_switch`, `death`, `victory`

The supplied A-Pose GLB was inspected directly: it contains one skin with 58 joints, two mesh nodes, and twelve clips (`idle-loop`, `walk-loop`, `run-loop`, `attack_light`, `attack_heavy`, `combo`, `finisher`, `dodge`, `hit_reaction`, `weapon_switch`, `death`, and `victory`). Its hand bone is named `RightHand`. The T-Pose GLB has the same joint and clip structure and is kept as a reference.

A second animated humanoid GLB is also available as a backup source: it has a 19-joint skin, a right-hand bone named `R_Hand`, and four clips (`Draeven_Idle`, `Draeven_Walk`, `Draeven_Run`, `Draeven_Attack_Test`). The current runtime loader targets the richer A-Pose source and now resolves either `RightHand` or `R_Hand` naming.

**Important:** these GLB files are present in the conversation Library, but are not yet tracked in this GitHub repository. The runtime therefore continues to use the procedural fallback until `draeven_Apose.glb` is committed at the path above. The loader now checks for a supported hand bone and reports missing expected clips instead of silently assuming the rig is valid. Godot import/runtime validation is still required before calling the model production-ready.
