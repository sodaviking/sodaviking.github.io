extends Node2D

var score: int = 0

@onready var scoreLabel = $ScoreLabel 

func _on_potato_object_potatohit():
	score += 1
	scoreLabel.text = str(score)
