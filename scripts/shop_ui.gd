extends Control

const SLOTS := 4

@onready var options: Array[Button] = [%Option1, %Option2, %Option3, %Option4]
@onready var buy_btn: Button = %Buy
@onready var continue_btn: Button = %Continue
@onready var pay_list: HBoxContainer = %PayList

var offers: Array = []
var selected := -1
var payment := {}          # typ robaka -> ile oddajemy
var pay_labels := {}       # typ robaka -> Label w wierszu
var pay_info: Label

func _ready() -> void:
	for i in options.size():
		options[i].pressed.connect(_on_option.bind(i))
	buy_btn.pressed.connect(_on_buy)
	continue_btn.pressed.connect(close)
	Upgrades.changed.connect(_refresh)
	_build_pay_rows()
	hide()

func _build_pay_rows() -> void:
	pay_info = Label.new()
	pay_list.add_child(pay_info)
	for t in Upgrades.BUG_TYPES:
		var row := HBoxContainer.new()
		var minus := Button.new()
		minus.text = "-"
		minus.pressed.connect(_change_pay.bind(t, -1))
		var lbl := Label.new()
		lbl.custom_minimum_size.x = 260
		var plus := Button.new()
		plus.text = "+"
		plus.pressed.connect(_change_pay.bind(t, 1))
		row.add_child(minus)
		row.add_child(lbl)
		row.add_child(plus)
		pay_list.add_child(row)
		pay_labels[t] = lbl

func open() -> void:
	_roll_offers()
	selected = -1
	payment.clear()
	_refresh()
	show()
	get_tree().paused = true

func close() -> void:
	hide()
	get_tree().paused = false

func _roll_offers() -> void:
	offers.clear()
	var pool: Array = []
	for id in Upgrades.DATA:
		if not Upgrades.is_maxed(id):
			pool.append(id)
	for n in SLOTS:
		if pool.is_empty():
			break
		var id: String = _pick_weighted(pool)
		pool.erase(id)
		var price := int(round(Upgrades.base_price(id) * randf_range(0.8, 1.2)))
		offers.append({"id": id, "price": maxi(price, 1), "sale": false})
	if not offers.is_empty() and randf() < 0.25:
		var o = offers.pick_random()
		o["price"] = maxi(int(round(o["price"] * 0.6)), 1)
		o["sale"] = true

func _pick_weighted(pool: Array) -> String:
	var total := 0.0
	for id in pool:
		total += Upgrades.DATA[id]["weight"]
	var r := randf() * total
	for id in pool:
		r -= Upgrades.DATA[id]["weight"]
		if r <= 0.0:
			return id
	return pool[0]

func _on_option(i: int) -> void:
	selected = i
	payment.clear()
	_refresh()

func _change_pay(type: String, delta: int) -> void:
	if selected < 0:
		return
	payment[type] = clampi(payment.get(type, 0) + delta, 0, Upgrades.bugs[type])
	_refresh()

func _on_buy() -> void:
	if selected < 0:
		return
	var o = offers[selected]
	if Upgrades.buy(o["id"], o["price"], payment):
		offers.remove_at(selected)
		selected = -1
		payment.clear()
		_refresh()

func _refresh() -> void:
	for i in options.size():
		if i < offers.size():
			var o = offers[i]
			var d = Upgrades.DATA[o["id"]]
			var txt: String = ("★ " if d["special"] else "") + d["name"]
			txt += " (poz. %d)" % (Upgrades.levels[o["id"]] + 1)
			txt += " - koszt: %d" % o["price"]
			if o["sale"]:
				txt += " PROMOCJA!"
			options[i].text = ("> " if i == selected else "") + txt
			options[i].tooltip_text = d["desc"]
			options[i].visible = true
		else:
			options[i].visible = false

	for t in Upgrades.BUG_TYPES:
		pay_labels[t].text = "%s (wart. %d): %d / %d" % [
			Upgrades.BUG_NAMES[t], Upgrades.bug_worth(t),
			payment.get(t, 0), Upgrades.bugs[t]]

	if selected >= 0 and selected < offers.size():
		var price: int = offers[selected]["price"]
		pay_info.text = "Wpłacono: %d / %d" % [Upgrades.payment_value(payment), price]
		buy_btn.disabled = not Upgrades.can_buy(offers[selected]["id"], price, payment)
	else:
		pay_info.text = "Wybierz ulepszenie"
		buy_btn.disabled = true
