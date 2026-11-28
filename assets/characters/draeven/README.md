# Draeven model (interim base)

- `draeven_model.glb` — KayKit "Adventurers Character Pack 1.0", Rogue (skinned, 41 bones, 76 clips). Source: https://github.com/KayKit-Game-Assets/KayKit-Character-Pack-Adventures-1.0
- `draeven_body.png`, `draeven_head.png` — 256x256 palette textures recolored from the pack's `rogue_texture.png` (navy coat, near-black leather, silver-white hair on the head mesh).
- `KAYKIT_LICENSE.txt` — CC0 license from the pack (credit to Kay Lousberg is appreciated, not required).

Materials are applied at runtime by `scripts/player/draeven_model_visual.gd`; the GLB's embedded texture is overridden.

## Things to verify in Godot
- Scale (`model_scale`) against the 1.82 m collision capsule.
- Facing (`model_yaw_degrees`); glTF faces +Z, gameplay faces -Z.
- Sword grip (`weapon_socket_rotation_degrees`) on the `handslot.r` bone.
- Clip names used for idle/run/attacks/dodge exist after import.
