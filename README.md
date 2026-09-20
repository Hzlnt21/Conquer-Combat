# Conquer Combat

Professional portfolio vertical slice fighting game 2D untuk browser dan Windows, dibuat dengan Godot 4.6.3 Standard dan GDScript.

Status saat ini: **v1.0 professional portfolio vertical slice**. Build release telah tervalidasi secara native serta di Chromium, Microsoft Edge, dan Mozilla Firefox.

Prototype saat ini memiliki:

- Izuna versus Xenon dengan Arcade Duel melawan CPU, Guided Tutorial, Training, dan Local Versus.
- Walk, crouch, jump, forward dash, dan backdash.
- Light, Medium, dan Heavy dengan startup, active, serta recovery frame.
- Pushbox, hurtbox, hitbox, hitstop, hitstun, damage, dan health bar.
- Normal block, blockstun, knockdown, KO, timer, dan best-of-three round flow.
- Normal attack data dan movement profile berbeda untuk Izuna dan Xenon.
- Memory Mark/Recall Izuna dan Emotional Echo/Despair Puppet Xenon telah berjalan di simulation.
- Tiga special placeholder per karakter: Recall Slash, Foxfire Step, Memory Break, Laughing Chain, Mocking Step, dan Despair Puppet.
- Basic cancel route pada hit atau block: `Light -> Medium -> Heavy -> Special`.
- Covenant Guard, ground throw, training reset, dan frame-data debug readout.
- Throw Tech dengan input buffer 10 frame dan recovery netral untuk kedua fighter.
- Tiga bar Conviction, Conquer Art, Shift Cancel, satu Burst per ronde, dan Ultimate untuk kedua karakter.
- Keyboard dua pemain dan basic controller mapping.
- Debug overlay serta reset dengan tombol `R`.
- Web export dan headless regression tests.
- Title screen, mode selection, pause menu, dan kembali ke title.
- CPU deterministik dengan tingkat Easy, Normal, dan Hard.
- How to Play, guided tutorial lima langkah, intro match, result screen, rematch, dan pause flow.
- Training dummy dengan mode Stand, Guard, dan CPU.
- Settings tersimpan untuk master volume, ambient music, screen shake, impact flash, dan remapping keyboard Player 1.
- Original procedural ambient music dan combat audio untuk UI, attack, hit, guard, special, Burst, Ultimate, dan result.
- Idle, attack, serta hit-reaction key poses untuk Izuna dan Xenon dengan screen impact feedback.
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
| Throw / Throw Tech | `O` | `6` | Right shoulder |
| Resource | `P` | `7` | Left stick click |
| Ultimate | `[` | `8` | Right stick click |
| Reset match | `R` | `R` | - |
| Debug overlay | `F1` | `F1` | - |
| Training reset | `F2` | `F2` | - |
| Refill health/resources | `F3` | `F3` | - |
| Toggle CPU/local (development) | `F4` | `F4` | - |
| Ganti tingkat CPU | `F5` | `F5` | - |
| Pause | `Esc` | `Esc` | - |
| Ganti training dummy | `F6` | `F6` | - |

Special dipilih dengan arah yang sedang ditahan: tanpa arah untuk Neutral Special, arah maju untuk Forward Special, dan bawah untuk Down Special. Normal block dilakukan dengan menahan arah menjauh dari lawan. Covenant Guard memiliki startup dan recovery, mengurangi blockstun serta pushback, tetapi tetap kalah terhadap Throw. Tekan Throw dalam jendela serangan lawan untuk melakukan Throw Tech. Resource bersifat kontekstual: Conquer Art saat netral, Shift Cancel saat recovery, dan Burst ketika berada dalam hitstun atau blockstun. Seluruh binding Player 1 dapat diubah melalui Settings.

## Dokumen

- Game Design Document: `docs/GDD.md`
- Technical Design Document: `docs/TECHNICAL_DESIGN.md`
- Web Performance Baseline: `docs/WEB_PERFORMANCE_BASELINE.md`
- Combat Visual Integration: `docs/visual-development/COMBAT_VISUAL_INTEGRATION_V01.md`
- Release Checklist: `docs/RELEASE_CHECKLIST_V1.md`
- Web Deployment: `docs/WEB_DEPLOYMENT.md`
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
& 'D:\Apps\Coding Apps\Godot_v4.6.3-stable_win64.exe\Godot_v4.6.3-stable_win64_console.exe' --headless --path 'D:\Code\Experiments\Conquer-Combat' --export-release 'Web' 'builds/release-web/index.html'
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

## Scope Rilis

v1.0 adalah vertical slice portfolio yang sengaja berfokus pada satu duel lengkap, bukan game komersial dengan roster besar atau online multiplayer. Build web dapat dipasang di website atau subdomain dan dimainkan langsung di browser desktop.

Simulation menjadi sumber kebenaran gameplay. Scene, animasi, audio, dan VFX hanya mempresentasikan state simulation.
