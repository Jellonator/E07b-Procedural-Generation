extends Node2D

const N := 1
const E := 2
const S := 4
const W := 8

var cell_walls := {
	Vector2( 0, -1): N,
	Vector2( 1,  0): E,
	Vector2( 0,  1): S,
	Vector2(-1,  0): W
}

var tile_size := Vector2(64, 64)
var width := 40
var height := 24

onready var node_map := $TileMap

func _ready():
	randomize()
	tile_size = node_map.cell_size
	node_map.scale = get_viewport().get_size() / (tile_size * Vector2(width, height))
	make_maze()

func check_neighbors(cell: Vector2, unvisited: Dictionary) -> Array:
	var ls := []
	for n in cell_walls.keys():
		if cell + n in unvisited:
			ls.append(cell + n)
	return ls

func make_maze():
	var unvisited := {}
	node_map.clear()
	for ix in range(width):
		for iy in range(height):
			var pos := Vector2(ix, iy)
			unvisited[pos] = pos
			node_map.set_cellv(pos, N|E|S|W)
	var stack := []
	unvisited.erase(Vector2(0, 0))
	stack.append(Vector2(0, 0))
	while not stack.empty():
		var pos := stack.back() as Vector2
		var neighbors := check_neighbors(pos, unvisited)
		if neighbors.size() == 0:
			stack.pop_back()
		else:
			var next := neighbors[randi() % neighbors.size()] as Vector2
			var dir := next - pos
			var current_walls = node_map.get_cellv(pos) & ~cell_walls[dir]
			var next_walls = node_map.get_cellv(next) & ~cell_walls[-dir]
			node_map.set_cellv(pos, current_walls)
			node_map.set_cellv(next, next_walls)
			unvisited.erase(next)
			stack.append(next)
			yield(get_tree(), "idle_frame")
