extends Node

var home_window : Window
var snail_instance

func _ready():
	# Create and add the home base window
	home_window = Window.new()
	add_child(home_window)
	
	home_window.transparent = true
	home_window.borderless = true
	home_window.always_on_top = true
	home_window.mouse_passthrough = false
	home_window.size = Vector2(200, 200)
	
	var usable = DisplayServer.get_display_safe_area()
	home_window.position = Vector2(usable.position.x, usable.position.y + usable.size.y - home_window.size.y)  # bottom-left
	
	var home_sprite = Sprite2D.new()
	home_sprite.texture = preload("res://sprout.png")
	home_sprite.centered = true
	home_sprite.position = home_window.size / 2
	home_window.add_child(home_sprite)
	
	# Load and instance the Snail scene into the main window
	var snail_scene = preload("res://snail.tscn")
	snail_instance = snail_scene.instantiate()
	add_child(snail_instance)
	
	# Pass home window reference to the snail script
	snail_instance.set_home_window(home_window)
