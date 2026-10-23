extends RefCounted

const CROPS = [
	{"name": "Karotte", "seconds": 8.0, "value": 5, "color": Color("e89b52")},
	{"name": "Tomate", "seconds": 20.0, "value": 15, "color": Color("df7569")},
	{"name": "Kürbis", "seconds": 45.0, "value": 40, "color": Color("d6b353")}
]
const SAVE_PATH = "user://farm.json"
var coins: int = 20
var harvests: int = 0
var selected: int = 0
var plots: Array = [{"crop": -1, "remaining": 0.0}, {"crop": -1, "remaining": 0.0}]
var automatic: bool = false
var offline_coins: int = 0

func field_cost() -> int:
	return 30 * (plots.size() - 1) * (plots.size() - 1)

func plant(index: int) -> bool:
	if index < 0 or index >= plots.size() or plots[index].crop != -1:
		return false
	plots[index] = {"crop": selected, "remaining": CROPS[selected].seconds}
	return true

func harvest(index: int) -> bool:
	if index < 0 or index >= plots.size():
		return false
	var plot: Dictionary = plots[index]
	if plot.crop < 0 or plot.remaining > 0:
		return false
	coins += CROPS[plot.crop].value
	harvests += 1
	plots[index] = {"crop": -1, "remaining": 0.0}
	return true

func buy_field() -> bool:
	if plots.size() >= 12 or coins < field_cost():
		return false
	coins -= field_cost()
	plots.append({"crop": -1, "remaining": 0.0})
	return true

func buy_automation() -> bool:
	if automatic or coins < 100:
		return false
	coins -= 100
	automatic = true
	return true

func advance(seconds: float) -> void:
	seconds = clampf(seconds, 0, 28800)
	for i in plots.size():
		var plot: Dictionary = plots[i]
		if not automatic:
			if plot.crop >= 0:
				plot.remaining = maxf(0, plot.remaining - seconds)
			continue
		var left: float = seconds
		if plot.crop >= 0:
			if plot.remaining > left:
				plot.remaining -= left
				continue
			left -= plot.remaining
			plot.remaining = 0
			harvest(i)
		plant(i)
		var duration: float = CROPS[selected].seconds
		var cycles := int(left / duration)
		coins += cycles * int(CROPS[selected].value)
		harvests += cycles
		plots[i].remaining = duration - fmod(left, duration)

func save_game(path: String = SAVE_PATH) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({"version": 1, "coins": coins, "harvests": harvests,
			"selected": selected, "plots": plots, "automatic": automatic,
			"saved_at": Time.get_unix_time_from_system()}))

func load_game(path: String = SAVE_PATH) -> void:
	if not FileAccess.file_exists(path):
		return
	var data = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not data is Dictionary or data.get("version") != 1:
		return
	var restored = data.get("plots", [])
	if not restored is Array or restored.size() < 2 or restored.size() > 12:
		return
	var clean: Array = []
	for entry in restored:
		if not entry is Dictionary:
			return
		var crop := clampi(int(entry.get("crop", -1)), -1, CROPS.size() - 1)
		clean.append({"crop": crop, "remaining": clampf(float(entry.get("remaining", 0)), 0, 45)})
	plots = clean
	coins = maxi(0, int(data.get("coins", 20)))
	harvests = maxi(0, int(data.get("harvests", 0)))
	selected = clampi(int(data.get("selected", 0)), 0, CROPS.size() - 1)
	automatic = bool(data.get("automatic", false))
	var before := coins
	advance(Time.get_unix_time_from_system() - float(data.get("saved_at", Time.get_unix_time_from_system())))
	offline_coins = coins - before
