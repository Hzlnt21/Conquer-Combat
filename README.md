# Conquer Combat

Prototype fighting game 2D untuk browser dan Windows, dibuat dengan Godot 4.6.3 Standard dan GDScript.

Status saat ini: milestone v0.6 application flow, deterministic CPU, universal resource systems, dan combat visual integration telah berjalan di browser build.

Prototype saat ini memiliki:

- Izuna versus Xenon dengan Arcade Duel melawan CPU, Training, dan Local Versus.
- Walk, crouch, jump, forward dash, dan backdash.
- Light, Medium, dan Heavy dengan startup, active, serta recovery frame.
- Pushbox, hurtbox, hitbox, hitstop, hitstun, damage, dan health bar.
- Normal block, blockstun, knockdown, KO, timer, dan best-of-three round flow.
- Normal attack data dan movement profile berbeda untuk Izuna dan Xenon.
- Memory Mark/Recall Izuna dan Emotional Echo/Despair Puppet Xenon telah berjalan di simulation.
- Tiga special placeholder per karakter: Recall Slash, Foxfire Step, Memory Break, Laughing Chain, Mocking Step, dan Despair Puppet.
- Basic cancel route pada hit atau block: `Light -> Medium -> Heavy -> Special`.
- Covenant Guard, ground throw, training reset, dan frame-data debug readout.
- Tiga bar Conviction, Conquer Art, Shift Cancel, satu Burst per ronde, dan Ultimate untuk kedua karakter.
- Keyboard dua pemain dan basic controller mapping.
- Debug overlay serta reset dengan tombol `R`.
- Web export dan headless regression tests.
- Title screen, mode selection, pause menu, dan kembali ke title.
- CPU deterministik dengan tingkat Easy, Normal, dan Hard.
- Visual brief Izuna siap untuk concept exploration.
- Canonical visual master Izuna telah disetujui dan dikunci.
- Turnaround empat arah Izuna dan rencana bagian Skeleton2D telah tersedia.
- Idle key pose Izuna telah tersedia sebagai seed frame untuk redraw dan rigging.
- Clean redraw idle Izuna dan separation map awal telah tersedia.
- Visual scale proof Izuna pada viewport 1280x720 telah tervalidasi.
- Ruined Shrine, Izuna, Xenon, dan HUD production-style telah terintegrasi menggantikan placeholder boxes saat debug dimatikan.

## Kontrol Prototype

| Aksi | Player 1 | Player 2 | Controller |
| --- | --- | --- | --- |
| Gerak | `A/D/W/S` | Arrow keys | D-pad / left stick |
| Light | `J` | `1` | X / Square |
| Medium | `K` | `2` | Y / Triangle |
| Heavy | `L` | `3` | B / Circle |
| Special | `I` | `4` | A / Cross |
| Covenant Guard | `U` | `5` | Left shoulder |
| Throw | `O` | `6` | Right shoulder |
| Resource | `P` | `7` | Left stick click |
| Ultimate | `[` | `8` | Right stick click |
| Reset match | `R` | `R` | - |
| Debug overlay | `F1` | `F1` | - |
| Training reset | `F2` | `F2` | - |
| Refill health/resources | `F3` | `F3` | - |
| Toggle CPU/local (development) | `F4` | `F4` | - |
| Ganti tingkat CPU | `F5` | `F5` | - |
| Pause | `Esc` | `Esc` | - |

Special dipilih dengan arah yang sedang ditahan: tanpa arah untuk Neutral Special, arah maju untuk Forward Special, dan bawah untuk Down Special. Normal block dilakukan dengan menahan arah menjauh dari lawan. Covenant Guard memiliki startup dan recovery, mengurangi blockstun serta pushback, tetapi tetap kalah terhadap Throw. Resource bersifat kontekstual: Conquer Art saat netral, Shift Cancel saat recovery, dan Burst ketika berada dalam hitstun atau blockstun.

## Dokumen

- Game Design Document: `docs/GDD.md`
- Technical Design Document: `docs/TECHNICAL_DESIGN.md`
- Web Performance Baseline: `docs/WEB_PERFORMANCE_BASELINE.md`
- Combat Visual Integration: `docs/visual-development/COMBAT_VISUAL_INTEGRATION_V01.md`
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

Export web:

```powershell
& 'D:\Apps\Coding Apps\Godot_v4.6.3-stable_win64.exe\Godot_v4.6.3-stable_win64_console.exe' --headless --path 'D:\Code\Experiments\Conquer-Combat' --export-debug 'Web' 'builds/web/index.html'
```

Menjalankan visual scale proof Izuna:

```powershell
& 'D:\Apps\Coding Apps\Godot_v4.6.3-stable_win64.exe\Godot_v4.6.3-stable_win64_console.exe' --path 'D:\Code\Experiments\Conquer-Combat' --editor 'res://scenes/fighters/IzunaVisualProof.tscn'
```

Jalankan scene dengan `F6`. Tekan `F1` untuk guide dan `Space` untuk pause animasi presentation.

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
