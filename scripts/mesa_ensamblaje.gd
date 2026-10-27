class_name MesaEnsamblaje
extends Node3D

signal spid_actualizado(etapa: int, total: int, mensaje: String)
signal spid_completado

@export var celda_mesa: Vector2i = Vector2i(0, -2)

var etapas_completadas: Array[String] = []
var orden_esperado: Array[String] = ["CHASIS", "RUEDAS", "SENSOR"]

@onready var spid_chasis: MeshInstance3D = $SoporteSpid/SpidChasis
@onready var spid_ruedas: Node3D = $SoporteSpid/SpidRuedas
@onready var spid_sensor: MeshInstance3D = $SoporteSpid/SpidSensor
@onready var luz_plataforma: OmniLight3D = $LuzPlataforma

func _ready() -> void:
	reiniciar()

func reiniciar() -> void:
	etapas_completadas.clear()
	if spid_chasis: spid_chasis.visible = false
	if spid_ruedas: spid_ruedas.visible = false
	if spid_sensor: spid_sensor.visible = false
	if luz_plataforma:
		luz_plataforma.light_color = Color(0.2, 0.4, 0.3)
		luz_plataforma.light_energy = 0.5
	spid_actualizado.emit(0, orden_esperado.size(), "Mesa lista. Esperando montaje del Chasis.")

func ensamblar_componente(tipo: String) -> bool:
	var siguiente_etapa = _obtener_siguiente_etapa()
	if tipo != siguiente_etapa:
		return false

	etapas_completadas.append(tipo)

	var tween = create_tween()
	match tipo:
		"CHASIS":
			spid_chasis.visible = true
			spid_chasis.scale = Vector3.ZERO
			tween.tween_property(spid_chasis, "scale", Vector3.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			spid_actualizado.emit(1, orden_esperado.size(), "¡Chasis de Spid fijado en el banco de montaje!")
		"RUEDAS":
			spid_ruedas.visible = true
			spid_ruedas.scale = Vector3.ZERO
			tween.tween_property(spid_ruedas, "scale", Vector3.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			spid_actualizado.emit(2, orden_esperado.size(), "¡Sistemas de tracción y 4 ruedas montadas!")
		"SENSOR":
			spid_sensor.visible = true
			spid_sensor.scale = Vector3.ZERO
			tween.tween_property(spid_sensor, "scale", Vector3.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			spid_actualizado.emit(3, orden_esperado.size(), "¡Sensor óptico y procesador A.D.A. conectado!")

	await tween.finished

	if etapas_completadas.size() == orden_esperado.size():
		await _activar_spid()
		spid_completado.emit()

	return true

func _activar_spid() -> void:
	# Animación donde Spid cobra vida con luces verdes pulsantes
	if luz_plataforma:
		var tw_luz = create_tween().set_loops(3)
		tw_luz.tween_property(luz_plataforma, "light_energy", 3.5, 0.2)
		tw_luz.tween_property(luz_plataforma, "light_energy", 1.2, 0.2)
		luz_plataforma.light_color = Color(0.2, 1.0, 0.5)

	# Bamboleo feliz de Spid
	var tw_spid = create_tween()
	tw_spid.tween_property($SoporteSpid, "position:y", 0.85, 0.2).set_trans(Tween.TRANS_SINE)
	tw_spid.tween_property($SoporteSpid, "position:y", 0.70, 0.2).set_trans(Tween.TRANS_BOUNCE)
	await tw_spid.finished

func probar_sistemas() -> bool:
	if etapas_completadas.size() < orden_esperado.size():
		return false

	var tw = create_tween()
	tw.tween_property($SoporteSpid, "rotation:y", deg_to_rad(360), 0.8).as_relative()
	await tw.finished
	return true

func _obtener_siguiente_etapa() -> String:
	for req in orden_esperado:
		if req not in etapas_completadas:
			return req
	return ""
