extends Node2D
## Hand-authored, deterministic pixel compositions. Source art lives here, not in
## unrelated generated pictures. Prototype art only; review before production.
##
## All shapes use integer logical-pixel coordinates, a shared restricted palette,
## and non-antialiased draws. Village and cave reuse character proportions.

const GROUND := Color("#779e58")
const DIRT := Color("#a7865d")
const LIGHT := Color("#f1dda9")
const INK := Color("#263442")
const WOOD := Color("#98643c")
const WOOD_DARK := Color("#66462d")
const ROOF := Color("#b66549")
const ROOF_HI := Color("#dd8f60")
const CAVE_FLOOR := Color("#343d4b")
const ROCK := Color("#536272")
const ROCK_DARK := Color("#26313e")
const TORCH := Color("#ffa74b")

var view: String = "village"
var art_scale: int = 0
var tick_time: float = 0.0
var worker_pos: Vector2 = Vector2(363, 342)
var carrying: bool = false
var completed: bool = false
var delivered: int = 0
var enemy_hp: int = 5
var enemy_hits: int = 0

func _box(x: float, y: float, w: float, h: float, c: Color) -> void:
	draw_rect(Rect2(Vector2(roundf(x), roundf(y)), Vector2(roundf(w), roundf(h))), c)

func _line(x: float, y: float, x2: float, y2: float, c: Color) -> void:
	draw_line(Vector2(roundf(x),roundf(y)),Vector2(roundf(x2),roundf(y2)),c,1.0,false)

func _hash(x: int, y: int) -> int:
	var n: int = x * 1777 + y * 733 + x * y * 31
	n = ((n << 13) ^ n)
	return absi(n * (n * n * 15731 + 789221) + 1376312589) % 100

func _draw() -> void:
	if view == "village":
		_draw_village()
	else:
		_draw_cave()

func _draw_village() -> void:
	_box(0, 0, 1120, 650, Color("#6b9655"))
	for yy in range(0, 650, 16):
		for xx in range(0, 1120, 16):
			var n: int = _hash(xx / 16, yy / 16)
			var c: Color = Color("#789f5a")
			if n < 24: c = Color("#80a65e")
			elif n < 47: c = Color("#749b56")
			elif n > 92: c = Color("#8bae65")
			_box(xx, yy, 16, 16, c)
			if n % 5 == 0:
				_box(xx + 3, yy + 8, 1, 3, Color("#4e854f"))
				_box(xx + 5, yy + 6, 1, 4, Color("#c6cb78"))
			if n > 95:
				_box(xx + 11, yy + 5, 2, 2, Color("#f3dfaa"))
				_box(xx + 10, yy + 4, 1, 1, Color("#e8998c"))

	# A wandering earthen village path, bordered with straw grass.
	_path(0, 371, 1118, 32)
	_path(179, 288, 30, 110)
	_path(363, 302, 31, 92)
	_path(631, 295, 34, 100)
	_path(888, 306, 34, 94)
	_path(704, 367, 35, 90)
	for x in range(15, 1100, 25):
		_box(x, 385 + (_hash(x,1) % 8), 3, 2, Color("#c9ad7b"))
		_box(x + 7, 365, 2, 2, Color("#755e45"))

	# Willow-colored water at the bottom of the clearing.
	_box(0, 480, 1120, 115, Color("#4e8490"))
	for yy in range(480, 598, 16):
		for xx in range(0, 1120, 16):
			if _hash(xx / 16, yy / 16) % 3 == 0:
				_box(xx+3, yy+4, 10, 2, Color("#74a9a4"))
			if _hash(xx / 16, yy / 16) % 8 == 0:
				_box(xx+7, yy+11, 7, 1, Color("#afd0b8"))
	_box(0, 477, 1120, 6, Color("#b1b978"))
	_box(0, 593, 1120, 6, Color("#335b58"))
	# Timber bridge across the creek.
	_box(478, 466, 80, 140, WOOD_DARK)
	for x in range(481, 556, 10):
		_box(x, 468, 8, 136, Color("#be9567"))
		_line(x+6, 474, x+6, 599, WOOD)
	_box(472, 470, 7, 135, Color("#5f4432"))
	_box(557, 470, 7, 135, Color("#5f4432"))
	for y in [485, 520, 557, 590]:
		_box(472, y, 92, 4, Color("#e1b57f"))

	# Plants are deliberately in clusters; not a repetitive wallpaper of noise.
	for p in [Vector2(84,225),Vector2(268,198),Vector2(489,194),Vector2(810,197),Vector2(1018,250),Vector2(95,425),Vector2(1033,423)]:
		_tree(p.x,p.y)
	for p in [Vector2(252,426),Vector2(280,447),Vector2(792,422),Vector2(824,452),Vector2(963,434)]:
		_bush(p.x,p.y)
	_flowerbed(218,331)
	_flowerbed(777,348)
	_flowerbed(1029,360)

	# All structures share the same single-square-grid building language.
	_house(126,236)
	_store(321,235)
	_forge(545,224)
	_cave_mouth(861,227)
	# One building plot is visibly supplied by the job simulation.
	_plot(698,295)
	_sign(835,366,"CAVE")
	_lantern(557,366)
	_lantern(793,365)
	# Inhabitant and guard have the same silhouette base and layered clothing.
	_character(worker_pos.x, worker_pos.y, false, carrying, false)
	_character(759,365 + sin(tick_time*1.5)*1.0, true, false, false)
	if carrying:
		_box(worker_pos.x-6,worker_pos.y-28,12,4, WOOD)
		_box(worker_pos.x-5,worker_pos.y-30,10,2,Color("#e3b47c"))
	if completed:
		_box(698, 296, 50, 4, Color("#b4d28a"))

