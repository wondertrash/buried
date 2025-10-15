extends Node2D
@export var powerup_scenes: Array[PackedScene]
@export var spawn_interval: float = 8.0
@export var max_powerups: int = 3
var rng := RandomNumberGenerator.new()
var active_powerups: Array = []
func _ready() -> void:
	var timer := Timer.new()
	timer.wait_time = spawn_interval
	timer.one_shot = false
	timer.autostart = true
	add_child(timer)
	timer.timeout.connect(_on_spawn_timer_timeout)
func _on_spawn_timer_timeout() -> void:
	if active_powerups.size() >= max_powerups:
		return
	if powerup_scenes.is_empty():
		return
	var scene: PackedScene = powerup_scenes.pick_random()
	var powerup = scene.instantiate()
	var spawn_pos = Vector2(
		(rng.randi_range(-4, 7) + 0.5) * 16,
		(rng.randi_range(0, 11) + 0.5) * 16
	)
	powerup.position = spawn_pos
	add_child(powerup)
	active_powerups.append(powerup)
	powerup.tree_exited.connect(func():
		active_powerups.erase(powerup))
