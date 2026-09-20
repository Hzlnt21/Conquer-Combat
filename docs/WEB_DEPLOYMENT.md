# Web Deployment

Conquer Combat v1.0 exports as a static Godot Web build. Upload every file from `builds/release-web/` to the same public directory; do not upload only `index.html`.

## Required MIME Types

| Extension | Content-Type |
| --- | --- |
| `.html` | `text/html; charset=utf-8` |
| `.js` | `text/javascript` |
| `.wasm` | `application/wasm` |
| `.pck` | `application/octet-stream` |

Threads are disabled in the shipping preset, so cross-origin isolation headers are not required. HTTPS is still recommended for public deployment. Cache versioned `.wasm` and `.pck` files, but revalidate `index.html` so releases update reliably.

## Suggested URL

Use a dedicated path or subdomain such as `play.example.com/conquer-combat/`. The build targets desktop keyboard and controller input; mobile touch controls are outside the v1.0 scope.

## Smoke Test

1. Open the public URL in a current Chrome or Edge desktop browser.
2. Confirm the title screen appears and ambient music starts after browser interaction if autoplay is restricted.
3. Complete the first Guided Tutorial objective.
4. Start Arcade Duel, pause, resume, and finish one match.
5. Reload the page and confirm audio, accessibility, and keyboard settings persist.
