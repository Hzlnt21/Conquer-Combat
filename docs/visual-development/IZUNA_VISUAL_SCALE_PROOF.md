# Izuna Visual Scale Proof

**Scene:** `res://scenes/fighters/IzunaVisualProof.tscn`  
**Source art:** `res://assets/characters/izuna/redraw/izuna-idle-clean-redraw-v01.png`  
**Status:** Validated presentation-scale proof

## Result

- The approved redraw remains readable at the 1280x720 gameplay target.
- Izuna's visible body height lands inside the planned 560-590 pixel range.
- Sword, mask, crimson mantle, and white outer layer retain a clear visual hierarchy.
- A subtle whole-body breathing and sway pass runs independently from combat simulation.

## Controls

- `F1`: toggle scale guides.
- `Space`: pause or resume presentation motion.

## Scope Boundary

This scene validates framing, scale, import, and presentation motion only. It is not the final character rig because the source art is still one composite texture.

The rig milestone requires separated transparent body parts from the Krita production source. Combat simulation remains unchanged and continues to use placeholder presentation.

## Next Gate

Create `izuna-idle-production-v01.kra`, export aligned transparent layers, and replace the composite preview with a real articulated Godot rig.
