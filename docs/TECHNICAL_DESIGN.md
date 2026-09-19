# Conquer Combat - Technical Design Document

**Document version:** 0.4<br>
**Engine:** Godot 4.6.3 Standard  
**Language:** GDScript  
**Renderer:** GL Compatibility  
**Primary target:** Desktop web browser  

Dokumen ini menerjemahkan GDD menjadi batas arsitektur yang dapat diimplementasikan dan diuji. Angka combat tetap mengikuti GDD dan akan berubah melalui playtest.

## 1. Technical Goals

1. Menjaga combat stabil pada simulation tick 60 Hz.
2. Memisahkan aturan gameplay dari scene, animasi, audio, dan VFX.
3. Membuat move dan fighter berbasis data agar balancing tidak memerlukan rewrite logic.
4. Menyediakan debug tooling sejak milestone v0.1a.
5. Menjaga biaya CPU, GPU, memory, dan download tetap cocok untuk browser.
6. Tidak menjanjikan rollback sekarang, tetapi menghindari keputusan yang menutup jalan ke rollback.

## 2. Non-Goals Awal

- Online multiplayer dan rollback implementation.
- Production asset pipeline lengkap.
- AI kompleks.
- Story, arcade, save progression, dan matchmaking.
- Framework ECS atau physics engine custom yang terlalu umum.
- Plugin besar sebelum kebutuhan nyata terbukti.

## 3. Architecture Overview

Project dibagi menjadi empat boundary utama.

### Application

Mengatur perpindahan screen, lifecycle match, settings, dan dependency wiring. Application tidak menentukan apakah serangan mengenai lawan.

### Simulation

Sumber kebenaran gameplay. Simulation memiliki:

- Frame counter.
- Fighter state dan integer position.
- Input history.
- Move timeline.
- Pushbox, hurtbox, hitbox, dan throw box.
- Hit resolution.
- Health, stun, knockdown, round timer, dan win state.
- Character mechanic state.

Simulation tidak memanggil animation, audio, particle, camera shake, atau UI secara langsung.

### Presentation

Membaca snapshot dan event dari simulation, lalu menampilkan:

- Character pose dan animation.
- Stage dan camera.
- HUD.
- Hit spark, trail, shader, dan particle.
- Audio dan screen shake.

Presentation boleh tertinggal atau diinterpolasi, tetapi tidak boleh mengubah hasil simulation.

### Content Data

Resource Godot yang mendefinisikan fighter, move, frame box, dan presentation key. Data menggunakan stable IDs, bukan filename sebagai kontrak gameplay.

## 4. Planned Folder Structure

```text
res://
  assets/
    audio/
    characters/
    stages/
    ui/
    vfx/
  data/
    fighters/
    moves/
    stages/
  docs/
  scenes/
    bootstrap/
    game/
    fighters/
    stages/
    ui/
  scripts/
    application/
    input/
    simulation/
      collision/
      combat/
      match/
    presentation/
    debug/
  tests/
    fixtures/
    simulation/
```

Folder dibuat ketika milestone pertama membutuhkannya. Empty architecture folders tidak dibuat hanya untuk terlihat lengkap.

## 5. Simulation Model

### Tick

- Godot physics tick ditetapkan 60 Hz.
- Match simulation menerima tepat satu input frame per fighter pada setiap tick.
- Semua timer combat disimpan sebagai integer frame.
- Pause presentation tidak boleh diam-diam memajukan simulation.

### Coordinate System

Simulation menggunakan integer subpixels agar hasil movement tidak bergantung pada float physics.

- `1 pixel = 1000 simulation units` sebagai baseline awal.
- Position dan velocity simulation menggunakan integer.
- Presentation mengubah simulation units menjadi `Vector2` untuk rendering.
- Gravity, acceleration, friction, dan knockback disimpan sebagai integer per tick.

Skala ini dapat disederhanakan setelah prototype, tetapi tidak boleh diganti di tengah milestone tanpa migration yang jelas.

### Fighter State

State awal yang direncanakan:

```text
INTRO
IDLE
WALK
CROUCH
JUMP_START
AIRBORNE
LANDING
DASH
BACKDASH
ATTACK
BLOCKSTUN
HITSTUN
KNOCKDOWN
WAKE_UP
KO
```

State transition dimiliki simulation. Animation finished signal tidak menentukan kapan recovery serangan selesai.

### Collision

Combat collision memakai axis-aligned integer rectangles.

- Pushbox diselesaikan lebih dulu.
- Throw checks dilakukan sesuai priority rule.
- Hitbox versus hurtbox menghasilkan hit candidate.
- Hit candidate disortir secara stabil sebelum resolution.
- Stage floor dan horizontal bounds menggunakan collision sederhana yang dimiliki match simulation.

Godot `Area2D` dapat dipakai sebagai visual debug helper, tetapi bukan authority hit detection.

## 6. Data Model

### FighterDefinition

Planned fields:

- Stable fighter ID.
- Display name dan presentation scene key.
- Maximum health.
- Movement constants.
- Default pushbox dan hurtbox profile.
- Move ID map.
- Character mechanic configuration.

