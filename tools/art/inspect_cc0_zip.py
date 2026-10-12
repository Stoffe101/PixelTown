#!/usr/bin/env python3
"""External CC0 art A/B audit only. Does not change gameplay or commit artwork.
Accept only PNG files from a limited ZIP; no scripts/executables are extracted.
"""
from __future__ import annotations
import hashlib
import json
import sys
import zipfile
from pathlib import Path
from PIL import Image, ImageDraw
ROOT=Path(__file__).resolve().parents[2]
def main():
    if len(sys.argv)!=3: raise SystemExit("usage: inspect_cc0_zip.py SOURCE.zip OUTPUT_DIR")
    source=Path(sys.argv[1]);dest=Path(sys.argv[2]);dest.mkdir(parents=True,exist_ok=True)
    records=[];images=[]
    with zipfile.ZipFile(source) as archive:
        entries=[item for item in archive.infolist() if item.filename.lower().endswith(".png") and not item.is_dir()]
        for index,item in enumerate(entries):
            if item.file_size>8_000_000 or item.file_size<=0 or len(records)>=65: continue
            try:
                with archive.open(item) as f:
                    from io import BytesIO
                    data=f.read(8_000_001)
                    if len(data)>8_000_000: continue
                    im=Image.open(BytesIO(data));im.load()
                    if im.width>3000 or im.height>3000:continue
                    im=im.convert("RGBA")
            except Exception as ex:
                print("Skip unreadable PNG:", item.filename,str(ex));continue
            fn=f"source_{index:03d}_{Path(item.filename).stem[:30]}.png"
            out=dest/fn
            out.write_bytes(data)
            records.append({"file":item.filename,"export":fn,"width":im.width,"height":im.height,"sha256":hashlib.sha256(data).hexdigest(),"bytes":len(data)})
            images.append((item.filename,im))
    if not records:raise SystemExit("No PNG images found in remote CC0 ZIP; manual review blocked.")
    (dest/"MANIFEST.json").write_text(json.dumps({"source":"https://opengameart.org/content/rpg-town-pixel-art-assets","author":"Ansimuz / Luis Zuno","license":"CC0, confirmed on creator's OpenGameArt entry","pack_sha256":hashlib.sha256(source.read_bytes()).hexdigest(),"files":records},indent=2))
    page_w=960;col_w=320;row_h=260
    for start in range(0,len(images),9):
        tile=Image.new("RGB",(page_w,3*row_h),(30,27,37))
        draw=ImageDraw.Draw(tile)
        for z,(name,im) in enumerate(images[start:start+9]):
            gx=(z%3)*col_w;gy=(z//3)*row_h
            scale=max(1,min(6,int(min((col_w-12)/im.width,(row_h-32)/im.height))))
            scale=min(scale,4)
            small=im.resize((im.width*scale,im.height*scale),Image.Resampling.NEAREST)
            if small.width>col_w-12 or small.height>row_h-36:
                shrink=min((col_w-12)/im.width,(row_h-36)/im.height)
                small=im.resize((max(1,int(im.width*shrink)),max(1,int(im.height*shrink))),Image.Resampling.NEAREST)
            tile.paste(small,(gx+max(0,(col_w-small.width)//2),gy+20),small)
            draw.text((gx+5,gy+5),name[-43:],fill="white")
        tile.save(dest/f"CONTACT_{start//9+1:02}.png")
    print("Art-source audit complete:",len(records),"files","SHA256",hashlib.sha256(source.read_bytes()).hexdigest())
    for rec in records:print(rec["file"],rec["width"],"x",rec["height"])
if __name__=="__main__":main()
