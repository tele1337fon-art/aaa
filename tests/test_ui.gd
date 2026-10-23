extends SceneTree

func _initialize() -> void:
	call_deferred("run_test")

func run_test() -> void:
	var scene = load("res://main.tscn").instantiate()
	# Avoid loading or writing the player's real save.
	var original_path := "user://farm.json"
	var backup := "user://farm.ui-test-backup.json"
	if FileAccess.file_exists(backup):
		push_error("Existing UI test backup found; restore it before testing")
		quit(1)
		return
	var had_save := FileAccess.file_exists(original_path)
	if had_save:
		DirAccess.rename_absolute(original_path, backup)
	root.add_child(scene)
	await process_frame
	assert(scene.plot_buttons.size() == 2)
	scene.crop_buttons[1].pressed.emit()
	scene.plot_buttons[0].pressed.emit()
	assert(scene.farm.plots[0].crop == 1)
	scene.farm.advance(20)
	scene.plot_buttons[0].pressed.emit()
	assert(scene.farm.coins == 35)
	scene.field_button.pressed.emit()
	assert(scene.plot_buttons.size() == 3)
	scene.queue_free()
	await process_frame
	DirAccess.remove_absolute(original_path)
	if had_save:
		DirAccess.rename_absolute(backup, original_path)
	print("PASS: scene startup, crop selection, planting, harvest, field purchase")
	quit()
