class_name PiezaTaller
extends Node3D

@export var tipo_pieza: String = "CHASIS" # CHASIS, RUEDAS, SENSOR
@export var celda_inicial: Vector2i = Vector2i(-2, 0)
@export var altura_suelo: float = 0.4

var padre_original: Node = null
var pos_inicial: Vector3

func _ready() -> void:
	padre_original = get_parent()
	pos_inicial = Vector3(celda_inicial.x * 2.0, altura_suelo, celda_inicial.y * 2.0)
	position = pos_inicial
	_iniciar_efecto_rotacion()

func _iniciar_efecto_rotacion() -> void:
	var tween = create_tween().set_loops()
	tween.tween_property(self, "rotation:y", TAU, 5.0).as_relative()

func reiniciar() -> void:
	if padre_original and get_parent() != padre_original:
		reparent(padre_original)
	position = pos_inicial
	rotation = Vector3.ZERO
	visible = true
