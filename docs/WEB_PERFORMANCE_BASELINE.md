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

After v0.8 presentation and export filtering:

| Item | Size |
| --- | ---: |
| Clean release payload | 45.45 MiB |
| Godot WebAssembly runtime | 35.95 MiB |
| Game package | 9.14 MiB |

The runtime package now includes the stage, six production character key poses, UI flow, and procedural audio. Development concept boards, turnaround sheets, visual-proof scenes, tests, and `SOURCE/` are explicitly excluded. Chromium CDP verification confirmed `document.readyState=complete`, a live canvas, and the rendered title screen from the release package.

Final v1.0 release:

| Item | Size |
| --- | ---: |
| Clean release payload | 45.46 MiB |
| Godot WebAssembly runtime | 35.95 MiB |
| Game package | 9.16 MiB |

The final build adds guided tutorial, persistent key remapping, procedural ambient music, credits, and release metadata without materially increasing the download. Automated 15-second boot captures confirmed a complete document, live canvas, and rendered title screen in portable Chromium 151, Microsoft Edge 153, and Mozilla Firefox 156. Chromium and Edge used CDP; Firefox used WebDriver BiDi.

## Release Gates

- Web export completes without errors.
- The page reaches a running Godot canvas through HTTP.
- Core combat remains functional with cosmetic debug disabled.
- Current desktop Chromium, Edge, and Firefox reach the live Godot title canvas.
- Payload and first-load timing must be measured again before public v1.0.
