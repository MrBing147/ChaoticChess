# MovementData.gd
# Represents a set of relative tile offsets that a unit can move or attack.
# For example, a knight's movement offsets would include (2,1), (1,2), etc.
# A bishop would have directions with unlimited range. Use `infinite_range`
# for pieces like bishops, rooks and queens. This resource can also be
# reused for attack patterns.

extends Resource
class_name MovementData

## List of direction vectors representing allowable moves relative to
## the current position. Each vector is a Vector2 where x and y are
## grid offsets (column, row).
@export var directions: Array[Vector2] = []

## Maximum number of steps the piece can move in a given direction. 1 means
## the piece moves exactly one square (e.g. king, knight, pawn). Use a
## high value like 8 for rooks, bishops and queens to denote unlimited
## range on an 8×8 board. Setting `infinite_range` to true overrides
## this value.
@export var max_steps: int = 1

## If true, the piece can move any number of squares in the given directions
## until blocked. When true, `max_steps` is ignored.
@export var infinite_range: bool = false

## Whether this movement data is for attack only; if true, it may not
## determine movement. Not used in the MVP but reserved for future design.
@export var attack_only: bool = false
