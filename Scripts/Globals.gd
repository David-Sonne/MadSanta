extends Node

#State enum
const PLAYING = "PLAYING"
const TEXT = "TEXT"
const PAUSED = "PAUSED"
const MAIN_MENU = "MAIN_MENU"
const LEVEL_SELECTION = "LEVEL_SELECTION"
const CREDITS = "CREDITS"
const FINISH_MENU = "FINISH_MENU"
const SETTINGS = "SETTINGS"
const COLLECT_SCREEN = "COLLECT_SCREEN"

enum CHEST_ITEMS { 
	SNOWBALL, #0
	ICICLE, #1
	#A, #1
	#B, #2
	#C, #3
}

#Debug 
const debug_mode = false
const skip_intro_text = false
const start_with_all_items = false

#Global constants
const levels = [preload("res://Scenes/level_1.tscn"), preload("res://Scenes/level_2.tscn")]

#Global variables
var fullscreen = false
var state = MAIN_MENU
var player: RigidBody2D = null
var level: Node2D = null
var level_buttons = []
var current_level = 1
var enemies_in_level = 0
var enemies_killed = 0
var previousMenu = ""

#Savable data
var unlocked_level = 1
var collected_items = []
var selected_weapon = null
var level1_played = false

@onready var collect_screen = get_node("/root/Main/UI/CollectScreen")
@onready var ui: UI = get_node("/root/Main/UI")

func _ready() -> void:
	if start_with_all_items:
		await timer(0.1)
		for chest_item in CHEST_ITEMS.values():
			collect_item(chest_item)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause") && Globals.state == Globals.PLAYING:
		change_scenes(Globals.PAUSED)
		get_tree().paused = true
	if Input.is_action_just_pressed("ESC"):
		get_tree().quit()
	if Input.is_action_just_pressed("F11"):
		fullscreen = !fullscreen
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)

func item_to_id(item: CHEST_ITEMS) -> int:
	return item
	#if item == CHEST_ITEMS.SNOWBALL: return 0
	#elif item == CHEST_ITEMS.ICICLE: return 1
	#else:
		#print("Item/Waffe ", item, " konnte nicht gefunden werden!!!")
		#return -1

func id_to_item(id: int):
	return id
	#if id == 0: return CHEST_ITEMS.SNOWBALL
	#elif id == 1: return CHEST_ITEMS.ICICLE
	#else:
		#print("ID ", id, " gehört keinem Item!!!")
		#return null

func isPaused() -> bool:
	return state != PLAYING

func update_level_buttons():
	for level_button in level_buttons:
		level_button.disabled = unlocked_level < level_button.level_number or level_button.level_number > levels.size()

func timer(seconds: float):
	return get_tree().create_timer(seconds).timeout

func start_level(level_scene: PackedScene):
	ui.start_level(level_scene)

func change_scenes(scene: String):
	ui.change_scenes(scene)

func finish_level():
	if current_level == unlocked_level:
		unlocked_level += 1
		#save data

func delete_level():
	ui.delete_level()

func collect_item(item: CHEST_ITEMS):
	collected_items.append(item)
	selected_weapon = item
	get_node("/root/Main/UI/WeaponSelection").add_selectable_weapon(item)
