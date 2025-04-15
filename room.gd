extends Node2D

@export var _dimensions = Vector2i(7, 5) # 7 * 5 (35) max. rooms can be created
@export var _start = Vector2i(-1, 0) # source of the path
#_start can be randomized by (-1, -1) or (-1, 0) for only random x position
@export var _critital_path_length = 13 # max. path length

@export var _branches = 3 # "side-paths" besides the main path
@export var _branch_length = Vector2i(1, 4) # length of the branches

var dungeon: Array = []
var _branch_candidates: Array[Vector2i] = []

func _ready():
	print("Started")
	_initialize_dungeon()
	_place_entrance()
	_generate_path(_start, _critital_path_length, "C")
	_generate_branches()
	_print_dungeon()

## Building the dungeon grid 
func _initialize_dungeon():
	for x in _dimensions.x:
		dungeon.append([])
		for y in _dimensions.y:
			dungeon[x].append(0)

## Setting the Source of the path
func _place_entrance():
	if _start.x < 0 or _start.x >= _dimensions.x:
		_start.x = randi_range(0, _dimensions.x - 1)
	if _start.y < 0 or _start.y >= _dimensions.y:
		_start.y = randi_range(0, _dimensions.y - 1)
	dungeon[_start.x][_start.y] = "S"

## Path generator, path marked with "C"
func _generate_path(curr_pos, length, marker):
	# breaking condition
	if length == 0:
		return true
	
	var current = curr_pos
	var direction: Vector2i

	# random direction
	match randi_range(0, 3):
		0:
			direction = Vector2i.UP 
		1: 
			direction = Vector2i.RIGHT
		2:
			direction = Vector2i.DOWN
		3: 
			direction = Vector2i.LEFT

	for i in 4:
		# checking if direction is a valid move
		var new_x = current.x + direction.x
		var new_y = current.y + direction.y

		if (new_x >= 0 and new_x < _dimensions.x and
			new_y >= 0 and new_y < _dimensions.y and 
			not dungeon[new_x][new_y]):
			
			current += direction # moving in selected direction
			dungeon[current.x][current.y] = marker # place marker in grid

			# adding branch
			if length > 1: # not last room
				_branch_candidates.append(current)

			# recursion loop
			if _generate_path(current, length - 1, marker):
				return true
			else:
				# safety rollback
				_branch_candidates.erase(current)
				dungeon[current.x][current.y] = 0
				current -= direction

		# rotate direction (rotate right)
		direction = Vector2(direction.y, -direction.x)

	return false

func _generate_branches():
	var branches_created = 0
	var candidate: Vector2i

	# Continue until created max. branches or until out of candidate positions
	while branches_created < _branches and _branch_candidates.size():
		# Randomly select a candidate and try to build a path
		candidate = _branch_candidates[randi_range(0, _branch_candidates.size() - 1)]
		if _generate_path(candidate, randi_range(_branch_length.x, _branch_length.y), str(branches_created + 1)):
			branches_created += 1
		else:
			# safety rollback
			_branch_candidates.erase(candidate)

## DEBUG: prints the grid 
func _print_dungeon():
	var dungeon_as_string = ""
	for y in range(_dimensions.y - 1, -1, -1):
		for x in _dimensions.x:
			if dungeon[x][y]:
				dungeon_as_string += "[" + str(dungeon[x][y]) + "]"
			else:
				dungeon_as_string += "   "
		dungeon_as_string += '\n' # <-- fixed typo here
	print(dungeon_as_string)
