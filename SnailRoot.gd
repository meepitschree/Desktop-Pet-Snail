extends Node2D

enum Edge { LEFT, BOTTOM, RIGHT, TOP }
enum State { ROAMING }

var state = Edge.LEFT
var speed = 300
var usable: Rect2i
var moving = true
var pause_time = 0.0
var pause_duration = 0.0
var window

# Home base info
var home_window : Window
var home_position : Vector2
var home_path = []
var home_path_index = 0
var home_pause_duration = 1.0
var home_pause_time = 0.0

var current_state = State.ROAMING

func set_home_window(home_win):
	home_window = home_win
	home_position = home_window.position + home_window.size / 2

func _ready():
	usable = DisplayServer.get_display_safe_area()
	window = get_window()
	
	window.transparent = true
	window.borderless = true
	window.always_on_top = true
	window.mouse_passthrough = false
	window.size = Vector2(64, 64)

	window.position = Vector2(usable.position.x, usable.position.y)

	$Snail.position = window.size / 2
	$Snail.centered = true
	$Snail.play("walk")
	$Snail.rotation_degrees = 90

	state = Edge.LEFT
	current_state = State.ROAMING
	
	randomize()
	pause_duration = randf_range(1.0, 3.0)

func _process(delta):
	match current_state:
		State.ROAMING:
			_process_roaming(delta)

func _process_roaming(delta):
	if not moving:
		pause_time += delta
		if pause_time >= pause_duration:
			print(pause_time)
			moving = true
			pause_time = 0.0
			pause_duration = randf_range(2.0, 5.0)
			$Snail.play("walk")
		else:
			return

	var pos = Vector2(window.position)
	var direction = Vector2.RIGHT.rotated(deg_to_rad($Snail.rotation_degrees))
	pos += direction * speed * delta

	match state:
		Edge.LEFT:
			if pos.y >= usable.position.y + usable.size.y - window.size.y:
				pos.y = usable.position.y + usable.size.y - window.size.y
				state = Edge.BOTTOM
				$Snail.rotation_degrees = 0
				start_pause()
		Edge.BOTTOM:
			if pos.x >= usable.position.x + usable.size.x - window.size.x:
				pos.x = usable.position.x + usable.size.x - window.size.x
				state = Edge.RIGHT
				$Snail.rotation_degrees = 270
				start_pause()
		Edge.RIGHT:
			if pos.y <= usable.position.y:
				pos.y = usable.position.y
				state = Edge.TOP
				$Snail.rotation_degrees = 180
				start_pause()
		Edge.TOP:
			if pos.x <= usable.position.x:
				pos.x = usable.position.x
				state = Edge.LEFT
				$Snail.rotation_degrees = 90
				start_pause()

	window.position = pos.round()

func _rotate_towards(target_pos: Vector2):
	var to_target = target_pos - Vector2(window.position)
	var angle_deg = rad_to_deg(to_target.angle())
	$Snail.rotation_degrees = angle_deg

func start_pause():
	moving = false
	pause_time = 0.0
	pause_duration = randf_range(1.0, 4.0)
	$Snail.stop()

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Snail petted!")
