class_name ControladorPrincipal
extends Control

@export var escena_bloque: PackedScene

@onready var paleta_contenedor: VBoxContainer = $HSplit/PanelIzquierdo/VBox/PaletaScroll/ListaBloques
@onready var lienzo: LienzoCodigo = $HSplit/PanelDerecho/VBox/LienzoCodigo
@onready var mundo_3d: Mundo3D = $HSplit/PanelCentral/SubViewportContainer/SubViewport/Mundo3D
@onready var label_estado: Label = $HSplit/PanelCentral/BarraEstado/LabelEstado
@onready var btn_ejecutar: Button = $HSplit/PanelDerecho/VBox/BarraBotones/BtnEjecutar
@onready var btn_paso: Button = $HSplit/PanelDerecho/VBox/BarraBotones/BtnPaso
@onready var btn_reiniciar: Button = $HSplit/PanelDerecho/VBox/BarraBotones/BtnReiniciar
@onready var btn_limpiar: Button = $HSplit/PanelDerecho/VBox/BarraBotones/BtnLimpiar

var en_ejecucion: bool = false
var indice_paso_actual: int = 0

func _ready() -> void:
	_inicializar_paleta()
	_conectar_senales()
	_actualizar_estado("Arrastra bloques de la izquierda al lienzo para programar el robot.")

func _inicializar_paleta() -> void:
	for child in paleta_contenedor.get_children():
		child.queue_free()

	var comandos = [
		{"id": "AVANZAR", "tit": "Avanzar 1 Paso", "ico": "⬆️", "color": Color(0.14, 0.45, 0.91)},
		{"id": "RETROCEDER", "tit": "Retroceder 1 Paso", "ico": "⬇️", "color": Color(0.35, 0.42, 0.53)},
		{"id": "GIRAR_DER", "tit": "Girar Derecha 90°", "ico": "↷", "color": Color(0.92, 0.52, 0.12)},
		{"id": "GIRAR_IZQ", "tit": "Girar Izquierda 90°", "ico": "↶", "color": Color(0.92, 0.52, 0.12)},
		{"id": "TOMAR", "tit": "Tomar / Recolectar", "ico": "📦", "color": Color(0.08, 0.65, 0.42)}
	]

	for c in comandos:
		var bloque: BloqueItem
		if escena_bloque:
			bloque = escena_bloque.instantiate() as BloqueItem
		else:
			bloque = BloqueItem.new()

		bloque.configurar(c.id, c.tit, c.ico, c.color, true)
		paleta_contenedor.add_child(bloque)

func _conectar_senales() -> void:
	btn_ejecutar.pressed.connect(_on_ejecutar_pressed)
	btn_paso.pressed.connect(_on_paso_pressed)
	btn_reiniciar.pressed.connect(_on_reiniciar_pressed)
	btn_limpiar.pressed.connect(_on_limpiar_pressed)

	if mundo_3d and mundo_3d.robot:
		mundo_3d.robot.colision_detectada.connect(_on_colision_detectada)
		mundo_3d.robot.item_recolectado.connect(_on_item_recolectado)

func _on_ejecutar_pressed() -> void:
	if en_ejecucion: return
	var secuencia = lienzo.obtener_secuencia_comandos()
	if secuencia.is_empty():
		_actualizar_estado("El lienzo está vacío. Arrastra comandos primero.")
		return

	en_ejecucion = true
	_bloquear_interfaz(true)
	_actualizar_estado("Ejecutando algoritmo...")

	for i in range(secuencia.size()):
		var bloque = secuencia[i]
		_actualizar_estado("Paso %d/%d: %s" % [i + 1, secuencia.size(), bloque.titulo])
		bloque.resaltar_ejecucion(true)

		var exito = await mundo_3d.robot.ejecutar_accion(bloque.id_comando)
		await get_tree().create_timer(0.15).timeout
		bloque.resaltar_ejecucion(false)

		if not exito and bloque.id_comando in ["AVANZAR", "RETROCEDER"]:
			_actualizar_estado("El robot no pudo completar el paso %d." % (i + 1))
			break

	en_ejecucion = false
	_bloquear_interfaz(false)
	_actualizar_estado("¡Ejecución terminada!")

func _on_paso_pressed() -> void:
	if en_ejecucion: return
	var secuencia = lienzo.obtener_secuencia_comandos()
	if secuencia.is_empty():
		_actualizar_estado("Agrega bloques al lienzo para ejecutar paso a paso.")
		return

	if indice_paso_actual >= secuencia.size():
		indice_paso_actual = 0

	var bloque = secuencia[indice_paso_actual]
	_actualizar_estado("Paso manual %d/%d: %s" % [indice_paso_actual + 1, secuencia.size(), bloque.titulo])

	en_ejecucion = true
	_bloquear_interfaz(true)
	bloque.resaltar_ejecucion(true)

	await mundo_3d.robot.ejecutar_accion(bloque.id_comando)
	await get_tree().create_timer(0.1).timeout
	bloque.resaltar_ejecucion(false)

	indice_paso_actual += 1
	en_ejecucion = false
	_bloquear_interfaz(false)

func _on_reiniciar_pressed() -> void:
	indice_paso_actual = 0
	await mundo_3d.reiniciar_mundo()
	_actualizar_estado("Robot y entorno reiniciados a la posición de partida.")

func _on_limpiar_pressed() -> void:
	if en_ejecucion: return
	lienzo.limpiar_todo()
	indice_paso_actual = 0
	_actualizar_estado("Lienzo de programación limpiado.")

func _bloquear_interfaz(bloquear: bool) -> void:
	btn_ejecutar.disabled = bloquear
	btn_paso.disabled = bloquear
	btn_limpiar.disabled = bloquear

func _actualizar_estado(mensaje: String) -> void:
	if label_estado:
		label_estado.text = mensaje

func _on_colision_detectada(mensaje: String) -> void:
	_actualizar_estado(mensaje)

func _on_item_recolectado(nombre_item: String) -> void:
	_actualizar_estado("¡Éxito! Has recolectado: %s" % nombre_item)
