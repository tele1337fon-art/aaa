extends SceneTree

const Farm = preload("res://scripts/farm.gd")

func _initialize() -> void:
	var farm = Farm.new()
	assert(farm.plant(0))
	assert(not farm.harvest(0))
	farm.advance(8)
	assert(farm.harvest(0))
	assert(farm.coins == 25 and farm.harvests == 1)
	assert(not farm.buy_field())
	farm.coins = 130
	assert(farm.buy_field())
	assert(farm.plots.size() == 3 and farm.coins == 100)
	assert(farm.buy_automation())
	farm.advance(80)
	assert(farm.coins == 150 and farm.harvests == 31)
	farm.selected = 1
	farm.advance(8)
	assert(farm.plots[0].crop == 1)
	farm.save_game("user://test_farm.json")
	var restored = Farm.new()
	restored.load_game("user://test_farm.json")
	assert(restored.coins == farm.coins)
	assert(restored.automatic and restored.plots.size() == 3)
	var capped = Farm.new()
	capped.automatic = true
	capped.advance(999999)
	assert(capped.coins == 36020)
	DirAccess.remove_absolute("user://test_farm.json")
	print("PASS: growth, harvest, purchases, automation, crop switching, save/load, offline cap")
	quit()
