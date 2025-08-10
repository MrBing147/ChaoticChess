# GameState.gd
# Global singleton for tracking match state, turns and selection. Using
# an autoload allows any scene to access the current game state and
# connect to its signals.

extends Node
class_name GameState

## Teams. In base chess there are two: white and black.
enum Team { WHITE, BLACK }

## Current team whose turn it is.
var current_turn: Team = Team.WHITE

## Reference to the currently selected piece node (or null if none).
var selected_piece: Node = null

## Legal moves for the selected piece. Populated by DemoMatch when a piece is selected.
var legal_moves: Array[Vector2i] = []

## Signals
signal turn_started(current_team)
signal piece_selected(piece, moves)
signal move_made(from_pos, to_pos, captured)
signal game_over(winner)

## Start a new game. Resets turn and selections.
func start_new_game() -> void:
    current_turn = Team.WHITE
    selected_piece = null
    legal_moves = []
    emit_signal("turn_started", current_turn)

## Switch to the other team and emit `turn_started`.
func end_turn() -> void:
    current_turn = Team.BLACK if current_turn == Team.WHITE else Team.WHITE
    selected_piece = null
    legal_moves = []
    emit_signal("turn_started", current_turn)

## Inform GameState that a piece has been selected. Stores the selected piece and its legal moves.
func select_piece(piece: Node, moves: Array[Vector2i]) -> void:
    selected_piece = piece
    legal_moves = moves
    emit_signal("piece_selected", piece, moves)

## Notify that a move has been made. Called by DemoMatch after moving a piece.
func notify_move(from_pos: Vector2i, to_pos: Vector2i, captured: Node = null) -> void:
    emit_signal("move_made", from_pos, to_pos, captured)

## Notify that the game is over. Provide the winner (Team enum) or null for draw.
func notify_game_over(winner):
    emit_signal("game_over", winner)
