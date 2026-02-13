extends Node

@onready var input_delay_timer: Timer = $InputDelay
@export var input_delay = 0.1
var next_input


func _ready() -> void:
	input_delay_timer.wait_time = input_delay


func _process(_delta: float) -> void:
	if next_input != null:
		sent_input_to_manager(next_input)
	
	if Input.is_action_pressed("Pressed_Up"):
		sent_input_to_manager(GameManager.Directions.up)
	elif Input.is_action_pressed("Pressed_Right"):
		sent_input_to_manager(GameManager.Directions.right)
	elif Input.is_action_pressed("Pressed_Down"):
		sent_input_to_manager(GameManager.Directions.down)
	elif Input.is_action_pressed("Pressed_Left"):
		sent_input_to_manager(GameManager.Directions.left)


func sent_input_to_manager(dir: GameManager.Directions):
	if !input_delay_timer.is_stopped():
		next_input = dir
		return
	
	GameManager.receve_player_input(dir)
	input_delay_timer.start()
	next_input = null
