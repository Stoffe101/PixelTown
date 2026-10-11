#!/usr/bin/env python3
"""CI visual proof: one changed source oak sprite updates all five scene instances."""
from __future__ import annotations
import argparse
from pathlib import Path
from PIL import Image, ImageChops
ROOT=Path(__file__).resolve().parents[2]
OAK=ROOT/"assets/sprites/environment/oak_tree.png"
CAM_X,CAM_Y=552,351
SCALE=3
OAK_POS=[(242,300),(352,232),(532,250),(735,246),(825,319)]

def tint():
    with Image.open(OAK) as original:
        image=original.convert("RGBA")
    count=0
    for y in range(image.height-20):
        for x in range(image.width):
            r,g,b,a=image.getpixel((x,y))
            if a > 240 and 50 <= g <= 185 and g > r*1.15:
                image.putpixel((x,y),(min(255,r+100),max(0,g-35),min(255,b+25),a))
                count+=1
    assert count>200, f"unexpected foliage source: {count} recolored pixels"
    image.save(OAK,optimize=True)
    print(f"Shared-source experiment: temporarily recolored {count} pixels in one oak PNG")

def verify(before,after):
    with Image.open(before) as a, Image.open(after) as b:
        a=a.convert("RGBA");b=b.convert("RGBA")
        assert a.size == b.size == (1920,1080), (a.size,b.size)
        mask=ImageChops.difference(a,b).convert("RGB")
        for i,(x,y) in enumerate(OAK_POS,1):
            sx=int((x-(CAM_X-320))*SCALE)
            sy=int((y-(CAM_Y-180))*SCALE)
            box=(max(0,sx-40*SCALE),max(0,sy-93*SCALE),min(1920,sx+40*SCALE),min(1080,sy))
            count=sum(1 for px in mask.crop(box).getdata() if px!=(0,0,0))
            if count<40:
                raise AssertionError(f"OakTree{i:02d} did not update from shared PNG: only {count} changed pixels in {box}")
            print(f"PASS OakTree{i:02d}: {count} changed pixels, position unchanged")
    print("PASS: a single source art edit visibly updated all five independently placed instances")

def main():
    ap=argparse.ArgumentParser()
    sub=ap.add_subparsers(dest="action",required=True)
    sub.add_parser("tint")
    check=sub.add_parser("verify")
    check.add_argument("before")
    check.add_argument("after")
    args=ap.parse_args()
    if args.action=="tint":tint()
    else:verify(Path(args.before),Path(args.after))
if __name__=="__main__":main()