func _path(x: float,y:float,w:float,h:float) -> void:
	_box(x-3,y-3,w+6,h+6,Color("#6c8b50"))
	_box(x,y,w,h,DIRT)
	if w > h:
		for dx in range(int(x)+9,int(x+w),22):
			_box(dx,y+7,6,2,Color("#bf9b6b"))
			_box(dx+8,y+21,4,2,Color("#826649"))
	else:
		for dy in range(int(y)+9,int(y+h),19):
			_box(x+9,dy,6,2,Color("#bf9b6b"))

func _tree(x: float,y:float) -> void:
	_box(x-14,y+35,38,8,Color("#577f4d"))
	_box(x+1,y+15,9,28,WOOD_DARK)
	_box(x+4,y+17,3,23,WOOD)
	for v in [Vector2(-13,3),Vector2(9,-5),Vector2(25,9),Vector2(-5,-18),Vector2(16,-23)]:
		_box(x+v.x-14,y+v.y-8,31,29,Color("#365e4c"))
		_box(x+v.x-12,y+v.y-11,27,24,Color("#568557"))
		_box(x+v.x-8,y+v.y-10,17,8,Color("#75a45e"))
	_box(x+14,y-8,4,3,Color("#b8c473"))
	_box(x-18,y+3,5,3,Color("#88ac65"))
	_box(x+26,y+18,5,3,Color("#83ac62"))

func _bush(x:float,y:float) -> void:
	_box(x-10,y+9,28,5,Color("#4c744f"))
	_box(x-12,y-2,24,15,Color("#365e4c"))
	_box(x-7,y-7,23,16,Color("#568758"))
	_box(x-3,y-8,8,4,Color("#84a967"))
	_box(x+11,y+2,5,4,Color("#94b474"))

func _flowerbed(x:float,y:float) -> void:
	for i in range(5):
		var px: float = x+i*9
		_box(px,y+4,1,8,Color("#437948"))
		_box(px-2,y+2,5,4,Color("#f1d68b") if i%2==0 else Color("#d99da2"))
		_box(px,y+3,1,1,Color("#fff0cc"))

func _house(x:float,y:float) -> void:
	_box(x+9,y+63,106,9,Color("#5c804f"))
	_box(x+12,y+28,99,41,Color("#f1d59c"))
	_box(x+15,y+30,4,37,Color("#d6ae76"))
	_box(x+102,y+30,5,37,Color("#b68d65"))
	_box(x+2,y+28,119,7,INK)
	# Stepped clay roof makes the sloping perspective unambiguous.
	for i in range(8):
		_box(x+4+i*7,y+23-i*4,115-i*14,5,ROOF)
		_box(x+7+i*7,y+22-i*4,109-i*14,2,ROOF_HI)
	_box(x+27,y+46,18,15,WOOD_DARK)
	_box(x+29,y+48,14,10,Color("#7db0a4"))
	_box(x+34,y+48,3,10,Color("#e5d9b0"))
	_box(x+71,y+40,23,29,WOOD_DARK)
	_box(x+74,y+43,17,26,Color("#946c47"))
	_box(x+86,y+57,2,2,LIGHT)
	_box(x+22,y+60,82,3,Color("#e6be89"))
	_box(x+5,y+62,9,6,Color("#ba8e61"))
	# Chimney / flowers / a warm little home.
	_box(x+84,y-13,14,19,INK)
	_box(x+86,y-12,10,17,Color("#a87b65"))
	_box(x+7,y+65,21,5,Color("#7b4b35"))
	_flowerbed(x+13,y+59)

