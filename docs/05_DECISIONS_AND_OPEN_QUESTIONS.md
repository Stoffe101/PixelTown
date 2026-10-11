# Canonical Design Decisions, Examples and Open Questions

**Purpose:** prevent future conversations from misremembering suggestions as agreements. Updated 2026-10-11. Change this file when the player explicitly agrees to a design change.

## Accepted decisions

| ID | Decision | Rationale |
| --- | --- | --- |
| D-001 | **PixelTown is a temporary repository name**, not the final title | Name will be chosen later |
| D-002 | A new original **2D living fantasy settlement simulation with incremental/automation** | New identity rather than reproducing Upload Labs or extending NODE//ZERO |
| D-003 | **Village and dungeons are equally central (Option B)** | The village always has a purpose; expeditions support longer-term play |
| D-004 | Keep **Option A's cozy, relaxed living-world atmosphere** even though exploration and combat matter | Different player moods supported |
| D-005 | Player guides an **autonomous village**, including inhabitants, jobs, crafting and growth | Avoid repetitive manual command chains |
| D-006 | Workshop/smithy **crafts usable weapons and armor** for village guards/mercenaries/adventurers | Village progression directly enables expeditions |
| D-007 | Caves/dungeons have **selectable floors/depths with visible recommended gear score** | Clear progression and risk |
| D-008 | Recommended GS is **not a hard unlock or gear gate** | Player is free to attempt risky content |
| D-009 | **Deeper/higher difficulty generally means better rewards and risk** | An incentive to gear up and explore |
| D-010 | Player picks **adventurers, equipment, supplies, formation and expedition depth** before departure | Meaningful pre-combat strategy |
| D-011 | Adventurers **navigate and fight autonomously**, with optional **Retreat, Defend, Focus Target** commands | Sim first, tactical choice without action-RPG micro |
| D-012 | Village and dungeon should **both continue to simulate** when the other view is active | One unified living world |
| D-013 | Cave rewards improve **gear, recipes, village buildings and infrastructure**, not merely item levels | Strong two-way gameplay loop |
| D-014 | Choose **small, cute, whimsical 2D pixel art**, styled as storybook miniatures with warm village and atmospheric caves | Achievable and recognizable visual identity |
| D-015 | Avoid uncanny/overly exaggerated character proportions and random inconsistent AI assets | Player disliked earlier character references |
| D-016 | **Prove pixel-art pipeline in an actual Godot prototype** before creating large asset catalogs | Feasibility and consistency |
| D-017 | **Prototype first**, notably The First Descent: tiny village, workshop, two adventurers, three floor difficulties, one meaningful discovery | Prevent long work on unproven gameplay |
| D-019 | **3440×1440 ultrawide monitor is a required supported resolution** alongside conventional 16:9 desktop targets | Real user display; include in QA from the beginning; exact presentation/scaling remains a prototype question |\n| D-018 | Original code/art/docs are **All Rights Reserved**, even though the repo is public | Public access is for review and CI, not reuse permission |

## Strong design intentions, pending prototype evidence

- Villagers should visibly carry resources, craft, farm and build independently.
- Overworld is normally safe/cozy; dungeon danger is mainly opt-in.
- Different party setups should feel meaningfully different; GS is not a universal win/loss formula.
- Progression introduces new decisions, not only bigger numbers.
- Use simple 4-direction sprites, modular buildings and local/limited animation.
- Make each dungeon discovery unlock something meaningful in village life.
- Avoid a mandatory prestige reset or tedious rebuilding.
- Let players watch ongoing cave combat or return to village management.

These are design goals and should be tested; don't claim an algorithm is chosen just because the target behavior is agreed.

## Previously discussed illustrative examples, NOT final mechanics

- RILL, a proposed water-driven living valley concept; **not** the game's final title or compulsory setting.
- Draw irrigation channels from a spring, power waterwheels, automate sluice gates under rainfall. Atmospheric/system inspiration only, not mandatory simulation.
- Four villagers, two adventurers, three cave floors in the first slice. Chosen prototype limits, not final game caps.
- Floors 1/5/10/20 with GS 10/35/70/140 and specific ore types. Demonstration numbers only.
- "Village Guard, Level 3, 82% health, Iron Sword, Wooden Shield" was an interface example, not canonical class/stat data.
- Luminous mushrooms unlocking renewable potion ingredients/cellar, or blue crystals enabling irrigation. Examples of how discoveries change village systems, not approved item lists.
- Day/night windows, smoke, wind and weather as liveliness cues. Exact simulation depth unchosen.
- Two contrasting style references: top-down pixel art and geometric 2D. **Pixel art won**; exact grid and palette remain testable.
- Reference games Littlewood, Necesse, Core Keeper. Visual inspiration only, no permission to copy assets.

## Open questions with high design impact

### Important soon
1. **Presentation:** exact top-down orientation, tile size, character sprite scale and camera zoom after comparing actual art.
2. **Construction:** direct placement of buildings versus designated plots built autonomously by villagers.
3. **Agent simulation:** simple priorities/needs and occupations; how much detail matters to gameplay?
4. **Combat:** base decision loop, movement and hit feedback, whether three commands are sufficient and their actual effects.
5. **Cave progression:** can you select any floor in a cave or must parties traverse earlier floors first? User wants **no gear-score lock**, but floor discovery/unlock rules are undecided.
6. **Failure:** retreat, wounds, rescue and death penalties. Permadeath **not decided**; not default by assumption.
7. **Crafting:** slots/stats, gear score calculation, actual resources and economy.
8. **Core fun:** whether one returning party and meaningful village upgrade is enough to make the player voluntarily repeat.

### Later, deliberately postponed
- Exact classes and party cap, skill levels, specialized combat roles and resistances.
- Dungeon generation, fog-of-war, floor bosses, pathfinding detail and difficulty modes.
- Weather, water, seasons, ecosystems, population expansion, social simulation.
- Multiple settlements, regions and outposts.
- Repeat expedition policies, simultaneous parties, offline outcomes and full automation.
- Research/lore, story endgame, number of hours of content and naming.
- Multiplayer/co-op, distribution, pricing/monetization and platform support beyond development on Windows.

## Change policy

When accepting a new decision:
- assign ID D-019 onward;
- note date and underlying player choice;
- identify superseded example or previous decision explicitly;
- update relevant design chapter and prototype acceptance;
- never imply planned behavior has shipped without evidence.

**Repository code and art remain proprietary under /LICENSE.** Third-party assets retain their separate terms if accepted later.
