# UnitResource.gd
# Defines the basic attributes for a unit in Chaotic Chess.
# This custom resource is loaded in the editor and assigned to pieces.
# See the Godot resource system documentation for details on how to
# create custom resources by extending `Resource` and assigning a
# `class_name`【981542292177860†L120-L143】.

extends Resource
class_name UnitResource

## Display name of the unit (e.g. "Knight", "Goblin")
@export var unit_name: String = ""

## Maximum hit points for this unit. Each pip is visualised on the board.
@export var max_hp: int = 1

## Movement data defining how this unit can move. Should reference a MovementData resource.
@export var movement_data: Resource

## Attack data defining how this unit attacks. Should reference a MovementData resource
## or a future AttackData resource. For MVP this can be the same as movement_data.
@export var attack_data: Resource

## Default deck of cards available to this unit at start. Cards modify movement or
## apply effects. Cards are optional for the MVP and may be empty.
@export var default_cards: Array[Resource] = []
