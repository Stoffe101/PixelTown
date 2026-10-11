#!/usr/bin/env python3
"""Temporary repair of a damaged palette CRC in a CC0 review sprite seed.

IMPORTANT: The seed is not approved production artwork. Its Git blob ID is
pinned. Only the PLTE CRC is allowed to change. Any other corruption fails.
Replace this bridge with a clean Aseprite export before art approval.
"""
import hashlib
from pathlib import Path
import struct
import zlib

path = Path(__file__).resolve().parents[2] / "assets/third_party/ninja_adventure/curated_houses.png"
EXPECTED_BLOB = "3d47a6adb7dcec8f794f0ed79ec16777db6b5ed8"
raw = path.read_bytes()
git_blob_sha = hashlib.sha1(b"blob " + str(len(raw)).encode() + b"\x00" + raw).hexdigest()
# Repeated setup calls also accept the repaired PNG with valid CRC.
if raw[:8] != b"\x89PNG\r\n\x1a\n":
    raise SystemExit("Invalid curated seed signature")
pos = 8
buf = bytearray(raw)
repaired = 0
while pos + 12 <= len(raw):
    size = struct.unpack_from(">I",raw,pos)[0]
    typ = raw[pos+4:pos+8]
    stop = pos+12+size
    if stop > len(raw):
        raise SystemExit("PNG chunk overrun")
    crc_pos = pos+8+size
    before = struct.unpack_from(">I",raw,crc_pos)[0]
    computed = zlib.crc32(raw[pos+4:crc_pos]) & 0xFFFFFFFF
    if before != computed:
        if typ != b"PLTE" or git_blob_sha != EXPECTED_BLOB:
            raise SystemExit(f"Unexpected corrupt PNG chunk {typ!r}; abort")
        struct.pack_into(">I",buf,crc_pos,computed)
        repaired += 1
    pos = stop
    if typ == b"IEND":
        break
if repaired > 1:
    raise SystemExit("Multiple unexpected palette errors")
if repaired:
    path.write_bytes(buf)
print("CURATED PNG VERIFY PASS: repaired PLTE CRC" if repaired else "CURATED PNG VERIFY PASS: no CRC errors")
