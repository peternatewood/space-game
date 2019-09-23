extends RigidBody

var hitpoints: int = 100


func _ready():
	self.connect("body_entered", self, "_on_body_entered")


func _on_body_entered(body):
	hitpoints -= 1
	print("Body Entered; hitpoints: ", hitpoints)
