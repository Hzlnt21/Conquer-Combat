# Combat Visual Integration v01

**Status:** Approved for prototype presentation<br>
**Viewport:** 1280x720<br>
**Renderer:** Godot Compatibility

![Combat visual integration](images/combat-visual-integration-v01.png)

## Integrated Assets

- `assets/stages/ruined-shrine/ruined-shrine-bg-v01.png`
- `assets/characters/izuna/game-ready/izuna-combat-idle-v01.png`
- `assets/characters/xenon/game-ready/xenon-combat-idle-v01.png`

The Ruined Shrine concept was converted into a clean 16:9 battle backdrop without labels or board layout. Izuna and Xenon were produced as transparent full-body combat cutouts based on their approved visual references. Alpha-channel integrity was checked before Godot integration.

The presentation layer now:

- Renders the final-sized stage instead of geometric debug scenery.
- Positions and flips character art from simulation coordinates and facing.
- Applies lightweight breathing, attack lean, hit tint, crouch, and knockdown transforms.
- Keeps hurtbox and hitbox geometry available only through the `F1` debug overlay.
- Uses framed health bars, character titles, round pips, mechanic bars, and a central timer medallion.
- Fades the control guide after the opening seconds of a match.

## Production Boundary

These cutouts establish composition, scale, palette, and browser presentation. They are not substitutes for the final animation package. Public v1.0 still requires authored or rigged movement, attack, block, hit, throw, knockdown, and KO animation states.

## Generation Record

Assets were created with the built-in image generation workflow and then copied into the project as versioned files.

Stage prompt summary: transform the approved Ruined Shrine board into a clean hand-painted anime fighting-game environment with a readable floor, central Covenant monument, layered depth, no characters, no labels, and no UI.

Izuna prompt summary: preserve the approved costume, face, fox mask, sword, and palette while producing a transparent full-body screen-right combat idle cutout.

Xenon prompt summary: preserve the approved jester silhouette, silver hair, chain-sickle, skull ornament, and magenta palette while matching Izuna's rendering quality in a transparent screen-left combat idle cutout.
