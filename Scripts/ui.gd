class_name UI extends CanvasLayer

var text_visible = false
var text_pointer = 0
var texts_to_show = []
var text_switch_blocked = false

func _ready() -> void:
	change_scenes(Globals.state)
	await Globals.timer(0.01)
	if Globals.state == Globals.PLAYING:
		start_level(preload("res://Scenes/level_1.tscn"))

func _process(delta: float) -> void:
	if Globals.PLAYING:
		$Text/Label.visible_ratio += delta/3
	if Globals.MAIN_MENU:
		$Background/SildeCam.position.x += 1

func start_text_sequence(texts):
	change_scenes(Globals.TEXT)
	text_switch_blocked = false
	texts_to_show = texts
	text_switch_blocked = true
	change_text(texts[0])
	text_switch_blocked = false

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Text"):
		if $Text/Label.visible_ratio < 1.0:
			$Text/Label.visible_ratio = 1
		else: next_text()

func next_text():
	if !text_switch_blocked and !texts_to_show.is_empty():
		text_switch_blocked = true
		if text_pointer == texts_to_show.size()-1:
			$Text/Animation.play_backwards("show_text")
			await Globals.timer(0.85)
			change_scenes(Globals.PLAYING)
			texts_to_show = []
			text_visible = false
			Globals.player.show_healthbar()
			Globals.level1_played = true
			if Globals.level != null:
				Globals.level.zoom_out()
		else:
			text_pointer += 1
			change_text(texts_to_show[text_pointer])
		text_switch_blocked = false

func change_text(text: String):
	if !text_visible:
		text_visible = true
		$Text/Label.text = text
		$Text/Animation.play("show_text")
		$Text/Label.visible_ratio = 0
		await Globals.timer(0.85)
	else:
		$Text/Animation.play("change_text")
		await Globals.timer(0.5)
		$Text/Label.text = text
		$Text/Label.visible_ratio = 0
		await Globals.timer(0.5)

func intro_text():
	Globals.player.hide_healthbar()
	var intro_text = [
		"Du bist ein Schneemann und deine Schneefrau wurde brutal von\n
		Schrergen des wild gewordenen Weihnachtsmannes getötet.",
		"Deine Mission ist es den Weihnachtsmann und seine fiesen\n
		Machenschaften zu stoppen und dich an ihm zu rächen.",
		"Doch sei gewarnt. Er hat bereits seine Schergen auf dich\n
		angesetzt. Sei also auf der hut!"
	]
	start_text_sequence(intro_text)

func change_scenes(sceneName: String) -> void:
	Globals.previousMenu = Globals.state
	$PauseMenu.visible = sceneName == Globals.PAUSED and Globals.state in [Globals.PLAYING, Globals.SETTINGS]
	$MainMenu.visible = sceneName == Globals.MAIN_MENU
	$LevelSelection.visible = sceneName == Globals.LEVEL_SELECTION
	$SettingsMenu.visible = sceneName == Globals.SETTINGS
	$Credits.visible = sceneName == Globals.CREDITS
	var scenes_without_background = [Globals.PLAYING, Globals.FINISH_MENU]
	$Background/SildeCam.enabled = sceneName not in scenes_without_background
	var scenes_with_title = [Globals.MAIN_MENU, Globals.LEVEL_SELECTION, Globals.CREDITS, Globals.FINISH_MENU, Globals.PAUSED, Globals.SETTINGS]
	$Title.visible = sceneName in scenes_with_title
	$WeaponSelection/Animation.play("show" if sceneName == Globals.PLAYING else "hide")
	if sceneName == Globals.MAIN_MENU:
		$Title.text = "Mad Santa"
	if sceneName == Globals.LEVEL_SELECTION:
		$Title.text = "Levelauswahl"
		Globals.update_level_buttons()
	if sceneName == Globals.CREDITS:
		$Title.text = "Credits"
	if sceneName == Globals.SETTINGS:
		$Title.text = "Einstellungen"
	if sceneName == Globals.PAUSED:
		$Title.text = "Pause"
	if sceneName == Globals.FINISH_MENU:
		$Title.text = "Geschafft!"
		$Animations.stop()
		$Animations.play("fade_finish_menu")
		$FinishMenu/MarginContainer/VBoxContainer/NextLevel.visible = Globals.levels.size() > Globals.current_level
		$FinishMenu/EnemiesKilled.text = str(Globals.enemies_killed, " / ", Globals.enemies_in_level)
	else:
		$FinishMenu.hide()
		$FinishMenu.modulate.a = 0
	if sceneName == Globals.COLLECT_SCREEN:
		$Animations.stop()
		$Animations.play("fade_collect_screen")
	else:
		$CollectScreen.hide()
		$CollectScreen.modulate.a = 0
		#TODO might need check for current game state
	if  sceneName in [Globals.MAIN_MENU, Globals.LEVEL_SELECTION] :
		delete_level()
	Globals.state = sceneName

func start_level(level_scene: PackedScene):
	var level = level_scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
	get_node("../").add_child(level)
	Globals.level = level
	Globals.current_level = level.level_number
	Globals.enemies_killed = 0
	Globals.enemies_in_level = level.get_node("Enemies").get_child_count()
	change_scenes(Globals.PLAYING)
	if level.level_number == 1 and !Globals.level1_played and !Globals.skip_intro_text:
		intro_text()
	else:
		await Globals.timer(0.017)
		level.zoom_out()


func next_level():
	delete_level()
	Globals.current_level += 1
	if Globals.levels.size() <= Globals.current_level:
		start_level(Globals.levels[Globals.current_level-1])
	else: change_scenes(Globals.LEVEL_SELECTION)

func play_again():
	delete_level()
	start_level(Globals.levels[Globals.current_level-1])

func delete_level():
	if Globals.level != null:
		Globals.level.queue_free()
		Globals.level = null
