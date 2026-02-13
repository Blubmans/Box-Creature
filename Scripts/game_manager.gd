extends Node

enum Spaces {
	empty,
	wall,
	player,
	body,
	player_end,
	body_end}
enum Directions {
	up,
	right,
	down,
	left}
var board = []
var boardSize: int = 10
var nonTransparantSpaces = [Spaces.wall, Spaces.player, Spaces.body]
var playerPos: Vector2i
var bodyParts = []
signal updatePlayerPos

func _ready() -> void:
	#setup board
	for i in range(10):
		board.append([])
		for j in range(10):
			board[i].append(Spaces.empty)


func set_board_walls(wallPositions):
	for i in range(len(wallPositions)):
		board[wallPositions[i].y][wallPositions[i].x] = Spaces.wall


func change_player_pos(originPos: Vector2i, pos: Vector2i):
	if board[originPos.y][originPos.x] == Spaces.player:
		board[originPos.y][originPos.x] = Spaces.empty
		playerPos = pos
		board[pos.y][pos.x] = Spaces.player
	else:
		board[originPos.y][originPos.x] = Spaces.empty
		board[pos.y][pos.x] = Spaces.body
	updatePlayerPos.emit(originPos, pos)


func list_bodyparts():
	bodyParts.clear()
	bodyParts.append(playerPos)
	
	var bodyPartLength = -1
	while len(bodyParts) != bodyPartLength:
		bodyPartLength = len(bodyParts)
		for i in range(len(bodyParts)):
			bodyParts.append(Vector2i(bodyParts[i].x, bodyParts[i].y - 1))
			bodyParts.append(Vector2i(bodyParts[i].x + 1, bodyParts[i].y))
			bodyParts.append(Vector2i(bodyParts[i].x, bodyParts[i].y + 1))
			bodyParts.append(Vector2i(bodyParts[i].x - 1, bodyParts[i].y))
		bodyParts = unique_array(bodyParts)
		for i in range(len(bodyParts) -1, -1, -1):
			if board[bodyParts[i].y][bodyParts[i].x] != Spaces.body && board[bodyParts[i].y][bodyParts[i].x] != Spaces.player:
				bodyParts.remove_at(i)


func unique_array(array: Array) -> Array:
	var unique: Array = []

	for i in array:
		if not unique.has(i):
			unique.append(i)

	return unique


func recieve_player_input(direction: Directions):
	# Get all body parts
	list_bodyparts()
	
	var small
	var big
	# Get the outer most bodyparts
	if direction == Directions.up || direction == Directions.down:
		small = playerPos.x
		big = playerPos.x
		for i in range(len(bodyParts)):
			if bodyParts[i].x < small:
				small = bodyParts[i].x
			if bodyParts[i].x > big:
				big = bodyParts[i].x
	else:
		small = playerPos.y
		big = playerPos.y
		for i in range(len(bodyParts)):
			if bodyParts[i].y < small:
				small = bodyParts[i].y
			if bodyParts[i].y > big:
				big = bodyParts[i].y
	
	# Make body part lines
	var bodyPartLines = []
	for i in range(big - small + 1):
		bodyPartLines.append([])
	
	for i in range(len(bodyParts)):
		if direction == Directions.up || direction == Directions.down:
			bodyPartLines[bodyParts[i].x - small].append(bodyParts[i])
		else:
			bodyPartLines[bodyParts[i].y - small].append(bodyParts[i])
	
	for i in range(len(bodyPartLines)):
		if direction == Directions.up || direction == Directions.left:
			bodyPartLines[i].sort()
		else:
			bodyPartLines[i].sort()
			bodyPartLines[i].reverse()
		for item in range(len(bodyPartLines[i])):
			move_player(bodyPartLines[i][item], direction)


func move_player(pos: Vector2i, direction: Directions):
	match direction:
		Directions.up:
			for i in range(1, boardSize):
				if board[pos.y - i][pos.x] in nonTransparantSpaces:
					change_player_pos(pos, Vector2i(pos.x, pos.y - i + 1))
					break
		Directions.right:
			for i in range(1, boardSize):
				if board[pos.y][pos.x + i] in nonTransparantSpaces:
					change_player_pos(pos, Vector2i(pos.x + i - 1, pos.y))
					break
		Directions.down:
			for i in range(1, boardSize):
				if board[pos.y + i][pos.x] in nonTransparantSpaces:
					change_player_pos(pos, Vector2i(pos.x, pos.y + i - 1))
					break
		Directions.left:
			for i in range(1, boardSize):
				if board[pos.y][pos.x - i] in nonTransparantSpaces:
					change_player_pos(pos, Vector2i(pos.x - i + 1, pos.y))
					break
