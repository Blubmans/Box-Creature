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
var bodyEndPositions = []
var headEndPositions = []
var nonTransparantSpaces = [Spaces.wall, Spaces.player, Spaces.body]
var playerPos: Array[Vector2i]
var bodyParts = []
signal updatePlayerPos
signal updateBodyLooks

func _ready() -> void:
	#setup board
	for i in range(10):
		board.append([])
		for j in range(10):
			board[i].append(Spaces.empty)


func set_level_data(level, playerPositions, headEnds, bodyEnds):
	board = level
	playerPos = playerPositions
	headEndPositions = headEnds
	bodyEndPositions = bodyEnds


func change_player_pos(originPos: Vector2i, pos: Vector2i):
	if board[originPos.y][originPos.x] == Spaces.player:
		board[originPos.y][originPos.x] = Spaces.empty
		playerPos.erase(originPos)
		playerPos.append(pos)
		board[pos.y][pos.x] = Spaces.player
	else:
		board[originPos.y][originPos.x] = Spaces.empty
		board[pos.y][pos.x] = Spaces.body
	updatePlayerPos.emit(originPos, pos)


func list_bodyparts() -> Array:
	var bodyList = []
	bodyList += playerPos
	
	var bodyPartLength = -1
	while len(bodyList) != bodyPartLength:
		bodyPartLength = len(bodyList)
		for i in range(len(bodyList)):
			bodyList.append(Vector2i(bodyList[i].x, bodyList[i].y - 1))
			bodyList.append(Vector2i(bodyList[i].x + 1, bodyList[i].y))
			bodyList.append(Vector2i(bodyList[i].x, bodyList[i].y + 1))
			bodyList.append(Vector2i(bodyList[i].x - 1, bodyList[i].y))
		bodyList = unique_array(bodyList)
		for i in range(len(bodyList) -1, -1, -1):
			if board[bodyList[i].y][bodyList[i].x] != Spaces.body && board[bodyList[i].y][bodyList[i].x] != Spaces.player:
				bodyList.remove_at(i)
	return bodyList


func unique_array(array: Array) -> Array:
	var unique: Array = []

	for i in array:
		if not unique.has(i):
			unique.append(i)

	return unique


func recieve_player_input(direction: Directions):
	# Get all body parts
	bodyParts = list_bodyparts()
	
	var small
	var big
	# Get the outer most bodyparts
	if direction == Directions.up || direction == Directions.down:
		small = bodyParts[0].x
		big = bodyParts[0].x
		for i in range(len(bodyParts)):
			if bodyParts[i].x < small:
				small = bodyParts[i].x
			if bodyParts[i].x > big:
				big = bodyParts[i].x
	else:
		small = bodyParts[0].y
		big = bodyParts[0].y
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
		bodyPartLines[i].sort()
		if direction == Directions.down || direction == Directions.right:
			bodyPartLines[i].reverse()
		for item in range(len(bodyPartLines[i])):
			move_player(bodyPartLines[i][item], direction)
	
	set_new_bodyparts()
	check_win()


func move_player(pos: Vector2i, direction: Directions):
	var i = 1
	match direction:
		Directions.up:
			while board[pos.y - i][pos.x] not in nonTransparantSpaces:
				i += 1
			change_player_pos(pos, Vector2i(pos.x, pos.y - i + 1))
		Directions.right:
			while board[pos.y][pos.x + i] not in nonTransparantSpaces:
				i += 1
			change_player_pos(pos, Vector2i(pos.x + i - 1, pos.y))
		Directions.down:
			while board[pos.y + i][pos.x] not in nonTransparantSpaces:
				i += 1
			change_player_pos(pos, Vector2i(pos.x, pos.y + i - 1))
		Directions.left:
			while board[pos.y][pos.x - i] not in nonTransparantSpaces:
				i += 1
			change_player_pos(pos, Vector2i(pos.x - i + 1, pos.y))


func check_win():
	var body = []
	for y in range(len(board)):
		if board[y].has(Spaces.body):
			for x in range(len(board[0])):
				if board[y][x] == Spaces.body:
					body.append(Vector2i(x, y))
	
	for i in range(len(body)):
		if body[i] not in bodyEndPositions:
			return
	
	for i in range(len(playerPos)):
		if playerPos[i] not in headEndPositions:
			return
	
	print("You win!")


func set_new_bodyparts():
	updateBodyLooks.emit(list_bodyparts())
