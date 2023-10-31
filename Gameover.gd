extends Control
func init(kills, score):
	$AudioStreamPlayer.play()
	$Kills.text = "Asteroids destroyed: " + str(kills)
	$Score.text = "Score: " + str(score)
