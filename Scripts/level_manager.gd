extends Node

var levels = [
	#[ # Level data layout
	#	[[heads], [bodies], [player_ends], [body_ends]],
	#	[BOARD DATA]
	#]
	[  # Level 1
		[
			[Vector2i(2, 2)], 
			[Vector2i(1, 2), Vector2i(2, 3), Vector2i(2, 4)], 
			[Vector2i(5, 7)], 
			[Vector2i(6, 7), Vector2i(5, 8), Vector2i(6, 8)]], 
		[
			[1, 1, 1, 1, 1, 1, 1, 1], 
			[1, 0, 0, 0, 1, 1, 1, 1], 
			[1, 3, 2, 0, 1, 1, 1, 1], 
			[1, 0, 3, 0, 0, 0, 0, 1], 
			[1, 1, 3, 0, 0, 0, 0, 1], 
			[1, 1, 0, 1, 0, 0, 0, 1], 
			[1, 1, 1, 0, 0, 0, 0, 1], 
			[1, 1, 1, 1, 1, 0, 0, 1], 
			[1, 1, 1, 1, 1, 0, 0, 1], 
			[1, 1, 1, 1, 1, 1, 1, 1]]
	],
	[  # Level 2
		[
			[Vector2i(4, 1)], 
			[Vector2i(5, 3), Vector2i(3, 3), Vector2i(4, 4)],
			[Vector2i(1, 7)],
			[Vector2i(7, 7), Vector2i(5, 7), Vector2i(3, 7)]],
		[
			[1, 1, 1, 1, 1, 1, 1, 1, 1],
			[1, 0, 0, 1, 2, 1, 0, 0, 1], 
			[1, 0, 0, 0, 0, 0, 0, 0, 1], 
			[1, 0, 0, 3, 1, 3, 0, 0, 1], 
			[1, 0, 1, 0, 3, 0, 1, 0, 1], 
			[1, 0, 0, 0, 0, 0, 0, 0, 1], 
			[1, 0, 1, 0, 1, 0, 1, 0, 1], 
			[1, 0, 1, 0, 1, 0, 1, 0, 1], 
			[1, 1, 1, 1, 1, 1, 1, 1, 1]]
	],
	[  # Level 3
		[
			[Vector2i(4, 2), Vector2i(2, 2)], 
			[Vector2i(3, 2), Vector2i(5, 2), Vector2i(1, 2)], 
			[Vector2i(7, 3), Vector2i(8, 1)], 
			[Vector2i(7, 1), Vector2i(8, 2), Vector2i(8, 3)]], 
		[
			[1, 1, 1, 1, 1, 1, 1, 1, 1, 1], 
			[1, 1, 0, 0, 0, 1, 0, 0, 0, 1], 
			[1, 3, 2, 3, 2, 3, 0, 1, 0, 1], 
			[1, 0, 0, 0, 0, 1, 0, 0, 0, 1], 
			[1, 1, 1, 1, 1, 1, 1, 1, 1, 1]]
	]
]

@export var loadLevel: bool = true
@export var loadLevelID: int = 0
@onready var ground: TileMapLayer = $Ground
@onready var walls: TileMapLayer = $Walls
const PLAYER = preload("uid://dll2a4k1akuut")
var currentLevel = []


func _ready() -> void:
	if loadLevel:
		load_level(loadLevelID)
	else:
		read_editor_data()
	GameManager.reloadLevel.connect(reload_level)


func read_editor_data():
	# Get all data and sort them in: wall, head, body, head_end, body_end
	var wallPositions = walls.get_used_cells()
	var headPositions = walls.get_used_cells_by_id(1, Vector2i(0, 0))
	for i in range(len(headPositions)):
		walls.erase_cell(headPositions[i])
	var bodyPositions = walls.get_used_cells_by_id(1, Vector2i(1, 0))
	bodyPositions += walls.get_used_cells_by_id(1, Vector2i(2, 0))
	for i in range(len(bodyPositions)):
		walls.erase_cell(bodyPositions[i])
	var headAndBodyPos = headPositions + bodyPositions
	for i in range(len(headAndBodyPos)):
		wallPositions.erase(headAndBodyPos[i])
	var headEnds = ground.get_used_cells_by_id(0, Vector2i(6, 3))
	var bodyEnds = ground.get_used_cells_by_id(0, Vector2i(5, 3))
	
	setup_level(wallPositions, headPositions, bodyPositions, headEnds, bodyEnds, true)


func reload_level():
	load_level(loadLevelID)


func load_level(levelID: int):
	walls.clear()
	ground.clear()
	currentLevel.clear()
	var wallPos = []
	for y in range(len(levels[levelID][1])):
		for x in range(len(levels[levelID][1][y])):
			ground.set_cell(Vector2i(x, y), 0, Vector2i(4, 3))
			if levels[levelID][1][y][x] == 1:
				wallPos.append(Vector2i(x, y))
			if Vector2i(x, y) in levels[levelID][0][2]:
				ground.set_cell(Vector2i(x, y), 0, Vector2i(6, 3))
			if Vector2i(x, y) in levels[levelID][0][3]:
				ground.set_cell(Vector2i(x, y), 0, Vector2i(5, 3))
	
	walls.set_cells_terrain_connect(wallPos, 0, 1)
	
	setup_level(wallPos, levels[levelID][0][0], levels[levelID][0][1], levels[levelID][0][2], levels[levelID][0][3])


func setup_level(wallPositions, headPositions, bodyPositions, headEnds, bodyEnds, printLevel: bool = false):
	# Set all walls
	wallPositions.sort()
	for y in range(wallPositions[len(wallPositions) - 1].y + 1):
		currentLevel.append([])
		for x in range(wallPositions[len(wallPositions) - 1].x + 1):
			currentLevel[y].append(GameManager.Spaces.empty)
	for i in range(len(wallPositions)):
		currentLevel[wallPositions[i].y][wallPositions[i].x] = GameManager.Spaces.wall
	
	# Set all heads and bodies
	for i in range(len(headPositions)):
		currentLevel[headPositions[i].y][headPositions[i].x] = GameManager.Spaces.player
	for i in range(len(bodyPositions)):
		currentLevel[bodyPositions[i].y][bodyPositions[i].x] = GameManager.Spaces.body
	
	spawn_body(headPositions, bodyPositions)
	
	# Sent levelData to Game Manager
	GameManager.set_level_data(currentLevel, headPositions, headEnds, bodyEnds)
	
	if printLevel:
		# Print easy level code
		print([[headPositions, bodyPositions, headEnds, bodyEnds], currentLevel])


func spawn_body(headPositions, bodyPositions):
	# Spawn heads and bodies
	for i in range(len(headPositions)):
		var head = PLAYER.instantiate()
		head.gridPosition = headPositions[i]
		head.position = headPositions[i] * 16
		head.isHead = true
		add_child(head)
	for i in range(len(bodyPositions)):
		var body = PLAYER.instantiate()
		body.gridPosition = bodyPositions[i]
		body.position = bodyPositions[i] * 16
		add_child(body)
		
