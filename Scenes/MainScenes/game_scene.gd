extends Node2D

signal game_finished(result)

var map_node
var game_ended = false

var build_mode = false
var build_valid = false
var build_tile
var build_location
var build_type

var current_wave = 0
var enemies_in_wave = 0

var base_health = 100
var cash = 100
var enemy_reward = 20

var selected_turret = null

func _ready():
	map_node = get_node("Map1")
	get_node("UI").update_cash_label(cash)

	for i in get_tree().get_nodes_in_group("build_buttons"):
		i.pressed.connect(func(): initiate_build_mode(i.name))

func _process(delta):
	if build_mode:
		update_towerPreview()

func select_turret_at_mouse():
	var mouse_pos = get_global_mouse_position()
	var turrets_node = map_node.get_node("Turrets")

	for turret in turrets_node.get_children():
		if turret.global_position.distance_to(mouse_pos) < 40:
			print("Selected turret: ", turret.name)
			selected_turret = turret
			get_node("UI").show_turret_options(turret)
			return

	print("No turret selected")
	get_node("UI").hide_turret_options()
	selected_turret = null

func _input(event):
	if event.is_action_released("ui_cancel") and build_mode:
		cancel_build_mode()
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			# Building has priority
			if build_mode:
				print("Trying to build")
				print("build_valid: ", build_valid)

				verify_and_build()
				cancel_build_mode()
				return

			# Do not deselect turret when clicking upgrade UI
			if get_node("UI").is_mouse_over_turret_options():
				return

			select_turret_at_mouse()
## Waves
func start_next_wave():
	var wave_data = retrieve_wave_data()
	await get_tree().create_timer(0.2).timeout
	spawn_enemies(wave_data)

func retrieve_wave_data():
	var wave_data = [["enemy_tank", 1.0],["enemy_tank", 1.0],["enemy_tank", 1.0],["enemy_tank", 1.0],["enemy_tank", 1.0],["enemy_tank", 1.0]]
	current_wave += 1
	enemies_in_wave = wave_data.size()
	return wave_data

func spawn_enemies(wave_data):
	for i in wave_data:
		var new_enemy = load("res://Scenes/Enemies/" + i[0] + ".tscn").instantiate()
		new_enemy.base_damage.connect(on_base_damage)
		new_enemy.enemy_destroyed.connect(on_enemy_destroyed)
		map_node.get_node("Path2D").add_child(new_enemy, true)
		await get_tree().create_timer(i[1]).timeout

func on_enemy_destroyed(give_reward = false):
	if game_ended:
		return
	
	if give_reward:
		cash += enemy_reward
		get_node("UI").update_cash_label(cash)
		
	enemies_in_wave -= 1

	if enemies_in_wave <= 0:
		game_ended = true
		game_finished.emit(true)


func on_base_damage(damage):
	if game_ended:
		return

	base_health -= damage

	if base_health <= 0:
		game_ended = true
		game_finished.emit(false)
	else:
		get_node("UI").update_health_bar(base_health)

## Building
func initiate_build_mode(tower_type):
	var selected_build_type = tower_type + "T1"
	var tower_cost = GameData.tower_data[selected_build_type]["cost"]

	if cash < tower_cost:
		print("Not enough cash")
		return

	if build_mode:
		cancel_build_mode()

	selected_turret = null
	get_node("UI").hide_turret_options()

	build_type = selected_build_type
	build_mode = true

	get_node("UI").set_tower_preview(build_type, get_global_mouse_position())

func update_towerPreview():
	var tower_exclusion = map_node.get_node("TowerExclusion")

	var mouse_global_position = get_global_mouse_position()
	var mouse_local_position = tower_exclusion.to_local(mouse_global_position)

	var current_tile = tower_exclusion.local_to_map(mouse_local_position)
	var tile_local_position = tower_exclusion.map_to_local(current_tile)
	var tile_global_position = tower_exclusion.to_global(tile_local_position)

	if tower_exclusion.get_cell_source_id(current_tile) == -1:
		get_node("UI").update_towerPreview(tile_global_position, "adff459a")
		build_valid = true
		build_location = tile_global_position
		build_tile = current_tile
	else:
		get_node("UI").update_towerPreview(tile_global_position, "ff00009a")
		build_valid = false

func cancel_build_mode():
	build_mode = false
	build_valid = false

	var preview = get_node_or_null("UI/TowerPreview")
	if preview:
		preview.queue_free()

func verify_and_build():
	if not build_valid:
		print("Cannot build here")
		return

	var tower_cost = GameData.tower_data[build_type]["cost"]

	if cash < tower_cost:
		print("Not enough cash")
		return

	cash -= tower_cost
	get_node("UI").update_cash_label(cash)

	var turrets_node = map_node.get_node("Turrets")
	var tower_exclusion = map_node.get_node("TowerExclusion")

	var new_tower = load("res://Scenes/Turrets/" + build_type + ".tscn").instantiate()

	new_tower.position = turrets_node.to_local(build_location)
	new_tower.built = true
	new_tower.type = build_type
	new_tower.ammo = GameData.tower_data[build_type]["ammo"]

	turrets_node.add_child(new_tower, true)

	tower_exclusion.set_cell(build_tile, 5, Vector2i(0, 0))
	
func upgrade_selected_turret():
	if selected_turret == null:
		print("No selected turret")
		return

	var next_type = GameData.tower_data[selected_turret.type]["upgrade"]

	if next_type == "":
		print("Max level")
		return

	var upgrade_cost = GameData.tower_data[selected_turret.type]["cost"]

	if cash < upgrade_cost:
		print("Not enough cash")
		return

	cash -= upgrade_cost
	get_node("UI").update_cash_label(cash)

	selected_turret.upgrade()
	get_node("UI").show_turret_options(selected_turret)

	print("Turret upgraded to: ", selected_turret.type)
