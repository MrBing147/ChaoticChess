# CardResource.gd
# Defines a card that can be played during the match. Cards modify
# movement or combat behaviour. This is a custom resource
# so it can be authored easily within the editor【981542292177860†L120-L143】.

extends Resource
class_name CardResource

## Name of the card (e.g. "Dash", "Heal")
@export var card_name: String = ""

## Energy/FP cost to play this card. FP budget is set on the pre-match screen.
@export var cost: int = 1

## Description shown to the player explaining the effect.
@export var description: String = ""

## The EffectData object that will be applied when this card is used. A
## card may apply multiple effects; the array is exported for extensibility.
@export var effects: Array[Resource] = []
