extends Control
func _on_playagain_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
func _on_quit_pressed() -> void:
	get_tree().quit()
	