func _store(x:float,y:float) -> void:
	_box(x+4,y+61,98,10,Color("#5b7d4b"))
	_box(x+10,y+22,84,43,Color("#a98b6a"))
	for i in range(7):
		_box(x+6+i*7,y+20-i*3,92-i*14,5,Color("#667a65"))
		_box(x+9+i*7,y+19-i*3,86-i*14,2,Color("#9bb094"))
	_box(x+18,y+44,25,22,WOOD_DARK)
	_box(x+21,y+47,19,19,Color("#a67b4d"))
	_line(x+21,y+47,x+39,y+64,Color("#c29665"))
	_line(x+40,y+47,x+22,y+64,Color("#c29665"))
	_box(x+62,y+36,20,16,INK)
	_box(x+64,y+38,16,12,Color("#b7cfbd"))
	_box(x+70,y+39,2,10,Color("#e4dfbb"))
	_box(x+2,y+58,16,11,WOOD_DARK)
	_box(x+4,y+55,12,14,Color("#d7c08f"))
	_box(x+87,y+58,11,11,WOOD_DARK)
	_box(x+89,y+54,8,14,Color("#dbbf83"))
	# Storage resource stack (matches the simulated wood count).
	for i in range(3):
		_box(x-14+i*6,y+65-i*3,16,5,WOOD_DARK)
		_box(x-13+i*6,y+64-i*3,13,2,Color("#c79a65"))

func _forge(x:float,y:float) -> void:
	_box(x+4,y+73,123,10,Color("#5f794f"))
	_box(x+12,y+26,109,52,Color("#e0bb8b"))
	_box(x+11,y+28,10,50,WOOD_DARK)
	_box(x+112,y+28,10,50,WOOD_DARK)
	for i in range(9):
		_box(x+1+i*7,y+24-i*3,129-i*14,5,Color("#586b74"))
		_box(x+4+i*7,y+23-i*3,123-i*14,2,Color("#82949c"))
	_box(x+91,y-17,16,30,INK)
	_box(x+94,y-16,10,29,Color("#8a7472"))
	for i in range(4):
		var off: float = sin(tick_time*1.2+i)*3
		_box(x+95+off,y-35-i*10,9+i*2,5,Color(0.84,0.88,0.83,0.35-i*0.06))
	_box(x+23,y+44,35,32,WOOD_DARK)
	_box(x+25,y+47,31,27,Color("#39464c"))
	_box(x+31,y+51,19,20,Color("#e38c42"))
	_box(x+35,y+57,11,12,Color("#ffcd73"))
	_box(x+74,y+44,24,32,WOOD_DARK)
	_box(x+77,y+49,18,27,Color("#765842"))
	_box(x+85,y+60,2,3,LIGHT)
	_box(x+2,y+69,16,10,Color("#38434a"))
	_box(x-1,y+67,20,4,Color("#9dabb1"))
	_box(x+13,y+62,5,6,Color("#bd9b76"))
	_lantern(x+112,y+51)

func _cave_mouth(x:float,y:float) -> void:
	_box(x+10,y+76,106,9,Color("#5a784e"))
	for i in range(5):
		_box(x+i*5,y+25+i*7,126-i*10,58-i*7,ROCK_DARK)
		_box(x+i*5+3,y+22+i*6,120-i*10,14,ROCK)
	_box(x+33,y+38,59,45,Color("#18252c"))
	_box(x+38,y+44,49,39,Color("#101920"))
	_box(x+44,y+61,38,22,Color("#2e373b"))
	_box(x+4,y+47,20,13,Color("#76888a"))
	_box(x+104,y+48,18,11,Color("#74858c"))
	_box(x+12,y+67,19,9,Color("#485b62"))
	_box(x+97,y+66,25,11,Color("#40545c"))
	_box(x+51,y+73,25,5,Color("#766b56"))
	_lantern(x+14,y+65)
	_lantern(x+108,y+64)

