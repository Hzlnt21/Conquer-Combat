# Conquer Combat

Prototype fighting game 2D untuk browser dan Windows, dibuat dengan Godot 4.6.3 Standard dan GDScript.

Status saat ini: milestone v0.1b two-player proof dan visual-development gate.

Prototype saat ini memiliki:

- Izuna mirror match untuk dua pemain.
- Walk, crouch, jump, forward dash, dan backdash.
- Light, Medium, dan Heavy dengan startup, active, serta recovery frame.
- Pushbox, hurtbox, hitbox, hitstop, hitstun, damage, dan health bar.
- Normal block, blockstun, knockdown, KO, timer, dan best-of-three round flow.
- Keyboard dua pemain dan basic controller mapping.
- Debug overlay serta reset dengan tombol `R`.
- Web export dan headless regression tests.
- Visual brief Izuna siap untuk concept exploration.
- Canonical visual master Izuna telah disetujui dan dikunci.
- Turnaround empat arah Izuna dan rencana bagian Skeleton2D telah tersedia.
- Idle key pose Izuna telah tersedia sebagai seed frame untuk redraw dan rigging.
- Clean redraw idle Izuna dan separation map awal telah tersedia.

## Dokumen

- Game Design Document: `docs/GDD.md`
- Technical Design Document: `docs/TECHNICAL_DESIGN.md`
- Izuna Visual Brief: `docs/VISUAL_BRIEF_IZUNA.md`
- Izuna Production Package: `docs/production/IZUNA_PRODUCTION_PACKAGE.md`

## Menjalankan Project

1. Buka Godot 4.6.3 Standard.
2. Import folder repository ini.
3. Jalankan project dengan `F6` atau `F5`.

Command line:

```powershell
& 'D:\Apps\Coding Apps\Godot_v4.6.3-stable_win64.exe\Godot_v4.6.3-stable_win64_console.exe' --path 'D:\Code\Experiments\Conquer-Combat' --editor
```

Validasi headless:

```powershell
& 'D:\Apps\Coding Apps\Godot_v4.6.3-stable_win64.exe\Godot_v4.6.3-stable_win64_console.exe' --headless --path 'D:\Code\Experiments\Conquer-Combat' --editor --quit
```

Menjalankan simulation tests:

```powershell
& 'D:\Apps\Coding Apps\Godot_v4.6.3-stable_win64.exe\Godot_v4.6.3-stable_win64_console.exe' --headless --path 'D:\Code\Experiments\Conquer-Combat' --script 'res://tests/run_tests.gd'
```

## Struktur Awal

```text
assets/      Asset sumber dan asset siap pakai.
data/        Resource data gameplay seperti fighter dan move definition.
docs/        Dokumentasi teknis project.
scenes/      Scene composition dan presentation.
scripts/     Source GDScript.
tests/       Headless tests dan simulation fixtures.
```

## Prinsip

> Playable first, pretty later.

Simulation menjadi sumber kebenaran gameplay. Scene, animasi, audio, dan VFX hanya mempresentasikan state simulation.
