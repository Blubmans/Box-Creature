extends CharacterBody2D

@export var isHead = false
@export var gridPosition: Vector2i = Vector2i(3, 2)
var floatingGridPosition: Vector2
@onready var timer: Timer = $Timer
@onready var sprite: AnimatedSprite2D = $Sprite2D


func _ready() -> void:
	GameManager.updatePlayerPos.connect(update_player_pos)
	floatingGridPosition = position * 16
	if isHead:
		GameManager.board[gridPosition.y][gridPosition.x] = GameManager.Spaces.player
		GameManager.playerPos = gridPosition
		sprite.animation = "Player"
	else:
		GameManager.board[gridPosition.y][gridPosition.x] = GameManager.Spaces.body
		sprite.animation = "Body"


func update_player_pos(oldPos: Vector2i, newPos: Vector2i):
	if oldPos != gridPosition:
		return
	
	gridPosition = Vector2(newPos)
	floatingGridPosition = position
	timer.start()


func _process(_delta: float) -> void:
	position = lerp(floatingGridPosition, Vector2(gridPosition) * 16, (0.1 - timer.time_left) / 0.1)
