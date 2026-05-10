extends Node2D

var map_node

var build_mode = false
var build_valid = false
var build_tile
var build_location
var build_type

func _ready():
	map_node = get_node("Map1")
	for i in get_tree().get_nodes_in_group("build_buttons"):
		i.pressed.connect(func(): initiate_build_mode(i.name))

func  _process(delta):
	if build_mode:
		update_towerPreview()

func _unhandled_input(event):
	if event.is_action_released("ui_cancel") and build_mode:
		cancel_build_mode()

	if event.is_action_released("ui_accept") and build_mode:
		verify_and_build()
		cancel_build_mode()

func initiate_build_mode(tower_type):
	if build_mode:
		cancel_build_mode() 
	build_type = tower_type + "T1" 
	build_mode = true
	get_node("UI").set_tower_preview(build_type, get_global_mouse_position())

func update_towerPreview():
	var mouse_position = get_global_mouse_position()
	var current_tile = map_node.get_node("TowerExclusion").local_to_map(mouse_position)
	var tile_position = map_node.get_node("TowerExclusion").map_to_local(current_tile)
	
	if map_node.get_node("TowerExclusion").get_cell_source_id(current_tile) == -1:
		get_node("UI").update_towerPreview(tile_position, "adff459a")
		build_valid = true
		build_location = tile_position
		build_tile = current_tile
	else:
		get_node("UI").update_towerPreview(tile_position, "ff00009a")
		build_valid = false

func cancel_build_mode():
	build_mode = false
	build_valid = false
	get_node("UI/TowerPreview").free()

func verify_and_build():
	if build_valid:
		# test for cash available
		var new_tower = load("res://Scenes/Turrets/" + build_type + ".tscn").instantiate()
		new_tower.position = build_location
		map_node.get_node("Turrets").add_child(new_tower, true)
		map_node.get_node("TowerExclusion").set_cell(build_tile, 5, Vector2i(0, 0))
		#deduct cash
		#update cash label
	
