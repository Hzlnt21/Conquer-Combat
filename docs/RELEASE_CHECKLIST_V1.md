# Conquer Combat v1.0 Release Checklist

## Scope

- [x] Two distinct fighters: Izuna and Xenon.
- [x] One production-style stage: Ruined Shrine of Conquest.
- [x] Arcade Duel, Guided Tutorial, Training, and Local Versus.
- [x] Best-of-three match flow, result screen, rematch, pause, and return to title.
- [x] Keyboard and controller play, with persistent Player 1 keyboard remapping.

## Combat

- [x] Movement, dash, jump, normals, directional specials, throws, and Throw Tech.
- [x] Block, Covenant Guard, hitstun, blockstun, knockdown, KO, and timeout.
- [x] Conviction Gauge, Conquer Art, Shift Cancel, Burst, and Ultimate.
- [x] Character mechanics: Memory Mark/Recall and Emotional Echo/Despair Puppet.
- [x] Deterministic CPU with Easy, Normal, and Hard difficulty.

## Presentation

- [x] Approved character identities and six runtime key poses.
- [x] Layered stage presentation, HUD, intro banner, result presentation, hit flash, and screen shake.
- [x] Procedural music and event-driven combat/UI sound effects.
- [x] Settings, controls, credits, and third-party notices.

## Verification

- [x] Godot editor import/parser check.
- [x] `PASS: 121 assertions`, including deterministic CPU-vs-CPU soak match.
- [x] Native 1280x720 visual captures for title, gameplay, tutorial, settings, controls, credits, and result.
- [x] Release export with development sources and visual proof assets excluded.
- [x] Chromium and Edge automated canvas smoke tests.
- [x] Firefox WebDriver BiDi canvas smoke test on the final release build.

Public-host smoke testing remains a deployment task because no production domain or hosting target is configured in this repository.

## Deliberate Non-Goals

Online multiplayer, mobile touch controls, a larger roster, story cinematics, rollback netcode, and frame-by-frame production animation are outside this portfolio vertical slice. They are future product work, not hidden v1.0 claims.
