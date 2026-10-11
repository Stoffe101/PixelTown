# Implementation Approach, QA and Repository Rules

**Status:** proposed technical foundations; no game implementation exists in this repo as of October 2026.

## Engine and target

**Godot 4.x, GDScript, 2D** is the proposed default, building on prior experience. Pin a tested stable Godot version once a project is initialized; do not reuse NODE//ZERO scripts or dependencies without deliberate review. Develop and test with a real Windows desktop build as well as suitable headless CI.

The game runs visually as crisp pixel art with consistent camera and nearest-neighbor rendering. Start with the smallest active 2D scene, not an elaborate framework.

## Separate real simulation from presentation

Recommended modules when needed:
- Village state: inhabitants, location, work priorities, resources and actual inventories.
- Jobs and logistics: tasks, item pickups, production and construction actions.
- Equipment and crafting: recipes, actual input reservation, manufactured outputs, gear slots/effects.
- Expedition state: party members, formation, floor selection, supplies, carried loot and safety rules.
- Cave encounters: entities, abilities, movement/targeting, commands, combat resolution and rewards.
- Progression: recipes, facilities and discoveries unlocked by outcomes.
- Save/load: stable serialization of village, inventory, party and ongoing expedition state.
- View layer: village and cave render real current simulation, with minimal contextual UI.

Use deterministic or seedable simulation logic where practical, with clear boundaries for visual animation; avoid fictitious labels, decorative stat curves and hardcoded loot not connected to actual state.

## Simultaneous village and dungeon

The simulation should update both domains irrespective of which camera/view the player is currently inspecting. A single world clock can drive bounded ticks for village jobs and cave behavior. Pause/speed modes are later UX decisions; idle/offline progression is not yet agreed. If engine frame updates are separate from simulation ticks, cap/budget AI processing for performance.

## Agent AI scope

Start simple: four villagers with a few work intents and visible task states, plus two adventurers with readable behaviors. Do not begin with an open-ended sophisticated GOAP planner, huge pathfinding system or thousands of concurrent entities. Show actual carrying, working, combat, injury and return.

## Quality gates

### Art/UX
- Real Godot village and cave screenshots at supported resolutions, not concept-art stand-ins.
- Character equipment overlays stay aligned during movement and combat.
- Pixel grid stays crisp, with no texture bleeding or mixed pixel scales.
- The player can clearly see building work, item transport, expedition departure/return and loot effects.
- Contextual HUD doesn't become another NODE//ZERO-style technical dashboard.
- Inspect contrast, colorblind-readable cues and scaled font readability.

### Core simulation
- Resources cannot be duplicated by repeated task assignment or view switching.
- Crafting consumes correct inputs once, produces correct outputs once and blocks gracefully on shortage.
- A cave run consumes expected supplies and returns only collected loot.
- Changing village/cave tabs doesn't reset or suspend the other simulation.
- Party assembly prevents duplicate simultaneous use of one person or piece of gear.
- Undergeared floor access remains available, with truthful warnings.
- Commands affect actual AI behavior and do not fabricate results.
- Failure/retreat/return correctly handles roster, injuries and inventory.
- Deterministic tests check that equipment/floor/formation have causal effects.

### Performance
- Measure actual rendered frames and interaction latency on real Windows hardware, not only headless simulation throughput.
- Avoid creating huge NPC fleets during prototype and then relying on optimizations to rescue the design.
- Keep sprites modular, batching efficient and effects restrained.

## GitHub Actions / public repo

The owner selected a **public** GitHub repository because private repository Actions minutes have reached the month's allowance. Keep workflows focused and cost-aware. Default to read-only GITHUB_TOKEN permissions and least-privilege jobs; never grant secrets or write permissions to untrusted pull requests. CI publishing of screenshots is optional and should not silently overwrite official approved baselines. A future implementation can adopt simple Godot import+core tests and a small image artifact pipeline; do not build a massive testing framework before there is a functional slice.

## All Rights Reserved and asset provenance

**Public repository does not equal open-source.** Original source, documents, designs and artwork are proprietary under /LICENSE. Do not label the project MIT, GPL, Apache, CC0 or other permissive/open source without explicit owner approval. GitHub interface viewing/forking under its Terms of Service is distinct from a license to reuse content.

Do not place secrets, licensed paid assets, private keys or proprietary third-party files in public git history. Any future external audio, fonts, sprites, code and tools require source/author/license evidence and explicit compatibility review. The original game's ARR claim does not remove rights third parties hold in their own materials.

Generated artwork also needs a source-editable master, usage notes and a coherence review. Never assume an image query result is licensed art we can ship.

## Dev documentation practice

- Use docs/00–06 as design chapters.
- Record accepted decisions in 05_DECISIONS_AND_OPEN_QUESTIONS.md, not only ephemeral chat.
- Update 04_PROTOTYPE_AND_ROADMAP.md as phases genuinely pass.
- In each implementation pass report code changed, real tests, screenshot references, unverified behavior, TODO and remaining blockers.
- Preserve a short fresh-chat handoff in START_HERE_NEXT_CHAT.md after major direction changes.
- Avoid committing to a complete story, tech tree, economy or visual detail before the first full loop earns approval.

## CI/display foundation (2026-10-11)

Initial CI and display-contract setup is documented in [07_CI_AND_DISPLAY.md](07_CI_AND_DISPLAY.md). Include **3440×1440 ultrawide** in rendered QA alongside 1920×1080 and 2560×1440. Current display-probe screenshots are NOT actual gameplay or approval of the art direction. The 640×360 pixel-art viewport, expand aspect and integer scaling remain provisional pending Windows review.
