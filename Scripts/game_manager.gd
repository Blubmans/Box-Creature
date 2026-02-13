extends Node

enum Spaces {
	empty,
	wall,
	player,
	box,
	player_end,
	box_end}
enum Directions {
	up,
	right,
	down,
	left}
var board = []

func _ready():
	#setup board
	for i in range(10):
		board.append([])
		for j in range(10):
			board[i].append(Spaces.empty)
	
	print(board)


func set_board_walls(wallPositions):
	pass


func receve_player_input(direction: Directions):
	match direction:
		Directions.up:
			pass
		Directions.right:
			pass
		Directions.down:
			pass
		Directions.left:
			pass
