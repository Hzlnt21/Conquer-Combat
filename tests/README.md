# Tests

Regression suite menggunakan script runner GDScript ringan tanpa addon eksternal. Suite saat ini mencakup frame timing, collision dan hit resolution, movement, block, round flow, character mechanics, special selection, delayed effects, serta basic cancel routes Izuna dan Xenon.

Jalankan dari PowerShell:

```powershell
& 'D:\Apps\Coding Apps\Godot_v4.6.3-stable_win64.exe\Godot_v4.6.3-stable_win64_console.exe' --headless --path 'D:\Code\Experiments\Conquer-Combat' --script 'res://tests/run_tests.gd'
```

Hasil baseline milestone v0.1c adalah `PASS: 61 assertions`.
