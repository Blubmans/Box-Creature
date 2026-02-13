extends Node

@onready var foreground: TileMapLayer = $Foreground


func _ready() -> void:
	print(foreground.get_used_cells())
