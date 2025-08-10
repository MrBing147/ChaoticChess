# pre_match.gd
# Handles the pre-match screen where players can view their FP budget and
# select cards/items before starting a match. For the MVP this screen
# displays mock items and transitions to the demo match when the
# start button is pressed.

extends Control

@onready var budget_label: Label = $Margin/VBox/BudgetLabel
@onready var start_button: Button = $Margin/VBox/StartButton

## FP budget available to the player. In a full game this might be loaded
## from SaveService or set based on difficulty. Here it's a constant.
var fp_budget: int = 10

func _ready() -> void:
    budget_label.text = "FP Budget: 0 / %d" % fp_budget
    start_button.pressed.connect(_on_start_button_pressed)

## Start the match by changing scenes to DemoMatch.
func _on_start_button_pressed() -> void:
    # Reset game state.
    GameState.start_new_game()
    # Change to DemoMatch scene
    var demo_scene := preload("res://Scenes/DemoMatch.tscn").instantiate()
    get_tree().current_scene.free()
    get_tree().current_scene = demo_scene
    get_tree().root.add_child(demo_scene)
