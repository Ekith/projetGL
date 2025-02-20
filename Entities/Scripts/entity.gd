class_name Entity

extends CharacterBody3D

enum races {
	Human,
	Dwarf,
	Dog,
	Goblin,
	BOSS
}

enum passiveMode {
	STILL, ## It stays still
	CAMP,  ## It randomly moves in a certain zone
	FOLLOWING_PATH ## It follows a precalculed path
}

enum aggressiveMode {
	STILL, ## It stays still
	FLEEING, ## It flies from the player
	DISTANCE, ## It stays at a precalculated distance from the player to use range weapons
	MELEE, ## It comes to the player to use melee weapons
	DISTMELEE ## It stays away from the player until they reach a limit, then it comes to them
}
	
enum targetingMode {
	NEAR, ## It targets the player when they enters his field of view
	INTERACTION, ## It targets the player when they interacts with it
	ATTACK ## It targets the player in response of its atatck
}

@export var race : races ## The entity's race
@export var description : String ## A brief description of the entity's lore
@export var hpMax : int ## The maximum amount of health points
var hp : int ## The current amount of health points
@export var isInvincible : bool ## Defines wheather or not it can die
@export var isTrackingPlayer : bool ## Definies wheter or not it follows the player


@export var speed : int ## Defines the entity's speed
@onready var navigation_agent_3d = $NavigationAgent3D

var last_time_pterg_pos_chg : float
var time_reach_targ_pos : float

@export_group("Behavior")

# entity mode 
@export_subgroup("Choose Behavior")
@export var pMode : passiveMode
@export var aMode : aggressiveMode
@export var tMode : targetingMode


# variable for camp behavior in passive mode
@export_subgroup("Camp passive mode")
var spawn_point : Vector3
@export var radius : float ## Radius of the zone, it randomly moves in

# variable for following path behavior in passive mode
@export_subgroup("Following path passive mode")
@export var list_of_position : Array ## Array containing the coordinates the entity has to reach along its path
var current_position_in_list : int
@export var reverse : int ## Refer to the passive_movement func doc (may change later)

# variable for aggressive mode
@export_subgroup("Aggressive mode")
var position_status_change : Array
@export var melee_distance : float ## Distance under which the entity attacks in melee
@export var dist_distance : float ## Distance at which the entity wants shoot the player
@export var stop_fleeing_distance : float ## Distance at which the entity will stop targeting the player


func movement()->Vector3:
	var res : Vector3
	if isTrackingPlayer == true:
		res = aggressive_movement()
		print("res aMode", res)
	else:
		res = passive_movement()
		print("res pMode", res)
	return res



func aggressive_movement() -> Vector3:
	var res : Vector3
	var player_position = get_parent_node_3d().get_parent_node_3d().get_node("Player").global_position
	if aMode == aggressiveMode.STILL:
		res = MovementAggressive.stillBehavior(position)
	elif aMode == aggressiveMode.FLEEING:
		res = MovementAggressive.fleeingBehavior(position, player_position, stop_fleeing_distance)
	elif aMode == aggressiveMode.DISTANCE:
		res = MovementAggressive.distanceBehavior(position, player_position, position_status_change)
	elif aMode == aggressiveMode.MELEE:
		res = MovementAggressive.meleeBehavior(position, player_position, position_status_change)
	elif aMode == aggressiveMode.DISTMELEE:
		res = MovementAggressive.meleeDistBehavior(position, player_position, position_status_change)
	else:
		res = position
	return res
	

func passive_movement()->Vector3:
	var res : Vector3
	if pMode == passiveMode.STILL:
		res = MovementPassive.stillBehavior(position)
	elif pMode == passiveMode.CAMP:
		res = MovementPassive.campBehavior(position, rotation, spawn_point, radius)
	elif  pMode == passiveMode.FOLLOWING_PATH:
		var tmp = MovementPassive.followingPathBehavior(list_of_position, current_position_in_list, reverse)
		res = tmp[0]
		current_position_in_list = tmp[1]
		reverse = tmp[2]
	else:
		res = position
	return res


func setTarget():
	if tMode == targetingMode.NEAR:
		print('=== DEBUG ===')
		print(get_parent_node_3d().get_children())
		if Movement.distanceVect(position, get_parent_node_3d().get_parent_node_3d().get_node("Player").global_position) < stop_fleeing_distance:
			isTrackingPlayer = true
		else :
			navigation_agent_3d.target_position = spawn_point
			isTrackingPlayer = false
			
	
	
func set_new_pos()->void:
	navigation_agent_3d.target_position = movement()
	last_time_pterg_pos_chg = Time.get_ticks_msec()
	time_reach_targ_pos = Time.get_ticks_msec()
	
	print("res2 ->", navigation_agent_3d.target_position)




func take_damage(damages : int):
	if !isInvincible:
		hp -= damages
		if (hp <= 0):
			queue_free()
	


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hp = hpMax; #hp initialization
	spawn_point = position
	current_position_in_list = 0
	isTrackingPlayer = false
	last_time_pterg_pos_chg = Time.get_ticks_msec()
	time_reach_targ_pos = Time.get_ticks_msec()
	position_status_change = [melee_distance, dist_distance]
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	setTarget()
	
	
	if isTrackingPlayer == false:
		if pMode == passiveMode.CAMP:
			if navigation_agent_3d.is_navigation_finished() or Time.get_ticks_msec()-last_time_pterg_pos_chg > 5000 :
					if Time.get_ticks_msec() - time_reach_targ_pos > 3000:
						set_new_pos()
	else:
		set_new_pos()
	
	velocity = global_position.direction_to(navigation_agent_3d.get_next_path_position()) * speed
	
	if is_on_floor() == false:
		velocity += get_gravity() * delta

	move_and_slide()
	
