## Smoke Tests

These tests ensure that scenes and critical systems load without runtime
errors. To run them, open each scene in the Godot editor and run the
project. No asserts are performed – the goal is to confirm that
the project starts and scenes can be instantiated without crashing.

1. **Load Scenes:** In the editor, double click `Scenes/PreMatch.tscn` and
   press **Play Current Scene**. It should display the pre‑match UI
   without any errors. Close and repeat for `Scenes/DemoMatch.tscn`.
2. **Autoloads:** Verify that both `GameState` and `SaveService` appear
   under **Project > Project Settings > Autoload**. They should be
   registered as singletons with correct paths (`Scripts/Autoloads/...`).
3. **Play Through Turn:** Start the game from `PreMatch`, click **Start
   Match**, select a piece, make a legal move and observe that no
   runtime errors occur in the output panel.
4. **Profile Save/Load:** In the script console create and save a
   profile using `SaveService.save_profile({"test": true})`, then
   reload the scene and call `SaveService.load_profile()` to ensure
   persistence.