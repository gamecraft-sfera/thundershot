class_name Level extends Node3D

@export_multiline var puzzle_text: String = ""

@export var author: String = "Pan Tau"

@export var names: Array[Label]

@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer
@onready var character: Player = %Character
@onready var author_name: Label = %AuthorName

var pocet_pokusu: int = 1
var celkovy_cas: float = 0.0

var new_score_index: int = 10

var top_ten_players: Array[PlayerScore] = []

var levels_list: Control

var _is_finished: bool = false



var player_original_position: Vector3


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#levels_list.visible = false
	load_values()
	_nastav_min_napisy()
	
	audio_stream_player.play()
	GameManager.final_text = puzzle_text
	player_original_position = character.global_position
	author_name.text = author
	%NextLevelPortal.on_finish.connect(_on_finish)
	%WinPanel.on_name_entered.connect(name_entered)

func load_values():
	var file = FileAccess.open("user://save.dat", FileAccess.READ)
	print(file.get_path_absolute())
	if file:
		var pocet: int = file.get_32()
		
		for i in pocet:
			var score : PlayerScore = PlayerScore.new()
			score.pocet_pokusu = file.get_32()
			score.celkovy_cas = file.get_float()
			score.autor = file.get_pascal_string()
			top_ten_players.append(score)
			
		file.close()
 
	_nastav_min_napisy()
	
func save_values():
	var file = FileAccess.open("user://save.dat", FileAccess.WRITE)
 
	file.store_32(top_ten_players.size())      # save int
	
	for score in top_ten_players:
		file.store_32(score.pocet_pokusu)
		file.store_float(score.celkovy_cas) # save float
		file.store_pascal_string(score.autor)
		
	file.close()

func _nastav_min_napisy():
	if not top_ten_players.is_empty():
		$LevelUI/Nejlepsipokus/Pokus/Label.text = str(top_ten_players[0].pocet_pokusu)
		$LevelUI/Nejlepsipokus/Cas/Label.text = String.num(top_ten_players[0].celkovy_cas, 0) + "s"
		%JmenoLabel.text = top_ten_players[0].autor
		
		for i in top_ten_players.size():
			names[i].text = str(i+1) + ". " + top_ten_players[i].autor + " " + str(top_ten_players[i].celkovy_cas) + " " + str(top_ten_players[i].pocet_pokusu)
			if i >= 9:
				break
	
func name_entered():
	var new_record: PlayerScore = PlayerScore.new()
	new_record.autor = %WinPanel.author_name
	new_record.celkovy_cas = celkovy_cas
	new_record.pocet_pokusu = pocet_pokusu
	top_ten_players.insert(new_score_index, new_record)
	
	%WinPanel.visible = false
	%Leaderboard.visible = true
	
	save_values()
	_nastav_min_napisy()

func _on_finish() -> void:
	_is_finished = true
	$LevelUI/TryAgainButton.visible = true
	
	for i in top_ten_players.size():
		if celkovy_cas < top_ten_players[i].celkovy_cas:
			new_score_index = i
			%WinPanel.visible = true
			return 
			
	if top_ten_players.size() < 10:
		new_score_index = top_ten_players.size()
		%WinPanel.visible = true
		

func _physics_process(delta: float) -> void:
	if not _is_finished:
		celkovy_cas += delta
	
	%Cas.text = String.num(celkovy_cas, 0) + "s"
	if character.global_position.y < -25.0:
		pocet_pokusu += 1
		%PocetPokusu.text = str(pocet_pokusu)
		character.global_position = player_original_position
		
func _input(_event: InputEvent) -> void:
	return
		
		


func _on_reset_button_pressed() -> void:
	top_ten_players.clear()
	save_values()
	_nastav_min_napisy()


func _on_hide_leaderboard_button_pressed() -> void:
	%Leaderboard.visible = false


func _on_try_again_button_pressed() -> void:
	get_tree().reload_current_scene()
