#!/usr/bin/env python3
"""PixelTown Art Pass 01: ORIGINAL layered, pixel-perfect hero structures.

Artist-editable masters are written as OpenRaster .ora (separate PNG layers).
PNG exports are deterministic; no generative AI or traced external game art.
Layer order: shadow/foundation, masonry, timber, roof, function, finishing.
"""
from pathlib import Path
from PIL import Image, ImageDraw
import random, io, zipfile, xml.etree.ElementTree as ET

ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/"assets"/"original"/"hero"
OUT.mkdir(parents=True,exist_ok=True)
SOURCES=ROOT/"art"/"source"/"architecture"
SOURCES.mkdir(parents=True,exist_ok=True)
P={
 "outline":"#293d43","shadow":"#3b5350","deep":"#344c4d",
 "stone":"#87918a","stone_dark":"#566b71","stone_light":"#adb3a2",
 "wood":"#84543a","wood_dark":"#5b3f36","wood_lit":"#b98253","wood_hl":"#d5a46d",
 "wall":"#dbc39a","wall_hl":"#f2d9a8","wall_sh":"#b49577",
 "roof":"#b06449","roof_dark":"#76484b","roof_lit":"#da8d5b","roof_edge":"#edb273",
 "slate":"#57747c","slate_dark":"#405c66","slate_lit":"#849ba0",
 "moss":"#6d9258","grass":"#86a76b","leaf":"#4c7959",
 "glass":"#649fa2","glow":"#f4be6d","flame":"#ffe09c",
 "metal":"#98b0b3","metal_hl":"#d2d6c7","iron":"#3b5359"}

def layer(w,h):return Image.new("RGBA",(w,h))
def rect(im,xy,c):
    # Normalize painter-authored corners (top/left and bottom/right).
    x0,y0,x1,y1=xy
    ImageDraw.Draw(im).rectangle((min(x0,x1),min(y0,y1),max(x0,x1),max(y0,y1)),fill=c)
def line(im,points,c,width=1):ImageDraw.Draw(im).line(points,fill=c,width=width,joint="curve")
def poly(im,pts,c):ImageDraw.Draw(im).polygon(pts,fill=c)
def specks(im,box,seed,colors,n,inside=None):
    rng=random.Random(seed)
    x0,y0,x1,y1=box
    if x1<x0 or y1<y0:
        return
    for j in range(n):
        x=rng.randint(x0,x1);y=rng.randint(y0,y1)
        if inside and im.getpixel((x,y))[3]==0:continue
        col=colors[j%len(colors)]
        rect(im,(x,y,x+rng.choice([1,2,3]),y+rng.choice([0,1])),col)
def export(name,layers,size):
    final=layer(*size)
    for title,img in layers:final.alpha_composite(img)
    final.save(OUT/(name+".png"),optimize=True)
    # Source remains genuinely layered and editable by Aseprite/Krita/GIMP
    root=ET.Element("image",{"w":str(size[0]),"h":str(size[1]),"name":name,"version":"0.0.1"})
    stack=ET.SubElement(root,"stack")
    with zipfile.ZipFile(SOURCES/(name+".ora"),"w") as z:
        z.writestr("mimetype","image/openraster",compress_type=zipfile.ZIP_STORED)
        for k,(title,img) in enumerate(reversed(layers)):
            fn="data/layer%02d.png"%k
            mem=io.BytesIO();img.save(mem,format="PNG")
            z.writestr(fn,mem.getvalue())
            ET.SubElement(stack,"layer",{"name":title,"src":fn,"x":"0","y":"0","opacity":"1.0","visibility":"visible","composite-op":"svg:src-over"})
        mem=io.BytesIO();final.save(mem,format="PNG")
        z.writestr("mergedimage.png",mem.getvalue())
        z.writestr("stack.xml",ET.tostring(root,encoding="utf-8"))
    print("ORIGINAL MASTER",name,size,"layers",len(layers))

def framed_window(im,x,y,lit=True):
    rect(im,(x-2,y-2,x+20,y+20),P["wood_dark"])
    rect(im,(x,y,x+17,y+16),P["wood_lit"])
    rect(im,(x+2,y+2,x+15,y+14),P["glow"] if lit else P["glass"])
    rect(im,(x+3,y+3,x+8,y+6),P["flame"] if lit else "#9dc7b8")
    rect(im,(x+9,y+2,x+11,y+14),P["wood_dark"])
    rect(im,(x+2,y+8,x+15,y+10),P["wood_dark"])
    rect(im,(x-4,y+17,x+21,y+20),P["wood_hl"])

