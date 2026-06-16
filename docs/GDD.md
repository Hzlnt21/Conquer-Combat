# Conquer Combat - Game Design Document

**Document version:** 0.2  
**Project status:** Pre-production  
**Working title:** Conquer Combat  
**Engine target:** Godot 4.6.3 Standard, GDScript  
**Primary platform:** Desktop web browser  
**Secondary platform:** Windows  

> This is a living design document. Numerical combat values are provisional until playtesting.

## 1. Project Overview

Conquer Combat is a 2D anime fighting game set in the dark-fantasy world of Eidara. Chosen fighters carry fragments of a broken metaphysical system called The Covenant. Their duels determine who may restore, conquer, or rewrite one of reality's fundamental laws.

The first playable release focuses on a polished 1v1 duel between Izuna, The Sacred Edge, and Xenon, The Smiling Despair.

### Elevator Pitch

Conquer Combat combines responsive, accessible fighting-game controls with deeper combo, cancel, defense, and resource systems. Every fighter expresses a different response to a broken world, while each match represents a clash of identity and conviction inside a temporary Resonance Field.

### Player Fantasy

The player becomes a fragment bearer whose attacks physically express memory, emotion, trauma, and will. Winning a duel means proving that their conviction can carry one of reality's laws.

### Target Players

- Players who enjoy anime fighting games and dramatic character abilities.
- Beginners who find traditional motion inputs difficult.
- Experienced players who enjoy spacing, timing, combos, cancels, and meter decisions.
- Portfolio visitors looking for a short game that launches directly in a browser.

### Design Pillars

1. **Responsive Combat** - Inputs feel immediate and attacks have clear impact.
2. **Accessible Depth** - Basic actions are simple; mastery comes from timing and decisions.
3. **Distinct Fighters** - Every character has a recognizable silhouette, rhythm, and mechanic.
4. **Dramatic Clarity** - Effects are stylish without obscuring combat information.
5. **Browser Ready** - The game loads quickly and maintains a stable 60 FPS.
6. **Playable First** - Combat is validated with placeholders before final assets are produced.

## 2. World and Premise

### Eidara

Eidara once existed in balance under The Covenant, a metaphysical system governing five fundamental laws:

- Law of Life
- Law of Memory
- Law of Emotion
- Law of Ruin
- Law of Fate

The Covenant did not remove conflict. It preserved balance between opposing realities: life and death, memory and forgetting, hope and despair, freedom and consequence.

### The Covenant Wardens

Five Wardens were chosen by The Covenant to protect its laws. They were neither gods nor rulers. Their duty was to preserve possibility and balance.

During a period of war and suffering, the Wardens attempted a forbidden ritual called The First Rewrite. They sought a perfect world without war, meaningless death, loss, or suffering.

### The First Rewrite and The Shattering

The Wardens tried to force every law toward one perfect future. Reality could not survive the removal of its natural contradictions. The Covenant fractured in an event called The Shattering.

The central theme of Conquer Combat is:

> Perfection imposed by a single will can be more destructive than the imperfect world it intends to heal.

### The Last Warden

The surviving Warden was formerly the Warden of Fate. His duty had been to protect choice and possibility, but during The First Rewrite he became the ritual's anchor and forced all futures toward one outcome.

His body and fate are now bound to the remains of The Covenant. He can observe fragments of possible futures and communicate through dreams, shrines, and Resonance, but he cannot directly change the world or wield a shard.

Each attempt to observe the future erodes part of his remaining human memory.

### Timeline

The main story occurs 120 years after The Shattering.

Fragment bearers age very slowly because their bodies and identities are sustained by a law of reality. They can still be injured and killed.

Over 120 years:

- The Shattering became disputed myth and doctrine.
- History became unreliable as Memory weakened.
- Extreme emotions began affecting physical reality.
- Fracture Zones formed where time, identity, and matter are unstable.
- Most people stopped believing The Covenant was real.

### The Origin Shard

The Origin Shard is the Covenant's central fragment. It does not represent one law; it carries the authority to reconnect all five laws.

The Last Warden sealed it beneath The Broken Covenant Shrine. The seal weakens after 120 years because:

- Memory of the original failure is fading.
- Emotional instability is accumulating across Eidara.
- Eidara's possible futures are narrowing toward restoration or collapse.

The Origin Shard can authorize one absolute rewrite of a major law. If mishandled, it may cause a Second Shattering.

