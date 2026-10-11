# Dungeon Floors, Gear Score, Party Preparation and Autonomous Combat

**Status:** high-level behavior agreed; algorithms and content not yet implemented.

## Agreed expedition contract

The player chooses:
1. **Adventurers**, who may be inhabitants/guards/mercenaries from the living village.
2. **Equipment**, crafted from real settlement resources.
3. **Supplies**, such as rations or recovery consumables.
4. **Formation**, affecting risk and role effectiveness.
5. **Expedition depth / cave floor**, with clearly communicated risk.

Exploration and combat then run **autonomously**. The player watches the party in an actual 2D cave and may issue three optional commands: **Retreat, Defend, Focus Target**. Preparation should matter more than rapid button pressing.

Both village and cave simulation should continue when the player switches between views, rather than freezing one view while observing the other.

## Recommended gear score, not hard locks

- Multiple floor levels should be selectable.
- Each level displays an **advisory recommended gear score**.
- **Never prohibit a floor simply because party score is below the recommendation.** If they want to attempt it, allow it.
- The interface warns clearly about insufficient gear and higher danger; warnings should be grounded, not imply a fabricated exact win probability.
- Generally deeper or higher-tier floors offer better rewards, rarer materials and more difficult enemies.
- Actual success depends on factors beyond raw gear score: gear abilities, resistances, composition, supplies, enemy type, formations and the player's tactical orders.

**Illustrative values only, not final difficulty balance:** Floor 1 recommended GS 10; floor 5 GS 35; floor 10 GS 70; floor 20 GS 140. These were examples in a discussion widget, not locked numbers or a promise of 20 floors.

## Milestone-gated groups versus gear-score recommendations (accepted)

**Progression controls which groups are available; equipment only informs readiness for floors already available.** Never confuse these two concepts.

- **Floors 1–3:** available to select from the beginning, in any order and at any gear score.
- **Floors 4–7:** initially progression-locked. **Successfully completing floor 3 unlocks all of 4–7 together.** No requirement to complete floors 4–6 before selecting floor 7.
- **Later groups:** boundaries, objectives and milestones beyond 4–7 remain undecided.

Once a group is unlocked, **any floor in that group can be attempted even with a severely under-geared party**. Recommended GS must stay visible, but it can only advise and warn, never block or override a completed milestone. The floor picker should clearly distinguish milestone-locked, unlocked-but-dangerous and previously completed floors without depending solely on color.

Completing floor 3 means a **genuine successful clear**, not merely entering, failing or retreating. Define the exact clear objective when we implement that system; do not silently invent a boss requirement.

The initial First Descent slice still needs only floors 1–3 as actual playable content. The 4–7 rule is a **confirmed progression design**, not an instruction to implement seven floors before gameplay is proven.

## Meaningful floor variation

The cave must be more than increasing enemy HP and loot amounts. Later floors can introduce stronger or different enemies, hazards, environmental conditions, valuable resources, optional discoveries and specialized encounter demands. The first prototype only needs **three floor choices** and evidence that a deeper floor feels riskier and more rewarding.

## During an expedition

Adventurers autonomously navigate chambers, choose targets, move toward enemies, fight and recover loot, with health, supplies and cargo tracked in the simulation. They should be shown moving and interacting on-screen, not represented solely by an idle timer.

Proposed commands:
- **Retreat:** leave deeper exploration, attempt extraction and keep surviving members and whatever resources they carry.
- **Defend:** prioritize survival/defensive behavior over aggressive progress.
- **Focus Target:** direct combat targeting to a specific enemy.

These are high-level behaviors, not final combat algorithms. Commands should be useful but optional so the player can manage the village while an expedition runs.

## Loot and consequences

Successful expeditions return raw materials, enemy drops, possibly new items, experience and unusual discoveries. The village receives these through the real economy. Adventurers can use resources on gear and recovery. A rare discovery should sometimes unlock a recipe, new production process, infrastructure or environmental capability.

Consider injury, exhaustion, item wear and supply consumption to create preparation tradeoffs. Avoid harshness solely to increase playtime. A party can choose to retreat with smaller rewards. The simulation should explain why it succeeds or fails.

**Permanent death is NOT decided.** If explored later, discuss forgiving default rules and optional difficulty settings first; do not silently introduce irreversible losses of loved villagers.

## Illustrative expedition example

Two guards equipped with basic gear attempt floor 2. Their gear score is slightly below the recommendation, so they see a caution but may proceed. A defense-oriented formation helps against early enemies. They find unusual ore but a guard loses health. The player orders retreat, watches them extract and return home; the recovered ore unlocks a new workshop recipe.

## Prototype scope

One cave, three selectable floor difficulties, two adventurers, one or two basic enemy types, initial formation/equipment/supplies, the three commands, risk and rewards tied to depth, and one resource/discovery that changes village production. Authored chambers are acceptable: procedural generation, large boss sets and a giant combat class system are explicitly future scope.

## Open questions

The 1–3 available / 4–7 unlocked together after clearing floor 3 rule is **decided**. The exact definition of a successful clear and subsequent floor-group boundaries remain open.

Party size beyond first slice, exact gear-score formula and equipment slots, floor traversal structure, death/injury/recovery severity, simultaneous parties, procedural cave generation, pathfinding, boss design, loot tables, offline expedition behavior, difficulty modes and rescue mechanics. Do not treat any of these as established.
