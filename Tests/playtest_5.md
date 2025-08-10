## Playtest 5 – Saving and Loading Profile

1. Open a Godot script console (`F8` run the game is not required). In a
   running project, the `SaveService` autoload is available globally.
2. Create a simple profile dictionary in GDScript:

   ```gdscript
   var profile = {
       "unlocked_cards": ["Dash", "Heal"],
       "fp_budget": 12
   }
   SaveService.save_profile(profile)
   ```

3. The `save_profile()` function uses `FileAccess.open()` with the
   `user://profile.save` path to write data【683929605036038†L21-L41】 and stores
   the dictionary using `store_var()`【683929605036038†L45-L67】.
4. After closing and relaunching the project, call `var loaded =
   SaveService.load_profile()` in the script console. The returned
   dictionary should match the saved profile.
5. End of test.