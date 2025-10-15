extends Area2D
@export var powerup_type: String = "nuke"
func _ready() -> void:
	body_entered.connect(_on_body_entered)
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		body.apply_powerup(powerup_type)
		queue_free()
