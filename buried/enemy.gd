extends CharacterBody2D
@export var move_speed: float = 16.0
@export var tile_size: int = 16
@export var health: int = 1
@onready var player: Node2D = get_tree().current_scene.get_node("Player")
@onready var anim: AnimationPlayer = $AnimationPlayer
var direction: Vector2 = Vector2.ZERO
var target_pos: Vector2
var moving: bool = false
var is_dead := false
var did_spawn_step := false
func _ready() -> void:
	add_to_group("Enemy")
	$Hurtbox.body_entered.connect(_on_body_entered)
	if direction != Vector2.ZERO:
		target_pos = (global_position + direction * tile_size).snapped(Vector2.ONE * tile_size)
		moving = true
func _physics_process(delta: float) -> void:
	if is_dead:
		return
	if moving:
		global_position = global_position.move_toward(target_pos, move_speed * delta)
		if global_position.distance_to(target_pos) < 0.1:
			global_position = target_pos
			moving = false
			if not did_spawn_step and direction != Vector2.ZERO:
				did_spawn_step = true
	elif did_spawn_step and player:
		var diff: Vector2 = player.global_position - global_position
		var dir: Vector2 = Vector2.ZERO
		if abs(diff.x) >= abs(diff.y):
			dir.x = sign(diff.x)
		else:
			dir.y = sign(diff.y)
		target_pos = (global_position + dir * tile_size).snapped(Vector2.ONE * tile_size)
		moving = true
	if moving:
		if not anim.is_playing() or anim.current_animation != "walk":
			anim.play("walk")
	else:
		anim.stop()
func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		die()
func die() -> void:
	$hurtAudio.play()
	if is_dead:
		return
	is_dead = true
	if anim.has_animation("death"):
		anim.play("death")
		z_index = 0
	set_physics_process(false)
	$CollisionShape2D.set_deferred("disabled", true)
	$Hurtbox/CollisionShape2D.set_deferred("disabled", true)
	var timer := get_tree().create_timer(8.0)
	timer.timeout.connect(queue_free)
func _on_death_anim_finished() -> void:
	if anim.has_animation("death"):
		queue_free()
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		body.die()