def door(im,x,y,w=22,h=35):
    rect(im,(x-3,y-2,x+w+2,y+h),P["outline"])
    rect(im,(x,y,x+w-1,y+h),P["wood_dark"])
    rect(im,(x+3,y+3,x+w-4,y+h),P["wood"])
    for yy in range(y+7,y+h-2,10):line(im,[(x+4,yy),(x+w-5,yy)],"#9e6c48")
    line(im,[(x+w//2,y+4),(x+w//2,y+h-1)],P["wood_dark"])
    rect(im,(x+w-8,y+h//2,x+w-6,y+h//2+2),P["glow"])

def roof(im,x0,y0,x1,y1,kind="copper"):
    dark=P["roof_dark"] if kind=="copper" else P["slate_dark"]
    mid=P["roof"] if kind=="copper" else P["slate"]
    hi=P["roof_lit"] if kind=="copper" else P["slate_lit"]
    edge=P["roof_edge"] if kind=="copper" else P["metal_hl"]
    # A distinct pitched, asymmetric two-plane roof with stepped pixel edges.
    poly(im,[(x0,y0+24),(x0+25,y0+1),(x1-20,y0+1),(x1,y0+24),(x1-8,y1),(x0+2,y1)],dark)
    poly(im,[(x0+5,y0+24),(x0+28,y0+5),(x1-24,y0+5),(x1-8,y0+24),(x1-18,y1-5),(x0+5,y1-5)],mid)
    poly(im,[(x0+28,y0+5),(x1-24,y0+5),(x1-8,y0+24),(x0+9,y0+24)],hi)
    line(im,[(x0+28,y0+4),(x1-23,y0+4),(x1-5,y0+24)],edge,2)
    line(im,[(x0+6,y1-4),(x1-17,y1-4)],dark,3)
    # Deliberate staggered shingles only INSIDE each roof facet.
    for row in range(3):
        yy=y0+12+row*7
        left=x0+21-row*6
        right=x1-22+row*4
        for xx in range(left+5+(row%2)*6,right,14):
            line(im,[(xx,yy),(xx+6,yy)],edge if (xx//14)%3==0 else dark)
            rect(im,(xx+6,yy+2,xx+7,yy+3),dark)
    for xx in range(x0+15,x1-13,27):
        rect(im,(xx,y1-7,xx+11,y1-6),hi)

def timbers(im,x0,y0,x1,y1):
    for xx in (x0,x1-5):
        rect(im,(xx,y0,xx+5,y1),P["wood_dark"])
        rect(im,(xx+1,y0,xx+2,y1),P["wood_lit"])
    rect(im,(x0,y0+6,x1,y0+10),P["wood"])
    rect(im,(x0,y1-10,x1,y1-7),P["wood"])
    for xx in range(x0+25,x1-14,34):
        line(im,[(xx,y0+11),(xx+11,y1-12)],P["wood_hl"],2)

def masonry(im,x0,y0,x1,y1):
    rect(im,(x0,y0,x1,y1),P["stone_dark"])
    rect(im,(x0+3,y0+3,x1-3,y1-3),P["stone"])
    for yy in range(y0+9,y1-5,9):
        line(im,[(x0+3,yy),(x1-2,yy)],P["stone_dark"])
        for xx in range(x0+7+(5 if (yy//9)%2 else 0),x1-6,19):
            line(im,[(xx,yy-8),(xx,yy-1)],P["stone_dark"])
    specks(im,(x0+5,y0+5,x1-6,y1-7),101,[P["stone_light"],"#687a7a"],35)

def make_smithy():
    W,H=164,126
    layers=[(n,layer(W,H)) for n in ["contact shadow","stone foundation","stucco walls","timber framing","pitched slate roof","forge equipment","warm finishing"]]
    sh,stone,wall,timber,ro,fn,finish=[x[1] for x in layers]
    ImageDraw.Draw(sh).ellipse((8,109,161,123),fill="#243b3760")
    masonry(stone,13,85,157,114)
    rect(wall,(19,45,132,98),P["wood_dark"])
    rect(wall,(23,49,128,96),P["wall"])
    rect(wall,(23,68,128,88),P["wall_hl"])
    rect(wall,(26,89,128,96),P["wall_sh"])
    # Receding right wall and side projection read as actual 2D depth.
    poly(wall,[(129,48),(154,60),(154,106),(130,98)],"#9d856c")
    for xx in (28,49,88,127):
        rect(timber,(xx,54,xx+4,103),P["wood_dark"])
        rect(timber,(xx+1,54,xx+2,100),P["wood_hl"])
    timbers(timber,19,52,130,103)
    specks(wall,(28,58,126,91),32,["#e4cca0","#d1b286","#cfb38e"],54)
    # Massive chimney rises through roof, with cooled ash and brick seams.
    rect(ro,(124,7,148,62),P["outline"])
    rect(ro,(127,10,144,55),P["stone_dark"])
    for y in range(15,48,8):
        line(ro,[(128,y),(143,y)],P["stone_light"])
        rect(ro,(133+(y//8)%2*4,y-5,134+(y//8)%2*4,y-1),P["stone"])
    rect(ro,(123,5,149,11),P["stone_light"])
    rect(ro,(127,3,146,8),P["outline"])
    roof(ro,6,19,148,67,"slate")
    rect(ro,(9,66,144,70),P["slate_dark"])
    # Gable sign, copper emblem and smoke hood.
    poly(ro,[(19,47),(39,25),(60,47)],P["wood_dark"])
    poly(ro,[(23,44),(39,29),(55,44)],P["wall"])
    line(ro,[(30,42),(39,35),(48,42)],P["wood_hl"],2)
    door(fn,86,75,24,35)
    framed_window(fn,36,75,False)
    # Actually looks like a forge: coal furnace, orange interior, anvil, steel.
    rect(fn,(16,86,53,111),P["outline"])
    rect(fn,(19,88,50,108),P["stone_dark"])
    rect(fn,(22,91,48,106),P["iron"])
    rect(fn,(25,95,45,106),"#b35939")
    rect(fn,(28,96,43,105),"#ef8b45")
    rect(fn,(33,98,40,104),P["flame"])
    for xx in [24,32,40,48]:
        rect(fn,(xx,88,xx+2,93),P["metal_hl"])
    # Workbench, tool rack and striking anvil on an independent yard pad.
    rect(fn,(114,104,154,108),P["wood_dark"])
    rect(fn,(119,109,124,117),P["wood"])
    rect(fn,(147,109,152,117),P["wood"])
    rect(fn,(126,96,147,103),P["iron"])
    rect(fn,(122,94,151,97),P["metal_hl"])
    rect(fn,(132,103,141,117),P["stone_dark"])
    for x in (115,123,153):
        rect(fn,(x,83,x+2,103),P["wood_dark"])
        rect(fn,(x-2,89,x+4,91),P["metal"])
    # Tiles and work pieces around building entrance.
    rect(fn,(75,110,113,113),P["stone_light"])
    rect(fn,(72,114,116,116),P["stone_dark"])
    for p in [(62,103),(57,110),(159,108)]:
        rect(fn,(p[0],p[1],p[0]+4,p[1]+3),P["stone"])
    # Focused amber windows; no false "working" smoke or flashing production.
    rect(finish,(39,79,50,85),"#b6d1bc")
    rect(finish,(38,77,40,82),P["metal_hl"])
    rect(finish,(116,78,120,80),P["glow"])
    rect(finish,(132,16,140,18),P["stone"])
    for x,y in [(18,111),(24,116),(147,117)]:
        rect(finish,(x,y,x+7,y+3),P["moss"])
    export("smithy",layers,(W,H))

def make_cottage():
    W,H=138,113
    layers=[(n,layer(W,H)) for n in ["ground contact","stone base","wattle plaster","wood structure","clay shingle roof","home and planting"]]
    sh,stone,wall,timber,ro,fn=[i[1] for i in layers]
    ImageDraw.Draw(sh).ellipse((6,102,135,111),fill="#263d3750")
    masonry(stone,12,87,129,105)
    rect(wall,(14,40,113,92),P["wood_dark"])
    rect(wall,(19,46,109,91),P["wall"])
    poly(wall,[(113,46),(126,53),(126,96),(113,90)],"#ab8b6c")
    timbers(timber,14,47,114,97)
    roof(ro,5,15,129,60)
    # Upper story under raised gable.
    poly(ro,[(27,42),(45,22),(66,42)],P["wood_dark"])
    poly(ro,[(32,40),(45,27),(61,40)],P["wall_hl"])
    rect(ro,(43,33,49,37),P["glass"])
    # A readable chimney sits behind eaves.
    rect(ro,(101,5,119,27),P["wood_dark"])
    rect(ro,(105,5,116,24),P["stone"])
    rect(ro,(103,5,120,8),P["stone_light"])
    door(fn,72,64,23,34)
    framed_window(fn,30,70,True)
    # Tiny planted window box, bench, flowers and threshold.
    rect(fn,(26,90,56,96),P["wood"])
    rect(fn,(26,89,55,91),P["wood_hl"])
    for x,c in ((28,"#e7b5a9"),(38,"#eed08a"),(50,"#b9bed9")):
        rect(fn,(x,84,x+2,90),P["leaf"])
        rect(fn,(x-2,82,x+3,86),c)
    rect(fn,(69,98,99,102),P["stone_light"])
    rect(fn,(65,103,103,106),P["stone_dark"])
    rect(fn,(112,94,129,100),P["wood_dark"])
    rect(fn,(112,88,125,95),P["wood_lit"])
    specks(wall,(22,63,109,90),11,["#f0d8ac","#cbb08b"],35)
    export("cottage",layers,(W,H))

def make_store():
    W,H=124,108
    layers=[(n,layer(W,H)) for n in ["contact","stone base","plaster walls","structural timber","slate roof","inventory props"]]
    sh,stone,wall,timber,ro,fn=[i[1] for i in layers]
    ImageDraw.Draw(sh).ellipse((3,100,119,107),fill="#233c3650")
    masonry(stone,8,82,114,103)
    rect(wall,(13,40,108,90),P["wall_sh"])
    rect(wall,(16,43,106,91),P["wall"])
    timbers(timber,12,44,108,99)
    roof(ro,4,11,119,54,"slate")
    rect(ro,(13,53,111,56),P["slate_dark"])
    door(fn,48,65,30,35)
    # Heavy cross-braced wooden warehouse double-door, barn locking hardware.
    line(fn,[(50,66),(74,97)],P["wood_hl"],2)
    line(fn,[(75,66),(51,96)],P["wood_hl"],2)
    rect(fn,(61,71,65,92),P["wood_dark"])
    rect(fn,(58,79,67,82),P["metal_hl"])
    rect(fn,(26,61,40,75),P["outline"])
    rect(fn,(28,64,38,72),P["glass"])
    rect(fn,(35,64,36,72),P["wood_hl"])
    # Inventory crates and sacks signal purpose without random scene clutter.
    for x,y in [(82,88),(98,93),(13,92)]:
        rect(fn,(x,y,x+18,y+12),P["wood_dark"])
        rect(fn,(x+2,y+2,x+16,y+10),P["wood_lit"])
        line(fn,[(x+3,y+3),(x+15,y+9)],P["wood_dark"])
        line(fn,[(x+15,y+3),(x+3,y+9)],P["wood_dark"])
    rect(fn,(82,78,95,90),P["wall_hl"])
    rect(fn,(85,75,93,79),P["wall_sh"])
    export("storehouse",layers,(W,H))

def make_gate():
    W,H=130,110
    layers=[(n,layer(W,H)) for n in ["shadow","rock masses","stone ledges","portal and carvings","warm clues"]]
    sh,rock,ledge,portal,acc=[i[1] for i in layers]
    ImageDraw.Draw(sh).ellipse((9,95,121,108),fill="#172d304d")
    poly(rock,[(4,92),(10,70),(13,50),(29,31),(46,19),(66,10),(91,18),(109,32),(121,58),(128,88),(120,101),(11,101)],P["outline"])
    poly(rock,[(8,86),(17,53),(38,28),(65,15),(87,22),(104,42),(116,74),(120,94),(10,96)],P["stone_dark"])
    poly(rock,[(13,76),(26,44),(46,30),(65,17),(80,25),(67,41),(38,52),(22,82)],P["stone"])
    poly(rock,[(88,27),(101,44),(115,76),(118,90),(103,86),(90,48)],P["stone"])
    for coords in [[(20,58),(38,55),(32,68)],[(87,49),(105,55),(107,72)],[(49,27),(64,18),(74,23)]]:
        line(ledge,coords,P["stone_light"],2)
    # Deep hollow with three progressive planes and a readable threshold.
    ImageDraw.Draw(portal).ellipse((34,47,96,112),fill=P["outline"])
    ImageDraw.Draw(portal).ellipse((40,53,91,113),fill="#17282f")
    poly(portal,[(47,79),(61,59),(75,62),(87,79),(88,107),(43,107)],"#0e1c26")
    rect(portal,(46,98,87,102),"#6e7367")
    rect(portal,(39,101,95,105),P["stone_light"])
    line(portal,[(22,94),(39,98)],P["stone_dark"],2)
    line(portal,[(93,97),(117,93)],P["stone_dark"],2)
    # Moss clumps follow rock contour and warn the eye about cave mystery.
    for x,y in [(16,68),(27,41),(35,31),(92,43),(109,67),(104,89)]:
        rect(acc,(x,y,x+9,y+5),P["moss"])
        rect(acc,(x+3,y-3,x+6,y),P["leaf"])
        rect(acc,(x+2,y+5,x+7,y+6),P["grass"])
    for x in (31,102):
        rect(acc,(x-2,82,x+2,101),P["wood_dark"])
        rect(acc,(x-5,76,x+5,87),P["outline"])
        rect(acc,(x-3,77,x+3,84),P["glow"])
        rect(acc,(x-1,76,x+1,82),P["flame"])
    export("cave_gate",layers,(W,H))


def make_tree():
    # A single irregular mature tree, with authored branches, trunk and
    # dark/light foliage clusters. Distinct from the two-trees-in-one atlas crop.
    W,H=86,112
    layers=[(n,layer(W,H)) for n in ["ground roots","trunk branches","deep leaf silhouette","canopy facets","light clusters","finishing"]]
    roots,trunk,dark,leaf,lit,finish=[x[1] for x in layers]
    ImageDraw.Draw(roots).ellipse((15,98,80,109),fill="#283c344e")
    poly(roots,[(39,103),(28,108),(25,106),(32,97),(35,84),(47,84),(52,99),(65,104),(61,108),(48,103)],P["wood_dark"])
    poly(trunk,[(33,103),(38,61),(42,47),(51,49),(50,85),(53,103),(47,103),(46,85),(42,69),(39,101)],P["wood_dark"])
    rect(trunk,(41,64,44,97),P["wood_lit"])
    line(trunk,[(37,84),(29,75),(26,66)],P["wood_dark"],4)
    line(trunk,[(49,77),(58,65),(64,63)],P["wood_dark"],4)
    # Canopy outline uses asymmetrical overlapping silhouettes instead of
    # perfect circles. All shadow/canopy layers are editable separately.
    d=ImageDraw.Draw(dark)
    for shape in [(8,41,53,85),(19,21,66,72),(37,31,81,78),
                  (14,14,57,54),(40,11,77,56),(2,50,35,80)]:
        d.ellipse(shape,fill="#315d4d")
    d=ImageDraw.Draw(leaf)
    for shape,c in [((10,38,49,77),"#4f8158"),((21,22,62,65),"#54895c"),
                    ((42,29,77,69),"#467a54"),((15,13,54,52),"#5e945f"),
                    ((44,13,74,50),"#64945d"),((4,52,31,76),"#5a8e59")]:
        d.ellipse(shape,fill=c)
    d=ImageDraw.Draw(lit)
    for shape,c in [((17,18,46,37),"#88ae6a"),((42,17,63,34),"#82aa67"),
                    ((24,30,51,44),"#79a663"),((11,47,33,59),"#78a161"),
                    ((54,37,72,48),"#69995f"),((25,54,44,62),"#61985e")]:
        d.ellipse(shape,fill=c)
    for x,y in [(19,28),(31,21),(42,38),(50,25),(59,44),(20,54),(39,60),
                (63,27),(15,68),(71,54),(8,60),(32,43),(56,58)]:
        rect(finish,(x,y,x+4,y+2),"#a0bf79" if (x+y)%3==0 else "#6a9a61")
        rect(finish,(x+4,y+3,x+6,y+3),"#305a48")
    for x,y in [(33,101),(55,102),(62,107)]:
        rect(finish,(x,y,x+6,y+2),P["grass"])
    export("mature_tree",layers,(W,H))

def make_cave_wall():
    W,H=150,106
    layers=[(n,layer(W,H)) for n in ["cave contact","massive rock","angled fractured facets","weathered seams","cave moss and mineral"]]
    sh,base,faces,seams,plants=[x[1] for x in layers]
    ImageDraw.Draw(sh).ellipse((2,87,147,105),fill="#14242e78")
    poly(base,[(1,93),(2,42),(18,24),(35,20),(54,5),(78,13),(100,0),
               (134,16),(149,31),(149,91),(143,100),(7,100)],"#263a44")
    poly(faces,[(8,87),(12,39),(26,29),(39,36),(46,75),(41,93)],"#3e5561")
    poly(faces,[(45,74),(40,25),(56,11),(71,18),(75,75),(70,94)],"#516672")
    poly(faces,[(76,88),(81,31),(106,12),(126,18),(137,58),(136,92)],"#405864")
    poly(faces,[(11,40),(25,29),(34,29),(22,52)],"#82908a")
    poly(faces,[(53,15),(68,12),(75,28),(62,24)],"#748787")
    poly(faces,[(105,13),(123,19),(138,38),(115,31)],"#70858a")
    line(seams,[(7,91),(24,79),(36,84)],"#253640",3)
    line(seams,[(41,35),(50,44),(45,74)],"#293d47",3)
    line(seams,[(77,34),(85,46),(81,75)],"#283a44",3)
    line(seams,[(113,40),(127,50),(122,81)],"#314751",2)
    for x,y in [(22,30),(61,19),(110,23),(44,79),(93,57),(132,83)]:
        line(seams,[(x,y),(x+9,y+1)],"#8b9a92")
    for x,y in [(6,80),(26,64),(50,39),(70,83),(125,63),(135,86)]:
        rect(plants,(x,y,x+10,y+4),"#467468")
        rect(plants,(x+2,y-2,x+6,y+1),"#658f74")
    export("cave_wall",layers,(W,H))


def make_inhabitants():
    # Tiny narrative-led character designs: coherent body/gear pixel anchors.
    # Every direction and frame sits in the same 24x32 cell. Exports also ship
    # as truly layered source masters, not a flattened generated picture.
    W,H=384,256
    names=["feet and contact","legs and silhouette","skin and face",
           "tunic and cloak","hair and trim","occupation detail"]
    layers=[(name,layer(W,H)) for name in names]
    feet,body,skin,coat,hair,detail=[l[1] for l in layers]
    ge=[(name,layer(384,128)) for name in
        ["metal armor","helmet","shield","drawn weapon"]]
    armor,helmet,shield,weapon=[a[1] for a in ge]
    for role in range(2):
      for direction in range(4):
        for scale in range(2):
          for frame in range(8):
            off_x=24*(scale*8+frame)
            off_y=32*(role*4+direction)
            xc=off_x+12
            fy=off_y+31
            short=-2 if scale==0 else 0
            stride=1 if frame in (1,6) else -1 if frame in (3,7) else 0
            work=frame in (4,5)
            strike=frame in (6,7)
            w=7 if scale==0 else 8
            # Boots overlap at the same foot pivot even when legs stride.
            rect(feet,(xc-6-stride,fy-5,xc-2-stride,fy),"#344747")
            rect(feet,(xc+2+stride,fy-5,xc+6+stride,fy),"#344747")
            rect(feet,(xc-5-stride,fy-4,xc-2-stride,fy-3),"#7d5f48")
            rect(feet,(xc+2+stride,fy-4,xc+5+stride,fy-3),"#7d5f48")
            # Irregular tunic apron / armor skirt with small hem trim.
            poly(body,[(xc-w,fy-15-short),(xc+w,fy-15-short),
                       (xc+w-1,fy-5),(xc+3,fy-7),(xc,fy-6),
                       (xc-4,fy-8),(xc-w+1,fy-6)],"#233940")
            c="#537f83" if role==0 else "#526e7a"
            poly(coat,[(xc-w+1,fy-19-short),(xc+w-1,fy-19-short),
                       (xc+w-2,fy-8),(xc-2,fy-7),(xc-w+2,fy-8)],c)
            rect(coat,(xc-w+1,fy-12,xc+w-2,fy-10),"#b68a60" if role==0 else "#9bb1ae")
            rect(coat,(xc-2,fy-12,xc+1,fy-9),"#e7cf99")
            if direction==1:
                # Back: cloth mantle and hair, not a smiling mask
                poly(coat,[(xc-6,fy-22-short),(xc+6,fy-22-short),
                           (xc+8,fy-7),(xc,fy-4),(xc-8,fy-7)],
                     "#3b655f" if role==0 else "#526372")
                line(detail,[(xc,fy-20),(xc,fy-7)],"#95a493",2)
            # Pixel limbs with genuinely different work and attack poses.
            # Actual alternating tool/action poses, not duplicate cells.
            ly=(-25 if frame==4 else -17) if work else (-23 if frame==6 else -18) if strike else -19
            ry=(-17 if frame==4 else -25) if work else (-17 if frame==6 else -23) if strike else -19
            rect(skin,(xc-w-3,fy+ly-short,xc-w+1,fy-11),
                 "#c39070")
            rect(skin,(xc+w-1,fy+ry-short,xc+w+3,fy-11),
                 "#e1b28a")
            rect(coat,(xc-w-3,fy+ly-short,xc-w+1,fy+ly+6-short),c)
            rect(coat,(xc+w-1,fy+ry-short,xc+w+3,fy+ry+6-short),c)
            # Neck, head and recognizable directional face.
            rect(skin,(xc-3,fy-25-short,xc+3,fy-21-short),"#c89073")
            rect(skin,(xc-6,fy-28-short,xc+6,fy-23-short),"#283a3d")
            rect(skin,(xc-5,fy-31-short,xc+5,fy-24-short),"#e0af86")
            rect(skin,(xc-4,fy-30-short,xc+3,fy-27-short),"#f3c69a")
            if direction==0:
                rect(detail,(xc-3,fy-26-short,xc-2,fy-25-short),"#23383c")
                rect(detail,(xc+3,fy-26-short,xc+4,fy-25-short),"#23383c")
                rect(detail,(xc-1,fy-23-short,xc+1,fy-23-short),"#b57862")
                rect(hair,(xc-7,fy-29-short,xc+5,fy-30-short),"#604736" if role==0 else "#455563")
                rect(hair,(xc-7,fy-31-short,xc-5,fy-25-short),"#805b43")
                rect(hair,(xc+1,fy-28-short,xc+4,fy-31-short),"#bd8352" if role==0 else "#7a929b")
            elif direction==1:
                rect(hair,(xc-6,fy-29-short,xc+6,fy-23-short),"#725038")
                rect(hair,(xc-4,fy-28-short,xc+4,fy-31-short),"#b08155")
            elif direction==2:
                rect(hair,(xc-7,fy-29-short,xc+4,fy-30-short),"#75533f")
                rect(hair,(xc-7,fy-31-short,xc-5,fy-25-short),"#604738")
                rect(detail,(xc-4,fy-26-short,xc-3,fy-25-short),"#23383c")
                rect(skin,(xc-7,fy-27-short,xc-5,fy-26-short),"#d29a77")
            else:
                rect(hair,(xc-4,fy-29-short,xc+7,fy-30-short),"#75533f")
                rect(hair,(xc+5,fy-31-short,xc+7,fy-25-short),"#604738")
                rect(detail,(xc+3,fy-26-short,xc+4,fy-25-short),"#23383c")
                rect(skin,(xc+5,fy-27-short,xc+7,fy-26-short),"#e9b78a")
            if role==0:
                # Worker is not an armored fighter: stitched satchel on right.
                rect(detail,(xc+5,fy-14,xc+9,fy-9),"#795a40")
                rect(detail,(xc+6,fy-13,xc+8,fy-11),"#c59b61")
                rect(detail,(xc-5,fy-18,xc-3,fy-16),"#e1bb86")
                if work:
                    # Hammer lifts and lowers with the real work-frame index.
                    head_y = fy - (27 if frame==4 else 20) - short
                    rect(detail,(xc-9,head_y,xc-8,head_y+9),"#a48a65")
                    rect(detail,(xc-13,head_y-2,xc-6,head_y),"#bac8c4")
                    rect(detail,(xc-11,head_y-3,xc-9,head_y-1),"#e7d6ad")
            else:
                ey=32*direction
                cfy=ey+31
                # All combat kit is on an independent, matching atlas
                # with exactly the same cells, feet and animation timing.
                def ar(im,x1,y1,x2,y2,color):
                    rect(im,(x1,cfy+y1-short,x2,cfy+y2-short),color)
                ar(armor,xc-7,-19,xc+7,-12,"#56717c")
                ar(armor,xc-5,-17,xc+5,-13,"#b7c9c5")
                ar(armor,xc-1,-17,xc+2,-14,"#f0dfab")
                ar(helmet,xc-7,-34,xc+7,-29,"#586a70")
                ar(helmet,xc-6,-35,xc+5,-33,"#b2c2bf")
                ar(helmet,xc-6,-31,xc-4,-25,"#80969a")
                ar(helmet,xc+4,-31,xc+6,-25,"#80969a")
                ar(helmet,xc-2,-36,xc+2,-35,"#d8d1b0")
                xx=xc-12 if direction != 2 else xc+8
                # Rounded tiny buckler with amber boss.
                poly(shield,[(xx,cfy-20-short),(xx+8,cfy-20-short),
                             (xx+9,cfy-14-short),(xx+5,cfy-7-short),
                             (xx+1,cfy-12-short)],"#263c43")
                rect(shield,(xx+1,cfy-19-short,xx+7,cfy-14-short),"#b98453")
                rect(shield,(xx+3,cfy-17-short,xx+5,cfy-13-short),"#eacb86")
                xx=xc+11 if direction!=2 else xc-13
                offset=-7 if frame==6 else 2 if frame==7 else 0
                ar(weapon,xx,-28+offset,xx+2,-10+offset,"#99b6bb")
                ar(weapon,xx,-29+offset,xx+1,-24+offset,"#d8dfd9")
                ar(weapon,xx-3,-12+offset,xx+5,-10+offset,"#edc48d")
                ar(weapon,xx,-9+offset,xx+2,-6+offset,"#785c46")
    export("inhabitants",layers,(W,H))
    export("guard_equipment",ge,(384,128))


def make_construction_site():
    W,H=118,94
    # In-progress building with physical foundations, supports, a saw bench
    # and half-constructed timber. No giant square crossed blueprint plane.
    parts=[(n,layer(W,H)) for n in ["site shadow","stone footing",
            "staged timber walls","posts and joists","builder details"]]
    sh,stone,frame,joists,fin=[x[1] for x in parts]
    ImageDraw.Draw(sh).ellipse((6,76,111,91),fill="#243d365c")
    masonry(stone,12,66,107,83)
    rect(frame,(19,44,102,67),P["wood_dark"])
    rect(frame,(22,46,95,66),P["wall_sh"])
    for yy in range(48,65,6):
        rect(frame,(23,yy,95,yy+2),"#ba956e")
        line(frame,[(31,yy),(87,yy)],P["wood_hl"])
    for x in [17,41,85,103]:
        rect(joists,(x,28,x+5,79),P["wood_dark"])
        rect(joists,(x+1,28,x+2,78),P["wood_hl"])
        rect(joists,(x-2,26,x+9,30),P["wood_lit"])
    line(joists,[(19,30),(64,16),(105,30)],P["wood_dark"],4)
    line(joists,[(24,31),(64,21),(100,31)],P["wood_hl"],2)
    line(joists,[(17,31),(17,75)],P["outline"])
    # A reusable sawhorse and two cut boards on the ground at the front.
    rect(fin,(23,81,92,85),P["wood_dark"])
    rect(fin,(26,80,90,82),P["wood_lit"])
    rect(fin,(18,84,48,87),P["wood"])
    rect(fin,(65,86,101,89),P["wood_hl"])
    rect(fin,(23,88,26,92),P["stone"])
    for p in [(49,75),(58,80),(107,72)]:
        rect(fin,(p[0],p[1],p[0]+4,p[1]+2),P["stone_light"])
    export("construction_site",parts,(W,H))
    # Finished small community watch hut uses the SAME foot/plot footprint.
    complete=[(n,layer(W,H)) for n in ["contact and stone footing",
             "finished walls","timber joinery","wood roof","door and trim"]]
    sh,wall,timber,roof_layer,fin=[x[1] for x in complete]
    ImageDraw.Draw(sh).ellipse((4,80,113,92),fill="#243d365c")
    masonry(sh,10,74,109,84)
    rect(wall,(15,37,103,75),P["wall_sh"])
    rect(wall,(19,39,99,75),P["wall_hl"])
    timbers(timber,15,40,104,78)
    roof(roof_layer,5,10,114,45,"slate")
    door(fin,50,53,18,23)
    framed_window(fin,25,53,False)
    rect(fin,(81,67,99,73),P["wood_lit"])
    for x in [86,92,97]:
        rect(fin,(x,61,x+2,69),P["wood_dark"])
    export("watch_hut",complete,(W,H))


def make_ancient_altar():
    W,H=132,108
    parts=[(n,layer(W,H)) for n in ["shadow","stone raised steps",
        "weathered carved pillar","mineral veins","ritual accents"]]
    sh,stone,carved,gem,acc=[i[1] for i in parts]
    ImageDraw.Draw(sh).ellipse((4,90,127,107),fill="#182d334f")
    masonry(stone,9,78,121,97)
    rect(stone,(14,72,116,81),P["stone_dark"])
    rect(stone,(21,65,109,74),P["stone"])
    rect(stone,(29,60,100,67),P["stone_light"])
    for x in (25,96):
        rect(carved,(x-9,35,x+10,67),P["outline"])
        rect(carved,(x-7,33,x+8,63),P["stone_dark"])
        rect(carved,(x-5,35,x+6,59),P["stone"])
        for y in (39,49,56):
            rect(carved,(x-4,y,x+3,y+2),P["stone_light"])
        rect(carved,(x-10,30,x+11,36),P["stone_dark"])
        rect(carved,(x-9,28,x+10,31),P["stone_light"])
        rect(carved,(x-11,62,x+10,65),P["outline"])
    # Separate striking central crystal; non-fake gameplay effects.
    poly(gem,[(67,14),(79,31),(73,53),(61,62),(51,48),(54,29)],"#294e5a")
    poly(gem,[(67,17),(77,34),(71,49),(62,57),(57,42),(59,29)],"#599fa2")
    poly(gem,[(66,20),(71,34),(67,47),(63,56),(59,40)],"#a3d3ba")
    poly(gem,[(66,20),(72,33),(69,38),(64,30)],"#def2d0")
    line(gem,[(67,19),(66,47)],"#d5ebdb")
    rect(acc,(48,62,83,66),P["outline"])
    rect(acc,(53,65,78,73),P["stone_light"])
    rect(acc,(60,69,72,73),P["glow"])
    for x,y in [(11,73),(109,68),(26,64),(92,64)]:
        rect(acc,(x,y,x+10,y+4),"#47685d")
        rect(acc,(x+2,y-2,x+6,y),P["moss"])
    for x,y in [(32,77),(84,78)]:
        rect(acc,(x,y,x+13,y+3),P["wood_dark"])
        rect(acc,(x+4,y-3,x+7,y+4),P["glow"])
    export("ancient_altar",parts,(W,H))

if __name__=="__main__":
    make_smithy()
    make_cottage()
    make_store()
    make_gate()
    make_tree()
    make_cave_wall()
    make_inhabitants()
    make_construction_site()
    make_ancient_altar()
