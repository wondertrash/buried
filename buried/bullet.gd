extends Area2D
@export var speed: float = 225
var direction: Vector2 = Vector2.ZERO
func _ready():
	monitoring = true
	connect("body_entered", Callable(self, "_on_body_entered"))
func _process(delta):
	position += direction * speed * delta
	if not get_viewport_rect().has_point(global_position):
		queue_free()
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Wall"):
		queue_free()
	elif body.is_in_group("Enemy"):
		if body.has_method("take_damage"):
			body.take_damage(1)
		else:
			body.queue_free()
		queue_free()
