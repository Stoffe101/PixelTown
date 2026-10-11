#!/usr/bin/env python3
"""Import a PINNED, CC0-only selection from Pixel-boy's Ninja Adventure artwork.

Accept the official creator's Godot V4 ZIP or the pinned GitHub project checkout.
Never import the project's source code, third-party sounds or other pack assets.
"""
import argparse
import hashlib
import json
from pathlib import Path
from zipfile import ZipFile

ROOT = Path(__file__).resolve().parents[2]
OUTPUT = ROOT / "assets" / "third_party" / "ninja_adventure"
UPSTREAM_REPO = "https://github.com/pixel-boy/NinjaAdventure"
UPSTREAM_COMMIT = "6ac78232d5aedcc85ce5f27d060ea92366f7c24a"
ART = {
    "tileset_floor.png": "e111065065edf806e7e893330086e68efc8755175d92f14d087b42d40a331e16",
    "tileset_village_abandoned.png": "6787c6e22a4d44ceee4f158309b2519707bdb70c59aca00b3d49006cadcca06e",
    "tileset_wall_simple.png": "ad5eb80ab4d5e65dbcda9dc012f9981323b277717349cdab012fc65ce06e43b2",
    "tileset_interior_floor.png": "e281598e2d90f43b31fd557b94c2d2abb00d307758a053b7df301575bf535e3a",
}

def main():
    parser = argparse.ArgumentParser()
    source = parser.add_mutually_exclusive_group(required=True)
    source.add_argument("--zip", type=Path, help="Exact original Godot Project V4.zip")
    source.add_argument("--source", type=Path, help="Pinned pixel-boy/NinjaAdventure GitHub checkout")
    args = parser.parse_args()
    OUTPUT.mkdir(parents=True, exist_ok=True)
    if args.zip:
        with ZipFile(args.zip) as z:
            contents = {}
            for name in ART:
                suffix = "/content/map/" + name
                found = [n for n in z.namelist() if n.endswith(suffix)]
                if len(found) != 1:
                    raise ValueError("Cannot uniquely locate " + suffix)
                contents[name] = z.read(found[0])
    else:
        contents = {name: (args.source / "content" / "map" / name).read_bytes()
                    for name in ART}
    for name, expected in ART.items():
        content = contents[name]
        actual = hashlib.sha256(content).hexdigest()
        if actual != expected:
            raise ValueError(f"License/supply-chain guard: hash mismatch {name} {actual}")
        (OUTPUT / name).write_bytes(content)
        print(f"IMPORTED CC0 {name}: {len(content)} bytes SHA256={actual}")
    report = {
        "publisher": "Pixel-boy / AAA",
        "pack": "Ninja Adventure Asset Pack (art subset from official Godot V4 example)",
        "original_url": "https://pixel-boy.itch.io/ninja-adventure-asset-pack",
        "repository": UPSTREAM_REPO,
        "pinned_ref": UPSTREAM_COMMIT,
        "license": "CC0-1.0 (applies to these original PNG artwork files)",
        "not_imported": "scripts, Godot project, fonts, music, paid packs, shaders",
        "files": ART,
    }
    (OUTPUT / "PROVENANCE.json").write_text(json.dumps(report,indent=2)+"\n",encoding="utf-8")

if __name__ == "__main__":
    main()
