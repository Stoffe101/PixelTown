extends RefCounted
## Config-level display contract, not a claim of real-world visual QA.

func run() -> Array[String]:
	var problems: Array[String] = []
	var base_width := int(ProjectSettings.get_setting("display/window/size/viewport_width", 0))
	var base_height := int(ProjectSettings.get_setting("display/window/size/viewport_height", 0))
	if base_width != 640 or base_height != 360:
		problems.append("The provisional logical viewport should remain 640x360 until art scale is reviewed")
	if ProjectSettings.get_setting("display/window/stretch/mode", "") != "viewport":
		problems.append("Pixel-art stretch mode must be viewport")
	if ProjectSettings.get_setting("display/window/stretch/aspect", "") != "expand":
		problems.append("Aspect mode must expand to support ultrawide without distortion")
	if ProjectSettings.get_setting("display/window/stretch/scale_mode", "") != "integer":
		problems.append("Integer stretch scaling must be enabled for crisp pixels")
	if base_width <= 0 or base_height <= 0:
		problems.append("Base viewport must be positive")
		return problems

	for display_size in [Vector2i(1920, 1080), Vector2i(2560, 1440), Vector2i(3440, 1440)]:
		var factor := int(floor(minf(float(display_size.x) / float(base_width), float(display_size.y) / float(base_height))))
		if factor < 1:
			problems.append("Insufficient integer scale for %s" % str(display_size))
			continue
		if display_size.x / factor < base_width or display_size.y / factor < base_height:
			problems.append("Visible canvas shrinks below design area for %s" % str(display_size))
		if display_size.x == 3440 and display_size.x / factor <= base_width:
			problems.append("Ultrawide must reveal additional horizontal canvas")
	return problems
