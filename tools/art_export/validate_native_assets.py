#!/usr/bin/env python3
"""Validate source PNGs used by new drag-and-drop scenes; no artwork regeneration."""
from pathlib import Path
from PIL import Image
ROOT = Path(__file__).resolve().parents[2]
ASSETS = {
 "assets/sprites/buildings/house_small.png": (128,144),
 "assets/sprites/characters/guard_attack_right.png": (128,72),
 "assets/sprites/characters/villager_activity_sheet.png": (256,144),
 "assets/sprites/buildings/blacksmith.png": (160,152),
 "assets/sprites/environment/oak_tree.png": (96,112),
 "assets/sprites/environment/large_rock.png": (40,30),
 "assets/sprites/props/barrel.png": (40,44),
 "assets/tilesets/village/village_ground_16.png": (128,64),
}
def main():
 for rel, size in ASSETS.items():
  with Image.open(ROOT/rel) as im:
   im.load()
   assert im.size == size and (im.mode == "RGBA" or (im.mode == "P" and "transparency" in im.info)), (rel, im.mode, im.size)
   alpha=im.convert("RGBA").getchannel("A")
   lo,hi=alpha.getextrema()
   assert hi==255,(rel,"not rendered")
   if "sprites/" in rel:
    assert lo==0,(rel,"no transparent background")
 print("PASS: native sprite candidates have verified dimensions, alpha and render pixels")
if __name__=="__main__": main()
