## Playtest 1 – Pre‑Match Flow

1. Launch the project in the Godot editor.
2. The `PreMatch` scene loads automatically as defined in `project.godot`.
3. Verify the screen title reads **"Chaotic Chess"** and that the FP budget label
   displays `FP Budget: 0 / 10` (the current total is zero because no items are selected).
4. Inspect the list of items. Two placeholders (Item A and Item B) should
   appear with FP costs in parentheses. These are mock cards for the MVP.
5. Click the **Start Match** button. The `DemoMatch` scene should load.
6. After the transition there should be an 8×8 board with pieces in the
   standard chess starting layout and HP pips displayed on each piece.
7. End of test.