## 3. The Conquest

The Conquest is not an organized tournament. It is The Covenant's automatic repair mechanism.

Fragments seek compatible or opposing fragments. When two bearers resonate strongly enough, they form a Resonance Field: a temporary layer of reality that contains their conflict and protects the surrounding world from most damage.

### Duel Triggers

- Physical proximity between fragment bearers.
- Strongly opposed goals or convictions.
- Instability caused by a Fracture Zone.
- Pressure from the awakening Origin Shard.

### Refusing a Duel

A bearer can resist, but prolonged resistance creates Resonance Burden:

- Recurring dreams of The Shattering.
- Unstable emotion or memory.
- Physical weakness near another bearer.
- Small fractures appearing in the environment.

The character retains agency, but refusing indefinitely endangers both bearer and surroundings.

### Victory and Defeat

The winner receives part of the opponent's Resonance, not their entire fragment or life. The defeated bearer becomes temporarily weaker while their fragment recovers.

Death is possible but is not required by The Conquest. This supports rematches and allows only selected story battles to be canon.

## 4. Initial Characters

### Izuna, The Sacred Edge

**Fragment:** Law of Memory  
**Role:** Protagonist  
**Archetype:** Rushdown / all-rounder  
**Difficulty:** Beginner-friendly, medium mastery ceiling  
**Ideal range:** Close to mid range

Izuna survived The Shattering when the Law of Memory bound itself to him. He remembers people, places, and events erased from history. His crimson memory flame burns through illusion and reality distortion.

He accepts guidance from The Last Warden but does not trust him. The Warden helped destroy Izuna's shrine, people, and former life.

Izuna wants to stabilize the Origin Shard without allowing any individual to own the right to Rewrite. His private temptation is to use that same power to restore everyone the world forgot.

**Core conflict:** He remembers everything the world lost, but recovering the world's memories gradually erodes his own personal identity.

#### Gameplay Identity

- Fast forward movement and short, decisive pressure.
- Clear sword range suitable for learning spacing.
- Straightforward basic combo routes.
- Memory Mark adds advanced routing and delayed pressure.
- Average defense and punishable recovery when attacks miss.

#### Character Mechanic: Memory Mark

Selected attacks place one Memory Mark on the opponent. Izuna can Recall the mark with specific special moves, causing crimson memory flame to repeat the recorded strike.

- Maximum one active mark.
- A new mark replaces the previous mark.
- Recall consumes the mark.
- Mark expires after a provisional 300 simulation frames.
- Mark is removed when Izuna is knocked down.
- Recall cannot occur during hitstop or after the round has ended.

The mechanic represents reality remembering Izuna's earlier attack.

### Xenon, The Smiling Despair

**Fragment:** Law of Emotion  
**Role:** Primary antagonist  
**Archetype:** Trickster / space control  
**Difficulty:** Intermediate  
**Ideal range:** Mid range

Xenon was once a traveling performer who witnessed people hide fear, grief, and hatred behind acceptable faces. He accepted his pain, laughed at it, and allowed the Law of Emotion to bind itself to him.

Xenon can give form to emotions that already exist. Fear becomes chains, pain becomes thorns, despair becomes puppets, and false laughter becomes blades.

He cannot create emotions from nothing. His manifestations become stronger when a target denies what they feel, and weaker when the target accepts it. Xenon experiences the emotions he manifests; his permanent smile is the mask that prevents them from consuming him.

Xenon wants to Rewrite Emotion so that no feeling can be concealed. To him this is not destruction, but absolute honesty.

**Core belief:** If suffering cannot be erased, no one should be allowed to hide it.

#### Gameplay Identity

- Controls mid-range space with chain and puppet attacks.
- Uses delayed threats to create ambiguous pressure.
- Slower movement than Izuna.
- Strong control when prepared, weaker when cornered.
- Emotional Echo rewards prediction and setup rather than raw speed.

#### Character Mechanic: Emotional Echo

Selected Xenon attacks generate one Echo token when blocked or when they counter-hit. Xenon can spend the token to animate a temporary Despair Puppet.

- Maximum one Echo token in the vertical slice.
- Echo expires after a provisional 360 simulation frames.
- Puppet activation consumes the token.
- Xenon loses the token when knocked down.
- The puppet has no independent AI; it performs a fixed data-driven action.

This provides a distinct setup mechanic without requiring a second autonomous fighter simulation.

