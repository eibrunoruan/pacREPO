extends Control

func _on_timer_timeout():
	# Esta linha carrega a cena do menu principal.
	get_tree().change_scene_to_file("res://Assets/Scenes/Menu/main_menu.tscn")
