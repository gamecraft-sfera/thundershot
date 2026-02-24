extends Label
class_name PlacedWordLabel

func set_word_text(word: String):
	text = word

func set_correct_state(is_correct: bool):
	pass
	#if is_correct:
	#	add_theme_color_override("font_color", Color(1, 1, 1, 1))  # White text
	#else:
	#	add_theme_color_override("font_color", Color(1, 0.8, 0.8, 1))  # Light red text

func set_placed_state():
	pass
	#add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 1))  # Gray color to indicate placed
