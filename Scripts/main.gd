extends Node

@onready var foreground: TileMapLayer = $Walls
@onready var ground: TileMapLayer = $Ground


func _ready() -> void:
	GameManager.set_board_walls(foreground.get_used_cells())
	GameManager.bodyEndPositions = ground.get_used_cells_by_id(0, Vector2i(5, 3))
	GameManager.headEndPositions = ground.get_used_cells_by_id(0, Vector2i(6, 3))