func _plot(x:float,y:float) -> void:
	if completed:
		_box(x-1,y+62,83,9,Color("#587c4e"))
		_box(x+2,y+21,77,43,Color("#e1c69a"))
		for i in range(6):
			_box(x+i*7,y+20-i*3,83-i*14,5,Color("#677d69"))
		_box(x+29,y+42,24,22,WOOD_DARK)
		_box(x+32,y+45,18,19,Color("#8c6c4a"))
		_box(x+8,y+47,15,11,Color("#8ab9a4"))
	else:
		_box(x-2,y+62,86,5,Color("#997a58"))
		for dx in [0,77]:
			for dy in [9,62]:
				_box(x+dx,y+dy-10,4,15,WOOD_DARK)
		_line(x,y+8,x+79,y+60,Color("#e2b77a"))
		_line(x+79,y+8,x,y+60,Color("#e2b77a"))
		_line(x,y+8,x+79,y+8,Color("#e2b77a"))
		_line(x,y+60,x+79,y+60,Color("#e2b77a"))
		for n in range(delivered):
			_box(x+9+n*21,y+51,16,9,WOOD_DARK)
			_box(x+10+n*21,y+50,15,4,Color("#bd9467"))

func _sign(x:float,y:float,title:String) -> void:
	_box(x,y,4,19,WOOD_DARK)
	_box(x-13,y-10,49,18,WOOD_DARK)
	_box(x-11,y-8,45,14,Color("#bb955e"))
	# Sign labeling is done in HUD inspection; keep physical mark as pixels.
	_box(x+1,y-2,12,2,Color("#e4d6a1"))
	_box(x+13,y-5,7,2,Color("#e4d6a1"))

func _lantern(x:float,y:float) -> void:
	_box(x-1,y-8,3,17,WOOD_DARK)
	_box(x-4,y-13,10,8,Color("#4b4c4b"))
	_box(x-2,y-11,6,5,Color("#ffd06f"))
	_box(x-1,y-10,4,3,Color("#fff0b4"))

func _draw_cave() -> void:
	_box(0,0,1120,650,Color("#1c2633"))
	for yy in range(0, 650, 16):
		for xx in range(0,1120,16):
			var n: int = _hash(xx/16+83,yy/16+67)
			var base: Color = CAVE_FLOOR
			if n < 23: base=Color("#374555")
			elif n > 70: base=Color("#293541")
			_box(xx,yy,16,16,base)
			if n > 88:
				_line(xx+4,yy+9,xx+11,yy+9,Color("#536573"))
				_line(xx+11,yy+9,xx+13,yy+12,Color("#23303d"))
			if n < 8:
				_box(xx+5,yy+6,2,2,Color("#607183"))
	# Hand-shaped cavern edges and depth.
	for x in range(0,1120,32):
		var h: int = 58+_hash(x,5)%36
		_box(x,0,33,h,Color("#192632"))
		_box(x,h-11,32,12,Color("#526372"))
		_box(x+4,h-8,22,4,Color("#6a7b82"))
		var bottom: int = 545+_hash(x,8)%32
		_box(x,bottom,33,650-bottom,Color("#202a34"))
		_box(x,bottom-7,31,8,Color("#465666"))
	for p in [Vector2(290,167),Vector2(493,142),Vector2(825,168),Vector2(990,249)]:
		_torch(p.x,p.y)
	for p in [Vector2(184,303),Vector2(385,461),Vector2(845,451),Vector2(956,348)]:
		_crystals(p.x,p.y)
	for p in [Vector2(206,410),Vector2(397,201),Vector2(831,246),Vector2(941,485)]:
		_stalagmite(p.x,p.y)
	# Centerpiece: an ancient stone threshold and an actual encounter.
	for x in range(470,810,16):
		_box(x,309,14,2,Color("#65717b"))
		_box(x,389,14,2,Color("#28343e"))
	_box(620,318,101,70,Color(0.09,0.14,0.18,0.33))
	_character(585 + sin(tick_time*1.1)*3,372,true,false,true)
	_slime(700,369)
	# Visible small encounter state, not a pretend production battle.
	for i in range(5):
		_box(675+i*11,326,9,5,Color("#9b574e") if i>=enemy_hp else Color("#d78571"))
	if enemy_hits>0 and fmod(tick_time,2.8)<0.35:
		_box(657,339,29,3,Color("#f8dc9b"))
		_box(683,335,4,11,Color("#ffe4a0"))
	# Mineable-looking vein and mystery, only decorative in Prototype 00.
	_box(757,416,75,10,Color("#19252d"))
	_crystals(792,413)

func _torch(x:float,y:float) -> void:
	for i in range(4,0,-1):
		draw_circle(Vector2(x,y),float(i*9),Color(1,0.68,0.28,0.025))
	_box(x-2,y-2,4,22,Color("#4e4039"))
	_box(x-5,y-7,10,10,Color("#b15f3a"))
	_box(x-3,y-10,6,9,Color("#ff9f4a"))
	_box(x-1,y-12,3,8,Color("#ffe5a0"))

