extends GutTest

const CORE_DIR := "res://src/core"
const BANNED_PATTERNS: Array[String] = [
	"Input\\.",
	"get_tree\\(",
	"Time\\.",
	"OS\\.get_ticks",
	"(?<!\\.)\\brandf\\(",
	"(?<!\\.)\\brandi\\(",
]


func test_core_has_no_forbidden_dependencies() -> void:
	var scripts := _find_scripts(CORE_DIR)
	assert_true(scripts.size() > 0, "core must contain at least one script")

	var regexes: Array[RegEx] = []
	for pattern in BANNED_PATTERNS:
		var regex := RegEx.new()
		var error := regex.compile(pattern)
		assert_eq(error, OK, "invalid banned pattern: %s" % pattern)
		regexes.append(regex)

	var violations: Array[String] = []

	for path in scripts:
		var file := FileAccess.open(path, FileAccess.READ)
		assert_not_null(file, "cannot open %s" % path)
		if file == null:
			continue

		var line_number := 0
		while not file.eof_reached():
			line_number += 1
			var line := file.get_line()
			var code := line.split("#", true, 1)[0]
			for index in regexes.size():
				if regexes[index].search(code) != null:
					violations.append("%s:%d: %s" % [path, line_number, BANNED_PATTERNS[index]])
		file.close()

	assert_eq(
		violations.size(),
		0,
		"forbidden dependencies in src/core:\n%s" % "\n".join(PackedStringArray(violations))
	)


func _find_scripts(dir_path: String) -> Array[String]:
	var scripts: Array[String] = []
	var directory := DirAccess.open(dir_path)
	if directory == null:
		return scripts

	directory.list_dir_begin()
	var entry := directory.get_next()
	while entry != "":
		if not entry.begins_with("."):
			var full_path := dir_path.path_join(entry)
			if directory.current_is_dir():
				scripts.append_array(_find_scripts(full_path))
			elif entry.ends_with(".gd"):
				scripts.append(full_path)
		entry = directory.get_next()
	directory.list_dir_end()
	return scripts
