#!/usr/bin/env python3
"""Validate PixelTown-original hero PNG exports and editable layered masters."""
import io,sys,zipfile,hashlib,xml.etree.ElementTree as ET
from pathlib import Path
from PIL import Image,ImageChops
ROOT=Path(__file__).resolve().parents[2]
TARGET=ROOT/"assets"/"original"/"hero"
MASTER=ROOT/"art"/"source"/"architecture"
EXPECTED={
"smithy":(164,126),"cottage":(138,113),"storehouse":(124,108),
"cave_gate":(130,110),"mature_tree":(86,112),"cave_wall":(150,106),
"inhabitants":(384,256),"guard_equipment":(384,128)
}
def validate(name,size):
    path=TARGET/f"{name}.png"
    with Image.open(path) as im:
        img=im.convert("RGBA")
        if img.size!=size:raise ValueError(f"{name}: incorrect size {img.size} != {size}")
        if img.getchannel("A").getbbox() is None:raise ValueError(f"{name}: fully transparent")
        if img.getpixel((0,0))[3]!=0:raise ValueError(f"{name}: opaque art at origin suggests atlas bleed")
    master=MASTER/f"{name}.ora"
    with zipfile.ZipFile(master) as z:
        if z.read("mimetype")!=b"image/openraster":raise ValueError(f"{name}: not OpenRaster")
        if not z.testzip() is None:raise ValueError(f"{name}: broken archive")
        stack=ET.fromstring(z.read("stack.xml"))
        if (int(stack.attrib["w"]),int(stack.attrib["h"]))!=size:
            raise ValueError(f"{name}: incorrect master canvas")
        layers=stack.findall("./stack/layer")
        if len(layers)<4:raise ValueError(f"{name}: too few editable layers")
        for el in layers:
            src=el.attrib.get("src")
            if src not in z.namelist():raise ValueError(f"{name}: missing layer {src}")
            with Image.open(io.BytesIO(z.read(src))) as l:
                if l.size!=size:raise ValueError(f"{name}: layer size mismatch")
        with Image.open(io.BytesIO(z.read("mergedimage.png"))) as merged:
            if ImageChops.difference(merged.convert("RGBA"),img).getbbox() is not None:
                raise ValueError(f"{name}: PNG export differs from layered master")
    print("HERO ART PASS",name,size, "layers",len(layers),"SHA256",hashlib.sha256(path.read_bytes()).hexdigest()[:16])
def main():
    for name,size in EXPECTED.items():validate(name,size)
    for name,rows in [("inhabitants",8),("guard_equipment",4)]:
        im=Image.open(TARGET/f"{name}.png").convert("RGBA")
        for row in range(rows):
            for col in range(16):
                if im.crop((col*24,row*32,(col+1)*24,(row+1)*32)).getchannel("A").getbbox() is None:
                    raise ValueError(f"{name}: blank frame {col},{row}")
    print("HERO ART PASS: all 4-way frames nonempty and layered masters verified")
if __name__=="__main__":
    try:main()
    except (ValueError,OSError,zipfile.BadZipFile) as exc:
        print("HERO ART FAIL",exc,file=sys.stderr)
        sys.exit(1)
