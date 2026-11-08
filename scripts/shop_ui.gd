extends Control

const SLOTS := 4

@onready var options: Array[Button] = [%Option1, %Option2, %Option3, %Option4]
@onready var buy_btn: Button = %Buy
@onready var continue_btn: Button = %Continue
@onready var pay_list: HBoxContainer = %PayList

var offers: Array = []
var selected := -1
var payment := {}       
var pay_labels := {}     
var pay_info: Label

func _ready() -> void:
	pass

func open() -> void:
	selected = -1
	payment.clear()
	show()
	get_tree().paused = true

func close() -> void:
	hide()
	get_tree().paused = false


func _on_option(i: int) -> void:
	selected = i
	payment.clear()

func _on_buy() -> void:
	if selected < 0:
		return
