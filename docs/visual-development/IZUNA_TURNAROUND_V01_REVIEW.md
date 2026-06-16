# Izuna Turnaround v0.1 - Review

**Asset:** `res://assets/characters/izuna/turnaround/izuna-turnaround-v01.png`  
**Status:** Approved as production reference  
**Canonical identity:** `res://assets/characters/izuna/concept/izuna-master-concept-v01.png`

## Views

- Front
- Left side
- Back
- Front three-quarter

All views preserve the locked face, hair streak, mask side, mantle, white garment, charcoal base costume, and overall proportions.

## What Is Locked

- Character height and lean athletic proportions.
- Mask position and tassel language.
- Crimson mantle over the asymmetrical white sleeve.
- Front and back harness construction.
- Waist cord and primary Covenant ornament.
- Trouser volume, shin wraps, and footwear.
- Katana/scabbard position at the waist.

## Cleanup Notes

- Small waist ornaments vary slightly between views; use the front view as authority.
- Use the back view as authority for harness crossing and mantle attachment.
- Use the side view as authority for garment depth and scabbard clearance.
- Weapon hardware must be normalized before final rig cutout.
- Turnaround is a visual construction reference, not a pixel-perfect texture atlas.

## Planned Skeleton2D Parts

### Core

- Pelvis/root
- Torso charcoal inner layer
- Neck
- Head
- Front hair
- Back hair
- Crimson hair streak
- Fox mask
- Mask tassels

### Left Side

- Upper arm
- Forearm guard
- Hand
- White upper sleeve
- White lower garment panel
- Crimson mantle

### Right Side

- Upper arm
- Forearm guard
- Hand

### Lower Body

- Left thigh/trouser volume
- Left shin wrap
- Left foot
- Right thigh/trouser volume
- Right shin wrap
- Right foot
- Front waist cords
- Rear waist cloth

### Weapon

- Katana blade
- Katana hilt and guard
- Scabbard
- Optional blade inscription overlay

### Effects

- Memory tails remain separate VFX nodes and are never baked into the body rig.
- Mask glow and glyphs remain separate overlays.

## Next Step

Idle key pose v0.1 has been created at `res://assets/characters/izuna/key-poses/izuna-idle-keypose-v01.png` and reviewed in `res://docs/visual-development/IZUNA_IDLE_KEYPOSE_V01_REVIEW.md`.

Next visual production step: clean redraw and body-part separation planning based on the idle key pose, using this turnaround as construction authority.

Current redraw reference: `res://assets/characters/izuna/redraw/izuna-idle-clean-redraw-v01.png`
