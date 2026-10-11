#!/usr/bin/env python3
"""Produce three isolated CC0 village facades from the pinned creator PNG.

Temporary reproducible art candidates. Real editable original PixelTown
architectural masters must eventually replace these extracted third-party art.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageChops

ROOT = Path(__file__).resolve().parents[2]
PATH = ROOT / "assets/third_party/ninja_adventure"
src = Image.open(PATH / "tileset_village_abandoned.png").convert("RGBA")
out = Image.new("RGBA",(240,96))
spec = {
    "cottage": ((191,95,256,176),(0,0),[(30,6),(36,8),(61,37),(64,53),(64,79),(1,79),(1,42),(15,20)]),
    "storage": ((174,0,225,48),(80,12),[(12,3),(43,3),(50,22),(50,47),(0,47),(0,27)]),
    "smithy": ((255,95,320,170),(160,0),[(14,1),(52,1),(64,22),(64,74),(1,74),(1,32)]),
}
for name,(rect,dest,points) in spec.items():
    tile=src.crop(rect)
    mask=Image.new("L",tile.size)
    ImageDraw.Draw(mask).polygon(points,fill=255)
    tile.putalpha(ImageChops.multiply(tile.getchannel("A"),mask))
    out.alpha_composite(tile,dest)
target=PATH/"curated_houses.png"
# Guard against atlas bleed / crop mistakes before CI accepts this art.
for label, (_, (px,py), _) in spec.items():
    tile = out.crop((px,py,px+(65 if label!="storage" else 51),py+(81 if label=="cottage" else 48 if label=="storage" else 75)))
    if tile.getchannel("A").getbbox() is None:
        raise ValueError(f"Empty building crop: {label}")
out.save(target,format="PNG",optimize=True)
print(f"CURATED CC0 BUILDING PASS: {target}, {out.size}, source: pinned Ninja Adventure V4")
