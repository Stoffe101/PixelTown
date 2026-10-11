# CI, display support and test evidence

**Status:** technical foundation, NOT a playable game or accepted visual style.

## Screen support contract

- **3440×1440** must be supported alongside 1920×1080 and 2560×1440. These are the initial CI targets, not the complete support matrix.
- Starting hypothesis: **640×360 logical pixels**, viewport stretch, expanding aspect and integer scaling, following Godot's pixel-art recommendations. This is provisional pending art and Windows testing.
- 3440×1440 should expose **more horizontal world**, rather than stretch sprites or force 16:9 pillarboxing. Important UI should use safe-area anchors, not float to the extreme edges without thought.
- Check actual camera composition, inventory placement, mouse targeting, pixel crispness and UI readability on the Windows ultrawide monitor. Linux virtual-display screenshots cannot certify physical DPI, refresh rate or how the game feels.
- Screenshots currently show a **display-probe shell** only: no village, cave, combat or approved art has been implemented.

## CI workflow

`.github/workflows/ci.yml` runs on main, ci/** branches, pull requests, and manual dispatch.

1. Repository checks protect required design files, ARR license, test structure and ultrawide workflow contract.
2. Godot **4.7.2-stable**, downloaded directly from official release URLs with pinned SHA-256 verification, imports the project on Linux and Windows.
3. GDScript runner discovers `tests/unit/*_test.gd`; each suite returns `Array[String]` failures and an empty list is a pass.
4. Both operating systems run headless startup checks. Reported engine/script errors fail CI even when Godot exits with status zero.
5. Linux uses **real non-headless rendering under Xvfb**, generating PNG captures at 1920×1080, 2560×1440, 3440×1440. The verifier checks PNG integrity and exact physical dimensions.
6. Available logs and captures are uploaded after failures as independent 7-day artifacts. The run summary lists which resolutions produced files.

Security and cost: read-only token permissions, SHA-pinned checkout/artifact actions, no secrets for PR code, no commits or automatic screenshot baseline updates, per-job time limits, branch-specific concurrency and minimal dependencies.

## Limits and forthcoming quality gates

- There are **no approved visual comparison baselines** yet. We need real gameplay art, in-engine screenshots and explicit user review first. Never silently auto-update baselines.
- There are **no gameplay, crafting, expedition or economy tests** yet, because those features do not exist. Add deterministic tests as systems are implemented.
- We have **no meaningful performance benchmark or 60 FPS claim** while the scene is still a diagnostic shell. Profile rendered gameplay on real Windows hardware once it exists.
- Export, installer and packaging workflows are deferred until actual game distribution is being tested.

## Review and local commands

Open **Actions → Godot CI**. Download `linux-godot-evidence` for PNG captures and logs, and `windows-godot-logs` for the native Windows smoke-test details.

```sh
godot --headless --editor --import --path .
godot --headless --path . --script res://tests/ci_runner.gd
godot --headless --path . --quit-after 12
```

Add a new unit suite as `tests/unit/some_feature_test.gd`:

```gdscript
extends RefCounted

func run() -> Array[String]:
    var failures: Array[String] = []
    # Append any failed assertions here.
    return failures
```

Current `scenes/main.tscn` is expressly **not final game art**. Later passes must capture actual village and cave scenes and add interaction, UI overflow and visual-regression tests for all target resolutions.
