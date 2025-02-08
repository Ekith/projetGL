class_name Bole

extends Spell

var mode : int #The Fireball is inactive at 0, 1 it is visible and 2 the ball is thrown
var position_t_moins_1 : Vector3
var t0 : int
var velocity : Vector3
var list_of_position : Array
var collision_shape: CollisionShape3D
var number_of_frame_since_release : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mode = 0
	t0 = 0
	number_of_frame_since_release = 0
	list_of_position = []
	collision_shape = get_node("CollisionShape3D")
	collision_shape.disabled = true
	visible = true  
	#var left_hand =get_parent_node_3d().get_parent_node_3d().get_node("Player").get_node("LeftHand")
	#var left_hand_position = left_hand.global_position
	#position = left_hand_position
	#velocity = Vector3(0, 0, 0)
	#list_of_position.append(position)
	gravity_scale = 0
	mass = 0
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var left_hand = get_parent_node_3d().get_parent_node_3d().get_node("Player").get_node("LeftHand")
	var left_hand_position = left_hand.global_position

	if mode == 0:
		position = left_hand_position
		list_of_position.append(position)
		if list_of_position.size() > 5:
			list_of_position.pop_at(0)
	elif mode == 1:
		if(number_of_frame_since_release < 10) :
			number_of_frame_since_release = number_of_frame_since_release + 1
		else :
			collision_shape.disabled = false 
		if t0 == 0:
			t0 = Time.get_ticks_msec()  # Définir t0 une seule fois
		velocity = calcul_velocity(left_hand_position, delta)
		linear_velocity = velocity 
		# Supprimer la boule après 3 secondes
		if Time.get_ticks_msec() - t0 > 3000:
			var scene = get_parent_node_3d()
			get_parent().remove_child(self)

func calcul_velocity(positionT, delta):
	# Moyenne glissante sur les dernières positions
	var moyenne_position = moyennnePosition(list_of_position)
	var velo = (moyenne_position - position_t_moins_1) / delta
	return velo


func moyennnePosition(list_of_position):
	var list_of_x : Array = []
	var list_of_y : Array = []
	var list_of_z : Array = []
	#Create lists of x, y and z
	for i in range(list_of_position.size()):
		list_of_x.append(list_of_position[i][0])
		list_of_y.append(list_of_position[i][1])
		list_of_z.append(list_of_position[i][2])
		#Calculous of the sums
	var somme_x = 0
	for x in list_of_x:
		somme_x += x
	
	var somme_y = 0
	for y in list_of_y:
		somme_y += y
	
	var somme_z = 0
	for z in list_of_z:
		somme_z += z
	
	# Calculous of the means
	var moyenne_x = somme_x / list_of_x.size()
	var moyenne_y = somme_y / list_of_y.size()
	var moyenne_z = somme_z / list_of_z.size()
	
	# Insert it into a vector
	var position = [moyenne_x, moyenne_y, moyenne_z]	
	return position
