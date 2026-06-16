# Izuna Idle Key Pose v0.1 - Review

**Asset:** `res://assets/characters/izuna/key-poses/izuna-idle-keypose-v01.png`  
**Status:** Approved as rigging seed  
**References:** `res://assets/characters/izuna/concept/izuna-master-concept-v01.png`, `res://assets/characters/izuna/turnaround/izuna-turnaround-v01.png`

## What Works

- Lower center of gravity reads better for a fighting-game idle than the upright master concept.
- Sword hand, scabbard hand, mantle, sleeve, and lower-body silhouette are clearly separated.
- Face, hair, crimson streak, mask placement, and costume identity remain consistent with the locked master.
- One-sword, one-scabbard readability is now clean and unambiguous.
- The stance feels calm, disciplined, and ready, which matches Izuna's personality.

## Cleanup Notes

- When redrawing for production, simplify small waist ornaments into a cleaner hierarchy.
- The scabbard hand should be normalized into a cleaner grip during the paintover pass.
- Preserve the current torso angle, but turn the hips and feet slightly more side-on if gameplay readability needs a stronger profile.
- Keep the white outer layer, crimson mantle, and black inner torso as separate paint groups for rigging.
- Do not add VFX or memory tails to the body base; they stay in a separate effects pass.

## Pipeline Use

- Use this pose as the primary seed for the clean line-art redraw.
- Use the turnaround front view as authority for costume construction if any surface detail drifts.
- Use the master concept as authority for face rendering, palette balance, and ornament language.

## Next Step

Clean redraw v0.1 has been created at `res://assets/characters/izuna/redraw/izuna-idle-clean-redraw-v01.png` and reviewed in `res://docs/visual-development/IZUNA_IDLE_REDRAW_V01_REVIEW.md`.

Next production step: manual clean redraw and closed-shape layer separation based on the approved redraw.
