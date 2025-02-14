extends Control

func _on_back_pressed() -> void:
	var scene = Globals.MAIN_MENU if Globals.previousMenu != Globals.PAUSED else Globals.PAUSED
	Globals.previousMenu = ""
	get_parent().change_scenes(scene)
