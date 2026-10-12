#!/usr/bin/env python3
"""Export genuine Aseprite masters to existing, shared prefab PNGs, atomically."""
import argparse,json,os,shutil,subprocess,struct,sys,tempfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
ASSETS=json.loads((ROOT/"art/production_assets.json").read_text())["objects"]
def main():
    p=argparse.ArgumentParser()
    p.add_argument("--id",help="one mapped object; default all masters that exist")
    p.add_argument("--exe",help="path to Aseprite binary")
    p.add_argument("--dry-run",action="store_true")
    a=p.parse_args()
    items=[i for i in ASSETS if a.id is None or i["id"]==a.id]
    if not items:print("Unknown asset id",a.id,file=sys.stderr);return 2
    candidates=[a.exe,os.environ.get("ASEPRITE_EXE"),shutil.which("aseprite")]
    if os.name=="nt":candidates.append(str(Path(os.environ.get("ProgramFiles","C:/Program Files"))/"Aseprite"/"Aseprite.exe"))
    exe=next((s for s in candidates if s and (Path(s).is_file() or shutil.which(s))),None)
    for item in items:
        src=ROOT/item["source"];out=ROOT/item["png"]
        if not src.is_file():
            if a.id:print("Missing genuine Aseprite master:",src,file=sys.stderr);return 3
            print("SKIP awaiting artist:",item["id"]);continue
        if a.dry_run:print("WOULD EXPORT",src.relative_to(ROOT),"to",out.relative_to(ROOT));continue
        if not exe:print("Aseprite not found: set ASEPRITE_EXE or --exe",file=sys.stderr);return 4
        with tempfile.TemporaryDirectory(prefix="pixel-art-") as d:
            tmp=Path(d);png=tmp/"render.png";meta=tmp/"frames.json"
            cmd=[str(exe),"--batch",str(src),"--sheet-type","horizontal","--sheet",str(png),"--data",str(meta),"--format","json-array"]
            proc=subprocess.run(cmd,capture_output=True,text=True)
            if proc.returncode or not png.is_file() or not meta.is_file():
                print("Export failed",item["id"],proc.stdout,proc.stderr,file=sys.stderr);return 5
            frames=json.loads(meta.read_text()).get("frames",[])
            with png.open("rb") as f:header=f.read(24)
            if header[:8]!=bytes([137,80,78,71,13,10,26,10]):print("Not PNG",item["id"],file=sys.stderr);return 6
            width,height=struct.unpack(">II",header[16:24])
            if [width,height]!=item["size"] or not frames:
                print("Size/frame mismatch",item["id"],[width,height],"expected",item["size"],file=sys.stderr);return 7
            pending=out.with_name(out.name+".pending")
            shutil.copyfile(png,pending);os.replace(pending,out)
            print("UPDATED SHARED SPRITE",item["id"],out.relative_to(ROOT))
    return 0
if __name__=="__main__":sys.exit(main())
