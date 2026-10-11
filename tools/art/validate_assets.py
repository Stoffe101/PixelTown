#!/usr/bin/env python3
"""Reject missing/corrupt sprites, nonuniform layout or undrawn animation cells."""
import json
import struct
import sys
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DIR = ROOT / "assets"
SIZES = {"terrain.png": (256, 64), "objects.png": (512, 256),
         "characters.png": (384, 256), "equipment.png": (384, 128)}
SIG = b"\x89PNG\r\n\x1a\n"

def png_pixels(path, expected):
    raw = path.read_bytes()
    if not raw.startswith(SIG):
        raise ValueError(f"{path}: invalid PNG signature")
    off = 8
    compressed = bytearray()
    wh = None
    while off + 12 <= len(raw):
        n = struct.unpack_from(">I", raw, off)[0]
        t = raw[off+4:off+8]
        data = raw[off+8:off+8+n]
        checksum = struct.unpack_from(">I", raw, off+8+n)[0]
        if zlib.crc32(t + data) != checksum:
            raise ValueError(f"{path}: invalid chunk CRC")
        if t == b"IHDR":
            w,h,depth,kind,comp,filt,inter = struct.unpack(">IIBBBBB", data)
            if (w,h) != expected or (depth,kind,comp,filt,inter) != (8,6,0,0,0):
                raise ValueError(f"{path}: wrong dimensions or format")
            wh = (w,h)
        elif t == b"IDAT":
            compressed.extend(data)
        elif t == b"IEND":
            break
        off += 12+n
    if not wh or not compressed:
        raise ValueError(f"{path}: missing image data")
    w,h = wh
    buf = zlib.decompress(compressed)
    if len(buf) != h*(w*4+1):
        raise ValueError(f"{path}: invalid pixel payload size")
    if any(buf[y*(w*4+1)] != 0 for y in range(h)):
        raise ValueError(f"{path}: unexpected PNG scanline filter")
    rows = [buf[y*(w*4+1)+1:(y+1)*(w*4+1)] for y in range(h)]
    return w,h,rows

def is_drawn(rows, x, y, w, h):
    return any(rows[yy][xx*4+3] != 0 for yy in range(y,y+h)
               for xx in range(x,x+w))

def main():
    imgs = {name:png_pixels(DIR/name,dimensions)
            for name,dimensions in SIZES.items()}
    data = json.loads((DIR/"atlas.json").read_text(encoding="utf-8"))
    if data.get("tile") != [16,16] or data["characters"]["cell"] != [24,32]:
        raise ValueError("Invalid art grid contract")
    w,h,rows = imgs["objects.png"]
    for name,(x,y,cw,ch) in data["frames"].items():
        if min(x,y,cw,ch)<0 or x+cw>w or y+ch>h or not is_drawn(rows,x,y,cw,ch):
            raise ValueError(f"Object atlas region missing/outside sheet: {name}")
    w,h,rows = imgs["characters.png"]
    for role in range(2):
        for direction in range(4):
            for scale in range(2):
                for frame in range(8):
                    x=(scale*8+frame)*24;y=(role*4+direction)*32
                    if not is_drawn(rows,x,y,24,32):
                        raise ValueError(f"Missing character sprite role={role} direction={direction} scale={scale} frame={frame}")
    w,h,rows = imgs["equipment.png"]
    for direction in range(4):
        for scale in range(2):
            for frame in range(8):
                if not is_drawn(rows,(scale*8+frame)*24,direction*32,24,32):
                    raise ValueError("Equipment atlas overlay missing or unaligned")
    for name in SIZES:
        print(f"PASS {name} {SIZES[name][0]}x{SIZES[name][1]}")
    print("PASS art source contract, character scale frames and equipment overlays")
    return 0

if __name__ == "__main__":
    try:
        sys.exit(main())
    except (ValueError, OSError, KeyError, IndexError) as e:
        print("FAIL art validation:",e,file=sys.stderr)
        sys.exit(1)
