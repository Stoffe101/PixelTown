#!/usr/bin/env python3
"""Validate stable one-to-one Aseprite master -> Godot prefab image mapping."""
import json,sys
from pathlib import Path
from PIL import Image
ROOT=Path(__file__).resolve().parents[2]
data=json.loads((ROOT/"art/production_assets.json").read_text())
assert data["schema_version"]==1
ids=set();sources=set();pngs=set()
for item in data["objects"]:
    id,src,png,scene=item["id"],item["source"],item["png"],item["prefab"]
    assert id not in ids and src not in sources and png not in pngs,(id,"duplicate")
    ids.add(id);sources.add(src);pngs.add(png)
    for path in (src,png,scene):assert not Path(path).is_absolute() and ".." not in Path(path).parts,path
    assert src.startswith("art/handmade/") and src.endswith(".aseprite")
    assert png.startswith("assets/sprites/") and not png.startswith("assets/third_party/")
    assert (ROOT/png).exists() and (ROOT/scene).exists()
    assert "res://"+png in (ROOT/scene).read_text(encoding="utf8"),id
    with Image.open(ROOT/png) as image:
        image.load()
        assert list(image.size)==item["size"],(id,image.size)
        assert image.mode=="RGBA" or (image.mode=="P" and "transparency" in image.info),id
    assert item["status"]!="approved" or (ROOT/src).is_file(),id
print(f"PASS: {len(ids)} canonical production PNG/prefab mappings. Missing masters are declared, not fabricated.")
