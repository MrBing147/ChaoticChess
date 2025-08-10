# EffectData.gd
# Describes an effect applied by cards or abilities. Uses exported
# properties so designers can configure the effect in the inspector【981542292177860†L120-L143】.

extends Resource
class_name EffectData

## Enumeration of effect types. Additional types can be added later.
enum EffectType { DAMAGE, HEAL, BUFF, DEBUFF }

## The type of the effect.
@export var type: EffectType = EffectType.DAMAGE

## Magnitude of the effect (e.g. amount of damage or heal). Interpreted according to type.
@export var magnitude: float = 0.0

## Duration of the effect in turns. 0 means instantaneous.
@export var duration: int = 0

## Whether the effect targets self (true) or an opponent (false).
@export var targets_self: bool = false

## Additional data can be stored here for complex effects.
@export var metadata: Dictionary = {}
