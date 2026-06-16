# Izuna Idle Clean Redraw v0.1 - Review

**Asset:** `res://assets/characters/izuna/redraw/izuna-idle-clean-redraw-v01.png`  
**Status:** Approved as redraw reference and separation authority  
**References:** `res://assets/characters/izuna/key-poses/izuna-idle-keypose-v01.png`, `res://assets/characters/izuna/turnaround/izuna-turnaround-v01.png`, `res://assets/characters/izuna/concept/izuna-master-concept-v01.png`

## What Improved

- Linework and silhouette readability are cleaner than the first idle key pose.
- Small costume details are more disciplined and no longer fight the pose.
- Weapon hand, scabbard hand, white outer layer, crimson mantle, and front torso are easier to separate into paint groups.
- Feet and lower-body stance read more clearly for a fighting-game idle base.
- The redraw stays faithful to the locked face, mask placement, hair shape, and costume identity.

## Minor Manual Cleanup

- Normalize the rear hand and scabbard contact into a cleaner closed shape during the manual redraw pass.
- Keep the front waist tassels simpler than shown here if they interfere with deformation.
- Preserve the current hip and shoulder counter-angle; only reduce detail, not structure.
- Keep the sword blade slightly longer than the visible hand-to-tip proportion if export padding becomes tight.

## Approved Separation Map

### Head

- Head and face base
- Front hair left
- Front hair center with crimson streak
- Front hair right
- Back hair mass
- Fox mask
- Mask tassels

### Torso

- Neck
- Black inner torso
- Chest harness straps
- Crimson shoulder mantle
- White outer body panel
- Front black skirt panel left
- Front black skirt panel right
- Rear waist cloth

### Right Side Weapon Arm

- Upper arm
- Forearm guard
- Hand
- Katana hilt and guard
- Katana blade
- Optional blade inscription overlay

### Left Side Scabbard Arm

- Upper arm
- Inner black sleeve
- White outer sleeve shell
- Forearm guard
- Hand
- Scabbard

### Lower Body

- Pelvis/root
- Left thigh trouser mass
- Right thigh trouser mass
- Left shin wrap and calf
- Right shin wrap and calf
- Left foot
- Right foot

### Accessories

- Front waist rope
- Primary diamond ornament
- Secondary tassel cluster
- Belt band and sheath mount

## Draw Order Notes

- Back hair stays behind the head base and mask tassels.
- White outer body panel stays behind the front torso but above the rear waist cloth.
- Crimson mantle stays above the white panel and black torso.
- Front skirt panels stay above both thigh masses.
- Katana arm stays above the torso silhouette.
- Scabbard stays behind the rear hand silhouette when possible.

## Pipeline Use

- Use this asset as the paintover target for the manual clean redraw.
- Use the turnaround as construction authority if hidden seams need to be resolved.
- Use the master concept as identity authority if facial or palette detail drifts.
- Do not bake any memory-flame VFX into this body base.

## Next Step

Create the manual clean redraw pass with explicit closed layer shapes for Skeleton2D cutting, then prepare a transparent-body export test.
