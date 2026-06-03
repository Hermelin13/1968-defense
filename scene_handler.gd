extends Node

var current_ui: Node = null
var current_game: Node = null

const MAIN_MENU_SCENE := "res://Scenes/UIScenes/main_menu.tscn"
const GAME_OVER_SCENE := "res://Scenes/UIScenes/game_over.tscn"
const WINNER_SCENE := "res://Scenes/UIScenes/game_win.tscn"
const GAME_SCENE := "res://Scenes/MainScenes/game_scene.tscn"


func _ready():
	load_ui(MAIN_MENU_SCENE)


func load_ui(scene_path: String):
	if current_ui:
		current_ui.queue_free()
		current_ui = null

	current_ui = load(scene_path).instantiate()
	add_child(current_ui)

	connect_ui_buttons(current_ui)


func connect_ui_buttons(ui: Node):
	var new_game_button = ui.get_node_or_null("MC/VBC/NewGame")
	var quit_button = ui.get_node_or_null("MC/VBC/Quit")
	var main_menu_button = ui.get_node_or_null("MC/VBC/MainMenu")

	if new_game_button:
		new_game_button.pressed.connect(on_new_game_pressed)

	if quit_button:
		quit_button.pressed.connect(on_quit_pressed)

	if main_menu_button:
		main_menu_button.pressed.connect(on_main_menu_pressed)


func on_new_game_pressed():
	if current_ui:
		current_ui.queue_free()
		current_ui = null

	current_game = load(GAME_SCENE).instantiate()
	current_game.name = "GameScene"
	current_game.game_finished.connect(unload_game)
	add_child(current_game)


func on_main_menu_pressed():
	load_ui(MAIN_MENU_SCENE)


func on_quit_pressed():
	get_tree().quit()


func unload_game(result):
	if current_game == null:
		return

	await get_tree().create_timer(2.0).timeout

	if current_game:
		current_game.queue_free()
		current_game = null

	if result:
		load_ui(WINNER_SCENE)
	else:
		load_ui(GAME_OVER_SCENE)