func _crystals(x:float,y:float) -> void:
	_box(x-23,y+8,53,6,Color("#263d4a"))
	draw_colored_polygon(PackedVector2Array([Vector2(x-21,y+8),Vector2(x-11,y-15),Vector2(x-4,y+9)]),Color("#567ca3"))
	draw_colored_polygon(PackedVector2Array([Vector2(x-2,y+9),Vector2(x+8,y-25),Vector2(x+18,y+9)]),Color("#82c9c7"))
	draw_colored_polygon(PackedVector2Array([Vector2(x+12,y+9),Vector2(x+23,y-9),Vector2(x+29,y+9)]),Color("#6d8db0"))
	_line(x+7,y-20,x+9,y+5,Color("#d1ede0"))

func _stalagmite(x:float,y:float) -> void:
	_box(x-18,y+13,44,7,Color("#26323c"))
	for i in range(4):
		_box(x+i*9-13,y+4-i*4,12,12+i*4,Color("#53626c"))
		_box(x+i*9-10,y+5-i*4,4,9,Color("#74808a"))

func _slime(x:float,y:float) -> void:
	var bob:float=sin(tick_time*3.0)*2.0
	_box(x-19,y+2,39,5,Color("#20373d"))
	_box(x-15,y-12+bob,32,18,Color("#273f47"))
	_box(x-13,y-16+bob,28,21,Color("#508978"))
	_box(x-7,y-19+bob,15,6,Color("#77afa0"))
	_box(x-9,y-9+bob,5,5,Color("#1e393f"))
	_box(x+5,y-9+bob,5,5,Color("#1e393f"))
	_box(x-4,y-2+bob,9,2,Color("#c6e2b1"))
	_box(x-14,y+2+bob,29,3,Color("#38665c"))

func _character(x:float,y:float,is_guard:bool,carry:bool,in_cave:bool) -> void:
	var s: float=1.0 if art_scale==0 else 1.25
	var step:float = float(int(sin(tick_time*6.0)*2.0)) if (carry or in_cave) else 0.0
	# 16x24 silhouette; a second 20x30 variant can be compared with key 2.
	_box(x-8*s,y-2*s,17*s,3*s,Color("#3b544b") if not in_cave else Color("#1e2c35"))
	_box(x-5*s,y-6*s+step,5*s,6*s,INK)
	_box(x+2*s,y-6*s-step,5*s,6*s,INK)
	_box(x-6*s,y-18*s,13*s,12*s,INK)
	_box(x-4*s,y-17*s,9*s,9*s,Color("#476f84") if is_guard else Color("#ae6751"))
	_box(x-8*s,y-15*s,4*s,8*s,Color("#63788b") if is_guard else Color("#d5b282"))
	_box(x+5*s,y-15*s,4*s,8*s,Color("#879bab") if is_guard else Color("#d5b282"))
	_box(x-6*s,y-26*s,13*s,11*s,INK)
	_box(x-4*s,y-24*s,9*s,8*s,Color("#f0be91"))
	if is_guard:
		_box(x-7*s,y-27*s,15*s,6*s,Color("#7f929e"))
		_box(x-6*s,y-29*s,13*s,4*s,Color("#b5bec1"))
		_box(x-1*s,y-30*s,3*s,4*s,Color("#d6cfac"))
		_box(x-8*s,y-18*s,17*s,4*s,Color("#708da4"))
		_box(x-3*s,y-16*s,6*s,6*s,Color("#b4bbc0"))
		# Readable shield and sword overlays stay aligned with the same sprite.
		_box(x-12*s,y-17*s,6*s,12*s,INK)
		_box(x-11*s,y-16*s,4*s,10*s,Color("#b88a58"))
		_box(x-10*s,y-14*s,2*s,5*s,Color("#e9c18b"))
		_box(x+10*s,y-20*s,2*s,18*s,Color("#b3cbd3"))
		_box(x+8*s,y-19*s,6*s,3*s,Color("#dde4df"))
		_box(x+9*s,y-5*s,4*s,4*s,WOOD_DARK)
	else:
		_box(x-5*s,y-28*s,11*s,6*s,Color("#86513c"))
		_box(x-6*s,y-25*s,3*s,8*s,Color("#86513c"))
		_box(x-2*s,y-18*s,4*s,3*s,Color("#edd4ae"))
		if carry:
			_box(x-8*s,y-22*s,4*s,9*s,Color("#826548"))
			_box(x-10*s,y-24*s,4*s,5*s,Color("#d3aa72"))
	_box(x-3*s,y-21*s,2*s,2*s,INK)
	_box(x+3*s,y-21*s,2*s,2*s,INK)