## 5. Match Rules

### Format

- Duel: 1v1
- Match: Best of three rounds
- Win requirement: First player to win two rounds
- Round timer: 99 counts
- Base health: 1000 integer HP
- Simulation rate: Fixed 60 ticks per second
- Target render rate: 60 FPS

### Round End

- HP reaches zero: Opponent wins the round.
- Timer reaches zero: Higher remaining HP percentage wins.
- Equal HP at timeout: Draw.
- Simultaneous KO: Draw.
- A draw awards neither player a round.
- A deciding draw is replayed once; a second deciding draw ends the match as a draw.

### Arena

Combat uses a fixed 2D side view. Fighters automatically face one another while in neutral states. Side switching updates directional inputs on the following simulation frame, never in the middle of resolving an attack.

Characters have separate gameplay shapes:

- **Pushbox:** Prevents fighters from occupying the same grounded space.
- **Hurtbox:** Defines areas that can receive attacks.
- **Hitbox:** Exists only during active attack frames.
- **Throw box:** Defines throw range independently from strike range.

## 6. Input and Movement

### Action Layout

Player 1 keyboard defaults:

| Action | Key |
| --- | --- |
| Move Left | A |
| Move Right | D |
| Jump | W |
| Crouch | S |
| Light | J |
| Medium | K |
| Heavy | L |
| Special | I |
| Covenant Guard | U |
| Throw | O |

Controller and Player 2 mappings are configurable later. Keyboard plus controller is the preferred local-versus setup because keyboard ghosting varies by hardware.

### Input Philosophy

- No traditional quarter-circle inputs are required in the first release.
- Specials use a direction plus Special or a context-sensitive Special button.
- Input buffer target: 5 simulation frames.
- Opposing horizontal directions resolve to neutral.
- Up and down pressed together resolve to neutral.
- Inputs are sampled and stored once per simulation frame.

### Movement Set

- Walk forward
- Walk backward
- Forward dash
- Backdash
- Single jump
- Crouch

There is no air dash, double jump, run, or free-form air blocking in the vertical slice.

Walk backward is slower than walk forward. Backdash has brief strike invulnerability followed by punishable recovery. Exact values remain provisional.

## 7. Attack and Defense Rules

### Attack Properties

- **High:** Whiffs against crouching opponents; can be standing-blocked.
- **Mid:** Can be blocked standing or crouching.
- **Low:** Must be crouching-blocked.
- **Throw:** Cannot be blocked and only connects within throw range.

The vertical slice prioritizes mids. Character-specific standing overheads and additional lows enter after basic combat is stable.

### Basic Cancel Chain

The universal beginner route is:

`Light -> Medium -> Heavy -> eligible Special`

Cancel permission is explicit move data. A move may define cancel rules for hit, block, and whiff independently. Unless specifically allowed, attacks cannot cancel on whiff.

### Blocking

Normal block is performed by holding away from the opponent.

- Standing block defends against high and mid attacks.
- Crouching block defends against low and mid attacks.
- Normal attacks deal no chip damage.
- Specials may deal small chip damage but cannot KO through chip in the vertical slice.
- Throws defeat both forms of block.

### Covenant Guard

Covenant Guard is a committed defensive stance, not a second risk-free block.

Vertical-slice behavior:

- Has a short startup before becoming active.
- Prevents movement and attacks while held.
- Reduces blockstun and pushback.
- Loses to throws.
- Has recovery after release.
- Does not parry or automatically counter in v0.1.

Timed parry, guard counter, anti-cross-up behavior, and resource cost are candidates for later playtests.

### Throw

- Grounded, close-range action.
- Cannot be blocked.
- Whiff has punishable recovery.
- Causes fixed damage and soft knockdown.
- Throw escape is omitted from v0.1 and required before public v1.0.

### Hit Reactions

- **Hitstun:** Defender cannot act after being hit.
- **Blockstun:** Defender cannot act after blocking.
- **Hitstop:** Both attacker and defender pause briefly on contact to communicate impact.
- **Knockdown:** Defender falls and automatically rises after a fixed duration.
- **Soft knockdown:** Limited wake-up advantage.
- **Hard knockdown:** Reserved for selected specials and later systems.

Wake-up attacks, rolls, air recovery, and complex tech options are outside v0.1.

### Damage and Combos

