# Izuna Production Package v0.1

**Character:** Izuna, The Sacred Edge  
**Purpose:** Convert approved visual-development references into a production-ready drawing and export package for Godot rigging.  
**Status:** Active production package  
**Engine target:** Godot 4.6.3 Standard, GL Compatibility  
**Viewport target:** 1280x720 gameplay presentation

## Package Goal

This package defines the exact handoff from visual-development art to game-usable character parts.

The immediate goal is not final animation. The immediate goal is a clean manual redraw that can be:

- separated into stable body-part layers,
- exported as aligned transparent PNGs,
- tested in Godot without re-positioning each part by hand.

## Canonical Inputs

Use these files as authority in descending order:

1. `res://assets/characters/izuna/redraw/izuna-idle-clean-redraw-v01.png`
2. `res://assets/characters/izuna/turnaround/izuna-turnaround-v01.png`
3. `res://assets/characters/izuna/concept/izuna-master-concept-v01.png`

Supporting reviews:

- `res://docs/visual-development/IZUNA_IDLE_REDRAW_V01_REVIEW.md`
- `res://docs/visual-development/IZUNA_TURNAROUND_V01_REVIEW.md`
- `res://docs/visual-development/IZUNA_MASTER_V01_REVIEW.md`

## Deliverables

The first production pass for Izuna must produce:

1. One manual redraw source file.
2. One flattened full-body approval export.
3. One aligned full-canvas PNG export per body part.
4. One simple guide export with floor line and root marker.
5. One Godot import-ready folder containing transparent part exports.

## Repository Locations

Use this structure:

```text
res://assets/characters/izuna/production/
  source/
    izuna-idle-production-v01.kra
  exports/
    composite/
      izuna_idle_fullbody_v01.png
    full-canvas/
      izuna_idle_body_head_base_v01.png
      izuna_idle_body_hair_front_l_v01.png
      ...
    guides/
      izuna_idle_guides_v01.png
```

`source/` is the editable master.  
`exports/composite/` is for approval snapshots.  
`exports/full-canvas/` is the Godot-facing transparent aligned package.  
`exports/guides/` contains non-runtime helpers.

## Canvas Spec

### Master Working Canvas

- Size: `2048 x 1536`
- Background: transparent
- Color mode: RGBA, 8-bit
- DPI metadata: `300`
- Orientation: landscape

This canvas is intentionally larger than the current generated redraw (`1536 x 1024`) so the manual redraw has safer margin for sword length, overlap paint, and export padding.

### Registration Rules

- Keep every exported body part on the exact same `2048 x 1536` canvas.
- Do not crop each part tightly for the first rigging pass.
- Shared registration is more important than minimizing empty transparent area.

### Guide Placement

- Horizontal root center: `x = 1024`
- Floor baseline: `y = 1408`
- Root marker: center point between both feet on the floor baseline

The floor baseline is a guide layer only. It is never included in runtime body-part exports.

## Character Scale Target

- Izuna should read as roughly `78%` to `82%` of screen height when standing in neutral gameplay framing.
- In the `1280 x 720` match view, the visible body target is approximately `560` to `590` rendered pixels tall before VFX.

This means the source package should favor clean downscaling rather than razor-thin detail.

## Layer Group Structure

Use these top-level groups in Krita:

1. `guides`
2. `composite_preview`
3. `head`
4. `torso`
5. `weapon_arm`
6. `scabbard_arm`
7. `lower_body`
8. `accessories`
9. `disabled_reference`

Keep source references in `disabled_reference` and never export that group.

## Required Production Layers

These are the minimum aligned export layers for the idle base.

### Head

- `izuna_head_base`
- `izuna_hair_back`
- `izuna_hair_front_l`
- `izuna_hair_front_c_streak`
- `izuna_hair_front_r`
- `izuna_mask`
- `izuna_mask_tassels`

### Torso

