class_name ItemCubo
extends Node3D

@export var celda_inicial: Vector2i = Vector2i(0, -2)
@export var altura_suelo: float = 0.5

var nodo_padre_original: Node = null
var pos_inicial: Vector3

func _ready() -> void:
	nodo_padre_original = get_parent()
	pos_inicial = Vector3(celda_inicial.x * 2.0, altura_suelo, celda_inicial.y * 2.0)
	position = pos_inicial

	# Animación suave de flotación / rotación para verse atractivo
	_iniciar_flotacion()

func _iniciar_flotacion() -> void:
	var tween = create_tween().set_loops()
	tween.tween_property(self, "rotation:y", rotation.y + TAU, 4.0)

func reiniciar() -> void:
	if nodo_padre_original and get_parent() != nodo_padre_original:
		reparent(nodo_padre_original)
	position = pos_inicial