- Health, damage, meter, timer, and frame counters use integers.
- Combo damage scaling is not required in v0.1a, but is required once extended combos are introduced.
- A provisional scaling floor of 30 percent is recommended.
- A combo counter and training readout are development tools before they are presentation features.

## 8. Universal Resource Systems

### Conviction Gauge

Conviction Gauge contains three bars.

It gains meter from:

- Landing an attack: substantial gain.
- Having an attack blocked: small gain.
- Receiving an attack: small comeback gain.

Passive gain from walking forward is postponed until playtesting proves it necessary.

It is spent on:

- 1 bar: Conquer Art
- 1 bar: Shift Cancel
- 3 bars: Ultimate Move

Meter does not carry between matches. Whether meter carries between rounds is deferred until balance testing; the default prototype behavior resets it each round.

### Conquer Art

An enhanced version of an eligible special. It may add damage, range, safety, or a character-mechanic interaction. It must remain visually readable and cannot rely on a long cinematic.

### Shift Cancel

Shift Cancel spends one bar to cancel eligible recovery into neutral. It supports combo extension and risk management.

Rules:

- Only moves explicitly marked as Shift-cancellable qualify.
- Cannot be used during hitstop.
- Cannot cancel throw whiff, Covenant Guard recovery, Burst recovery, or Ultimate recovery.
- Visual and audio feedback must be distinct from normal cancels.

### Burst / Reversal

Burst uses a separate resource with one charge per round.

- Can be activated during eligible hitstun or blockstun.
- Pushes the opponent away.
- Deals negligible or zero damage.
- Can be baited and punished.
- Cannot be activated during KO, throw cinematics, or Ultimate cinematics.

Burst is not part of v0.1 and enters during MVP development.

## 9. Izuna Moveset

Frame data below is an initial tuning target, not final balance.

### Standing Normals

| Move | Input | Property | Startup | Damage | Purpose |
| --- | --- | --- | ---: | ---: | --- |
| Memory Fang | Light | Mid | 5 | 40 | Fast poke and combo starter |
| Crimson Arc | Medium | Mid | 9 | 70 | Main spacing and combo bridge |
| Sacred Rend | Heavy | Mid | 14 | 110 | Risky ender that applies Memory Mark |

Cancel routes:

- Light -> Medium or eligible Special
- Medium -> Heavy or eligible Special
- Heavy -> eligible Special on hit or block
- No normal cancel on whiff

### Special Moves

#### Recall Slash

**Input:** Neutral + Special  
Izuna performs a fast mid-range crimson slash.

- Reliable special ender.
- If Memory Mark is active, consumes it and creates a delayed second slash.
- Delayed slash extends pressure on block and combos on hit.
- Punishable when used raw at close range.

#### Foxfire Step

**Input:** Forward + Special  
Izuna dashes through a short distance with a flame-covered draw slash.

- Approach and whiff-punish tool.
- Does not pass through a blocking opponent.
- Side switching is only allowed when it cleanly crosses an airborne or knocked-down opponent.
- Conquer Art version travels farther and gains one hit of projectile armor.

#### Memory Break

**Input:** Down + Special  
Izuna performs an upward anti-air slash.

- Invulnerable to airborne strikes during early startup.
- Highly punishable on block or whiff.
- Recall interaction adds a downward foxfire strike after a marked target is launched.

### Throw: Forgotten Oath

Izuna catches the opponent, turns past them, and strikes the Memory Mark position with the sword hilt. Causes soft knockdown but does not apply a Mark.

### Conquer Art: Sacred Recall

Enhanced Recall Slash. It consumes one bar, produces a larger flame arc, and automatically creates a temporary Mark before resolving Recall. This allows the enhanced move to function even when no Mark was previously active, but yields less damage than consuming an existing Mark.

### Ultimate: Ninefold Severance

Izuna records nine possible cuts, then collapses them into one decisive strike.

- Costs three Conviction bars.
- Short confirm window; unsafe when used raw.
- Cinematic target: under four seconds.
- Final hit causes hard knockdown.
- Does not erase the opponent's fragment in story canon.

## 10. Xenon Moveset

### Standing Normals

| Move | Input | Property | Startup | Damage | Purpose |
| --- | --- | --- | ---: | ---: | --- |
| False Smile | Light | Mid | 6 | 35 | Short claw or chain-hilt poke |
| Grief Lash | Medium | Mid | 10 | 75 | Long chain control and combo bridge |
| Curtain Fall | Heavy | Mid | 16 | 115 | Large sickle sweep and knockdown ender |

