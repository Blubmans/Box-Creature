extends Node

var levels = [
	#[ # Level data layout
	#	[], # LEVEL DATA: [heads], [bodies], [player_ends], [body_ends]
	#	[]  # BOARD DATA
	#]
	[  # Level 1
		
	],
	[  # Level 2
		[
			[Vector2i(4, 1)], 
			[Vector2i(5, 3), Vector2i(3, 3), Vector2i(4, 4)],
			[Vector2i(1, 7)],
			[Vector2i(7, 7), Vector2i(5, 7), Vector2i(3, 7)]
		],
		[
			[1, 1, 1, 1, 1, 1, 1, 1, 1],
			[1, 0, 0, 1, 2, 1, 0, 0, 1], 
			[1, 0, 0, 0, 0, 0, 0, 0, 1], 
			[1, 0, 0, 3, 1, 3, 0, 0, 1], 
			[1, 0, 1, 0, 3, 0, 1, 0, 1], 
			[1, 0, 0, 0, 0, 0, 0, 0, 1], 
			[1, 0, 1, 0, 1, 0, 1, 0, 1], 
			[1, 0, 1, 0, 1, 0, 1, 0, 1], 
			[1, 1, 1, 1, 1, 1, 1, 1, 1]
			]
	]
]

@export var loadLevel: bool = false
@export var loadLevelID: int = 1
@onready var ground: TileMapLayer = $Ground
@onready var walls: TileMapLayer = $Walls
const PLAYER = preload("uid://dll2a4k1akuut")
var currentLevel = []


func _ready() -> void:
	if loadLevel:
		load_level(loadLevelID)
	else:
		read_editor_data()


func read_editor_data():
	# Get all data and sort them in: wall, head, body, head_end, body_end
	var wallPositions = walls.get_used_cells()
	var headPositions = walls.get_used_cells_by_id(1, Vector2i(0, 0))
	var bodyPositions = walls.get_used_cells_by_id(1, Vector2i(1, 0))
	bodyPositions += walls.get_used_cells_by_id(1, Vector2i(2, 0))
	var headAndBodyPos = headPositions + bodyPositions
	for i in range(len(headAndBodyPos)):
		wallPositions.erase(headAndBodyPos[i])
	var headEnds = ground.get_used_cells_by_id(0, Vector2i(6, 3))
	var bodyEnds = ground.get_used_cells_by_id(0, Vector2i(5, 3))
	
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
	
	# Sent levelData to Game Manager
	GameManager.set_level_data(currentLevel, headPositions, headEnds, bodyEnds)
	
	# Spawn heads and bodies
	for i in range(len(headPositions)):
		var head = PLAYER.instantiate()
		head.isHead = true
		head.gridPosition = headPositions[i]
		add_child(head)
		walls.erase_cell(headPositions[i])
	for i in range(len(bodyPositions)):
		var body = PLAYER.instantiate()
		body.gridPosition = bodyPositions[i]
		add_child(body)
		walls.erase_cell(bodyPositions[i])
	
	# Print easy level code
	print([[headPositions, bodyPositions, headEnds, bodyEnds], currentLevel])


func load_level(levelID: int):
	var wallPos = []
	for y in range(len(levels[levelID][1])):
		for x in range(len(levels[levelID][1][y])):
			if levels[levelID][1][y][x] == 1:
				wallPos.append(Vector2i(x, y))
	walls.set_cells_terrain_connect(wallPos, 0, 1)
