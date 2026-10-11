# Curated building sprite sheet (CC0 third-party art)

`curated_houses.png`, 240×96 indexed PNG, was prepared from the **user-supplied Ninja Adventure Asset Pack**, by Pixel-boy and AAA. The source is `Backgrounds/Tilesets/TilesetHouse.png` (528×368 pixels). It is **not original PixelTown artwork**.

Creator: https://pixel-boy.itch.io/ninja-adventure-asset-pack

License: **CC0 1.0**. Commercial use, adaptation and raw public redistribution are permitted. This file remains identified as CC0 third-party material in the publicly readable repository and is not governed by our original-code/art All Rights Reserved terms.

Source regions (pixel coordinates in the creator's TilesetHouse.png) and export positions in the curated 240×96 PNG:

- Timber cottage: source (399,229)–(467,307); output (0,0), 68×78 candidate with transparent masked edges.
- Storage hut: source (128,0)–(192,57); output (80,12), 64×57.
- Workshop/shop shell: source (254,0)–(318,57); output (160,12), 64×57.

The source regions were isolated by a polygon cutout and removal of tiny disconnected neighbor artifacts, with a color-limited lossless pixel placement export. This is a **visual placeholder from a coherent CC0 family**, not the final PixelTown-owned Aseprite building set. In particular, the shop shell needs distinctive smithy props, furnace and occupation animation before artistic approval.

PNG SHA-256: `eb259222f17ba77f81759b2b29d7684e9b13a759ccdd86538d099b53119fafd3`

Avoid editing upstream artwork in-place. Future original buildings should be authored as layered masters in `art/source/architecture` and exported independently.