Xenon's normals are slightly slower than Izuna's but control more horizontal space. Grief Lash has a vulnerable extended hurtbox along the chain during recovery.

### Special Moves

#### Laughing Chain

**Input:** Neutral + Special  
Xenon sends a chain forward at mid range.

- On hit, pulls the opponent slightly toward Xenon.
- On counter-hit, grants one Emotional Echo.
- On block, grants an Echo only if Xenon had no token and the move connected near maximum range.
- Punishable if used too close.

#### Despair Puppet

**Input:** Down + Special  
Requires and consumes one Emotional Echo. Xenon places a small puppet that attacks after a fixed delay.

- The puppet performs one predetermined mid strike.
- It disappears if Xenon is hit before activation.
- Only one puppet may exist.
- It cannot independently track or choose targets.

#### Mocking Step

**Input:** Forward + Special  
Xenon performs a short evasive stage step followed by an optional chain strike if Special is pressed again.

- Brief upper-body strike evasion, not full invulnerability.
- Throw and low attacks defeat the step.
- Follow-up is unsafe on block.
- Conquer Art version leaves a false afterimage that attacks once.

### Throw: Shared Misery

Xenon hooks the opponent with the chain and forces a manifested shadow through them. Causes fixed damage and soft knockdown. The animation remains short and contains no graphic injury.

### Conquer Art: Unmasked Chorus

Enhanced Despair Puppet. Costs one bar and does not require an Echo token. If an Echo is available, consuming it adds a second delayed strike rather than increasing raw damage excessively.

### Ultimate: The Last Laugh

Xenon opens a stage of manifested masks and forces the opponent's denied emotions to attack from multiple directions.

- Costs three Conviction bars.
- Must be confirmed from a valid hit or used as a high-risk punish.
- Cinematic target: under four seconds.
- Ends with Xenon's smile disappearing for one brief shot.
- Causes hard knockdown.

## 11. Stage and Presentation

### Official Stage Name

**Arena name:** Ruined Shrine of Conquest  
**Historical location:** The Broken Covenant Shrine

The stage is the location of The First Rewrite and the seal beneath the Origin Shard.

### Visual Layers

1. Distant fractured sky
2. Covenant sigil and far shrine architecture
3. Ruined shrine structures
4. Midground debris
5. Battle floor
6. Low-cost foreground fog
7. Sparse particles and Resonance effects

The center remains visually quiet. Foreground effects never cover feet, attack silhouettes, or UI-critical space.

### Visual Direction

- Clean anime dark fantasy
- Sharp silhouettes and expressive posing
- White, charcoal, crimson, violet, and magenta palette
- Brush-stroke attack effects
- Layered painted backgrounds
- Thin, modern UI with high contrast

## 12. Modes

### Vertical Slice

- Local 1v1 testing
- Basic training environment
- Restart round and reset position
- Hitbox and frame-data debug overlay

### MVP

- Training mode
- Local Versus
- Basic CPU opponent
- Settings for audio and basic input mapping
- Stable web build

### Public v1.0

- Title screen
- Character select
- Tutorial
- Short arcade route
- Intro dialogue
- Local Versus
- Training
- Settings
- Credits

Online multiplayer is explicitly outside v1.0 unless the offline combat, deterministic simulation strategy, performance, and production schedule are all proven first.

## 13. Development Milestones

### v0.1a - Combat Skeleton

- Izuna versus stationary dummy
- Fixed 60 Hz simulation
- Walk, crouch, jump, dash, and backdash
- Pushbox, hurtbox, and debug display
- Light, Medium, and Heavy
- Hitstop, hitstun, knockback, and health
- Placeholder shapes only

### v0.1b - Two-Player Proof

- Izuna mirror match
- Two input profiles
- Auto-facing and side switching
- Normal block and blockstun
- Knockdown, wake-up, KO, timer, and rounds
- Local restart flow

### v0.1c - Character Contrast

- Xenon added
- One complete basic route per character
- Character mechanics: Memory Mark and Emotional Echo
- Three specials per character using placeholder effects
- First balance and readability pass

### v0.1d - Defensive Slice

- Covenant Guard placeholder
- Throw
- Training reset options
- Basic frame-data display
- Initial browser performance test

### v0.5 - MVP

