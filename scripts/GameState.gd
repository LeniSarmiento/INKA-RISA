extends Node

# Estado global para conectar el menú, el mapa y el nivel jugable.
var selected_level: int = 1
var max_unlocked_level: int = 10
var last_score: int = 0
var completed_levels: Array[int] = []

func select_level(level: int) -> void:
	selected_level = clamp(level, 1, 10)

func mark_completed(level: int, score: int) -> void:
	last_score = score
	if not completed_levels.has(level):
		completed_levels.append(level)
