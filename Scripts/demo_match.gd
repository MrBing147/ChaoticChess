# demo_match.gd
# Scene script for the demonstration match. It generates an 8×8 board,
# spawns pieces in standard chess starting positions, implements base
# chess movement rules and displays HP pips on pieces. It also uses
# GameState to manage turns and selections.

extends Node2D

const BOARD_SIZE: int = 8

## A container that holds the board cells (buttons). Created in _ready().
var board_container: GridContainer

## Maps board positions (Vector2i) to the piece Node occupying that square.
var board: Dictionary = {}

## Preloaded scene for pieces.
var PieceScene := preload("res://Pieces/Piece.tscn")

func _ready() -> void:
    # Setup root UI container for the board.
    board_container = GridContainer.new()
    board_container.columns = BOARD_SIZE
    board_container.anchor_left = 0.0
    board_container.anchor_top = 0.0
    board_container.anchor_right = 1.0
    board_container.anchor_bottom = 1.0
    board_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    board_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
    add_child(board_container)

    # Create 8×8 cells.
    for row in range(BOARD_SIZE):
        for col in range(BOARD_SIZE):
            var cell := Button.new()
            cell.name = "Cell_%d_%d" % [col, row]
            # Store position in metadata so it can be looked up later.
            cell.set_meta("pos", Vector2i(col, row))
            cell.text = ""
            cell.focus_mode = Control.FOCUS_NONE
            # Colour the cell by alternating shades. We use theme overrides for background.
            var style := StyleBoxFlat.new()
            if ((col + row) % 2) == 0:
                style.bg_color = Color(0.9, 0.9, 0.9)
            else:
                style.bg_color = Color(0.5, 0.5, 0.5)
            cell.add_theme_stylebox_override("normal", style)
            cell.pressed.connect(_on_cell_pressed.bind(cell))
            board_container.add_child(cell)

    # Initialise the game state and spawn pieces.
    GameState.start_new_game()
    _setup_initial_positions()

## Return the Button representing the given board coordinate.
func _get_cell(pos: Vector2i) -> Button:
    var index: int = pos.y * BOARD_SIZE + pos.x
    return board_container.get_child(index) as Button

## Create and place pieces on the starting positions. Each piece has a
## UnitResource created on the fly with appropriate name and HP. HP values
## are arbitrary: pawns have 1 HP, knights/bishops/rooks have 2 HP,
## queen and king have 3 HP. Teams are assigned based on row.
func _setup_initial_positions() -> void:
    # Clear board dictionary
    board.clear()
    # Remove any existing piece children from cells.
    for child in get_tree().get_nodes_in_group("pieces"):
        child.queue_free()

    # Helper to create a unit resource.
    func create_unit(name: String, hp: int) -> UnitResource:
        var unit := UnitResource.new()
        unit.unit_name = name
        unit.max_hp = hp
        return unit
    # Definitions for back rank pieces in order per file.
    var back_rank := ["Rook", "Knight", "Bishop", "Queen", "King", "Bishop", "Knight", "Rook"]

    # Spawn pieces for each team.
    for team in [GameState.Team.WHITE, GameState.Team.BLACK]:
        var pawn_row := (team == GameState.Team.WHITE) ? 6 : 1
        var back_row := (team == GameState.Team.WHITE) ? 7 : 0
        # Pawns
        for col in range(BOARD_SIZE):
            var pawn_piece := PieceScene.instantiate() as Piece
            pawn_piece.unit = create_unit("Pawn", 1)
            pawn_piece.team = team
            _place_piece(pawn_piece, Vector2i(col, pawn_row))
        # Back rank pieces
        for col in range(BOARD_SIZE):
            var piece_name: String = back_rank[col]
            var hp: int = 2
            if piece_name in ["King", "Queen"]:
                hp = 3
            var new_piece := PieceScene.instantiate() as Piece
            new_piece.unit = create_unit(piece_name, hp)
            new_piece.team = team
            _place_piece(new_piece, Vector2i(col, back_row))

## Place a piece onto the board at the specified coordinate.
func _place_piece(piece: Piece, pos: Vector2i) -> void:
    # Record in dictionary.
    board[pos] = piece
    # Add to cell.
    var cell := _get_cell(pos)
    cell.add_child(piece)
    # Occupy the entire cell.
    piece.anchor_left = 0.0
    piece.anchor_top = 0.0
    piece.anchor_right = 1.0
    piece.anchor_bottom = 1.0
    piece.board_position = pos
    # Register in group for cleanup
    piece.add_to_group("pieces")

## Handle a cell being pressed. Either selects a piece or performs a move.
func _on_cell_pressed(cell: Button) -> void:
    var pos: Vector2i = cell.get_meta("pos")
    var piece: Piece = board.get(pos, null)
    # If no piece selected yet
    if GameState.selected_piece == null:
        if piece != null and piece.team == GameState.current_turn:
            var moves := _calculate_legal_moves(piece)
            GameState.select_piece(piece, moves)
            _highlight_moves(moves)
        return
    else:
        # If clicking the same team piece, reselect
        if piece != null and piece.team == GameState.current_turn:
            _clear_highlights()
            var moves2 := _calculate_legal_moves(piece)
            GameState.select_piece(piece, moves2)
            _highlight_moves(moves2)
            return
        # Attempt to move to the clicked cell if in legal moves
        var target_moves: Array[Vector2i] = GameState.legal_moves
        for m in target_moves:
            if m == pos:
                _move_piece(GameState.selected_piece, pos)
                return
        # Otherwise, clear selection
        _clear_highlights()
        GameState.selected_piece = null
        GameState.legal_moves = []

