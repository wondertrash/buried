extends Node
@export var mob_scene: PackedScene
@export var spawn_points: Array[NodePath] = []
@export var mobs_per_wave: int = 10
@export var mob_increase: int = 5
var current_wave: int = 0
var active_enemies: Array = []
@onready var wave_timer: Timer = Timer.new()
var waves = [
	{"count": 5, "delay": 1.0},
	{"count": 10, "delay": 0.5},
	{"count": 15, "delay": 0.3},
	{"count": 20, "delay": 0.5},
	{"count": 10, "delay": 0.35},
	{"count": 5, "delay": 0.25},
	{"count": 10, "delay": 1.0},
	{"count": 5, "delay": 0.07}
]
func _ready():
	wave_timer = Timer.new()
	wave_timer.one_shot = true
	add_child(wave_timer)
	wave_timer.timeout.connect(_spawn_wave)
	start_waves()
func start_waves():
	current_wave = 0
	_spawn_wave()
func _spawn_wave():
	if current_wave >= waves.size():
		var win = get_tree().current_scene.get_node("GameManager/YouWin")
		if win:
			win.process_mode = Node.PROCESS_MODE_ALWAYS
			win.visible = true
			get_tree().paused = true
			$winAudio.play()
		return
	var wave_data = waves[current_wave]
	current_wave += 1
	var wave_size = wave_data["count"]
	var spawn_delay = wave_data["delay"]
	for i in range(wave_size):
		var t = get_tree().create_timer(i * spawn_delay)
		t.timeout.connect(_spawn_mob)
func _spawn_mob():
	if mob_scene == null or spawn_points.is_empty():
		return
	var spawn_point = get_node(spawn_points.pick_random())
	var mob = mob_scene.instantiate()
	mob.global_position = spawn_point.global_position
	match spawn_point.name:
		"topL":
			mob.direction = Vector2.DOWN
		"topR":
			mob.direction = Vector2.DOWN
		"rightU":
			mob.direction = Vector2.LEFT
		"rightD":
			mob.direction = Vector2.LEFT
		"downL":
			mob.direction = Vector2.UP
		"downR":
			mob.direction = Vector2.UP
		"leftU":
			mob.direction = Vector2.RIGHT
		"leftD":
			mob.direction = Vector2.RIGHT
	mob.move_speed *= pow(1.25, current_wave - 1)
	mob.move_speed = min(mob.move_speed, 64)
	get_tree().current_scene.add_child(mob)
	active_enemies.append(mob)
	var weak = weakref(mob)
	mob.tree_exited.connect(func():
		if weak.get_ref():
			active_enemies.erase(weak.get_ref())
		else:
			active_enemies.erase(mob)
		if active_enemies.is_empty():
			call_deferred("_on_wave_cleared")
	)
func _on_wave_cleared():
	wave_timer.start(0.35)
func _exit_tree() -> void:
	for child in get_tree().root.get_children():
		if child is Timer and not child.is_inside_tree():
			child.queue_free()
	active_enemies.clear()
