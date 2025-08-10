# Chaotic Chess – Mini GDD (MVP)

## Vision

**Chaotic Chess** combines classical chess tactics with a collectible card system
and hit‑point (HP) based combat.  Players begin by drafting cards in a
pre‑match phase and then deploy standard chess pieces on an 8×8 board.
Pieces have HP pips; instead of being removed immediately, captured units
lose HP until they are destroyed.  Cards grant temporary abilities or
alter movement/attack patterns.  The MVP demonstrates core systems:
pre‑match selection, an interactive board with legal moves, HP reduction
and saving/loading of player profiles.

## Mechanics

* **Board & Movement:** The game uses an 8×8 grid like chess.  Movement
  patterns are defined in `MovementData` resources, using direction
  vectors and step counts.  The board logic uses tile‑based movement
  similar to grid‑based games: a piece’s position is snapped to the grid
  and moves are calculated by adding relative offsets【429551017522398†L22-L75】.
* **Units:** Each piece is defined by a `UnitResource` which extends
  Godot’s `Resource` class【981542292177860†L120-L143】.  The resource stores the
  unit name, max HP, movement and attack data and default cards.  In the
  MVP, standard chess pieces are created at runtime with HP values (1
  for pawns, 2 for rooks/knights/bishops and 3 for king/queen).  When
  a unit is damaged its HP pips decrease; when HP reaches zero the
  piece is removed.
* **Cards:** Cards are instances of `CardResource`.  A card has a name,
  FP cost, description and one or more `EffectData` objects.  Effects
  specify a type (damage, heal, buff), magnitude and duration.  Cards
  are not fully implemented in the MVP but scaffolding exists for
  future expansion.
* **FP (Force Points) Budget:** Before each match the player has a fixed
  FP budget used to select cards.  The Pre‑Match screen lists
  available cards and shows remaining FP.  For the MVP the list uses
  placeholder items.  The FP budget is configurable in the script.
* **Saving & Profiles:** A `SaveService` singleton persists player
  profiles to disk using Godot’s `FileAccess`.  User data is saved
  under `user://` rather than `res://` (packaged resources) as per the
  engine guidelines【683929605036038†L21-L41】.  Profiles are serialized with
  `store_var()` and loaded with `get_var()`【683929605036038†L45-L67】.

## Game Loop

1. **Pre‑Match:** The player enters the pre‑match screen where they see
   their FP budget and available cards.  They select cards within the
   budget (mocked in the MVP).  Pressing **Start Match** transitions to
   the match scene.
2. **Match:**  The board spawns with standard chess pieces.  On a
   player’s turn they click a piece to view its legal moves; green
   highlights show where it can move.  Clicking a highlighted square
   moves the piece.  Capturing an opponent unit reduces its HP.  If
   HP falls to zero the unit is removed.
3. **Turn Switching:** After a valid move the turn switches.  The game
   ends when one king is destroyed.  Advanced chess rules (castling,
   en passant, promotion) are omitted in the MVP.
4. **Post‑Match:** In a full game the outcome would feed back into the
   profile, unlocking cards or adjusting FP budget.  The MVP focuses
   solely on match play.

## Architecture Overview

### Scene Hierarchy

```
ChaoticChess
├── project.godot         (project settings and autoloads)
├── Scenes
│   ├── PreMatch.tscn     (Control)
│   │   ├── MarginContainer
│   │   │   └── VBoxContainer
│   │   │       ├── Label           (title)
│   │   │       ├── Label           (FP budget)
│   │   │       ├── VBoxContainer   (items list)
│   │   │       └── Button          (start match)
│   └── DemoMatch.tscn    (Node2D)
│       └── GridContainer (8×8 board, created at runtime)
├── Pieces
│   └── Piece.tscn        (Control)
│       ├── Label         (symbol)
│       └── Label         (HP pips)
├── Scripts
│   ├── Autoloads
│   │   ├── game_state.gd (singleton for turns, selection & signals)
│   │   └── save_service.gd (singleton for saving/loading profiles)
│   ├── Resources
│   │   ├── unit_resource.gd
│   │   ├── card_resource.gd
│   │   ├── effect_data.gd
│   │   └── movement_data.gd
│   ├── demo_match.gd     (handles board creation, movement & capture)
│   ├── pre_match.gd      (handles pre‑match UI & scene switch)
│   └── piece.gd          (per‑piece behaviour, HP)
└── Tests
    ├── playtest_1.md – Pre‑Match Flow
    ├── playtest_2.md – Pawn Movement
    ├── playtest_3.md – Knight Movement
    ├── playtest_4.md – Capturing & HP
    ├── playtest_5.md – Save/Load Profile
    └── smoke_tests.md
```

### Data & Systems

* **Resources:**  `UnitResource`, `CardResource`, `EffectData` and
  `MovementData` extend `Resource` and use exported variables.  Using
  `class_name` makes them accessible from the inspector so designers
  can create new units and cards without scripting【981542292177860†L120-L143】.
* **Autoloads:**  `GameState` holds the current turn, selected piece and
  emits signals (`turn_started`, `piece_selected`, `move_made`,
  `game_over`).  `SaveService` handles serialisation and uses the
  `user://` path for writing files【683929605036038†L21-L41】.
* **DemoMatch:**  At runtime it instantiates a `GridContainer` for
  the board.  Each cell is a `Button` with an alternating colour.  The
  script tracks a `board` dictionary mapping positions to `Piece`
  nodes.  When a piece is selected, it calculates legal moves using
  helper functions derived from chess rules.  Moves are highlighted
  by replacing the cell’s style box.  On move completion the script
  updates the `board` mapping, applies damage to captured pieces and
  signals the end of the turn via `GameState`.
* **PreMatch:** Displays the player’s FP budget and available cards.
  On pressing **Start Match** it calls `GameState.start_new_game()` and
  instantiates the `DemoMatch` scene, replacing the current scene.

## Controls & UX

* **Selecting Units:** Tap a piece to select it.  Legal moves highlight in
  green.  Tap a highlighted square to move.
* **HP Pips:** Hearts below each piece show remaining HP.  Damage
  reduces hearts; zero hearts removes the piece.
* **Portrait Orientation:** The project settings lock the orientation to
  portrait for mobile phones via `window/handheld/orientation = 1`.
* **Saving:** Profile saving/loading occurs via script calls (there is
  no UI yet).  The profile includes unlocked cards and FP budget.

## Future Work

The MVP lays the groundwork for more complex mechanics:

* Implement card selection in the Pre‑Match screen and card effects in
  matches (movement modifiers, buffs, debuffs).
* Add win conditions such as check/checkmate or destruction of all
  opposing units.
* Integrate an AI opponent for single‑player play.
* Create additional unit types and boards beyond standard chess.
* Provide an in‑game tutorial and UI feedback for card usage.