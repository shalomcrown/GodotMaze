extends Node3D

enum Direction {EAST, SOUTH, WEST, NORTH}

@export var wall_scene: PackedScene
@export var width: int = 10
@export var height: int = 10
@export var loops: bool = false
@export var entry: Vector2i = Vector2i(0, 0)
@export var exit: Vector2i = Vector2i(9, 9)
@export var entrance_direction: Direction = Direction.WEST
@export var exit_direction: Direction = Direction.EAST

var linear_velocity = 0

var exit_cell
var entry_cell

var cells

var floor_size
var floor_width
var floor_height
var cell_width
var cell_height

class Cell:
	var walls
	var wallsTraversed
	var visited = false
	var row
	var col
	var exit_cell
	var finish
	var exit
	var start
	var entrance
	
	func _init(_row, _col):
		row = _row
		col = _col
		walls = [true, true, true, true]
		wallsTraversed = [false, false, false, false]
		
#--------------------------------------------------------------------------------

func get_cell(row, col):
	return cells[col + row * width]
	
#======================================================================

func get_unvisited_neighbours(cell):
	var neighbours = []
	var next
	
	if (cell.col > 0):
		next = get_cell(cell.row, cell.col - 1)
		if not next.visited:
			neighbours.append(next)

	if (cell.col < width - 1):
		next = get_cell(cell.row, cell.col + 1)
		if not next.visited:
			neighbours.append(next)
			
	if (cell.row > 0):
		next = get_cell(cell.row - 1, cell.col)
		if not next.visited:
			neighbours.append(next)

	if (cell.row < height - 1):
		next = get_cell(cell.row + 1, cell.col)
		if not next.visited:
			neighbours.append(next)
			
	return neighbours

#======================================================================

func removeCommonWall(cellA, cellB):
	if cellA.col == cellB.col:
		if cellA.row < cellB.row:
			cellA.walls[Direction.SOUTH] = false
			cellB.walls[Direction.NORTH] = false
		else:
			cellA.walls[Direction.NORTH] = false
			cellB.walls[Direction.SOUTH] = false
	else:
		if cellA.col < cellB.col:
			cellA.walls[Direction.EAST] = false
			cellB.walls[Direction.WEST] = false
		else:
			cellA.walls[Direction.WEST] = false
			cellB.walls[Direction.EAST] = false


#======================================================================

func new_setup():
	cells = []
	var stack = []
	for row in range(height):
		for col in range(width):
			cells.append(Cell.new(row, col))
	
	var current_cell = get_cell(entry.x, entry.y)
	#current_cell.walls[entrance_direction] = false
	current_cell.visited = true
	entry_cell = current_cell
	stack.append(entry_cell)
	
	exit_cell = get_cell(exit.x, exit.y)
	exit_cell.walls[exit_direction] = false
	
	while (stack.size() > 0):
		var cell = stack.pop_front()
		var neighbours = get_unvisited_neighbours(cell)
		
		if (neighbours.size() > 0):
			stack.append(cell)
			var selectedNeighbour = neighbours[randi() % neighbours.size()]
			selectedNeighbour.visited = true
			stack.append(selectedNeighbour)
			removeCommonWall(cell, selectedNeighbour)

	# TODO: Loops 
	

func add_walls():
	new_setup()
	floor_size = $Floor/CollisionShape3D.shape.size
	floor_width = $Floor/CollisionShape3D.shape.size.x 
	floor_height = $Floor/CollisionShape3D.shape.size.z
	cell_width = floor_width / width
	cell_height = floor_height / height
	
	for row in range(height):
		for col in range(width):
			var cell = get_cell(row, col)
			var cell_corner_x = -floor_width / 2 + col * cell_width
			var cell_corner_z = -floor_height / 2 + row * cell_height
			
			if cell.walls[Direction.NORTH]:
				var wall = wall_scene.instantiate()
				wall.scale.x = cell_width / 2
				#wall.rotation.y = PI / 2
				wall.position.x = cell_corner_x + cell_width / 2
				wall.position.z = cell_corner_z
				add_child(wall)

			if cell.walls[Direction.SOUTH]:
				var wall = wall_scene.instantiate()
				wall.scale.x = cell_width / 2
				#wall.rotation.y = PI / 2
				wall.position.x = cell_corner_x + cell_width / 2
				wall.position.z = cell_corner_z + cell_height
				add_child(wall)
				
									
			if cell.walls[Direction.WEST]:
				var wall = wall_scene.instantiate()
				wall.scale.x = cell_height / 2
				wall.rotation.y = PI / 2
				wall.position.x = cell_corner_x
				wall.position.z = cell_corner_z + cell_height / 2
				add_child(wall)
				
			if cell.walls[Direction.EAST]:
				var wall = wall_scene.instantiate()
				wall.scale.x = cell_height / 2
				wall.rotation.y = PI / 2
				wall.position.x = cell_corner_x + cell_width
				wall.position.z = cell_corner_z + cell_height / 2
				add_child(wall)
	

# Called when the node enters the scene tree for the first time.
func _ready():
	add_walls()
	
	$Player.position.x =  -$Floor/CollisionShape3D.shape.size.x / 2 + entry_cell.col * cell_width + cell_width / 2
	$Player.position.z =  -$Floor/CollisionShape3D.shape.size.x / 2 + entry_cell.col * cell_width + cell_width / 2
	$Player/PlayerCamera.current = true

	
func _process(delta):
	if Input.is_action_just_pressed("ui_home"):
		$CheatCameraPivot/CheatCamera.current = true
	if Input.is_action_just_pressed("ui_cancel"):
		$Player/PlayerCamera.current = true	
