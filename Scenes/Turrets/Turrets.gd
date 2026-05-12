extends Node2D

var ammo
var type
var enemy_array = []
var built = false
var enemy
var reloaded = true

func _ready():
	if built:
		self.get_node("Range/CollisionShape2D").get_shape().radius = 0.5 * GameData.tower_data[type]["range"]

func _physics_process(delta):
	if enemy_array.size() != 0 and built:
		select_enemy()
		turn()
		if reloaded:
			fire()
	else:
		enemy = null
	
func turn():
	get_node("Turret").look_at(enemy.position)
	
func fire():
	reloaded = false
	if ammo == "Projectile":
		fire_gun()
	elif ammo == "Missile":
		fire_missile()
	enemy.on_hit(GameData.tower_data[type]["damage"])
	await get_tree().create_timer(GameData.tower_data[type]["reload"]).timeout
	reloaded = true

func fire_gun():
	get_node("AnimationPlayer").play("Fire")

func fire_missile():
	pass
	
func select_enemy():
	var enemy_progress_array = []
	for i in enemy_array:
		enemy_progress_array.append(i.progress)
	var max_progress = enemy_progress_array.max()
	var enemy_index = enemy_progress_array.find(max_progress)
	enemy = enemy_array[enemy_index]

func _on_range_body_entered(body):
	enemy_array.append(body.get_parent())
	print(enemy_array)

func _on_range_body_exited(body):
	enemy_array.erase(body.get_parent())
