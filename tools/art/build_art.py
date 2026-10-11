#!/usr/bin/env python3
"""Original, source-editable PixelTown pixel atlas builder. Python stdlib only.

Re-run this script to regenerate all four PNG sheets and their JSON atlas map.
The hand-authored motifs are original and may be edited without any paid tools.
"""
from pathlib import Path
import json
import math
import random
import struct
import zlib

ROOT = Path(__file__).resolve().parents[2]
ASSETS = ROOT / "assets"
ASSETS.mkdir(parents=True, exist_ok=True)
P = dict(ink="#263440", grass="#789e5e", wood="#855c3f", wall="#e7cda0",
         roof="#b7684b", rooflight="#df9a6e", stone="#647581",
         highlight="#eddca7", skin="#dfb38b", armor="#9db8c0",
         cave="#394957", foliage="#578858")

class Canvas:
    def __init__(self, w, h):
        self.w, self.h = w, h
        self.b = bytearray(w*h*4)
    def pixel(self, x, y, color):
        x, y = int(x), int(y)
        if x < 0 or y < 0 or x >= self.w or y >= self.h:
            return
        color = color.lstrip("#")
        rgba = bytes.fromhex(color) + b"\xff"
        self.b[(y*self.w+x)*4:(y*self.w+x)*4+4] = rgba
    def rect(self, x, y, w, h, col):
        for yy in range(int(y), int(y+h)):
            for xx in range(int(x), int(x+w)):
                self.pixel(xx, yy, col)
    def ell(self, x, y, rx, ry, col):
        for yy in range(-int(ry), int(ry)+1):
            for xx in range(-int(rx), int(rx)+1):
                if xx*xx*ry*ry+yy*yy*rx*rx <= rx*rx*ry*ry:
                    self.pixel(x+xx, y+yy, col)
    def line(self,x0,y0,x1,y1,col):
        x0,y0,x1,y1=map(int,(x0,y0,x1,y1))
        dx,dy=abs(x1-x0),-abs(y1-y0)
        sx,sy=(1 if x0<x1 else -1),(1 if y0<y1 else -1)
        e=dx+dy
        while True:
            self.pixel(x0,y0,col)
            if x0==x1 and y0==y1:break
            q=2*e
            if q>=dy:e+=dy;x0+=sx
            if q<=dx:e+=dx;y0+=sy
    def save(self, path):
        rows=b"".join(b"\0"+self.b[y*self.w*4:(y+1)*self.w*4] for y in range(self.h))
        def chunk(name,data):
            payload=name+data
            return struct.pack(">I",len(data))+payload+struct.pack(">I",zlib.crc32(payload))
        blob=(b"\x89PNG\r\n\x1a\n"+chunk(b"IHDR",struct.pack(">IIBBBBB",self.w,self.h,8,6,0,0,0))
              +chunk(b"IDAT",zlib.compress(rows,9))+chunk(b"IEND",b""))
        path.write_bytes(blob)

