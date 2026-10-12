#!/usr/bin/env python3
"""Review source images by a single CC0 artist, without altering shipping assets."""
from __future__ import annotations
import json, hashlib,sys
from pathlib import Path
from PIL import Image
def main():
  directory=Path(sys.argv[1]);data=[]
  for imagefile in sorted(directory.glob("*.png")):
    with Image.open(imagefile) as image:
      image.load()
      width,height=image.size
      native=image.convert("RGBA")
      # Preserve source resolution. Generate a manageable nearest-pixel display preview separately.
      scale=min(3,max(1,int(1024/max(width,height))))
      if scale==1 and max(width,height)>1600:
        # Do not change original, just present a smaller exploratory crop.
        display=native.crop((0,0,min(width,1024),min(height,900)))
      else:display=native.resize((width*scale,height*scale),Image.Resampling.NEAREST)
      display.thumbnail((1600,1200),Image.Resampling.NEAREST)
      display.save(directory/(imagefile.stem+"-review.png"))
      data.append({"name":imagefile.name,"size":[width,height],"sha256":hashlib.sha256(imagefile.read_bytes()).hexdigest()})
  (directory/"SOURCE_MANIFEST.json").write_text(json.dumps(data,indent=2))
  print(json.dumps(data,indent=2))
if __name__=="__main__":main()
