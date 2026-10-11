# PixelTown (working repository name)

> **A living fantasy village that supports autonomous adventurers exploring an increasingly dangerous underground world.** A cozy 2D pixel-art simulation with crafting, settlement development, equipment, expeditions, meaningful choices, and gradually expanding automation.

**Status:** pre-production / design documentation. **PixelTown is a temporary repo name, not the final game title.** No playable game, approved art pack, or implemented systems are implied by these documents.

## License and public visibility

**Copyright © 2026 Christoffer Lööf. All rights reserved.** Original source code, artwork, designs, documentation, and other project materials are **proprietary, not open-source**. This repository is intentionally public so development can use public GitHub CI minutes, **not** to grant permission for reuse, modification, commercial use or redistribution. See [LICENSE](LICENSE) and [Contributor policy](CONTRIBUTING.md).

GitHub's Terms of Service still permit ordinary viewing and platform functionality (including certain forking). Public visibility cannot prevent unauthorized copying; it means the repository is viewable without granting an open-source license. Any future third-party assets keep their own licenses and must be tracked separately.


## The fantasy

Start with a handful of little inhabitants. They gather, farm, transport goods, and work in a village that visibly lives. Build a workshop and smithy, commission equipment, train or recruit adventurers, choose a party and its supplies, and send it into the caves. Watch explorers navigate and fight automatically, with optional tactical commands. Discoveries and rare materials return to the village to unlock new recipes, infrastructure, and capabilities. The upgraded settlement prepares stronger and more interesting expeditions. Both halves of the game continue supporting each other.

The settlement should feel comfortable, charming and autonomous; going underground is an opt-in source of excitement, risk and meaningful progression.

## Documentation map

| Document | Purpose |
| --- | --- |
| [Project vision](docs/00_PROJECT_VISION.md) | Identity, player's experience, core loops and design pillars |
| [Living world & village](docs/01_VILLAGE_AND_SYSTEMS.md) | Villagers, occupations, workshop, economy, environment and automation |
| [Expeditions & combat](docs/02_EXPEDITIONS_AND_COMBAT.md) | Cave floors, recommended gear score, autonomous parties, player commands, loot and consequences |
| [Pixel art direction](docs/03_ART_DIRECTION.md) | Visual identity, sprite guidelines, animation, creation workflow and feasibility risks |
| [First prototype & roadmap](docs/04_PROTOTYPE_AND_ROADMAP.md) | The First Descent vertical slice, acceptance gates, future phases and boundaries |
| [Decisions & open questions](docs/05_DECISIONS_AND_OPEN_QUESTIONS.md) | Agreed ideas versus illustrative examples and unresolved design decisions |
| [Technical approach & QA](docs/06_TECHNICAL_AND_QA.md) | Proposed engine, modular simulation, evidence, testing and documentation rules |
| [CI and ultrawide display](docs/07_CI_AND_DISPLAY.md) | Implemented initial CI checks, diagnostic rendering evidence and 3440×1440 support target |\n| [New-chat handoff](docs/START_HERE_NEXT_CHAT.md) | Self-contained prompt to give a fresh ChatGPT conversation |

**Start with the vision, decisions log and first prototype** before implementing features.

## Current development rule

**Prototype the smallest complete and fun loop before building the whole game.** One village, one workshop, a couple of adventurers, a cave with a few selectable floors, a return trip with loot, and one village improvement unlocked by that loot. Test playability and real in-engine pixel art, not just attractive concept descriptions.

All mechanics are **design only** until implemented and tested. The older NODE//ZERO game is a separate project and must not be assumed to define this game's codebase, visual language, economy or architecture.

## Source of truth

This repository tracks the design discussion through October 2026. Gameplay decisions may evolve through prototypes and explicit player review. Preserve previously agreed decisions when refining the design, and mark newly invented details as proposals, not commitments.

## First technical foundation

A provisional Godot 4.7.2 display probe and CI pipeline now live in this repository. They are NOT the visual prototype or gameplay. CI checks Linux + Windows startup and captures 1920×1080, 2560×1440 and 3440×1440 diagnostics with real Godot rendering. See [CI & display](docs/07_CI_AND_DISPLAY.md) for evidence and limits.
