extends SceneTree
## Minimal standalone unit-test runner, using only Godot itself.
## Unit scripts follow tests/unit/*_test.gd and expose run() -> Array[String].

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var test_files := DirAccess.get_files_at("res://tests/unit")
	var executed := 0
	var failures := 0
	for file_name in test_files:
		if not file_name.ends_with("_test.gd"):
			continue
		executed += 1
		var file_path := "res://tests/unit/" + file_name
		var test_script := load(file_path) as Script
		if test_script == null or not test_script.can_instantiate():
			printerr("FAIL ", file_name, ": cannot load test")
			failures += 1
			continue
		var suite: Object = test_script.new()
		if not suite.has_method("run"):
			printerr("FAIL ", file_name, ": missing run()")
			failures += 1
			continue
		var result: Variant = suite.call("run")
		if not result is Array:
			printerr("FAIL ", file_name, ": run() did not return an Array")
			failures += 1
			continue
		for problem in result:
			printerr("FAIL ", file_name, ": ", str(problem))
			failures += 1
		if result.is_empty():
			print("PASS ", file_name)
	if executed == 0:
		printerr("FAIL no unit suites discovered")
		failures += 1
	print("CI UNIT TESTS: ", executed, " suite(s), ", failures, " failure(s)")
	quit(0 if failures == 0 else 1)
