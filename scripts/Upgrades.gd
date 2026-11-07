extends Node

signal changed

const BUG_TYPES := ["ant", "beetle", "caterpillar", "snail", "moth", "earthworm"]
const BUG_NAMES := {"ant": "Mrówka", "beetle": "Chrząszcz", "caterpillar": "Gąsienica",
	"snail": "Ślimak", "moth": "Ćma", "earthworm": "Dżdżownica"}
# ile "punktów" jest wart każdy robak (do ustawienia)
const BUG_VALUE := {"ant": 1, "beetle": 3, "caterpillar": 2, "snail": 4, "moth": 5, "earthworm": 2}

var bugs := {}

const DATA := {
	"cooldown": {"name": "Szybsze łapanie", "desc": "Krótszy cooldown po złapaniu.", "cost": 10, "base": 1.0, "step": -0.12, "max": 5, "weight": 10, "special": false},
	"time": {"name": "+10 sekund", "desc": "Dodaje czas do rundy.", "cost": 15, "base": 0.0, "step": 10.0, "max": 5, "weight": 10, "special": false},
	"value": {"name": "Cenniejsze robaki", "desc": "Więcej monet za każdego robaka.", "cost": 20, "base": 1.0, "step": 1.0, "max": 5, "weight": 8, "special": false},
	"radius": {"name": "Wybuchowy klik", "desc": "Klik zbiera też robaki w promieniu.", "cost": 25, "base": 0.0, "step": 50.0, "max": 4, "weight": 4, "special": true},
	"spawn_count": {"name": "Więcej robaków", "desc": "Więcej robaków pojawia się naraz.", "cost": 20, "base": 1.0, "step": 1.0, "max": 4, "weight": 6, "special": true},
	"spawn_rate": {"name": "Szybszy spawn", "desc": "Robaki pojawiają się częściej.", "cost": 15, "base": 1.0, "step": -0.1, "max": 5, "weight": 8, "special": false},
	"rare_chance": {"name": "Rzadkie robaki", "desc": "Większa szansa na rzadkiego robaka.", "cost": 25, "base": 0.05, "step": 0.05, "max": 5, "weight": 5, "special": true},
	"double_catch": {"name": "Podwójny łup", "desc": "Szansa, że złapany robak liczy się za dwa.", "cost": 30, "base": 0.0, "step": 0.1, "max": 5, "weight": 4, "special": true},
	"slow_bugs": {"name": "Leniwe robaki", "desc": "Robaki chodzą wolniej.", "cost": 15, "base": 1.0, "step": -0.08, "max": 5, "weight": 7, "special": false},
	"bug_magnet": {"name": "Magnes", "desc": "Robaki blisko kursora zwalniają.", "cost": 35, "base": 0.0, "step": 60.0, "max": 3, "weight": 2, "special": true},
}

var levels := {}

func _ready() -> void:
	reset()

func reset() -> void:
	for id in DATA:
		levels[id] = 0
	for t in BUG_TYPES:
		bugs[t] = 0
	changed.emit()

func is_maxed(id: String) -> bool:
	return levels[id] >= DATA[id]["max"]

# cena bazowa rośnie z poziomem
func base_price(id: String) -> int:
	return DATA[id]["cost"] * (levels[id] + 1)
	
# to wywołuje kolega po złapaniu robaka
func add_bug(type: String, n: int = 1) -> void:
	if randf() < get_value("double_catch"):
		n *= 2
	bugs[type] += n
	changed.emit()

# wartość jednego robaka z uwzględnieniem ulepszenia "value"
func bug_worth(type: String) -> int:
	return maxi(int(round(BUG_VALUE[type] * get_value("value"))), 1)

func payment_value(payment: Dictionary) -> int:
	var total := 0
	for t in payment:
		total += payment[t] * bug_worth(t)
	return total

func can_buy(id: String, price: int, payment: Dictionary) -> bool:
	if is_maxed(id):
		return false
	for t in payment:
		if payment[t] > bugs[t]:
			return false
	return payment_value(payment) >= price

func buy(id: String, price: int, payment: Dictionary) -> bool:
	if not can_buy(id, price, payment):
		return false
	for t in payment:
		bugs[t] -= payment[t]
	levels[id] += 1
	changed.emit()
	return true

# to wywołuje kolega w mechanice gry
func get_value(id: String) -> float:
	return DATA[id]["base"] + DATA[id]["step"] * levels[id]
