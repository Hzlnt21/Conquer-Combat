# Web Performance Baseline

**Milestone:** v0.1d Defensive Slice<br>
**Engine:** Godot 4.6.3 Standard<br>
**Export:** Web release, Compatibility renderer

## Baseline

| Item | Size |
| --- | ---: |
| Complete `index.*` payload | 42.96 MiB |
| Godot WebAssembly runtime | 35.95 MiB |
| Game package | 6.65 MiB |

After combat visual integration v01:

| Item | Size |
| --- | ---: |
| Complete `index.*` payload | 47.30 MiB |
| Godot WebAssembly runtime | 35.95 MiB |
| Game package | 10.99 MiB |

The first production-style stage and two transparent fighter cutouts add 4.34 MiB to the exported package. This remains acceptable for development, but later texture-size and import-compression passes must prevent linear growth as animation frames are added.

The build was served through local HTTP and rendered successfully in portable Chromium at a 1280x720 target viewport. The captured frame showed the arena, both fighters, HUD, timer, and the debug overlay disabled by default.

This is an initial engineering baseline, not the final shipping budget. Final optimization will re-check texture imports, unused-resource export, audio compression, cache headers, and release-template size after production assets are integrated.

## Release Gates

- Web export completes without errors.
- The page reaches a running Godot canvas through HTTP.
- Core combat remains functional with cosmetic debug disabled.
- Final portfolio deployment must be tested on current desktop Chrome, Edge, and Firefox.
- Payload and first-load timing must be measured again before public v1.0.
