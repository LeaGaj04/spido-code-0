class_name Mundo3D
extends Node3D

@onready var astronauta: AstronautaIngeniero = $Astronauta
@onready var mesa_spid: MesaEnsamblaje = $MesaEnsamblaje
@onready var contenedor_piezas: Node3D = $ContenedorPiezas

var piezas_por_celda: Dictionary = {}

func _ready() -> void:
	registrar_piezas()

func registrar_piezas() -> void:
	piezas_por_celda.clear()
	for child in contenedor_piezas.get_children():
		if child is PiezaTaller and child.visible:
			var celda = Vector2i(
				int(round(child.position.x / 2.0)),
				int(round(child.position.z / 2.0))
			)
			piezas_por_celda[celda] = child

func es_celda_solida(celda: Vector2i) -> bool:
	if mesa_spid and mesa_spid.celda_mesa == celda:
		return true
	return false

func obtener_pieza_en(celda: Vector2i) -> Node3D:
	if piezas_por_celda.has(celda):
		var pieza = piezas_por_celda[celda]
		piezas_por_celda.erase(celda)
		return pieza
	return null

func obtener_mesa_en(celda: Vector2i) -> MesaEnsamblaje:
	if mesa_spid and mesa_spid.celda_mesa == celda:
		return mesa_spid
	return null

func reiniciar_mundo() -> void:
	if astronauta:
		await astronauta.reiniciar()
	if mesa_spid:
		mesa_spid.reiniciar()
	for child in contenedor_piezas.get_children():
		if child.has_method("reiniciar"):
			child.reiniciar()
	registrar_piezas()
