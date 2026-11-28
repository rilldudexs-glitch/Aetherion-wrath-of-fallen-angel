# AETHERION: Wrath of the Fallen

Godot 4 third-person action prototype. Rendering is configured for the Compatibility renderer to support lower-end Android devices.

## Current player foundation

- Draeven third-person movement and orbit camera.
- Keyboard actions for desktop testing.
- Android touch HUD: virtual movement stick, light attack, heavy attack, and dodge.
- Camera drag on the right side of the screen.
- Target lock-on with nearest visible enemy selection and camera/player facing assist.
- Three-step light combo, heavy attack, dodge cancel, and hit VFX.
- Enemy attack telegraphs, wind-up/recovery states, and a shared cap of two simultaneous attackers.
- Encounter wave pacing with configurable inter-wave breaks and optional arena gate locking.

## Mobile controls

- Left lower area: virtual movement stick.
- Right side: drag to orbit the camera.
- Lower-right buttons: light attack, heavy attack, dodge, and lock-on.
- Desktop: press Q to toggle lock-on. Enemies register themselves in the `enemies` group.

The Android touch HUD is shown when the runtime reports touchscreen support. Desktop keyboard controls remain available.

## Project status

This is an active prototype. EncounterDirector exposes `arena_locked`, `arena_unlocked`, `wave_started`, `wave_cleared`, and `inter_wave_break` signals for arena UI and gate feedback. The repository changes have not yet been validated in a Godot editor/runtime or packaged into a tested APK.