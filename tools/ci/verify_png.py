#!/usr/bin/env python3
"""Validate actual Godot screenshots, not visual quality or an approved baseline."""
import argparse
import struct
from pathlib import Path
import zlib

PNG_SIG = b"\x89PNG\r\n\x1a\n"

def verify(file: Path, width: int, height: int) -> None:
    data = file.read_bytes()
    if len(data) < 1024 or not data.startswith(PNG_SIG):
        raise ValueError(f"{file}: missing/too-small PNG")

    offset = len(PNG_SIG)
    seen_header = False
    seen_end = False
    compressed = bytearray()
    depth = kind = 0
    while offset + 12 <= len(data):
        length = struct.unpack_from(">I", data, offset)[0]
        end = offset + 12 + length
        if end > len(data):
            raise ValueError(f"{file}: truncated chunk")
        chunk = data[offset + 4 : offset + 8]
        payload = data[offset + 8 : offset + 8 + length]
        stored_crc = struct.unpack_from(">I", data, offset + 8 + length)[0]
        if zlib.crc32(chunk + payload) != stored_crc:
            raise ValueError(f"{file}: invalid CRC in {chunk!r}")
        if chunk == b"IHDR":
            if seen_header or length != 13:
                raise ValueError(f"{file}: invalid header")
            actual_w, actual_h, depth, kind = struct.unpack_from(">IIBB", payload)
            if (actual_w, actual_h) != (width, height):
                raise ValueError(f"{file}: expected {width}x{height}, got {actual_w}x{actual_h}")
            if depth != 8 or kind not in (2, 6):
                raise ValueError(f"{file}: unsupported PNG color format ({depth}, {kind})")
            seen_header = True
        elif chunk == b"IDAT":
            compressed.extend(payload)
        elif chunk == b"IEND":
            seen_end = True
            break
        offset = end
    if not seen_header or not seen_end or not compressed:
        raise ValueError(f"{file}: incomplete PNG")
    channels = 3 if kind == 2 else 4
    stride = width * channels + 1
    uncompressed = zlib.decompress(compressed)
    if len(uncompressed) != stride * height:
        raise ValueError(f"{file}: incomplete pixel data")
    if len(set(uncompressed[i * stride : (i + 1) * stride] for i in
               (0, height // 8, height // 2, 7 * height // 8, height - 1))) < 2:
        raise ValueError(f"{file}: no observable difference between sampled image rows")
    print(f"PASS render capture {width}x{height}: {file} ({len(data)} bytes)")

def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("file", type=Path)
    parser.add_argument("width", type=int)
    parser.add_argument("height", type=int)
    args = parser.parse_args()
    verify(args.file, args.width, args.height)

if __name__ == "__main__":
    main()
