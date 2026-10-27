class_name Mundo3D
extends Node3D

@onready var robot: RobotPrimitivo = $RobotPrimitivo
@onready var contenedor_items: Node3D = $ContenedorItems

var items_por_celda: Dictionary = {}

func _ready() -> void:
	registrar_items()

func registrar_items() -> void:
	items_por_celda.clear()
	for child in contenedor_items.get_children():
		if child is Node3D:
			var celda = Vector2i(
				int(round(child.position.x / 2.0)),
				int(round(child.position.z / 2.0))
			)
			items_por_celda[celda] = child

func obtener_recolectable_en(celda: Vector2i) -> Node3D:
	if items_por_celda.has(celda):
		var item = items_por_celda[celda]
		items_por_celda.erase(celda)
		return item
	return null

func reiniciar_mundo() -> void:
	if robot:
		await robot.reiniciar()
	# Restaurar items
	for child in contenedor_items.get_children():
		if child.has_method("reiniciar"):
			child.reiniciar()
	registrar_items()
