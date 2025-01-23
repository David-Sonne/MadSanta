extends CanvasLayer

var text_visible = false
var text_pointer = 0
var texts_to_show = []
var text_switch_blocked = false

func _ready() -> void:
	$MainMenu.show()
	$LevelSelection.hide()

func _process(delta: float) -> void:
	if Globals.PLAYING:
		$Text/Label.visible_ratio += delta/3
	if Globals.MAIN_MENU:
		$Background/SildeCam.position.x += 1

func start_text_sequence(texts):
	Globals.state = Globals.PAUSED
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
			Globals.state = Globals.PLAYING
			texts_to_show = []
			text_visible = false
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

func change_scenes(sceneName: String) -> void:
	match sceneName:
		Globals.MAIN_MENU:
			$MainMenu.show()
			$LevelSelection.hide()
		Globals.LEVEL_MENU:
			$MainMenu.hide()
			$LevelSelection.show()
		Globals.PLAYING:
			$LevelSelection.hide()
			$Background/SildeCam.enabled = false

func start_level(level_scene: PackedScene):
	var level = level_scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
	get_node("../").add_child(level)
	Globals.level = level
	if level.editor_description == "Level 1":
		intro_text()

func intro_text():
	var intro_text = [
		"Du bist ein Schneemann und deine Schneefrau wurde brutal von\n
		Schrergen des wild gewordenen Weihnachtsmannes getötet.",
		"Deine Mission ist es den Weihnachtsmann und seine fiesen\n
		Machenschaften zu stoppen und dich an ihm zu rächen.",
		"Doch sei gewarnt. Er hat bereits seine Schergen auf dich\n
		angesetzt. Sei also auf der hut!"
	]
	start_text_sequence(intro_text)
