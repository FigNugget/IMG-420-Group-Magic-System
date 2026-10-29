extends Node

var health: int = 3
var total_coins: int = 0

func coin_collected(value: int):
	total_coins += value
	EventController.emit_signal("coin_collected", total_coins)

func health_deplete(value: int):
	health -= 1
	EventController.emit_signal("health_deplete", health)