- `izuna_neck`
- `izuna_torso_black_inner`
- `izuna_harness_chest`
- `izuna_mantle_crimson`
- `izuna_body_white_outer`
- `izuna_skirt_front_l`
- `izuna_skirt_front_r`
- `izuna_waist_cloth_rear`

### Weapon Arm

- `izuna_arm_weapon_upper`
- `izuna_arm_weapon_forearm`
- `izuna_arm_weapon_hand`
- `izuna_katana_hilt_guard`
- `izuna_katana_blade`
- `izuna_katana_inscription_overlay`

### Scabbard Arm

- `izuna_arm_scabbard_upper`
- `izuna_arm_scabbard_inner_sleeve`
- `izuna_arm_scabbard_white_sleeve`
- `izuna_arm_scabbard_forearm`
- `izuna_arm_scabbard_hand`
- `izuna_scabbard`

### Lower Body

- `izuna_pelvis_root`
- `izuna_leg_l_thigh`
- `izuna_leg_r_thigh`
- `izuna_leg_l_calf`
- `izuna_leg_r_calf`
- `izuna_foot_l`
- `izuna_foot_r`

### Accessories

- `izuna_waist_rope_front`
- `izuna_ornament_primary`
- `izuna_ornament_secondary`
- `izuna_belt_sheath_mount`

## Drawing Rules

### Shape Rules

- Every export layer must be a closed readable shape.
- Paint hidden overlap under adjacent layers to avoid holes during motion.
- Use at least `24` to `40` pixels of underlap behind neighboring parts.

### Detail Rules

- Preserve facial identity exactly.
- Simplify micro-details that do not survive gameplay scale.
- Keep only the strongest costume breaks and ornament beats.
- Avoid tiny independent tassels if they will require separate bones without gameplay value.

### Shading Rules

- Keep form shading inside each part.
- Minimize cast shadows from one moving part onto another moving part.
- Do not paint VFX glow into the body base.
- Keep highlight language consistent across separate parts.

### Line Rules

- Maintain clean outer silhouettes over internal costume line noise.
- Sword edge and scabbard contour must remain readable at half scale.
- The fox mask must remain immediately recognizable even when the character is small on screen.

## Export Rules

### Composite Export

- Format: PNG
- File: `izuna_idle_fullbody_v01.png`
- Canvas: flattened full character on transparent background
- Use: visual approval and quick comparison

### Body-Part Export

- Format: PNG
- Alpha: yes
- Canvas: full shared `2048 x 1536`
- Background: fully transparent
- One file per approved layer
- Naming pattern: `izuna_idle_body_<part-name>_v01.png`

### Guide Export

- Format: PNG
- File: `izuna_idle_guides_v01.png`
- Include only: floor baseline, root marker, optional safe margins
- Never imported into runtime scene

## Draw Order Contract

Godot stacking should follow this order unless later animation tests prove otherwise:

1. rear waist cloth
2. back hair
3. pelvis and legs
4. torso black inner
5. white outer body panel
6. crimson mantle
7. front skirt panels
8. scabbard arm
9. scabbard
10. weapon arm
11. katana
12. neck and head base
13. front hair
14. mask
15. mask tassels
16. front accessories

The exact node order may shift, but this draw order should be the starting contract.

## Godot Handoff Notes

- Import body-part PNGs as normal 2D textures.
- Keep filter enabled.
- Keep repeat disabled.
- Mipmaps are unnecessary for this first 2D character pass.
- Preserve alpha.

The first rigging test should use the exported full-canvas parts directly in Godot before any optimization or atlas work.

## Definition Of Done

The Izuna production package is considered complete when:

1. The `.kra` source file exists in the repo path defined above.
2. All required idle layers export successfully on a shared canvas.
3. The composite export matches the approved redraw silhouette.
4. No part reveals holes when translated slightly in a test comp.
5. The full package can be imported into Godot without manual per-part re-registration.

## Immediate Next Step

Create the actual `izuna-idle-production-v01.kra` source file in Krita from the approved redraw, then export the first full-canvas body-part set for a Godot rig smoke test.
