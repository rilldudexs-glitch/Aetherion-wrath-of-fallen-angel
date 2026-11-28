# AETHERION: Wrath of the Fallen

Godot 4 third-person action prototype. Rendering is configured for the Compatibility renderer to support lower-end Android devices.

## Current player foundation

- Draeven third-person movement and orbit camera.
- Keyboard actions for desktop testing.
- Android touch HUD: virtual movement stick, light attack, heavy attack, and dodge.
- Camera drag on the right side of the screen.
- Target lock-on with nearest visible enemy selection and camera/player facing assist.
- Three-step light combo, heavy attack, dodge cancel, and hit VFX.
- Four Soul Arms forms: Origin Blade, Chain Blades, Twin Reapers, and Soul Swords.
- Soul Energy resource with passive regeneration and elemental skills.
- Saved progression foundation: Flame/Frost start unlocked; story rewards can unlock Storm, Void, and Life, with two element slots available to equip.
- Soul Arms-only upgrade path: each of the four weapon forms levels independently up to level 5, improving weapon damage and elemental skill power. Soul Shards are the upgrade currency; reward hooks are ready for future chests, bosses, and arena clears.
- Progression is stored locally in `user://aetherion_progress.cfg` on the device.
- Five element skill profiles: Flame (burst damage), Frost (enemy slow), Storm (limited multi-target strike), Void (wide area), and Life (self-heal plus light area damage). The prototype starts with Flame and Frost equipped; other elements are reserved for story unlocks.
- Weapon transformations use a timed shrink/swap/reappear animation; each form has its own attack pose, reach/damage tuning, and slash color.
- Enemy attack telegraphs, wind-up/recovery states, and a shared cap of two simultaneous attackers.
- Encounter wave pacing with configurable inter-wave breaks and optional arena gate locking.

## Mobile controls

- Left lower area: virtual movement stick.
- Right side: drag to orbit the camera.
- Lower-right buttons: light attack, heavy attack, dodge, lock-on, FORM to cycle Soul Arms, ELEM to switch equipped element, SKILL to cast its ability, and USE to collect nearby rewards.
- START at the upper-right opens the pause menu on touch devices. Desktop uses Escape or P; gamepads use the Start button.
- World rewards can grant Soul Shards or unlock a new element; approach a pickup and press G on desktop or USE on mobile.
- Arena wave clears award Soul Shards automatically (configurable on EncounterDirector).
- Soul Energy and active element are shown above the combat buttons.
- Desktop: press E to cycle weapon forms, R to switch the active element, and F to cast its skill.
- Desktop: press Q to toggle lock-on. Enemies register themselves in the `enemies` group.

The Android touch HUD is shown when the runtime reports touchscreen support. Desktop keyboard controls remain available.

## Pause menu

- God-of-War-style pause overlay pauses the whole scene tree.
- Equipment tab shows all four Soul Arms and allows upgrades directly using Soul Shards.
- Elements tab shows discovered/equipped elements and allows equipping a discovered element into slot 2.
- Settings tab is a placeholder; audio, graphics and controller options are not wired yet.

## Progression hooks (prototype foundation)

- `unlock_element("storm")` / `unlock_element("void")` / `unlock_element("life")`: call from a story discovery reward.
- `equip_element(slot, element_name)`: equip a discovered element into slot 0 or 1.
- `grant_soul_shards(amount)`: award upgrade currency from a reward source.
- `upgrade_current_weapon()`: spend the selected form's shard cost to raise its level (maximum level 5). Costs rise from 5 to 11 shards across levels; the pause menu provides the in-game interface.
- `WorldRewardPickup`: reusable Area3D reward scene for Soul Shards or story element unlocks. The main test scene includes a shard pickup and a Storm relic as interaction examples.
- Progression saves automatically after each change. A dedicated in-game upgrade/discovery UI and actual reward placements are still future work.

## Project status

This is an active prototype. EncounterDirector exposes `arena_locked`, `arena_unlocked`, `wave_started`, `wave_cleared`, and `inter_wave_break` signals for arena UI and gate feedback. The repository changes have not yet been validated in a Godot editor/runtime or packaged into a tested APK.