- Conviction Gauge
- Conquer Arts
- Shift Cancel
- Burst
- Ultimates
- Basic CPU
- Audio settings and key remapping
- Stable browser build

### v1.0 - Playable Release

- Finalized character and stage assets
- Tutorial and short arcade mode
- Final UI and audio pass
- Throw escape and required defensive polish
- Accessibility and controller testing
- Browser compatibility and load-time optimization
- Credits and portfolio deployment

## 14. Asset Production Plan

Final assets are produced only after the matching gameplay behavior is approved.

### Character Asset Minimum

Per character:

- One approved front three-quarter master design
- Simplified turnaround
- Separated body parts for hybrid skeletal animation
- Idle
- Walk forward and backward
- Dash and backdash
- Jump, fall, and landing
- Crouch
- Light, Medium, Heavy
- Three specials
- Throw
- Block and Covenant Guard
- Hit reactions
- Knockdown, get-up, and KO
- Portrait and small icon

Animation uses a hybrid approach:

- Skeletal animation for idle, movement, and reusable transitions.
- Authored key poses or short frame sequences for attacks and impacts.
- Modular VFX reused through scale, rotation, timing, and color where appropriate.

AI image generation is used for concept exploration and approved source frames, not for independently generating every animation frame. Full strips are generated or edited together to reduce visual drift.

### Stage Asset Minimum

- Seven separated parallax layers
- Collision-free battle floor reference
- Lightweight ambient loop
- Optional Resonance variants using shaders and particles

### Audio Minimum

- UI confirm, cancel, and navigation
- Light, medium, and heavy impacts
- Block and Covenant Guard impacts
- Dash, jump, and landing
- Character-specific special effects
- KO and round calls
- One looping stage theme

Voice acting is optional and outside the initial vertical slice.

## 15. Technical Constraints

- Godot 4.6.3 Standard with GDScript and Compatibility renderer.
- Gameplay simulation is separate from rendering and animation playback.
- AnimationPlayer is presentation, not combat authority.
- Fixed 60 Hz simulation tick.
- Move data defines startup, active, recovery, damage, stun, hitstop, knockback, attack property, and cancel rules.
- Custom simple collision resolution is preferred over relying on nondeterministic physics behavior.
- Inputs are stored per simulation frame.
- Random behavior uses an explicit seeded generator.
- Debug overlays can show frame state, boxes, velocity, input history, and current move.
- Stage assets use compressed textures and limited overdraw.
- VFX have browser-safe particle and shader budgets.
- Gameplay remains functional when cosmetic effects are disabled.

These rules do not guarantee rollback networking, but they prevent early architecture from making rollback unnecessarily expensive later.

## 16. Scope Guardrails

The following are not part of the first public release unless the schedule changes deliberately:

- Online multiplayer and matchmaking
- Tag or assist combat
- More than two playable characters
- Multiple final stages
- Story cinematics
- Full voice acting
- Complex branching campaign
- Mobile touch controls
- Cosmetic store or monetization
- 3D character models

## 17. Open Questions for Playtesting

These decisions must be answered through play rather than discussion alone:

- Is Covenant Guard fun and distinct from normal block?
- Should Conviction carry between rounds?
- Is Memory Mark understandable during fast combat?
- Does Emotional Echo create strategy without overwhelming beginners?
- Is the 6-action layout comfortable on keyboard and common controllers?
- How much chip damage keeps specials threatening without encouraging passive play?
- Does the game need motion inputs for long-term depth, or are directional specials sufficient?
- What texture, audio, and effect budgets produce acceptable browser load time?

## 18. Canon and Naming Summary

- World: Eidara
- Reality system: The Covenant
- Failed ritual: The First Rewrite
- Catastrophe: The Shattering
- Former guardians: The Covenant Wardens
- Surviving guide: The Last Warden, formerly Warden of Fate
- Timeline: 120 years after The Shattering
- Core fragment: The Origin Shard
- Repair mechanism: The Conquest
- Duel space: Resonance Field
- Protagonist: Izuna, The Sacred Edge - Law of Memory
- Antagonist: Xenon, The Smiling Despair - Law of Emotion
- Arena: Ruined Shrine of Conquest
- Historical location: The Broken Covenant Shrine

## 19. Production Principle

> Playable first, pretty later.

Conquer Combat succeeds first by making Izuna versus Xenon readable, responsive, and enjoyable. Additional characters, systems, story, and final visual production follow only after that duel proves the foundation works.
