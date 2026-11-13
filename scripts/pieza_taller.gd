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
	_actualizar_aspecto()
	_iniciar_efecto_rotacion()

func _actualizar_aspecto() -> void:
	var malla = find_child("MallaPieza", true, false) as MeshInstance3D
	if not malla: return

	var mat = StandardMaterial3D.new()
	mat.roughness = 0.3
	match tipo_pieza:
		"TUERCA", "TORNILLO":
			mat.albedo_color = Color(0.95, 0.82, 0.25, 1)
			mat.metallic = 0.95
			mat.roughness = 0.2
			mat.emission_enabled = true
			mat.emission = Color(0.9, 0.75, 0.2, 1)
			mat.emission_energy_multiplier = 0.8
		"PLACA":
			mat.albedo_color = Color(0.3, 0.5, 0.7, 1)
			mat.metallic = 0.8
			mat.roughness = 0.3
		"MICROCHIP":
			mat.albedo_color = Color(0.1, 0.6, 0.3, 1)
			mat.metallic = 0.4
			mat.roughness = 0.2
			mat.emission_enabled = true
			mat.emission = Color(0.2, 0.9, 0.4, 1)
			mat.emission_energy_multiplier = 1.8
		"CHASIS":
			mat.albedo_color = Color(0.15, 0.45, 0.3, 1)
			mat.emission_enabled = true
			mat.emission = Color(0.2, 0.6, 0.4, 1)
			mat.emission_energy_multiplier = 0.5
		"RUEDAS":
			mat.albedo_color = Color(0.15, 0.18, 0.22, 1)
			mat.metallic = 0.6
			mat.roughness = 0.5
		"SENSOR":
			mat.albedo_color = Color(0.2, 0.9, 0.6, 1)
			mat.emission_enabled = true
			mat.emission = Color(0.2, 0.9, 0.6, 1)
			mat.emission_energy_multiplier = 2.0
		"BRAZOS":
			mat.albedo_color = Color(0.95, 0.65, 0.15, 1)
			mat.metallic = 0.5
			mat.emission_enabled = true
			mat.emission = Color(0.9, 0.5, 0.1, 1)
			mat.emission_energy_multiplier = 0.8
		"BATERIA", "NUCLEO":
			mat.albedo_color = Color(0.15, 0.75, 0.95, 1)
			mat.emission_enabled = true
			mat.emission = Color(0.2, 0.85, 1.0, 1)
			mat.emission_energy_multiplier = 2.5
	malla.material_override = mat

func _iniciar_efecto_rotacion() -> void:
	var tween = create_tween().set_loops()
	tween.tween_property(self, "rotation:y", TAU, 5.0).as_relative()

func reiniciar() -> void:
	if padre_original and get_parent() != padre_original:
		reparent(padre_original)
	position = pos_inicial
	rotation = Vector3.ZERO
	visible = true
