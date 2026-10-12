# Live world integration pilot
This pass replaces visible legacy art references with existing canonical scene sprites where compatible while preserving editor-saved positions, gameplay markers, camera and simulation.

The live Worker, Guard and Slime are now actual **AnimatedSprite2D** instances sharing the same prefab SpriteFrames used in the gallery. Standing agents play directional idle; moving agents play directional walking; transport shows the existing carried-wood object; enemy bounce no longer has a second sine-wave bob. The simulation includes short, observable gathering and building phases (material conservation retained).

The guard's brief hit-time lunge is a **temporary placeholder**, NOT completed attack animation. Likewise dedicated gather/carry/work art still needs genuinely authored source frames. These do not pass the artistic animation gate just because actions have meaningful state labels.

The storehouse temporarily reuses the accepted CC0 cottage with crates instead of the incompatible old geometric warehouse. A distinct storehouse master remains outstanding. Original placeholder art files remain tracked until all dependent scenes are migrated.

The cave's `ChamberWalls` is an editor-saved 32px TileMapLayer; real material transition and wall-corner review still required. No complete autotile support is claimed. Run `scenes/main.tscn` for actual gameplay, or use the CI village/cave screenshot artifacts. PR remains draft.
