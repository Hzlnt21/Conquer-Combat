# Tests

Regression suite menggunakan script runner GDScript ringan tanpa addon eksternal. Suite saat ini mencakup frame timing, collision dan hit resolution, movement, block, Covenant Guard, throw dan Throw Tech, round flow, training reset, character mechanics, special selection, delayed effects, cancel routes, Conviction, Conquer Art, Shift Cancel, Burst, Ultimate, serta determinisme dan perilaku dasar CPU.

Jalankan dari PowerShell:

```powershell
& 'D:\Apps\Coding Apps\Godot_v4.6.3-stable_win64.exe\Godot_v4.6.3-stable_win64_console.exe' --headless --path 'D:\Code\Experiments\Conquer-Combat' --script 'res://tests/run_tests.gd'
```

Hasil baseline release v1.0 adalah `PASS: 121 assertions`.
