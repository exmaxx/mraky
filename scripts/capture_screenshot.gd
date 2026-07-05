extends SceneTree

const OUTPUT := "user://screenshot.png"


func _initialize() -> void:
	call_deferred("_capture")


func _capture() -> void:
	var scene: PackedScene = load("res://scenes/main.tscn")
	var main: Node = scene.instantiate()
	root.add_child(main)

	await process_frame
	await process_frame
	await create_timer(0.5).timeout

	var image: Image = root.get_viewport().get_texture().get_image()
	var path := ProjectSettings.globalize_path(OUTPUT)
	var err := image.save_png(path)
	if err != OK:
		push_error("Screenshot failed: %s" % err)
		quit(1)
		return

	print("SCREENSHOT_SAVED:", path)
	quit()
