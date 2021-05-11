extends Sprite
class_name Piece

# Declare member variables here. Examples:
# references
var tile = null # no explicit typing
var cached_tile = null
var main_ref = null

# piece type and team
var piece_type = 0 
var team = 0
var team_prefix = ""

# moves
var possible_moves = [] # type Move
var has_moved : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	main_ref = tile.main_ref
	team_prefix = "white_" if team == 0 else "black_"
	set_piece_type(piece_type)
	
func set_piece_type(new_piece_type : int):
	piece_type = new_piece_type
	texture = load("res://Sprites/"+team_prefix+PieceType.new().PIECES[piece_type].to_lower()+".png")

func search_for_path_block(input_array):
	var ret_data = []
	for i in range(input_array.size()):
		var t = input_array[i]
		var piece = t.piece
		if piece == null:
			ret_data.append(Move.new(self.tile, t, self, null))
		else:
			if piece.team == team:
				break
			else:
				ret_data.append(Move.new(self.tile, t, self, piece))
				break
	return ret_data

func generate_vertical_moves():
	var data = []
	data.append_array(search_for_path_block(tile.get_upward()))
	data.append_array(search_for_path_block(tile.get_downward()))
	return data
	
func generate_horizontal_moves():
	var data = []
	data.append_array(search_for_path_block(tile.get_left()))
	data.append_array(search_for_path_block(tile.get_right()))
	return data
	
func generate_diagonal_moves():
	var data = []
	data.append_array(search_for_path_block(tile.get_up_left()))
	data.append_array(search_for_path_block(tile.get_up_right()))
	data.append_array(search_for_path_block(tile.get_down_left()))
	data.append_array(search_for_path_block(tile.get_down_right()))
	return data
	
func is_possible_move(tile):
	for move in possible_moves:
		if move.end_tile == tile:
			return true
	return false

func get_possible_move(end_tile):
	for move in possible_moves:
		if move.end_tile == end_tile:
			return move

func clear_pseudo_legals():
	var cache = possible_moves.duplicate()
	possible_moves.clear()
	for move in cache:
		main_ref.move(move, true)
		if !get_team().get_enemy_team().has_enemy_in_check():
			possible_moves.append(move)
		main_ref.undo_move(move, true)

#	var move = possible_moves[4]
#	main_ref.move(move, true)
#	if !get_team().get_enemy_team().has_enemy_in_check():
#		possible_moves.append(move)	

func generate_possible_moves(pseudo_check : bool =  true): # this is gonna be messy...
	possible_moves.clear()
	
	var generation = []
	match piece_type:
		0: # pawn
			pass
		1: # rook
			possible_moves.append_array(generate_vertical_moves())
			possible_moves.append_array(generate_horizontal_moves())
		2: # knight
			pass
		3: # bishop
			possible_moves.append_array(generate_diagonal_moves())
		4: # queen
			possible_moves.append_array(generate_vertical_moves())
			possible_moves.append_array(generate_horizontal_moves())
			possible_moves.append_array(generate_diagonal_moves())
		5: # king
			var s = tile.get_surrounding_tiles()
			for t in s:
				if t.has_piece() and t.has_enemy_piece(team):
					possible_moves.append(Move.new(tile, t, self, t.piece))
				elif !t.has_piece():
					possible_moves.append(Move.new(tile, t, self, null))
	if pseudo_check:
		clear_pseudo_legals()
		
	possible_moves.append(Move.new(tile, tile, self, null)) # always allow the user to put the piece back

					
func results_in_check(move : Move, team : int):
	pass

func set_tile(new_tile):
	tile = new_tile
	position = tile.position
	
func get_team():
	return main_ref.teams[team]


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass