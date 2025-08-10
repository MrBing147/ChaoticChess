# SaveService.gd
# Provides simple persistent storage for player profiles and settings.
# It uses Godot's FileAccess API to read and write to files located in
# the `user://` directory, as recommended by the Godot docs【683929605036038†L21-L41】.
# Data is saved using `store_var()` and loaded using `get_var()`【683929605036038†L45-L67】.
# Do not store user data in `res://` because packaged games cannot write
# there【683929605036038†L21-L31】.

extends Node
class_name SaveService

## Signal emitted after a successful profile save.
signal profile_saved

## Signal emitted after a profile is loaded. The profile data is passed as
## the first argument.
signal profile_loaded(data)

## Path relative to user:// where the profile is stored.
var profile_path: String = "user://profile.save"

## Save the given profile dictionary to disk. Emits `profile_saved` on success.
func save_profile(profile: Dictionary) -> void:
    var file := FileAccess.open(profile_path, FileAccess.WRITE)
    if file == null:
        push_warning("Failed to open file for writing: %s" % profile_path)
        return
    # store_var serialises Godot objects and dictionaries【683929605036038†L45-L67】
    file.store_var(profile)
    file.close()
    emit_signal("profile_saved")

## Load the profile from disk. Returns an empty dictionary if no file exists.
func load_profile() -> Dictionary:
    if not FileAccess.file_exists(profile_path):
        # Return a new profile with default values if nothing is saved.
        return {}
    var file := FileAccess.open(profile_path, FileAccess.READ)
    if file == null:
        push_warning("Failed to open file for reading: %s" % profile_path)
        return {}
    # get_var deserialises the stored data【683929605036038†L45-L67】
    var data := file.get_var()
    file.close()
    emit_signal("profile_loaded", data)
    return data