### MoveDefinition

Setiap move minimal memiliki:

- Stable move ID.
- Startup, active, dan recovery frames.
- Damage, chip damage, hitstop, hitstun, dan blockstun.
- Horizontal dan vertical knockback.
- High, mid, low, atau throw property.
- Hit level dan knockdown result.
- Frame-by-frame boxes atau box timeline.
- Cancel rules untuk hit, block, dan whiff.
- Meter gain dan meter cost.
- Presentation animation key.
- Audio dan VFX event keys.

Move data akan dibuat sebagai custom `Resource`. Runtime tidak mencari move melalui nama node atau nama file asset.

### Frame Input

Setiap player menghasilkan bitmask action per tick:

- Left, right, up, down.
- Light, medium, heavy.
- Special, Covenant Guard, throw.
- Menu/debug actions berada di channel terpisah.

Input history menyimpan pressed, released, dan held state. Buffer baseline adalah lima frame.

## 7. Combat Resolution Order

Urutan provisional per simulation tick:

1. Sample atau consume frame input.
2. Resolve facing dari state tick sebelumnya.
3. Advance state timers dan buffered commands.
4. Apply movement intent, gravity, dan stage bounds.
5. Resolve fighter pushboxes.
6. Activate boxes untuk current move frame.
7. Collect throw dan strike candidates.
8. Resolve candidates dengan stable priority.
9. Apply hitstop, damage, stun, knockback, meter, dan mechanic effects.
10. Evaluate KO, timer, dan round state.
11. Emit immutable presentation events dan snapshot.

Order ini harus memiliki automated tests sebelum combo dan character mechanics menjadi kompleks.

## 8. Input Mapping

Physical input dipetakan ke semantic action di satu boundary.

Planned actions:

```text
p1_left, p1_right, p1_up, p1_down
p1_light, p1_medium, p1_heavy
p1_special, p1_guard, p1_throw
p2_left, p2_right, p2_up, p2_down
p2_light, p2_medium, p2_heavy
p2_special, p2_guard, p2_throw
```

InputMap Godot menangani device mapping. Simulation hanya menerima `FrameInput` dan tidak mengetahui keyboard atau controller yang digunakan.

## 9. Presentation Events

Simulation dapat menghasilkan event value sederhana:

- Attack started.
- Hit connected.
- Attack blocked.
- Throw connected.
- Fighter landed.
- Knockdown started.
- Round ended.
- Character mechanic changed.

Event membawa ID dan angka gameplay, bukan reference Node. Presentation memutuskan animasi, sound, VFX, dan camera response yang sesuai.

## 10. Debug and Testing

### Runtime Debug Overlay

Target v0.1a:

- Simulation frame.
- Current fighter state dan state frame.
- Current move dan move frame.
- Position dan velocity.
- Pushbox, hurtbox, hitbox, dan throw box.
- Health dan hitstun.
- Input history lima hingga sepuluh frame.

### Automated Tests

Headless tests diprioritaskan untuk simulation murni:

- State transition pada frame yang benar.
- Attack hanya aktif pada active frames.
- Hit hanya diterapkan sekali per allowed hit ID.
- Pushbox tidak overlap setelah resolution.
- Block direction mengikuti facing yang benar.
- KO dan timeout tidak menghasilkan pemenang ganda.
- Simulation yang diberi seed dan input sama menghasilkan snapshot sama.

Plugin test belum ditambahkan. Milestone v0.1a dapat memakai script runner headless kecil agar dependency tetap minimal.

## 11. Browser Constraints

- Gunakan GL Compatibility renderer.
- Baseline viewport 1280x720 dengan aspect ratio tetap.
- Texture besar dikompresi dan dibatasi sesuai kebutuhan visual aktual.
- Cosmetic VFX memiliki quality toggle dan tidak memengaruhi simulation.
- Hindari particle count tinggi, transparent overdraw besar, dan shader mahal.
- Audio loop dan SFX dipotong serta dikompresi sebelum shipping.
- Initial download budget ditentukan setelah placeholder web build pertama.
- Web build diuji melalui HTTP server, bukan membuka file HTML langsung.

## 12. Save and Settings Boundary

Vertical slice belum memiliki progression save.

Settings yang direncanakan:

- Master, music, dan SFX volume.
- Input bindings.
- Fullscreen dan display scale.
- Screen shake dan VFX intensity.
- Debug settings hanya tersedia di development build.

Save data tidak pernah menyimpan Node atau animation state.

## 13. Git and Asset Policy

- Repository memiliki satu canonical source.
- `.godot/`, builds, exports, dan log tidak di-commit.
- Binary art dan audio menggunakan Git LFS.
- Source artwork boleh disimpan dalam repo ketika relevan dan ukurannya terkontrol.
- Generated animation frames tidak menggantikan approved source frame tanpa review.
- Filename boleh berubah; stable content ID tidak boleh berubah sembarangan.

## 14. Milestone Entry Criteria

### v0.1a dapat dimulai ketika

- Project dapat di-import dan dijalankan headless.
- Scene bootstrap valid.
- Boundary simulation dan presentation disetujui melalui TDD ini.
- Input action names dan integer coordinate policy dikunci.

