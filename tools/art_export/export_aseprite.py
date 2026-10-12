#!/usr/bin/env python3
"""Export true .aseprite files to Godot sprites; never rename PNGs as masters."""
from __future__ import annotations
import argparse, json, os, shutil, subprocess, sys, tempfile
from pathlib import Path
ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "art" / "handmade"
DEST = ROOT / "assets" / "handmade"
def main() -> int:
    p=argparse.ArgumentParser()
    p.add_argument("--exe",help="Aseprite path or use ASEPRITE_EXE")
    p.add_argument("--dry-run",action="store_true")
    args=p.parse_args()
    files=sorted([*SOURCE.rglob("*.aseprite"),*SOURCE.rglob("*.ase")])
    if not files:
        print("No native Aseprite files found; no sprites modified.")
        return 0
    candidates=[args.exe,os.environ.get("ASEPRITE_EXE"),shutil.which("aseprite"),shutil.which("aseprite.exe")]
    if os.name=="nt":
        candidates.append(str(Path(os.environ.get("ProgramFiles","C:/Program Files"))/"Aseprite"/"Aseprite.exe"))
    exe=next((str(x) for x in candidates if x and (shutil.which(x) or Path(x).is_file())),None)
    if not exe and not args.dry_run:
        print("Aseprite not found. Set ASEPRITE_EXE or pass --exe.",file=sys.stderr)
        return 2
    for src in files:
        relative=src.relative_to(SOURCE).with_suffix("")
        dest=DEST/relative.with_suffix(".png")
        data_dest=DEST/relative.with_suffix(".json")
        if args.dry_run:
            print(src.relative_to(ROOT),"->",dest.relative_to(ROOT))
            continue
        with tempfile.TemporaryDirectory(prefix="pixeltown-") as directory:
            tmp=Path(directory)
            sheet=tmp/"sprite.png";data=tmp/"frames.json"
            command=[exe,"--batch",str(src),"--sheet-type","horizontal","--sheet",str(sheet),"--data",str(data),"--format","json-array"]
            run=subprocess.run(command,capture_output=True,text=True)
            if run.returncode or not sheet.is_file() or not data.is_file():
                print("Aseprite export failed:",src,run.stdout,run.stderr,file=sys.stderr)
                return 3
            frames=json.loads(data.read_text(encoding="utf-8")).get("frames",[])
            if not frames:
                print("No sprite frames:",src,file=sys.stderr)
                return 4
            dest.parent.mkdir(parents=True,exist_ok=True)
            shutil.copyfile(sheet,dest)
            if len(frames)>1:
                shutil.copyfile(data,data_dest)
            elif data_dest.exists():
                data_dest.unlink()
            print("Exported:",dest.relative_to(ROOT),"frames:",len(frames))
    return 0
if __name__ == "__main__":
    sys.exit(main())
