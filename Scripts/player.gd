extends CharacterBody2D

@export var isHead = false
@export var gridPosition: Vector2i = Vector2i(3, 2)
@export var floatingGridPosition: Vector2
@onready var timer: Timer = $Timer


func _ready() -> void:
	GameManager.updatePlayerPos.connect(update_player_pos)
	floatingGridPosition = position


func update_player_pos():
	for i in range(GameManager.boardSize):
		if GameManager.board[i].find(GameManager.Spaces.player) != -1:
			gridPosition = Vector2(GameManager.board[i].find(GameManager.Spaces.player), i)
			floatingGridPosition = position
			timer.start()


func _process(_delta: float) -> void:
	position = lerp(floatingGridPosition, Vector2(gridPosition) * 16, (0.1 - timer.time_left) / 0.1)