def roof(c,x,y,w,col,hi):
    for step in range(18):
        inset=max(0,12-step*2)
        c.rect(x+inset,y+step,w-2*inset,2,col)
        if step%4==0:c.rect(x+inset+3,y+step,w-2*inset-7,1,hi)
    for r in range(3):
        for k in range(6):
            c.rect(x+8+k*(w-15)//6+(r%2)*4,y+20+r*4,7,1,hi)

def walls(c,x,y,w,h,wall=P["wall"]):
    c.rect(x+4,y+19,w-8,h-19,P["wood"])
    c.rect(x+8,y+23,w-16,h-27,wall)
    for xx in (x+8,x+w-11):c.rect(xx,y+24,3,h-27,"#a87a58")
    for yy in range(y+31,y+h-5,10):c.rect(x+12,yy,w-24,1,"#c4a580")
    c.rect(x+4,y+h-6,w-8,5,"#717875")

def window(c,x,y):
    c.rect(x-2,y-2,19,17,P["wood"])
    c.rect(x,y,15,12,"#7fb7b1")
    c.rect(x+7,y,2,12,P["wall"])
    c.rect(x,y+5,15,2,P["wall"])
    c.rect(x-3,y+12,21,3,"#b98e65")

def door(c,x,y,w=17,h=26):
    c.rect(x-2,y-2,w+4,h+2,P["ink"])
    c.rect(x,y,w,h,"#8e6447")
    for yy in range(5,h-2,7):c.rect(x+2,y+yy,w-4,1,"#b98a60")
    c.rect(x+w-5,y+h//2,2,2,P["highlight"])

def leaves(c,cx,cy,rx,ry,salt):
    c.ell(cx,cy+2,rx+2,ry+2,"#2c594b")
    c.ell(cx,cy,rx,ry,P["foliage"])
    c.ell(cx-4,cy-4,max(2,rx-6),max(2,ry-6),"#80ae69")
    r=random.Random(salt)
    for _ in range(24):
        x=cx+r.randrange(-rx+3,rx-2)
        y=cy+r.randrange(-ry+3,ry-2)
        if (x-cx)**2/max(1,rx**2)+(y-cy)**2/max(1,ry**2)<.85:
            c.rect(x,y,2,2,r.choice(["#457653","#91b877","#aad087"]))

def ground():
    """Sixteen original quiet-grass variants; retain water/cave support tiles.

    Sparse clusters prevent the 16px tuft wallpaper revealed in real screenshots.
    """
    c=Canvas(256,64)
    grass=["#74965b","#729458","#719355","#75965b",
           "#729457","#719456","#73945a","#729358"]
    for row in range(4):
        for tile in range(16):
            x,y=tile*16,row*16
            r=random.Random(tile*73+row*3301)
            if row==0:
                c.rect(x,y,16,16,grass[(tile*5+tile//3)%len(grass)])
                for _ in range(1+int(tile%3==0)):
                    xx=x+3+r.randrange(10)
                    yy=y+3+r.randrange(10)
                    c.rect(xx,yy,1,3,"#537f50")
                    c.rect(xx+2,yy+1,1,2,"#5d8754")
                    c.rect(xx+1,yy+1,1,1,"#a7bd78")
                if tile in (3,11):
                    c.rect(x+6,y+11,2,2,"#d6c38e")
                    c.rect(x+7,y+10,1,1,"#efdfa7")
            elif row==1:
                c.rect(x,y,16,16,"#a98257" if tile<8 else "#54899b")
                for _ in range(6):
                    xx=x+r.randrange(16);yy=y+r.randrange(16)
                    c.rect(xx,yy,3 if tile>=8 else 2,1,
                           "#91b8b3" if tile>=8 else "#c7a16a")
            elif row==2:
                c.rect(x,y,16,16,["#354452","#415161","#4b5e6b"][tile%3])
                for _ in range(5):
                    c.rect(x+r.randrange(16),y+r.randrange(16),3,1,"#536979")
            else:
                c.rect(x,y,16,16,"#65717d" if tile<8 else "#3c4a57")
                for _ in range(4):
                    c.rect(x+r.randrange(16),y+r.randrange(16),2,2,"#718392")
    c.save(ASSETS/"terrain.png")

def objects():
    c=Canvas(512,256)
    # House (0,0), 88x80.
    walls(c,2,10,84,65);roof(c,0,10,88,P["roof"],P["rooflight"])
    c.rect(60,1,13,16,"#72605a");window(c,15,46);door(c,51,49)
    c.rect(12,70,19,4,"#648c55")
    # Storage (96,0), 80x80.
    walls(c,97,12,79,63,"#cbb698");roof(c,96,10,80,"#647a78","#a8b6aa")
    door(c,107,51,24,23);window(c,145,45)
    for i in range(3):
        c.rect(137+i*8,64-i*2,16,11,"#89603b")
        c.rect(139+i*8,63-i*2,11,3,"#d0ac79")
    # Smithy (192,0), 112x80.
    walls(c,193,11,109,64,"#cfc0a7")
    c.rect(274,3,15,30,P["ink"]);c.rect(278,2,8,30,"#927f7a")
    roof(c,192,12,112,"#526e79","#9fb5b9")
    c.rect(209,44,38,31,P["wood"])
    c.rect(214,48,28,25,P["ink"])
    c.rect(220,51,18,21,"#df8746")
    c.rect(226,54,9,16,"#ffe5a4")
    door(c,265,49)
    c.rect(195,67,29,6,"#4a6065");c.rect(192,64,33,3,P["armor"])
    # Cave mouth (320,0), 96x80.
    for r in range(7):
        inset=abs(3-r)*4
        c.rect(320+inset,5+r*10,96-2*inset,15,"#344754")
        c.rect(325+inset,4+r*10,86-2*inset,5,["#657989","#758993"][r%2])
    c.ell(368,64,26,28,"#14232d");c.ell(368,71,18,24,"#0c1a27")
    c.rect(354,75,28,4,"#b59a6a")
    # Tree (432,0), 64x80.
    c.rect(460,33,10,40,"#6a513e");c.rect(464,34,3,37,"#b78959")
    leaves(c,462,31,26,21,23)
    leaves(c,445,37,11,13,24);leaves(c,482,34,11,14,25)
    leaves(c,462,13,18,12,26)
    # Blueprint and finished hut.
    c.rect(4,152,88,5,"#a88052")
    for xx in (6,86):
        for yy in (112,153):c.rect(xx,yy-12,5,18,P["wood"])
    for a,b,aa,bb in [(8,112,90,153),(90,112,8,153),(8,112,90,112),(8,153,90,153)]:
        c.line(a,b,aa,bb,"#ead09a")
    walls(c,113,108,94,48,"#d4c2a0");roof(c,112,108,96,"#567773","#a4b8a7");door(c,154,131,16,24)
    # Well and foliage (224+,96).
    c.ell(248,138,21,5,"#45614f")
    c.rect(230,119,37,22,P["stone"]);c.rect(235,122,26,14,"#4c9da8")
    for xx in (231,262):c.rect(xx,101,4,21,P["wood"])
    roof(c,226,99,44,P["roof"],P["rooflight"])
    leaves(c,295,115,13,10,34)
    # Crate, torch, mushrooms and cave crystal.
    c.rect(325,103,23,22,"#8d623e");c.rect(327,105,19,18,"#b88b5c")
    c.line(328,106,345,122,"#765039");c.line(345,106,328,122,"#765039")
    c.rect(371,112,4,22,P["wood"]);c.ell(372,108,5,10,"#ffa45c");c.rect(371,100,4,12,"#ffe3a1")
    for k in range(3):
        xx=398+k*9;yy=110+(k%2)*3
        c.rect(xx,yy+3,3,11,"#bbcaba")
        c.ell(xx+2,yy+3,7,4,"#659fa3")
        c.rect(xx,yy,6,2,"#a6dfca")
    for xx,yy,h,col in ((437,116,22,"#5386a5"),(448,106,33,"#77bbc0"),(463,113,26,"#6d9fb5")):
        c.rect(xx,yy+7,10,h,col)
        c.line(xx,yy+7,xx+5,yy,P["armor"])
        c.line(xx+5,yy,xx+9,yy+7,P["armor"])
        c.rect(xx+2,yy+9,2,h-6,"#c5dcd5")
    # Slime enemy.
    c.ell(21,195,17,12,P["ink"]);c.ell(21,192,16,11,"#589d89")
    c.ell(15,186,8,5,"#89cfb5")
    c.rect(12,192,4,4,P["ink"]);c.rect(26,192,4,4,P["ink"])
    c.rect(17,198,10,2,"#e5ecc8")
    # Reusable extra atlas objects, all editable in the pixel master:
    # crop rows 80,176 96x64
    c.rect(81,183,95,51,"#5d7b4f")
    c.rect(84,185,89,46,"#866649")
    for row in range(4):
        c.rect(86,190+row*10,84,4,"#b38c5b")
        for col in range(9):
            x=88+col*9+(row%2)*2;y=185+row*10
            c.rect(x,y+5,2,8,"#47794d")
            c.rect(x-2,y+4,4,4,"#6ba362")
            c.rect(x+2,y+2,5,4,"#9ec275")
    c.rect(82,234,91,2,"#d2ac77")
    # stocked timber wagon 184,176 64x48
    c.rect(187,198,52,19,"#654935")
    c.rect(190,194,46,20,"#b38354")
    for xx in range(193,232,8):c.rect(xx,197,2,16,"#e1b477")
    for xx in (191,225):
        c.ell(xx+5,216,7,7,"#2e3940")
        c.ell(xx+5,216,3,3,"#d4b27b")
    c.rect(198,188,16,8,"#c7af7c")
    c.rect(213,187,14,8,"#748d58")
    c.rect(237,205,12,3,P["wood"])
    # modular fence 256,176 64x32
    c.rect(257,189,62,3,"#ab8251");c.rect(257,199,62,3,"#d2a26e")
    for xx in range(258,320,15):
        c.rect(xx,180,5,30,"#674d38")
        c.rect(xx+1,179,3,29,"#c18f5d")
        c.rect(xx+1,177,3,3,"#e6c184")
    # river timber bridge 328,176 80x64
    c.rect(335,181,67,54,"#67513f")
    for xx in range(339,400,9):
        c.rect(xx,182,7,51,"#c49d6e")
        c.rect(xx+5,182,1,50,"#896748")
    c.rect(330,185,5,53,"#684b35")
    c.rect(403,185,5,53,"#684b35")
    for yy in (189,217):c.rect(329,yy,80,4,"#dfb67e")
    # natural rock cluster 416,176 48x40
    for dx,dy,w,h in [(1,13,22,18),(17,5,23,26),(32,16,16,18)]:
        c.ell(416+dx+w//2,176+dy+h//2,w//2,h//2,P["ink"])
        c.ell(416+dx+w//2,176+dy+h//2-2,max(3,w//2-3),max(3,h//2-4),"#72868b")
        c.rect(416+dx+5,176+dy+4,7,2,"#acb9b1")
    # flowerbed 472,176 32x32
    for i,(dx,dy) in enumerate([(5,14),(15,9),(24,18),(9,24),(21,26)]):
        c.rect(472+dx,176+dy,2,9,"#457d55")
        c.ell(472+dx,176+dy,3,3,["#f4d594","#e6adb3","#d7bfdf"][i%3])
        c.rect(472+dx,176+dy,1,1,"#fff2cf")
    c.save(ASSETS/"objects.png")

def character_sheets():
    b=Canvas(384,256);g=Canvas(384,128)
    for role in range(2):
        for direction in range(4):
            for size in range(2):
                for frame in range(8):
                    x=(size*8+frame)*24;yy=(role*4+direction)*32
                    cx=x+12;foot=yy+31;sh=0 if size else 2
                    def body(dx,dy,w,h,col):b.rect(cx+dx,foot+dy+sh,w,h,col)
                    stride=1 if frame in (1,6) else -1 if frame in (3,7) else 0
                    body(-6+stride,-6,5,6,P["ink"]);body(2-stride,-6,5,6,P["ink"])
                    body(-7,-21,14,15,P["ink"])
                    body(-6,-20,12,13,"#506f80" if role else "#b57456")
                    body(-9,-20,4,8,P["armor"] if role else P["skin"])
                    body(6,-20,4,8,P["armor"] if role else P["skin"])
                    if frame in (4,5):body(6,-24 if frame==5 else -21,4,9,P["skin"])
                    body(-6,-30,13,12,P["ink"]);body(-5,-29,11,10,P["skin"])
                    body(-6,-32,13,6,"#736858" if role else "#774b38")
                    if direction==0:
                        body(-3,-24,2,2,P["ink"]);body(3,-24,2,2,P["ink"])
                    elif direction==1:body(-5,-29,11,6,"#774b38")
                    elif direction==2:body(-6,-29,3,10,"#774b38")
                    else:body(4,-29,3,10,"#774b38")
                    body(-4,-17,8,3,P["armor"] if role else "#e7bd8d")
                    if role:
                        def item(dx,dy,w,h,col):g.rect(cx+dx,direction*32+31+dy+sh,w,h,col)
                        alt=frame>=4
                        item(-8,-31,16,7,"#577e78" if alt else "#788f9e")
                        item(-7,-33,14,4,"#b2a684" if alt else "#b9ced1")
                        item(-3,-35,6,3,P["highlight"])
                        item(-7,-21,14,4,"#638b82" if alt else "#86a6af")
                        side=-12 if direction==2 else 10
                        shield=8 if direction==2 else -12
                        item(shield,-20,7,15,P["ink"])
                        item(shield+1,-19,5,13,"#618479" if alt else "#ac8154")
                        item(shield+2,-16,3,7,P["highlight"])
                        item(side,-29 if frame>=6 else -23,3,18,"#d1dfe0")
                        item(side-2,-9,7,3,"#f0d49c")
                        item(side,-5,3,4,P["wood"])
    b.save(ASSETS/"characters.png")
    g.save(ASSETS/"equipment.png")

ground();objects();character_sheets()
atlas = {"version":1,"tile":[16,16],
 "frames":{"cottage":[0,0,88,80],"storage":[96,0,80,80],
 "forge":[192,0,112,80],"cave_mouth":[320,0,96,80],
 "tree":[432,0,64,80],"blueprint":[0,96,96,64],
 "built_hut":[112,96,96,64],"well":[224,96,48,48],
 "bush":[280,96,32,32],"crate":[320,96,32,32],
 "torch":[360,96,24,40],"mushrooms":[392,96,32,32],
 "crystal":[432,96,48,48],"slime":[0,176,40,32],
 "farm":[80,176,96,64],"wagon":[184,176,64,48],
 "fence":[256,176,64,32],"bridge":[328,176,80,64],
 "rocks":[416,176,48,40],"flowers":[472,176,32,32]},
 "characters":{"cell":[24,32],"size_candidates":["20x30","24x32"],
 "directions":["south","north","west","east"],"frames":["idle","walk1","idle2","walk2","work1","work2","attack1","attack2"],
 "rows":["villager south","villager north","villager west","villager east","guard south","guard north","guard west","guard east"],
 "equipment":"aligned 1:1 to guard frames, independent atlas"}}
(ASSETS/"atlas.json").write_text(json.dumps(atlas,indent=2)+"\n",encoding="utf-8")
print("GENERATED 4 original pixel PNG sheets + atlas.json")
