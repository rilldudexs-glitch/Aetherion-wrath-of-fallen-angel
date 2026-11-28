# Draeven — Character Art & Technical Specification

## Approved visual direction

**Style:** Realistic stylized (Option A). The character should feel like a grounded action-game protagonist: more detailed and proportionally human than a blocky low-poly avatar, while remaining deliberately optimized for low-end Android hardware.

## Silhouette and proportions

- Slim, athletic humanoid proportions; avoid bulky shoulders, chest, arms, or legs.
- Medium-length coat with a clean, readable silhouette.
- Keep the silhouette recognizable at gameplay camera distance.
- Avoid excessive dangling accessories and tiny geometry that will not read in motion.

## Head and face

- Silver-white hair, medium length, falling downward over the forehead and sides of the face.
- Do not use a swept-back hairstyle.
- Defined but restrained facial structure; blue eyes.
- Face detail should be baked into textures where possible rather than relying on expensive geometry.

## Clothing and palette

- Outer coat: midnight navy / blue-black.
- Inner clothing: near-black.
- Armor and trim: restrained silver accents.
- Keep material count and texture memory low; prefer a compact shared texture atlas.

## Rig and animation requirements

The production replacement must be a genuinely skinned humanoid mesh with:
- A usable humanoid skeleton and vertex weights.
- Separate, clearly named animation clips for idle, walk, run, jump, dodge, light attack, and heavy attack (where available).
- Stable deformation at shoulders, elbows, hips, knees, and coat joints.
- A right-hand attachment point for the existing sword scene/node.
- A consistent forward axis and documented scale/origin for Godot import.

A static anatomy mesh or a procedural arrangement of primitive meshes does **not** satisfy this requirement. A generated placeholder rig should not be called production-ready until its skinning and animation have been visually checked in-engine.

## Android performance targets

- Target device: Redmi 7, 3 GB RAM.
- Prefer a modest real-time mesh budget, one compact material/texture set, and limited transparency.
- Avoid costly real-time hair strands, cloth simulation, excessive bones, and high-cost shaders.
- Use baked textures and simple material response; preserve the Compatibility renderer path.
- Profile in the actual Godot project before treating performance as confirmed.

## Integration order

1. Select a base mesh whose license permits modification and inclusion in the game.
2. Verify its skeleton, skin weights, scale, forward axis, and animation clips.
3. Adapt proportions and appearance to the approved Draeven design.
4. Retarget or add required animation clips and verify deformations.
5. Attach the existing sword to the right hand and verify grip alignment through idle and attack poses.
6. Replace the procedural VisualRoot in the player scene only after the imported model passes visual and runtime checks.

## Current status

Interim base (branch `draeven-kaykit-base`): the KayKit Adventurers "Rogue" skinned model (CC0, 41 bones, built-in animation clips) recolored to the Draeven palette (midnight navy coat, near-black inner clothing, silver-white hair). It is loaded by `scripts/player/draeven_model_visual.gd`, which falls back to the procedural visual if the model cannot be loaded.

This is a stylized chibi base, **not** the approved slim realistic-stylized design: proportions and the hairstyle still differ from the spec. It has not yet been visually checked in-engine or profiled on the target Android device, so scale, facing, sword grip alignment and deformation are unverified. The procedural visual remains in `draeven_visual.gd` as the fallback.
