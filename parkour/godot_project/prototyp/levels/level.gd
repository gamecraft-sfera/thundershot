class_name Level extends Node3D

@export_multiline var puzzle_text: String = ""

@export var author: String = "Pan Tau"

@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer
@onready var character: Player = %Character
@onready var author_name: Label = %AuthorName

var levels_list: Control



var player_original_position: Vector3


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#levels_list.visible = false
	audio_stream_player.play()
	GameManager.final_text = puzzle_text
	player_original_position = character.global_position
	author_name.text = author
	
func _physics_process(_delta: float) -> void:
	if character.global_position.y < -25.0:
		character.global_position = player_original_position
		
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("levels"):
		if levels_list:
			levels_list.visible = not levels_list.visible
			if levels_list.visible:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				#get_tree().paused = false
			else:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			levels_list = load("uid://d3yo104xfw1br").instantiate()
			$LevelUI.add_child(levels_list)
			levels_list.visible = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
		
