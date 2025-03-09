class_name PlayerScript

extends Node3D

const SPEED = 10.0
const JUMP_VELOCITY = 4.5

enum SpellEnum {FIREBALL, ## Spell fireball
				HEALORB, ## Spell 2
				ELECTRICARC ## Spell 3
				}
var selected_spell : SpellEnum ## The variable where the selected spell is save

# Références des noeuds enfants
@onready var camera: Camera3D = $Camera
@onready var left_hand: Node3D = $LeftHand
@onready var right_hand: Node3D = $RightHand

enum Hands {
	RIGHT,
	LEFT
}
@export var main_hand : Hands

# @export var name : String
@export var stats : Statistics = Statistics.new()

# Delete this variable when Statistics will be implemented
@export var hpMax : int
var hp : int

@export var manaMax : int
var mana : int
var t_recharge_mana ## last time the mana was regen

# @export var armorSet : Set
var inventory : Array[Object]

func _ready():
	mana = manaMax
	hp = 50
	t_recharge_mana = Time.get_ticks_msec()
	
	

## Function which regen the the number of manapoint every second (replace this function later)
func recharge_mana():
	if mana+2 < manaMax:
		if Time.get_ticks_msec()-t_recharge_mana>1000:
			mana +=2
			t_recharge_mana = Time.get_ticks_msec()


func _on_equipment(new_stats:Variant) -> void:
	stats.HP += new_stats.HP
	stats.ATK += new_stats.ATK
	stats.DEF += new_stats.DEF
	stats.speed += new_stats.speed
	stats.ATKSpeed *= new_stats.ATKSpeed
	
func _on_unequipment(old_stats:Variant) -> void:
	stats.HP -= old_stats.HP
	stats.ATK -= old_stats.ATK
	stats.DEF -= old_stats.DEF
	stats.speed -= old_stats.speed
	stats.ATKSpeed /= old_stats.ATKSpeed


## return the scene of the spell to instantiate in function of the variable SpellEnum
func which_spell():
	if selected_spell == SpellEnum.FIREBALL:
		return "res://Spells/Fireball/Scenes/fire_ball.tscn"
	elif selected_spell == SpellEnum.HEALORB:
		return "res://Spells/Fireball/Scenes/heal_orb.tscn"
	elif selected_spell == SpellEnum.ELECTRICARC:
		return "res://Spells/Fireball/Scenes/electric_arc.tscn"


## Reduce the number of manapoint (function call by spells)
func lost_mana(mana_point_consume : int)->bool:
	if mana - mana_point_consume < 0:
		return false
	else :
		mana -= mana_point_consume
		return true

## Heal the player
func heal_player(heal_point: int):
	hp += heal_point
	if hp > hpMax:
		hp = hpMax

## Gave damage to the player
func damage_player(damages: int):
	hp -= damages
	if hp < 0:
		pass


"""
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
"""
