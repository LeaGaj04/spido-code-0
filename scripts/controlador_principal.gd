class_name ControladorPrincipal
extends Control

@export var escena_bloque: PackedScene

@onready var paleta_contenedor: VBoxContainer = $HSplit/PanelIzquierdo/VBox/PaletaScroll/ListaBloques
@onready var lienzo: LienzoCodigo = $HSplit/PanelDerecho/VBox/LienzoCodigo
@onready var mundo_3d: Mundo3D = $HSplit/PanelCentral/SubViewportContainer/SubViewport/Mundo3D
@onready var label_mision: Label = $HSplit/PanelCentral/BarraMision/LabelMision
@onready var label_progreso: Label = $HSplit/PanelCentral/BarraMision/LabelProgreso
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
	_actualizar_estado("Controla al astronauta para llevar las piezas a la mesa y construir a Spid.")

func _inicializar_paleta() -> void:
	for child in paleta_contenedor.get_children():
		child.queue_free()

	# Paleta con colores verdes y grises acordes a SpidoCode
	var comandos = [
		{"id": "AVANZAR", "tit": "Avanzar 1 Paso", "ico": "🚶", "color": Color(0.13, 0.77, 0.45)},
		{"id": "RETROCEDER", "tit": "Retroceder 1 Paso", "ico": "🔙", "color": Color(0.55, 0.62, 0.70)},
		{"id": "GIRAR_DER", "tit": "Girar Derecha 90°", "ico": "↷", "color": Color(0.20, 0.82, 0.60)},
		{"id": "GIRAR_IZQ", "tit": "Girar Izquierda 90°", "ico": "↶", "color": Color(0.20, 0.82, 0.60)},
		{"id": "TOMAR_PIEZA", "tit": "Tomar Pieza", "ico": "✋", "color": Color(0.18, 0.85, 0.35)},
		{"id": "ENSAMBLAR", "tit": "Ensamblar en Spid", "ico": "🔧", "color": Color(0.30, 0.95, 0.50)},
		{"id": "DIAGNOSTICO", "tit": "Diagnóstico Spid", "ico": "⚡", "color": Color(0.40, 1.0, 0.70)}
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

	if mundo_3d:
		if mundo_3d.astronauta:
			mundo_3d.astronauta.accion_fallida.connect(_on_accion_fallida)
			mundo_3d.astronauta.pieza_recogida.connect(_on_pieza_recogida)
			mundo_3d.astronauta.pieza_ensamblada.connect(_on_pieza_ensamblada)
		if mundo_3d.mesa_spid:
			mundo_3d.mesa_spid.spid_actualizado.connect(_on_spid_actualizado)
			mundo_3d.mesa_spid.spid_completado.connect(_on_spid_completado)

func _on_ejecutar_pressed() -> void:
	if en_ejecucion: return
	var secuencia = lienzo.obtener_secuencia_comandos()
	if secuencia.is_empty():
		_actualizar_estado("El lienzo está vacío. Arrastra comandos de montaje primero.")
		return

	en_ejecucion = true
	_bloquear_interfaz(true)
	_actualizar_estado("Astronauta ejecutando protocolo de montaje...")

	for i in range(secuencia.size()):
		var bloque = secuencia[i]
		_actualizar_estado("Paso %d/%d: %s" % [i + 1, secuencia.size(), bloque.titulo])
		bloque.resaltar_ejecucion(true)

		var exito = await mundo_3d.astronauta.ejecutar_accion(bloque.id_comando)
		await get_tree().create_timer(0.12).timeout
		bloque.resaltar_ejecucion(false)

		if not exito and bloque.id_comando in ["AVANZAR", "ENSAMBLAR"]:
			_actualizar_estado("Secuencia detenida por advertencia en el paso %d." % (i + 1))
			break

	en_ejecucion = false
	_bloquear_interfaz(false)
	_actualizar_estado("Secuencia finalizada.")

func _on_paso_pressed() -> void:
	if en_ejecucion: return
	var secuencia = lienzo.obtener_secuencia_comandos()
	if secuencia.is_empty():
		_actualizar_estado("Agrega bloques al lienzo para probar paso a paso.")
		return

	if indice_paso_actual >= secuencia.size():
		indice_paso_actual = 0

	var bloque = secuencia[indice_paso_actual]
	_actualizar_estado("Paso %d/%d: %s" % [indice_paso_actual + 1, secuencia.size(), bloque.titulo])

	en_ejecucion = true
	_bloquear_interfaz(true)
	bloque.resaltar_ejecucion(true)

	await mundo_3d.astronauta.ejecutar_accion(bloque.id_comando)
	await get_tree().create_timer(0.08).timeout
	bloque.resaltar_ejecucion(false)

	indice_paso_actual += 1
	en_ejecucion = false
	_bloquear_interfaz(false)

func _on_reiniciar_pressed() -> void:
	indice_paso_actual = 0
	await mundo_3d.reiniciar_mundo()
	_actualizar_estado("Taller y astronauta reiniciados al estado de inicio.")

func _on_limpiar_pressed() -> void:
	if en_ejecucion: return
	lienzo.limpiar_todo()
	indice_paso_actual = 0
	_actualizar_estado("Lienzo vaciado.")

func _bloquear_interfaz(bloquear: bool) -> void:
	btn_ejecutar.disabled = bloquear
	btn_paso.disabled = bloquear
	btn_limpiar.disabled = bloquear

func _actualizar_estado(mensaje: String) -> void:
	if label_estado:
		label_estado.text = mensaje

func _on_accion_fallida(motivo: String) -> void:
	_actualizar_estado("⚠️ %s" % motivo)

func _on_pieza_recogida(nombre: String) -> void:
	_actualizar_estado("📦 Astronauta tomó: %s" % nombre)

func _on_pieza_ensamblada(tipo: String) -> void:
	_actualizar_estado("✅ ¡Pieza %s montada con éxito en Spid!" % tipo)

func _on_spid_actualizado(etapa: int, total: int, mensaje: String) -> void:
	if label_progreso:
		label_progreso.text = "Ensamblaje: [%d/%d]" % [etapa, total]
	_actualizar_estado(mensaje)

func _on_spid_completado() -> void:
	if label_progreso:
		label_progreso.text = "¡SPID CONSTRUIDO! [3/3]"
	_actualizar_estado("🎉 ¡Misión Cumplida! Spid ha sido completamente ensamblado y activado.")
