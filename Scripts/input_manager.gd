extends Node


func _process(_delta: float) -> void:
	if Input.is_action_pressed("Pressed_Up"):
		GameManager.receve_input(GameManager.Directions.up)
	elif Input.is_action_pressed("Pressed_Right"):
		GameManager.receve_input(GameManager.Directions.right)
	elif Input.is_action_pressed("Pressed_Down"):
		GameManager.receve_input(GameManager.Directions.down)
	elif Input.is_action_pressed("Pressed_Left"):
		GameManager.receve_input(GameManager.Directions.left)
