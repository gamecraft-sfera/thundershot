extends Node3D

@onready var text_label: RichTextLabel = %TextLabel

@export var use_random_color: bool = true

@export_multiline var original_text: String = "[wave amp=40.0 freq=1.0 connected=1]Jdu loukou a duše plane
Však ke mě se naděje [color=red]nedostane[/color]
sdf fg fs dhs gsd hs ghydsh shydhsd hdg dhsdgh sghsgdh sdgh sdghsdg sdg h[/shake]"

var is_animating: bool = false
var marked_word: String = ""
var used: bool = false

func _ready() -> void:
	text_label.visible = false
	text_label.modulate.a = 0.0  # Start fully transparent
	
	# Parse colored word from original_text
	parse_marked_word()

func parse_marked_word():
	var regex = RegEx.new()
	regex.compile("\\[color=[^\\]]+\\]([^\\[]+)\\[/color\\]")
	var result = regex.search(original_text)
	if result:
		marked_word = result.get_string(1)
		print("Marked word found: ", marked_word)
	else:
		print("No colored word found in text")

func interact():
	if used:
		return
	used = true
	if is_animating:
		return  # Prevent multiple animations at once
		
	text_label.visible = true
	text_label.text = original_text
	
	if use_random_color:
		text_label.set("theme_override_colors/default_color", Color(randf(), randf(), randf()))
	
	start_fade_in_animation()

func start_fade_in_animation():
	is_animating = true
	
	var tween = create_tween()
	tween.tween_property(text_label, "modulate:a", 1.0, 2.5)  # Fade in over 0.5 seconds
	tween.tween_callback(_on_fade_complete)
	

func _on_fade_complete():
	is_animating = false
	GameManager.word_found(marked_word)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.ineractable_node = self


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.remove_interaction()
