# piece.gd
# Script attached to each piece instance. Manages unit data, current HP and
# visual representation of the piece (symbol and HP pips).

extends Control
class_name Piece

## Resource describing this unit. Can be assigned via inspector.
@export var unit: UnitResource

## Which team the piece belongs to (GameState.Team.WHITE or BLACK).
@export var team: GameState.Team = GameState.Team.WHITE

## Current hit points. Defaults to unit.max_hp when the piece is spawned.
var hp: int

## Board coordinates (0‑7 for x and y). Updated by DemoMatch when moving.
var board_position: Vector2i = Vector2i.ZERO

## Called when the node enters the scene tree for the first time.
func _ready() -> void:
    # Initialise HP from the unit resource.
    hp = unit.max_hp if unit else 1
    _update_visuals()

## Apply damage to this piece. Returns true if the piece is dead.
func apply_damage(amount: int) -> bool:
    hp -= amount
    _update_visuals()
    return hp <= 0

## Update the displayed symbol and HP pips.
func _update_visuals() -> void:
    var symbol_label := $Symbol as Label
    var hp_label := $HPLabel as Label
    if unit:
        symbol_label.text = unit.unit_name.substr(0,1) # Use first letter as a simple symbol.
    else:
        symbol_label.text = "?"
    # Display HP as hearts or filled circles.
    hp_label.text = "".join(["❤️" for i in range(hp)])
