extends Control

const Farm = preload("res://scripts/farm.gd")
var farm = Farm.new()
var balance: Label
var status: Label
var field_button: Button
var auto_button: Button
var grid: GridContainer
var crop_buttons: Array[Button] = []
var plot_buttons: Array[Button] = []
var save_elapsed := 0.0
var refresh_elapsed := 0.0

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("edf2df"))
	farm.load_game()
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 20)
	add_child(margin)
	var scroll := ScrollContainer.new()
	margin.add_child(scroll)
	var body := VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 16)
	scroll.add_child(body)
	var theme_resource := Theme.new()
	theme_resource.default_font_size = 18
	theme_resource.set_color("font_color", "Label", Color("294b37"))
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("3d694d") if state != "disabled" else Color("8c9d87")
		if state == "hover":
			style.bg_color = Color("507d57")
		for corner in ["top_left", "top_right", "bottom_left", "bottom_right"]:
			style.set("corner_radius_" + corner, 12)
		style.content_margin_left = 12
		style.content_margin_right = 12
		style.content_margin_top = 12
		style.content_margin_bottom = 12
		if state == "focus":
			style.bg_color = Color.TRANSPARENT
			style.set_border_width_all(3)
			style.border_color = Color("e6b955")
		theme_resource.set_stylebox(state, "Button", style)
	body.theme = theme_resource
	label(body, "WIESENZEIT", 36)
	label(body, "Deine kleine Farm. Ein bisschen jeden Tag.", 16)
	balance = label(body, "", 28)
	label(body, "1 · Wähle deine nächste Saat", 19)
	var row := HBoxContainer.new()
	body.add_child(row)
	for i in Farm.CROPS.size():
		var crop: Dictionary = Farm.CROPS[i]
		var button := Button.new()
		button.text = "%s\n%ds · %d Münzen" % [crop.name, crop.seconds, crop.value]
		button.add_theme_font_size_override("font_size", 15)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(func(): farm.selected = i; farm.save_game(); refresh())
		row.add_child(button)
		crop_buttons.append(button)
	label(body, "2 · Tippe zum Pflanzen und Ernten", 19)
	grid = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	body.add_child(grid)
	label(body, "Deine Farm wächst", 23)
	field_button = Button.new()
	field_button.pressed.connect(func(): farm.buy_field(); farm.save_game(); refresh())
	body.add_child(field_button)
	auto_button = Button.new()
	auto_button.pressed.connect(func(): farm.buy_automation(); farm.save_game(); refresh())
	body.add_child(auto_button)
	status = label(body, "", 16)
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label(body, "Automatisch gespeichert · Offline-Ertrag bis 8 Stunden\nOhne Werbung. Ohne Käufe. Einfach wachsen lassen.", 14)
	if farm.offline_coins > 0:
		status.text = "Willkommen zurück! Deine Farm hat %d Münzen verdient." % farm.offline_coins
	else:
		status.text = "Saat ist kostenlos. Mit 100 Münzen übernimmt die Erntehilfe das Pflanzen und Ernten."
	refresh()

func label(parent: Node, text: String, size: int) -> Label:
	var node := Label.new()
	node.text = text
	node.add_theme_font_size_override("font_size", size)
	parent.add_child(node)
	return node

func refresh() -> void:
	balance.text = "%d Münzen  ·  %d Ernten" % [farm.coins, farm.harvests]
	for i in crop_buttons.size():
		crop_buttons[i].modulate = Color("f3d88b") if farm.selected == i else Color.WHITE
	while plot_buttons.size() < farm.plots.size():
		var i := plot_buttons.size()
		var button := Button.new()
		button.custom_minimum_size = Vector2(0, 112)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(func():
			if not farm.harvest(i):
				farm.plant(i)
			farm.save_game()
			refresh())
		grid.add_child(button)
		plot_buttons.append(button)
	for i in farm.plots.size():
		var plot: Dictionary = farm.plots[i]
		if plot.crop < 0:
			plot_buttons[i].text = "Feld %d\n+ Pflanzen" % (i + 1)
			plot_buttons[i].modulate = Color.WHITE
		else:
			var crop: Dictionary = Farm.CROPS[plot.crop]
			plot_buttons[i].text = "%s\n%s" % [crop.name, "Ernten! +%d" % crop.value if plot.remaining <= 0 else "Wächst · %ds" % ceili(plot.remaining)]
			plot_buttons[i].modulate = crop.color if plot.remaining <= 0 else Color("c8dfb4")
	field_button.text = "Neues Feld · %d Münzen" % farm.field_cost() if farm.plots.size() < 12 else "Alle 12 Felder freigeschaltet"
	field_button.disabled = farm.plots.size() >= 12 or farm.coins < farm.field_cost()
	auto_button.text = "Erntehilfe aktiv" if farm.automatic else "Erntehilfe einstellen · 100 Münzen"
	auto_button.disabled = farm.automatic or farm.coins < 100

func _process(delta: float) -> void:
	farm.advance(delta)
	save_elapsed += delta
	refresh_elapsed += delta
	if refresh_elapsed >= 0.2:
		refresh_elapsed = 0
		refresh()
	if save_elapsed >= 5:
		save_elapsed = 0
		farm.save_game()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		farm.save_game()
