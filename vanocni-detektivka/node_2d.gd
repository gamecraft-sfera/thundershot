extends Node2D

var pocitadlo = 10

func _on_texture_button_pressed() -> void:
	pocitadlo = pocitadlo - 1
	print("JSEM ZMACKNUTEJ")
	
	$TextureButton.visible = false
	$Darek3.visible = true


func _on_darek_tlacitko_pressed() -> void:
	pocitadlo = pocitadlo - 1
	$Label.text = str(pocitadlo)
	print(pocitadlo)
	if pocitadlo == 0:
		$Darek3.visible = true
	#$"darek tlacitko".visible = false
	$Darek3.visible = true
