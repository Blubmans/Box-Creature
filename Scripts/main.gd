extends Node

@onready var foreground: TileMapLayer = $Walls


func _ready() -> void:
	GameManager.set_board_walls(foreground.get_used_cells())
