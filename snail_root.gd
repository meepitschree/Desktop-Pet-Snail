extends Window

var window := self

enum Edge { LEFT, BOTTOM, RIGHT, TOP }
enum Action { ROAMING }

# Movement
var curr_edge = Edge.LEFT
var counter_clockwise = false
var speed := 300
var moving := true

# Pause logic
var pause_time := 0.0
var pause_duration := 0.0

# Display bounds
var usable: Rect2i

# Home logic (optional)
var home_window: Window
var home_position: Vector2
var home_path := []
var home_path_index := 0
var home_pause_duration := 1.0
var home_pause_time := 0.0

# State
var current_action = Action.ROAMING

func set_home_window(home_win: Window):
	home_window = home_win
	home_position = home_window.position + home_window.size / 2

func _ready():
	usable = DisplayServer.get_display_safe_area()
	
	window.transparent = true
	window.borderless = true
	window.always_on_top = true
	window.mouse_passthrough = false
	window.size = Vector2(50, 50)
	window.position = usable.position
	
	connect("mouse_entered", Callable(self, "_mouse_entered"))
	connect("mouse_exited", Callable(self, "_mouse_exited"))

	$Snail.centered = true
	$Snail.position = window.size / 2
	$Snail.play("walk")

	counter_clockwise = false
	_update_snail_direction()
	randomize()
	pause_duration = randf_range(1.0, 3.0)

func _process(delta):
	match current_action:
		Action.ROAMING:
			_process_roaming(delta)

func _process_roaming(delta):
	if not moving:
		pause_time += delta
		if pause_time >= pause_duration:
			moving = true
			pause_time = 0.0
			pause_duration = randf_range(2.0, 5.0)
			$Snail.play("walk")
		return

	var pos = Vector2(window.position)
	var direction = Vector2.RIGHT.rotated(deg_to_rad($Snail.rotation_degrees))
	pos += direction * speed * delta

	if counter_clockwise:
		match curr_edge:
			Edge.LEFT:
				if pos.y >= usable.position.y + usable.size.y - window.size.y:
					pos.y = usable.position.y + usable.size.y - window.size.y
					curr_edge = Edge.BOTTOM
					$Snail.rotation_degrees = 0
					start_pause()
			Edge.BOTTOM:
				if pos.x >= usable.position.x + usable.size.x - window.size.x:
					pos.x = usable.position.x + usable.size.x - window.size.x
					curr_edge = Edge.RIGHT
					$Snail.rotation_degrees = 270
					start_pause()
			Edge.RIGHT:
				if pos.y <= usable.position.y:
					pos.y = usable.position.y
					curr_edge = Edge.TOP
					$Snail.rotation_degrees = 180
					start_pause()
			Edge.TOP:
				if pos.x <= usable.position.x:
					pos.x = usable.position.x
					curr_edge = Edge.LEFT
					$Snail.rotation_degrees = 90
					start_pause()
	else:
		match curr_edge:
			Edge.TOP:
				if pos.x >= usable.position.x + usable.size.x - window.size.x:
					pos.x = usable.position.x + usable.size.x - window.size.x
					curr_edge = Edge.RIGHT
					$Snail.rotation_degrees = 90
					start_pause()
			Edge.RIGHT:
				if pos.y >= usable.position.y + usable.size.y - window.size.y:
					pos.y = usable.position.y + usable.size.y - window.size.y
					curr_edge = Edge.BOTTOM
					$Snail.rotation_degrees = 180
					start_pause()
			Edge.BOTTOM:
				if pos.x <= usable.position.x:
					pos.x = usable.position.x
					curr_edge = Edge.LEFT
					$Snail.rotation_degrees = 270
					start_pause()
			Edge.LEFT:
				if pos.y <= usable.position.y:
					pos.y = usable.position.y
					curr_edge = Edge.TOP
					$Snail.rotation_degrees = 0
					start_pause()

	window.position = pos.round()

func _rotate_towards(target_pos: Vector2):
	var to_target = target_pos - Vector2(window.position)
	$Snail.rotation_degrees = rad_to_deg(to_target.angle())

func start_pause():
	#moving = false
	pause_time = 0.0
	pause_duration = randf_range(1.0, 4.0)
	#$Snail.stop()
	
func _mouse_entered():
	moving = false
	$Snail.play("idle")  # optional if you have an idle animation
	print("Snail hovered — paused")

func _mouse_exited():
	moving = true
	$Snail.play("walk")
	print("Snail unhovered — resumed")

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Snail petted!")
		counter_clockwise = !counter_clockwise
		_update_snail_direction()
		moving = true
		$Snail.play("walk")

func _update_snail_direction():
	$Snail.flip_v = !counter_clockwise

	# Recalculate current edge from position
	var pos = window.position
	var margin = 5
	if abs(pos.x - usable.position.x) < margin:
		curr_edge = Edge.LEFT
	elif abs(pos.x - (usable.position.x + usable.size.x - window.size.x)) < margin:
		curr_edge = Edge.RIGHT
	elif abs(pos.y - usable.position.y) < margin:
		curr_edge = Edge.TOP
	elif abs(pos.y - (usable.position.y + usable.size.y - window.size.y)) < margin:
		curr_edge = Edge.BOTTOM

	match curr_edge:
		Edge.LEFT:
			$Snail.rotation_degrees = 90 if counter_clockwise else 270
		Edge.RIGHT:
			$Snail.rotation_degrees = 270 if counter_clockwise else 90
		Edge.TOP:
			$Snail.rotation_degrees = 180 if counter_clockwise else 0
		Edge.BOTTOM:
			$Snail.rotation_degrees = 0 if counter_clockwise else 180
