# PixelTown: Copy/Paste Handoff for a New Chat

**Repository:** https://github.com/Stoffe101/PixelTown
**Repo name is temporary. Game name NOT finalized.**
**Status:** design/pre-production, initially created 2026-10-11.
**License:** original code, artwork, designs and docs are **All Rights Reserved** (see /LICENSE). Repo intentionally public to use public GitHub Actions while the private Actions quota is exhausted. Public does NOT grant permission to reuse or redistribute project assets or source code.

## Copy the entire prompt below into a new ChatGPT conversation

---

We are starting a NEW, ORIGINAL 2D Godot simulation/incremental adventure game. Our current repository is https://github.com/Stoffe101/PixelTown; "PixelTown" is only a TEMP name. Before proposing changes or writing code, READ the latest README.md and docs/00_PROJECT_VISION.md through docs/06_TECHNICAL_AND_QA.md, plus /LICENSE, directly from the GitHub repository and check current branches/files. The GitHub docs, especially docs/05_DECISIONS_AND_OPEN_QUESTIONS.md, are the canonical source of truth. Never pretend features are implemented until verified.

GAME PREMISE: A cozy pixel-art living fantasy village above ground and increasingly challenging cave/dungeon expeditions below. It is an intertwined **living village + autonomous adventurer-guild** simulator with incremental growth and meaningful automation. The village is warm/relaxing, but expeditions provide voluntary combat, risk, discoveries and long-term goals. **Both systems are equally important (Option B)**, not a village builder with token dungeon content or an action RPG with a village menu.

CORE LOOP: Villagers autonomously gather, farm, carry, work and construct. The player guides village priorities, workshops and smithies to craft weapons, armor, shields and supplies. The player chooses adventurers, real equipment, supplies, formation and a cave floor. Parties autonomously explore and fight in a visible 2D cave, and the player can optionally issue **Retreat, Defend, Focus Target**. Caves have difficulty/depth floors with **recommended gear scores, never equipment-based hard locks**, and deeper levels generally yield greater risk and better rewards. Expedition loot, rare materials and discoveries return to the actual village economy, enabling new recipes, buildings, infrastructure and village automation, not only stronger gear. The two simulations should continue even when switching between village and cave view.

ART DECISION: Chosen **small, charming, whimsical, storybook-like 2D PIXEL ART**, cozy bright village contrasting with atmospheric dark caves. Tiny recognizable inhabitants with good silhouettes and readable clothing/helmets/weapons, not strange giant-eyed AI babies. Direction is provisional top-down and 16×16 terrain tiles, approximately 16×24 characters, 4-direction simple animations and modular structures; exact dimensions must be tested. We need a genuinely CONSISTENT and maintainable art pipeline, not a bulk batch of unrelated AI sprites. I can't make art/models myself, so you need to make responsible choices based on what you can actually produce, assess licenses for external assets and demonstrate everything in an actual Godot scene. Concept references aren't shipped game art.

PROGRESSION & FEEL: First minutes involve a charming settlement, making initial gear, an expedition and one meaningful discovery. The game supports relaxed village optimization and more exciting high-risk underground challenges. Activities have visible consequences. Avoid dull mid/endgame patterns, walls of permanently open UI, endless pointless currencies, frustrating manual repetition or adding features without a compelling player experience.

FIRST DEVELOPMENT GOAL: Don't start by building the full game. FIRST create the small art/visual prototype showing a cohesive grassy village, a workshop, cave, one villager/guard and one enemy. Then make the **First Descent** playable vertical slice: ~4 villagers, one workshop/storage, two equipped adventurers, one cave with ~3 selectable difficulty floors and recommended GS warnings, autonomous combat, optional tactical commands, actual returned loot and one cave discovery enabling a visible village upgrade. Playtest and review real screenshots/motion in-engine before making a large roadmap. These counts are PROTOTYPE targets, not final game caps.

IMPORTANT OPEN QUESTIONS: final name and lore, art size/perspective, exact profession/needs systems, building placement vs autonomous zoning, crafting/equipment stats and GS formula, floors and progression map, enemy behaviors, injury/permadeath (NOT approved as default), world generation, offline progression, endgame content, multiplayer/monetization. Discuss rather than silently committing. Previous illustrative values like floor 20/GS 140, irrigation and luminous mushrooms are examples, not final canon.

WORKFLOW: Keep updated docs in repo, meaningful tests, visuals and implementation notes; don't automatically rewrite past decisions. Public repo with **ALL RIGHTS RESERVED**, no open-source license, third-party assets only if properly licensed for our commercial/proprietary use. Current public repository choice is for CI allowance, not permission for others to copy code. We used NODE//ZERO in a prior, separate project but this is NOT a NODE//ZERO continuation or Upload Labs imitation. Preserve our game's own identity. The first task in this new chat is to review the actual repository and recommend the smallest useful first art/tech prototype and concrete acceptance checks; wait for my go-ahead to expand beyond it.

---

## Short version for future updates

"This chat continues PixelTown (temporary name), the cozy pixel-art living village + autonomous dungeon adventuring game at https://github.com/Stoffe101/PixelTown. Read the README and every relevant doc in docs/, especially decisions and prototype roadmap, before working. Original assets/code ARR. Keep village and expeditions equally important, cave gear score advisory only, autonomous combat with optional Retreat/Defend/Focus Target, a coherent pixel-art pipeline and a small complete playable prototype before expanding."

**Note:** This is a handoff prompt, not an actual assistant memory update. A new conversation should read the live repository docs rather than assume this snapshot reflects the latest code.
