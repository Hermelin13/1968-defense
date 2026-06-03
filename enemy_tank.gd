extends PathFollow2D

signal base_damage(damage)
signal enemy_destroyed

var hp = 50
var speed = 100
var baseDamage = 21

@onready var health_bar = get_node("HealthBar")
@onready var impact_area = get_node("Impact")
var projectile_impact = preload("res://Scenes/SupportScenes/projectile_impact.tscn")

func _ready():
	health_bar.max_value = hp
	health_bar.value = hp
	health_bar.top_level = true

func _physics_process(delta):
	if progress_ratio >= 1.0:
		emit_signal("base_damage", baseDamage)
		enemy_destroyed.emit()
		queue_free()
	move(delta)

func move(delta):
	progress += speed * delta
	health_bar.set_position(position - Vector2(30,30))

func on_hit(damage, hit_type = "Projectile"):
	impact(hit_type)

	hp -= damage
	health_bar.value = hp

	if hp <= 0:
		enemy_destroyed.emit()
		on_destroy()


func impact(hit_type):
	var spread := 10
	var impact_scale := Vector2(0.2, 0.2)

	if hit_type == "Missile":
		spread = 20
		impact_scale = Vector2(1.2, 1.2)

	var x_pos = randi_range(-spread, spread)
	var y_pos = randi_range(-spread, spread)

	var impact_location = Vector2(x_pos, y_pos)
	var new_impact = projectile_impact.instantiate()
	new_impact.position = impact_location
	new_impact.scale = impact_scale
	impact_area.add_child(new_impact)

func on_destroy():
	get_node("CharacterBody2D").queue_free()
	await get_tree().create_timer(0.2).timeout
	self.queue_free()
