# CI, display support and test evidence

**Status:** technical foundation, NOT a playable game or accepted visual style.

## Screen support contract

- **3440×1440** must be supported alongside 1920×1080 and 2560×1440. These are the initial CI targets, not the complete support matrix.
- Starting hypothesis: **640×360 logical pixels**, viewport stretch, expanding aspect and integer scaling, following Godot's pixel-art recommendations. This is provisional pending art and Windows testing.
- 3440×1440 should expose **more horizontal world**, rather than stretch sprites or force 16:9 pillarboxing. Important UI should use safe-area anchors, not float to the extreme edges without thought.
- Check actual camera composition, inventory placement, mouse targeting, pixel crispness and UI readability on the Windows ultrawide monitor. Linux virtual-display screenshots cannot certify physical DPI, refresh rate or how the game feels.
- The original CI display probe has been replaced by **an unapproved original pixel-art Prototype 00 scene**: a village, cave, people, and demonstration activity. This is not finished gameplay or approved game art.

## CI workflow

`.github/workflows/ci.yml` runs on main, ci/** branches, pull requests, and manual dispatch.

1. Repository checks protect required design files, ARR license, test structure and ultrawide workflow contract.
2. Godot **4.7.2-stable**, downloaded directly from official release URLs with pinned SHA-256 verification, imports the project on Linux and Windows.
3. GDScript runner discovers `tests/unit/*_test.gd`; each suite returns `Array[String]` failures and an empty list is a pass.
4. Both operating systems run headless startup checks. Reported engine/script errors fail CI even when Godot exits with status zero.
5. Linux uses **real non-headless rendering under Xvfb**, generating actual Godot art-review PNG captures at 1920×1080, 2560×1440, 3440×1440, including village and cave views and **both candidate character sprite scales**. Godot renders each frame at its actual integer-scaled logical viewport, then the capture script scales the frame using nearest-neighbor pixels to the target physical image size. The verifier checks PNG integrity and exact output dimensions. These are representative pixel-art output captures, not raw monitor screenshots.
6. Available logs and captures are uploaded after failures as independent 7-day artifacts. The run summary lists which resolutions produced files.

Security and cost: read-only token permissions, SHA-pinned checkout/artifact actions, no secrets for PR code, no commits or automatic screenshot baseline updates, per-job time limits, branch-specific concurrency and minimal dependencies.

## Prototype 00B sprite validation

CI creates four original PNG sprite/tileset sheets + JSON from a source-editable, dependency-free Python master before Godot import. An asset validator checks PNG integrity, exact pixel sizes, metadata region bounds, and presence of drawable frames and aligned guard equipment. Linux CI renders actual village/cave atlas scenes, Windows imports and runs deterministic tests, and review PNG + source atlases are uploaded. This never constitutes automatic visual sign-off.

## Limits and forthcoming quality gates

- There are **no approved visual comparison baselines** yet. We need real gameplay art, in-engine screenshots and explicit user review first. Never silently auto-update baselines.
- The **tiny Prototype 00 demonstration state** has a deterministic no-wood-duplication, building-completion and background cave-tick unit test. There are still **no full crafting, expedition, equipment, or economy features/tests**. Add appropriate deterministic tests with each real system.
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

Current `scenes/main.tscn` contains an early **in-engine village/cave art experiment**, not final approved game art. CI captures it but performs **no pixel-perfect comparison** until real human-reviewed baselines are approved. Later passes should add input/UI overflow and interaction visual QA once appropriate.
