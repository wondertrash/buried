class_name Player extends CharacterBody2D
var move_speed: float = 88.0
var direction: Vector2 = Vector2.ZERO
var state: String = "idle"
var attacking: bool = false
var cardinal_direction: Vector2 = Vector2.DOWN
var fire_timer: float = 0.5
var shoot_dir: Vector2 = Vector2.ZERO
@onready var legs_anim: AnimationPlayer = $Legs/AnimationPlayer
@onready var upper_body_anim: AnimationPlayer = $UpperBody/AnimationPlayer
@onready var bullet_scene = preload("res://bullet.tscn")
@export var fire_rate: float = 0.5
var speed_multiplier: float = 1.0
var default_speed: float = 88.0
var shoot_cooldown: float = 0.5
var default_cooldown: float = 0.5
var shotgun_enabled: bool = false
var smoke_scene = preload("res://smoke.tscn")
var is_dead := false
func _process(delta):
	direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	if direction != Vector2.ZERO:
		direction = direction.normalized()
	if direction != Vector2.ZERO:
		if abs(direction.x) > abs(direction.y):
			cardinal_direction = Vector2.RIGHT if direction.x > 0 else Vector2.LEFT
		else:
			cardinal_direction = Vector2.DOWN if direction.y > 0 else Vector2.UP
	if direction == Vector2.ZERO:
		legs_anim.play("idle_down")
	else:
		if abs(direction.x) > abs(direction.y):
			legs_anim.play("walk_left" if direction.x < 0 else "walk_right")
		else:
			legs_anim.play("walk_down" if direction.y > 0 else "walk_up")
	if Input.is_action_pressed("attack_up"):
		upper_body_anim.play("attack_up")
	elif Input.is_action_pressed("attack_right"):
		upper_body_anim.play("attack_right")
	elif Input.is_action_pressed("attack_down"):
		upper_body_anim.play("attack_down")
	elif Input.is_action_pressed("attack_left"):
		upper_body_anim.play("attack_left")
	else:
		if direction == Vector2.ZERO:
			upper_body_anim.play("idle_down")
		else:
			if abs(direction.x) > abs(direction.y):
				upper_body_anim.play("walk_left" if direction.x < 0 else "walk_right")
			else:
				upper_body_anim.play("walk_down" if direction.y > 0 else "walk_up")
	var dir = Vector2.ZERO
	if Input.is_action_pressed("ui_up"):
		dir.y -= 1
	if Input.is_action_pressed("ui_right"):
		dir.x += 1
	if Input.is_action_pressed("ui_down"):
		dir.y += 1
	if Input.is_action_pressed("ui_left"):
		dir.x -= 1
	shoot_dir = dir.normalized()
	if shoot_dir != Vector2.ZERO:
		handle_shooting(delta)
func _physics_process(_delta):
	velocity = direction * default_speed * speed_multiplier
	move_and_slide()
func HandleAttack() -> bool:
	if Input.is_action_pressed("attack_up"):
		upper_body_anim.play("attack_up")
		return true
	elif Input.is_action_pressed("attack_right"):
		upper_body_anim.play("attack_right")
		return true
	elif Input.is_action_pressed("attack_down"):
		upper_body_anim.play("attack_down")
		return true
	elif Input.is_action_pressed("attack_left"):
		upper_body_anim.play("attack_left")
		return true
	return false
func handle_shooting(delta):
	fire_timer -= delta
	if fire_timer <= 0:
		shoot(shoot_dir)
		fire_timer = shoot_cooldown
func shoot(direction: Vector2):
	if shotgun_enabled:
		_spawn_bullet(direction.rotated(deg_to_rad(-12)))
		_spawn_bullet(direction)
		_spawn_bullet(direction.rotated(deg_to_rad(12)))
	else:
		_spawn_bullet(direction)
func _spawn_bullet(direction: Vector2):
	var bullet = bullet_scene.instantiate()
	var spawn_pos = position + direction * 8
	var offset = Vector2(0, -8)
	bullet.position = spawn_pos + offset
	bullet.direction = direction.normalized()
	get_parent().add_child(bullet)
	$shootAudio.play()
func apply_powerup(type: String) -> void:
	match type:
		"machine_gun":
			$powerupAudio.play()
			shoot_cooldown = 0.1
			_reset_after_time("machine_gun", 12.0)
		"nuke":
			$nukeAudio.play()
			for enemy in get_tree().get_nodes_in_group("Enemy"):
				if enemy.has_method("die"):
					enemy.die()
			for i in range(64):
				var delay := randf_range(0.0, 1.0)
				var timer := get_tree().create_timer(delay)
				timer.timeout.connect(spawn_smoke)
		"coffee":
			$powerupAudio.play()
			speed_multiplier = 1.8
			_reset_after_time("coffee", 16.0)
		"shotgun":
			$powerupAudio.play()
			shotgun_enabled = true
			shoot_cooldown = 0.8
			_reset_after_time("shotgun", 12.0)
func _reset_after_time(type: String, duration: float) -> void:
	var t = Timer.new()
	t.wait_time = duration
	t.one_shot = true
	add_child(t)
	t.start()
	t.timeout.connect(func():
		match type:
			"coffee":
				speed_multiplier = 1.0
			"machine_gun":
				shoot_cooldown = default_cooldown
			"shotgun":
				shotgun_enabled = false
				shoot_cooldown = default_cooldown
		t.queue_free())
func spawn_smoke() -> void:
	var smoke = smoke_scene.instantiate()
	var map_size = Vector2(384, 384)
	var map_offset = Vector2(-128, -96)
	var pos = map_offset + Vector2(randf() * map_size.x, randf() * map_size.y)
	smoke.global_position = pos
	get_tree().current_scene.add_child(smoke)
func die():
	if is_dead:
		return
	is_dead = true
	var game_over = get_tree().current_scene.get_node("GameManager/GameOver")
	if game_over:
		game_over.process_mode = Node.PROCESS_MODE_ALWAYS
		game_over.visible = true
	get_tree().paused = true
	$gameOverAudio.play()
