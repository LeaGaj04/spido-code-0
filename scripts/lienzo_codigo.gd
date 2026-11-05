class_name LienzoCodigo
extends PanelContainer

signal algoritmo_modificado

@export var escena_bloque: PackedScene

@onready var contenedor_bloques: VBoxContainer = $Scroll/ContenedorBloques
@onready var label_vacio: Label = $Scroll/ContenedorBloques/LabelVacio

func _ready() -> void:
	custom_minimum_size = Vector2(250, 200)
	_actualizar_estado_vacio()

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is Dictionary and data.get("tipo") == "bloque_codigo"

func _drop_data(at_position: Vector2, data: Variant) -> void:
	if not _can_drop_data(at_position, data):
		return

	var idx_destino = _calcular_indice_insercion(at_position.y)

	if data.get("es_de_paleta", false):
		var nuevo_bloque: BloqueItem
		if escena_bloque:
			nuevo_bloque = escena_bloque.instantiate() as BloqueItem
		else:
			nuevo_bloque = BloqueItem.new()

		nuevo_bloque.configurar(
			data.get("id_comando", "AVANZAR"),
			data.get("titulo", "Comando"),
			data.get("prefijo", "[CMD]"),
			data.get("color_borde", Color(0.13, 0.77, 0.45)),
			false
		)
		nuevo_bloque.solicitado_eliminar.connect(_on_bloque_solicitado_eliminar)

		contenedor_bloques.add_child(nuevo_bloque)
		contenedor_bloques.move_child(nuevo_bloque, idx_destino)
	else:
		var nodo_origen = data.get("nodo_origen")
		if is_instance_valid(nodo_origen) and nodo_origen.get_parent() == contenedor_bloques:
			contenedor_bloques.move_child(nodo_origen, idx_destino)

	_actualizar_estado_vacio()
	algoritmo_modificado.emit()

func _calcular_indice_insercion(pos_y: float) -> int:
	var hijos = contenedor_bloques.get_children()
	var indice = 0
	for h in hijos:
		if h is BloqueItem and h.visible:
			var center_y = h.global_position.y + (h.size.y * 0.5) - contenedor_bloques.global_position.y
			if pos_y > center_y:
				indice += 1
	return indice

func obtener_secuencia_comandos() -> Array[BloqueItem]:
	var lista: Array[BloqueItem] = []
	for h in contenedor_bloques.get_children():
		if h is BloqueItem and h.visible:
			lista.append(h)
	return lista

func limpiar_todo() -> void:
	for h in contenedor_bloques.get_children():
		if h is BloqueItem:
			h.queue_free()
	_actualizar_estado_vacio()
	algoritmo_modificado.emit()

func _on_bloque_solicitado_eliminar(bloque: BloqueItem) -> void:
	bloque.queue_free()
	await get_tree().process_frame
	_actualizar_estado_vacio()
	algoritmo_modificado.emit()

func _actualizar_estado_vacio() -> void:
	var hay_bloques = false
	for h in contenedor_bloques.get_children():
		if h is BloqueItem and not h.is_queued_for_deletion():
			hay_bloques = true
			break
	if label_vacio:
		label_vacio.visible = not hay_bloques
