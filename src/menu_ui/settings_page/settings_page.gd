extends MultiPageUIPage


func _on_btn_back_pressed() -> void:
	if active:
		print ("_on_btn_back_pressed(settings): " + _back_page_name)
		change_page_request.emit(_back_page_name)