### v0.1a selesai ketika

- Izuna placeholder dapat bergerak dan menyerang dummy.
- Tiga normal attack mengikuti frame data.
- Hitstop, hitstun, damage, dan pushbox terlihat di debug overlay.
- Automated tests mencakup core frame timing dan hit resolution.
- Headless validation dan browser smoke test lulus.

## 15. Architecture Decisions

Keputusan berikut dikunci untuk prototype:

1. GDScript, bukan C#, untuk web compatibility dan iterasi cepat.
2. Simulation menjadi authority; AnimationPlayer hanya presentation.
3. Integer frame dan integer subpixels untuk state gameplay.
4. Data-driven move definitions menggunakan custom Resource.
5. Custom AABB combat collision, bukan physics callback sebagai authority.
6. Tidak menambahkan addon sampai kebutuhan nyata muncul.
7. Online multiplayer tetap future concern, bukan requirement v0.1.

## 16. Implementation Status

Milestone v0.1a combat skeleton saat ini mencakup:

- Pure GDScript simulation untuk fighter, move timeline, collision, dan hit resolution.
- Izuna placeholder melawan stationary training dummy.
- Walk, crouch, jump, forward dash, dan backdash.
- Light, Medium, dan Heavy dengan frame data provisional.
- Pushbox, hurtbox, hitbox, health, hitstop, hitstun, dan knockback.
- Canvas presentation terpisah dari simulation.
- Runtime debug boxes dan frame readout.
- Headless regression tests untuk attack timing, single-hit rule, pushbox, dash, dan reset.
- Web export serta browser smoke test.

Yang masih tersisa sebelum v0.1a dianggap gameplay-complete:

- Presentation event untuk hit spark dan screen feedback yang lebih jelas.
- Input history tampil di debug overlay.
- Dummy reset shortcut yang lebih lengkap untuk training.
- Playtest manual untuk tuning movement dan tiga normal attack.

### v0.1b two-player proof

- Izuna mirror match menggunakan simulation path yang sama untuk P1 dan P2.
- Keyboard mapping untuk dua pemain dan basic mapping untuk dua controller.
- Normal block dengan menahan arah menjauh dari lawan.
- Blockstun, heavy knockdown, automatic wake-up, KO, timeout, dan draw.
- Best-of-three round score dan automatic next-round flow.
- Simultaneous-hit resolution yang mendukung double KO.
- Web QA untuk input dan damage dari kedua pemain.
- Visual-development gate dibuka untuk silhouette Izuna.

### v0.1c character contrast foundation

- Roster prototype sekarang menggunakan Izuna untuk P1 dan Xenon untuk P2.
- Setiap karakter memiliki normal move data dan movement profile terpisah.
- Izuna Heavy menerapkan state Memory Mark dengan expiry 300 simulation frames.
- Xenon Medium memperoleh Emotional Echo ketika diblok atau mengenai counter-hit.
- Memory Mark dan Emotional Echo dibersihkan saat pemiliknya terkena knockdown.
- Presentation placeholder menampilkan identity serta debug state kedua mechanic.
- Tiga special placeholder tersedia untuk setiap karakter melalui Neutral, Forward, dan Down + Special.
- Recall Slash dapat mengonsumsi Memory Mark untuk membuat delayed strike.
- Despair Puppet memerlukan Emotional Echo, menyerang setelah fixed delay, dan hilang jika Xenon terkena hit.
- Foxfire Step dan Mocking Step menggunakan deterministic per-frame travel di simulation.
- Laughing Chain menarik lawan ke arah Xenon ketika mengenai target.
- Universal cancel route pada hit atau block adalah Light ke Medium/Special, Medium ke Heavy/Special, dan Heavy ke Special.
- Input serangan tetap dapat masuk ke buffer selama hitstop.
- Headless regression suite mencakup 61 assertions untuk core combat, character mechanics, special selection, delayed effects, dan cancel routes.

Milestone v0.1c dianggap implementation-complete. Angka frame, jarak, damage, invulnerability khusus, serta variasi follow-up tetap provisional dan masuk playtest atau milestone lanjutan.

### v0.1d defensive slice

- Covenant Guard memiliki startup empat frame, active hold, dan recovery sepuluh frame.
- Guard aktif mengurangi blockstun dan pushback tanpa memberi parry atau counter otomatis.
- Ground throw memiliki startup, active window, punishable whiff recovery, fixed damage, dan soft knockdown.
- Throw mengabaikan normal block serta Covenant Guard, tetapi tidak mengenai lawan airborne.
- `F2` mengembalikan neutral training spacing dan `F3` mengisi health serta membersihkan mechanic state.
- Debug overlay menampilkan current move phase dan frame data startup/active/recovery.
- Debug overlay disembunyikan secara default dan dapat dibuka dengan `F1`.
- Headless regression suite mencakup 78 assertions.
- Web release berhasil dirender melalui HTTP lokal di Chromium; baseline payload awal adalah 42.96 MiB.

Milestone v0.1d implementation-complete. Throw escape tetap wajib sebelum public v1.0 sesuai GDD.
