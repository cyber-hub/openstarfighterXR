@icon("res://node_icons/brain.svg")
extends ShipControllerBase
class_name PlayerController

@export var activate_action : String = "trigger_click"
@export var input_action : String = "primary"
@export_category("Control")
@export_range(1, 6, 0.05) var _input_scale_power: float = 2
@export var _input_smoothing: float = 12.0

var cam_rig: GameCameraRig:
	set(value):
		_hud.cam = value.get_cam_ref()

var _last_mouse_movement: Vector2
var _pitch_input: float
var _yaw_input: float
var _roll_input: float

@onready var _hud: Hud = $Hud
#@onready var _hud: Hud = $Viewport2Din3D.connect_scene_signal("Hud")

#@onready var player = $Player
#@onready var player_left_controller : XRController3D = $Player/LeftHandController
#@onready var player_right_controller : XRController3D = $Player/RightHandController
# My Controller node
#@onready var _controller := XRHelpers.get_xr_controller(self)
# controller.is_button_pressed("trigger_click")
#controller.get_vector2("primary")

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_hud.player_ship = _ship
	#$XROrigin3D/LeftController.button_pressed.connect(self._on_left_controller_button_pressed)
	#$XROrigin3D/LeftController.button_released.connect(self._on_left_controller_button_released)
	#if _controller.is_button_pressed("trigger_click"):
	#	is_fire_commanded = true
	#	fire_weapon_command.emit()
	#if _controller.is_button_released("trigger_click"):
	#	is_fire_commanded = false

func _on_left_controller_button_pressed(button: String) -> void:
	print ("Button pressed: " + button)
	is_fire_commanded = true
	fire_weapon_command.emit()
 
func _on_left_controller_button_released(button: String) -> void:
	print ("Button release: " + button)

func action():
		is_fire_commanded = true
		

func _input(event: InputEvent):
	if event is InputEventMouseMotion:
		var event_mouse_motion = event as InputEventMouseMotion
		_last_mouse_movement = event_mouse_motion.relative
	elif event.is_action_pressed("player_switch_weapon"):
		if _ship.get_weapon_mode() == Ship.WeaponMode.BLASTER:
			change_weapon_mode_command.emit(Ship.WeaponMode.MISSILE)
		else:
			change_weapon_mode_command.emit(Ship.WeaponMode.BLASTER)
	elif event.is_action_pressed("player_fire"):
		is_fire_commanded = true
		fire_weapon_command.emit()
	elif event.is_action_released("player_fire"):
		is_fire_commanded = false
	elif event.is_action_pressed("player_afterburn"):
		is_afterburn_commanded = true
		afterburner_command.emit()
	elif event.is_action_released("player_afterburn"):
		is_afterburn_commanded = false


func _physics_process(delta: float):
	#XR controller pressed, fire:
	var controllers = XRServer.get_trackers(XRServer.TRACKER_CONTROLLER)
	for name in controllers:
		var tracker : XRPositionalTracker = controllers[name]
		if tracker.get_input(activate_action):
			is_fire_commanded = true
			fire_weapon_command.emit()
			is_fire_commanded = false
	## Movement
	if _last_mouse_movement != Vector2.ZERO:
		_apply_mouse_motion(delta)
		_last_mouse_movement = Vector2.ZERO
	else:
		_check_input_pitch_controller(delta)
		_check_input_yaw_controller(delta)
	
	_check_input_roll(delta)
	
	var look_target: Vector3 = Vector3.FORWARD * 30
	look_target += Vector3.LEFT * _yaw_input
	look_target += Vector3.UP * _pitch_input
	#look_target += Vector3.LEFT * Globals.joyX
	#look_target += Vector3.UP * Globals.joyY
	direction_target = _ship.global_position.direction_to(_ship.to_global(look_target))
	
	roll_command = _roll_input
	
	# Update hud
	if is_instance_valid(_hud.tracked_target):
		_hud.update_intercept_marker_position(
				calc_target_intercept_point(_hud.tracked_target)
		)


func _check_input_pitch_controller(delta: float) -> void:
	var pitch_input_raw =  (
			Input.get_action_strength("player_pitch_up") - 
			Input.get_action_strength("player_pitch_down")
	)
	# So input effect from controller stick input isn't on a linear scale
	#pitch_input_raw = sign(pitch_input_raw) * (pow(abs(pitch_input_raw), _input_scale_power))
	if Globals.joyLY != 0:
		pitch_input_raw = Globals.joyLY*0.15
	else:
		pitch_input_raw = Globals.joyRY*0.15
	
	_pitch_input = lerp(_pitch_input, pitch_input_raw, _input_smoothing * delta)


func _check_input_yaw_controller(delta: float) -> void:
	var yaw_input_raw =  (
			Input.get_action_strength("player_yaw_left") - 
			Input.get_action_strength("player_yaw_right")
	)
	#yaw_input_raw = sign(yaw_input_raw) * (pow(abs(yaw_input_raw), _input_scale_power))
	if Globals.joyLX != 0:
		yaw_input_raw = -Globals.joyLX*0.15
	else:
		yaw_input_raw = -Globals.joyRX*0.15
	
	_yaw_input = lerp(_yaw_input, yaw_input_raw, _input_smoothing * delta)


func _apply_mouse_motion(delta: float) -> void:
	var max_val: int = 10
	var normalized: Vector2 = Vector2(
		clamp(_last_mouse_movement.x / max_val, -1, 1),
		clamp(_last_mouse_movement.y / max_val, -1, 1)
	)
	
	_yaw_input = lerp(_yaw_input, -normalized.x, _input_smoothing * delta)
	
	_pitch_input = lerp(_pitch_input, -normalized.y, _input_smoothing * delta)
	#_yaw_input = lerp(-Globals.joyX, -normalized.x, _input_smoothing * delta)
	
	#_pitch_input = lerp(-Globals.joyY,-normalized.y, _input_smoothing * delta)


func _check_input_roll(delta: float) -> void:
	var roll_input_raw =  (
			Input.get_action_strength("player_roll_left") - 
			Input.get_action_strength("player_roll_right")
	)
	roll_input_raw = sign(roll_input_raw) * (pow(abs(roll_input_raw), _input_scale_power))
	
	_roll_input = lerp(_roll_input, roll_input_raw, _input_smoothing * delta)

