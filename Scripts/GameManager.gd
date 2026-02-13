extends Node

enum Spaces 
{
	empty,
	wall,
	player,
	box
}

var board = []

func _ready():
	#setup board
	for i in range(10):
		board.append([])
		for j in range(10):
			board[i].append(Spaces.empty)
	
	print(board)