## Move the given piece to a new board position. Handles capturing and turn switching.
func _move_piece(piece: Piece, new_pos: Vector2i) -> void:
    var old_pos: Vector2i = piece.board_position
    var target_piece: Piece = board.get(new_pos, null)
    var captured: Node = null
    # If there is an enemy piece on target square, apply damage.
    if target_piece != null and target_piece.team != piece.team:
        var dead := target_piece.apply_damage(1)
        if dead:
            # Remove from scene and board
            board.erase(new_pos)
            captured = target_piece
            target_piece.queue_free()
    # Remove piece from old position
    board.erase(old_pos)
    # Unparent from old cell
    piece.get_parent().remove_child(piece)
    # Place in new cell
    board[new_pos] = piece
    var new_cell := _get_cell(new_pos)
    new_cell.add_child(piece)
    piece.board_position = new_pos
    # Clear highlights and selection
    _clear_highlights()
    GameState.selected_piece = null
    GameState.legal_moves = []
    # Notify game state
    GameState.notify_move(old_pos, new_pos, captured)
    # Check for simple checkmate: no legal moves for opponent's king. For MVP we ignore.
    # End turn
    GameState.end_turn()

## Highlight the given list of positions by tinting the cell colours.
func _highlight_moves(moves: Array[Vector2i]) -> void:
    for pos in moves:
        var cell := _get_cell(pos)
        var style := StyleBoxFlat.new()
        style.bg_color = Color(0.2, 0.7, 0.3, 0.6) # green highlight
        cell.add_theme_stylebox_override("normal", style)

## Reset cell colours to their default.
func _clear_highlights() -> void:
    for row in range(BOARD_SIZE):
        for col in range(BOARD_SIZE):
            var pos := Vector2i(col, row)
            var cell := _get_cell(pos)
            # Determine default colour.
            var default_style := StyleBoxFlat.new()
            if ((col + row) % 2) == 0:
                default_style.bg_color = Color(0.9, 0.9, 0.9)
            else:
                default_style.bg_color = Color(0.5, 0.5, 0.5)
            cell.add_theme_stylebox_override("normal", default_style)

## Calculate legal moves for a given piece based on basic chess rules. Returns an array
## of Vector2i positions. The function takes into account board bounds and blocking pieces,
## but does not implement special moves such as castling, promotion or en passant.
func _calculate_legal_moves(piece: Piece) -> Array[Vector2i]:
    var moves: Array[Vector2i] = []
    var pos: Vector2i = piece.board_position
    var name: String = piece.unit.unit_name
    var team: GameState.Team = piece.team
    # Helper to add a move if it's on the board and not blocked by own piece.
    func try_add(move_pos: Vector2i, capture_only: bool=false):
        if move_pos.x < 0 or move_pos.x >= BOARD_SIZE or move_pos.y < 0 or move_pos.y >= BOARD_SIZE:
            return
        var occupant: Piece = board.get(move_pos, null)
        if occupant == null:
            if not capture_only:
                moves.append(move_pos)
        else:
            if occupant.team != team:
                moves.append(move_pos)

    match name:
        "Pawn":
            var dir := (team == GameState.Team.WHITE) ? -1 : 1
            var start_row := (team == GameState.Team.WHITE) ? 6 : 1
            # Forward move
            var forward_pos := pos + Vector2i(0, dir)
            if board.get(forward_pos, null) == null:
                try_add(forward_pos)
                # Double move from starting row
                if pos.y == start_row:
                    var double_forward := pos + Vector2i(0, dir*2)
                    if board.get(double_forward, null) == null:
                        try_add(double_forward)
            # Captures
            try_add(pos + Vector2i(1, dir), true)
            try_add(pos + Vector2i(-1, dir), true)
        "Rook":
            # Horizontal and vertical lines until blocked
            for dir_vec in [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]:
                var step := 1
                while true:
                    var target := pos + dir_vec * step
                    if target.x < 0 or target.x >= BOARD_SIZE or target.y < 0 or target.y >= BOARD_SIZE:
                        break
                    var occupant := board.get(target, null)
                    if occupant == null:
                        moves.append(target)
                    else:
                        if occupant.team != team:
                            moves.append(target)
                        break
                    step += 1
        "Knight":
            var offsets := [Vector2i(1,2), Vector2i(2,1), Vector2i(-1,2), Vector2i(-2,1), Vector2i(1,-2), Vector2i(2,-1), Vector2i(-1,-2), Vector2i(-2,-1)]
            for off in offsets:
                try_add(pos + off)
        "Bishop":
            for dir_vec in [Vector2i(1,1), Vector2i(-1,1), Vector2i(1,-1), Vector2i(-1,-1)]:
                var step := 1
                while true:
                    var target := pos + dir_vec * step
                    if target.x < 0 or target.x >= BOARD_SIZE or target.y < 0 or target.y >= BOARD_SIZE:
                        break
                    var occupant := board.get(target, null)
                    if occupant == null:
                        moves.append(target)
                    else:
                        if occupant.team != team:
                            moves.append(target)
                        break
                    step += 1
        "Queen":
            # Combine rook and bishop moves
            for dir_vec in [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1), Vector2i(1,1), Vector2i(-1,1), Vector2i(1,-1), Vector2i(-1,-1)]:
                var step := 1
                while true:
                    var target := pos + dir_vec * step
                    if target.x < 0 or target.x >= BOARD_SIZE or target.y < 0 or target.y >= BOARD_SIZE:
                        break
                    var occupant := board.get(target, null)
                    if occupant == null:
                        moves.append(target)
                    else:
                        if occupant.team != team:
                            moves.append(target)
                        break
                    step += 1
        "King":
            for dir_vec in [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1), Vector2i(1,1), Vector2i(-1,1), Vector2i(1,-1), Vector2i(-1,-1)]:
                try_add(pos + dir_vec)
        _:
            # Default: no moves
            pass
    return moves
