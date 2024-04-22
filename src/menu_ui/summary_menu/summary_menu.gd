extends Control

var labeltext = " Hoops Collected in "
# Called when the node enters the scene tree for the first time.
func _ready():
	set_label(str(Globals.hops) + labeltext + str(Globals.time) + "s")

func set_label(Lstring):
	#$Label.text = Lstring
	$Label.text = Globals.summarytext

func _on_summary_screen_exit_btn_pressed() -> void:
	get_tree().paused = false
	SceneSwitcher.transition_to_main_menu()
