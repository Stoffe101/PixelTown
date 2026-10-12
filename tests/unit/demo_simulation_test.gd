extends RefCounted
const DemoState = preload("res://scripts/demo_simulation.gd")

func run() -> Array[String]:
	var failures: Array[String] = []
	var sim = DemoState.new()
	if not sim.resources_conserved():
		failures.append("Initial wood resources are inconsistent")
	var first_hp: int = sim.enemy_hp
	for i in range(600):
		sim.advance(0.1)
		if not sim.resources_conserved():
			failures.append("Wood duplicated/lost at tick %d" % i)
			break
	if not sim.building_complete:
		failures.append("Worker never finished building after three deliveries")
	if sim.storage_wood != 0 or sim.delivered_wood != 3 or sim.carried_wood != 0:
		failures.append("Final resource ledger is incorrect")
	if sim.worker_state != "idle":
		failures.append("Worker should idle after finishing construction")
	if sim.enemy_hits < 1 or sim.expedition_loot < 1:
		failures.append("Cave sandbox combat did not advance during village simulation")
	if first_hp == sim.enemy_hp and sim.enemy_hits == 0:
		failures.append("Cave sandbox had no autonomous activity")
	var after: int = sim.delivered_wood
	sim.advance(15.0)
	if sim.delivered_wood != after or not sim.resources_conserved():
		failures.append("Finished building created extra material")
	var activity := DemoState.new()
	var seen: Dictionary = {}
	for j in range(800):
		seen[activity.worker_state] = true
		activity.advance(0.05)
		if not activity.resources_conserved():
			failures.append("Lost resources during activity")
			break
	for state in ["gather","deliver","build","return","idle"]:
		if not seen.has(state):
			failures.append("Worker never entered real activity: "+state)
	return failures
