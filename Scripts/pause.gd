extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass #$Background/SildeCam.position.x += 1 # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_resume_pressed() -> void:
	get_tree().paused = false
	get_parent().change_scenes(Globals.PLAYING)

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_parent().play_again()


func _on_options_pressed() -> void:
	get_parent().change_scenes(Globals.SETTINGS)
	pass

func _on_exit_level_pressed() -> void:
	get_tree().paused = false
	get_parent().change_scenes(Globals.MAIN_MENU) 


func _on_quit_game_pressed() -> void:
	get_tree().quit()
