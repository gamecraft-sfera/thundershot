class_name Level extends Node3D

@export_multiline var puzzle_text: String = ""

@export var author: String = "Pan Tau"

@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer
@onready var character: Player = %Character
@onready var author_name: Label = %AuthorName

var pocet_pokusu: int = 1
var celkovy_cas: float = 0.0

var min_pocet_pokusu: int = 99999
var min_celkovy_cas: float = 99999

var levels_list: Control



var player_original_position: Vector3


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#levels_list.visible = false
	load_values()
	
	audio_stream_player.play()
	GameManager.final_text = puzzle_text
	player_original_position = character.global_position
	author_name.text = author
	%NextLevelPortal.on_finish.connect(_on_finish)

func load_values():
	var file = FileAccess.open("user://save.dat", FileAccess.READ)
	print(file.get_path_absolute())
	if file:
		min_pocet_pokusu = file.get_32()
		min_celkovy_cas = file.get_float()
		file.close()
		print("min pokusu: ", min_pocet_pokusu)
		print("min cas:", min_celkovy_cas)
 
	_nastav_min_napisy()
	
func save_values():
	var file = FileAccess.open("user://save.dat", FileAccess.WRITE)
 
	file.store_32(min_pocet_pokusu)      # save int
	file.store_float(min_celkovy_cas) # save float
	file.close()

func _nastav_min_napisy():
	$LevelUI/Nejlepsipokus/Pokus/Label.text = str(min_pocet_pokusu)
	$LevelUI/Nejlepsipokus/Cas/Label.text = String.num(min_celkovy_cas, 0) + "s"
	
	
func _on_finish() -> void:
	if pocet_pokusu < min_pocet_pokusu:
		min_pocet_pokusu = pocet_pokusu
	if celkovy_cas < min_celkovy_cas:
		min_celkovy_cas = celkovy_cas
		
	save_values()
		
	_nastav_min_napisy()
	

func _physics_process(delta: float) -> void:
	celkovy_cas += delta
	
	%Cas.text = String.num(celkovy_cas, 0) + "s"
	if character.global_position.y < -25.0:
		pocet_pokusu += 1
		%PocetPokusu.text = str(pocet_pokusu)
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
		
		


func _on_reset_button_pressed() -> void:
	min_pocet_pokusu = 99999
	min_celkovy_cas = 99999
	save_values()
	_nastav_min_napisy()
