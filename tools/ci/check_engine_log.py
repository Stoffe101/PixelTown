#!/usr/bin/env python3
"""Godot sometimes prints errors while returning success; treat those as CI failures."""
import re
import sys
from pathlib import Path

ERROR = re.compile(r"^\\s*(?:ERROR:|SCRIPT ERROR:|Parse Error:)", re.IGNORECASE)
# Treat recurring Godot script warnings as actionable CI failures. Ordinary
# informational output is not an error.
NOISY_GDSCRIPT = re.compile(
    r"GDScript::reload: (?:Integer division\\.|The parameter .+ is never used)",
    re.IGNORECASE,
)

def main() -> int:
    found = []
    for name in sys.argv[1:]:
        p = Path(name)
        if not p.exists():
            print(f"Missing engine log: {name}", file=sys.stderr)
            return 1
        for number, line in enumerate(p.read_text(encoding="utf-8", errors="replace").splitlines(), 1):
            if ERROR.search(line) or NOISY_GDSCRIPT.search(line):
                found.append(f"{name}:{number}: {line}")
    if found:
        print("Godot error(s) found:\n" + "\n".join(found), file=sys.stderr)
        return 1
    print("PASS Godot logs have no reported engine/script errors")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
