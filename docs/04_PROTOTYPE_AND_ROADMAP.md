# First Playable Prototype and Development Roadmap v0.1

**Current state:** design/pre-production with a tested Godot CI/display-probe foundation, not yet a real game-art or gameplay prototype.

## The mistake we refuse to repeat

In the older NODE//ZERO project we spent substantial effort on large features, visual polish and CI before proving that the essential player experience was enjoyable and original. This time, the first gate is a **small but complete playable loop**. No ambitious multi-year roadmap should be treated as approval to build everything at once.

## Prototype 00B: Asset-production proof, before interactive blueprints

Work in **draft PR** with original modular PNG atlases, source-editable master, Godot TileMapLayer, bottom-anchored y-sorted objects, two character sizes and aligned gear sheets. Preserve the old working wood/cave demo. Compare real normal-scale village and cave screenshots, both scales and multiple display sizes/zoom levels against Prototype 00. **Do not mark Art Gate A accepted or merge without owner review.** See [Prototype 00B log](09_PROTOTYPE_00B.md).

## Prototype 00: Visual identity and technical feasibility

**Pass 1: Art and camera experiment.** Make a tiny Godot village with grass, two simple buildings, one villager, one armored guard and a cave entrance. Use slightly angled-looking top-down art on a normal square grid, **not isometric pathfinding**. Compare two sprite sizes at real gameplay zoom. Capture real engine visuals at 1920×1080, 2560×1440 and 3440×1440 before committing to an art standard.

**Pass 2: Make one villager's construction journey real.** Place a blueprint, fetch material, carry it to the plot and finish a visibly changing building. Check that every animation represents actual resource and construction state. Keep the simulation intentionally tiny.


**Goal:** prove that original pixel art is cohesive and realistically extensible.

Deliver a playable Godot scene with:
- a small grassy village clearing and path;
- one house, one storage shed, a working smithy and a cave entrance;
- one villager and one guard with equipment visual differences;
- work, movement and simple combat feedback;
- a small underground room with one enemy;
- legible information only when an object is inspected.

Acceptance:
- looks charming and consistent at intended game resolution;
- animations are meaningful, not uncanny or fake;
- characters retain consistent proportions and equipment overlays line up;
- producing a second character or building variant is straightforward;
- art source files, asset provenance and exact rendering settings are preserved;
- style remains coherent above and below ground.

No polished title screen, huge UI, research tree or dozens of sprite variants.

## Prototype 01: The First Descent (minimal complete loop)

**Goal:** make the first expedition actually rewarding and worth repeating.

Starting scenario (adjustable):
- one miniature village with **four inhabitants**, not a sprawling town;
- basic gathering, storage, hauling and a single crafting workshop/smithy;
- ability to craft/equip essential gear for **two adventurers**;
- one nearby cave with **three selectable danger/depth levels**;
- advisory recommended GS per level with warnings, but **no gear-score entry lock**;
- **all three prototype floors are selectable immediately**; later, clearing floor 3 unlocks the entire 4–7 group regardless of equipment;
- one or two enemies and basic autonomous positioning/attacks;
- optional **Retreat, Defend, Focus Target** during the live expedition;
- material and/or discovery recovered through a genuine return-trip result;
- **one rare material unlocking a visible village improvement**, not only a stronger sword.

### The player journey

1. Observe villagers gather and bring resources to storage.
2. Commission weapons or armor at the actual workshop.
3. Equip two adventurers, choose supplies, formation and cave floor.
4. Watch the party leave and fight in a visible 2D cave while village work continues.
5. Intervene if needed, extract safely or risk continuing.
6. Loot returns to the village economy, changing production or available crafting.
7. Use the reward to improve village life or preparation; consider the next floor.

### Explicit success criteria

- Player understands **what to do next** without reading a design document.
- Crafting a sword visibly connects resource gathering, labor, inventory and party gear.
- Party equipment and chosen floor **actually affect** encounters, not just labels.
- Warnings are advisory. A player can attempt **any unlocked floor** while under-geared; progression-group locks are separate from GS.
- Optional commands change real party behavior without constant micro.
- Expedition loot has a meaningful village consequence.
- At least two preparations or floor choices feel genuinely different.
- The settlement continues running while watching a dungeon.
- Returning adventurers, carrying loot and new infrastructure are visually rewarding.
- After one complete loop, the player wants to try again with a different choice.

An important anti-criterion: **the prototype is a failure if it is only pretty and technically functioning, but boring to replay**. Don't mask that with more menus, equipment tiers or effects.

## Suggested implementation sequence (gates, not promises)

After art/camera, construction is the first interaction test, followed by two adventurers fighting one enemy and returning with a resource, then that resource unlocking one visible village capability. Delay extra dungeons, professions and broad automation until the loop feels rewarding.


### Phase 0: Pre-production
Canonical design docs, temporary repository name, ARR license, agreed input/gameplay boundaries, a narrow art pipeline and clean Godot project.

### Phase 1: Art / environment proof
Single village and dungeon art scene, crisp render and small character animation system. Approve visual identity using real screenshots/video.

### Phase 2: Living village slice
Clock/tick, four villagers, small job/hauling queue, storage and one workshop. Actual inputs become actual equipment. Avoid unbounded agent simulation.

### Phase 3: Expedition slice
Party selection, simple gear slots, advisory gear-score floor picker, authored rooms, autonomous encounters, selected tactical commands and deterministic outcome accounting.

### Phase 4: Full-loop validation
Transport cave loot back, unlock one new village capability, replay the run. Balance inputs/risks/rewards. User tests the real game on Windows. Refactor based on observed boredom, friction or unclear choices.

### Phase 5: Content/depth, only after prototype sign-off
Professions, additional recipes and enemy behavior, optional village automation, environmental consequences, party combinations and more dungeon variety. Each addition must produce a **new decision**, not just an extra item or stat.

### Phase 6: Midgame and long-term depth, speculative
More diverse cave biomes, expeditions and facilities, discoveries with cross-system village effects, meaningful risk settings, adaptive automation, expedition objectives, authored milestones and an eventual endgame payoff. No commitments to 10+ hours, hundreds of floors, multiplayer or procedural worlds before real playtesting.

## Development decision checkpoints

**Gate A:** art viable? If no, change style/resolution/pipeline.
**Gate B:** villagers/world feel alive? If no, fix action feedback and meaningful simulation.
**Gate C:** one expedition is enjoyable? If no, refine preparation, visible combat, pacing and agency.
**Gate D:** loot materially changes village gameplay? If no, reconnect the systems.
**Gate E:** player voluntarily repeats the loop? If no, address underlying boredom before adding content.

## Tasks deliberately deferred

Full world generation, multiple settlements, huge profession tree, advanced weather/hydrology, large RPG stat systems, bosses, procedural dungeons, multiplayer, expansive UI, economy balancing for 20 floors, cosmetic sprite wardrobes and permanent character loss. They must be separately justified by the experience.

## Evidence expected in every implementation pass

Document what changed, why, actual inputs and outcome, passing/failing tests, screenshots from the **real running engine**, current limitations, and a short human playtest checklist. A screenshot of generated concept art is not evidence that gameplay looks like it.

See the technical/QA document and decisions record.
