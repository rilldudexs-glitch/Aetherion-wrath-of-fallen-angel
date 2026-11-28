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
- Five element skill profiles: Flame (burst damage), Frost (enemy slow), Storm (limited multi-target strike), Void (wide area), and Life (self-heal plus light area damage). The prototype starts with Flame and Frost equipped; other elements are reserved for story unlocks.
- Weapon transformations use a timed shrink/swap/reappear animation; each form has its own attack pose, reach/damage tuning, and slash color.
- Enemy attack telegraphs, wind-up/recovery states, and a shared cap of two simultaneous attackers.
- Encounter wave pacing with configurable inter-wave breaks and optional arena gate locking.

## Mobile controls

- Left lower area: virtual movement stick.
- Right side: drag to orbit the camera.
- Lower-right buttons: light attack, heavy attack, dodge, lock-on, FORM to cycle Soul Arms, ELEM to switch equipped element, and SKILL to cast its ability.
- Soul Energy and active element are shown above the combat buttons.
- Desktop: press E to cycle weapon forms, R to switch the active element, and F to cast its skill.
- Desktop: press Q to toggle lock-on. Enemies register themselves in the `enemies` group.

The Android touch HUD is shown when the runtime reports touchscreen support. Desktop keyboard controls remain available.

## Project status

This is an active prototype. EncounterDirector exposes `arena_locked`, `arena_unlocked`, `wave_started`, `wave_cleared`, and `inter_wave_break` signals for arena UI and gate feedback. The repository changes have not yet been validated in a Godot editor/runtime or packaged into a tested APK.