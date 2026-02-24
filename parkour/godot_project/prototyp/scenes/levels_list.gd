extends Control


@export var levels: Array[PackedScene]

@onready var v_box_container: VBoxContainer = %VBoxContainer


var button_scn: PackedScene = preload("uid://bqm1drs3i17qp")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for level in levels:
		var btn: Button = button_scn.instantiate()
		var tmp_lvl: Level = level.instantiate()
		btn.text = tmp_lvl.author
		btn.visible = true
		v_box_container.add_child(btn)
		btn.pressed.connect(_on_btn_clicked.bind(level))


func _on_btn_clicked(scene: PackedScene) -> void:
	get_tree().change_scene_to_packed(scene)
