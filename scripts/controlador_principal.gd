class_name ControladorPrincipal
extends Control

@export var escena_bloque: PackedScene

# Contenedores UI con Scene Unique Nodes (%)
@onready var paleta_contenedor: VBoxContainer = %ListaBloques
@onready var lienzo: LienzoCodigo = %LienzoCodigo
@onready var mundo_3d: Mundo3D = %Mundo3D

# Elementos Didacticos
@onready var label_nivel_titulo: Label = %LabelNivelTitulo
@onready var btn_nivel_prev: Button = %BtnNivelPrev
@onready var btn_nivel_next: Button = %BtnNivelNext
@onready var label_ada_texto: Label = %LabelADATexto
@onready var label_concepto: Label = %LabelConcepto
@onready var label_estado: Label = %LabelEstado

# Botones de Ejecucion
@onready var btn_ejecutar: Button = %BtnEjecutar
@onready var btn_paso: Button = %BtnPaso
@onready var btn_reiniciar: Button = %BtnReiniciar
@onready var btn_limpiar: Button = %BtnLimpiar

# Popup / Modal de Victoria
@onready var panel_victoria: PanelContainer = %ModalVictoria
@onready var label_estrellas: Label = %LabelEstrellas
@onready var label_victoria_detalle: Label = %LabelDetalle
@onready var btn_modal_siguiente: Button = %BtnModalSiguiente
@onready var btn_modal_reintentar: Button = %BtnModalReintentar

var niveles: Array[Dictionary] = []
var indice_nivel_actual: int = 0

var en_ejecucion: bool = false
var indice_paso_actual: int = 0
var errores_durante_ejecucion: int = 0

# Diccionario maestro de comandos didacticos (sin emojis)
const COMANDOS_DISPONIBLES = {
	"AVANZAR": {"tit": "Avanzar 1 Paso", "prefijo": "[AVZ]", "color": Color(0.13, 0.77, 0.45)},
	"RETROCEDER": {"tit": "Retroceder 1 Paso", "prefijo": "[RET]", "color": Color(0.55, 0.62, 0.70)},
	"GIRAR_DER": {"tit": "Girar Derecha 90", "prefijo": "[DER]", "color": Color(0.20, 0.82, 0.60)},
	"GIRAR_IZQ": {"tit": "Girar Izquierda 90", "prefijo": "[IZQ]", "color": Color(0.20, 0.82, 0.60)},
	"TOMAR_PIEZA": {"tit": "Tomar Pieza", "prefijo": "[TOM]", "color": Color(0.18, 0.85, 0.35)},
	"ENSAMBLAR": {"tit": "Ensamblar en Spid", "prefijo": "[ENS]", "color": Color(0.30, 0.95, 0.50)}
}

func _ready() -> void:
	niveles = DatosNiveles.obtener_niveles()
	_conectar_senales()
	panel_victoria.visible = false
	cargar_nivel(0)

func cargar_nivel(indice: int) -> void:
	if indice < 0 or indice >= niveles.size():
		return

	indice_nivel_actual = indice
	var nivel = niveles[indice_nivel_actual]

	# Actualizar cabecera didactica
	label_nivel_titulo.text = "[NIVEL %d] %s - %s" % [nivel.id, nivel.titulo, nivel.subtitulo]
	label_ada_texto.text = nivel.instruccion
	label_concepto.text = "Concepto: %s" % nivel.concepto_clave

	btn_nivel_prev.disabled = (indice_nivel_actual == 0)
	btn_nivel_next.disabled = (indice_nivel_actual == niveles.size() - 1)

	# Actualizar paleta con SOLO los bloques autorizados en este nivel
	_actualizar_paleta(nivel.bloques_permitidos)

	# Limpiar lienzo y estado
	lienzo.limpiar_todo()
	panel_victoria.visible = false
	errores_durante_ejecucion = 0
	indice_paso_actual = 0

	# Cargar en el mundo 3D
	mundo_3d.cargar_nivel(nivel)
	_actualizar_estado("Nivel cargado. Organiza tus bloques y presiona 'Ejecutar'.")

func _actualizar_paleta(bloques_permitidos: Array) -> void:
	for child in paleta_contenedor.get_children():
		child.queue_free()

	for id_cmd in bloques_permitidos:
		if COMANDOS_DISPONIBLES.has(id_cmd):
			var data = COMANDOS_DISPONIBLES[id_cmd]
			var bloque: BloqueItem
			if escena_bloque:
				bloque = escena_bloque.instantiate() as BloqueItem
			else:
				bloque = BloqueItem.new()

			bloque.configurar(id_cmd, data.tit, data.prefijo, data.color, true)
			paleta_contenedor.add_child(bloque)

func _conectar_senales() -> void:
	btn_ejecutar.pressed.connect(_on_ejecutar_pressed)
	btn_paso.pressed.connect(_on_paso_pressed)
	btn_reiniciar.pressed.connect(_on_reiniciar_pressed)
	btn_limpiar.pressed.connect(_on_limpiar_pressed)

	btn_nivel_prev.pressed.connect(func(): cargar_nivel(indice_nivel_actual - 1))
	btn_nivel_next.pressed.connect(func(): cargar_nivel(indice_nivel_actual + 1))

	btn_modal_siguiente.pressed.connect(_on_modal_siguiente_pressed)
	btn_modal_reintentar.pressed.connect(_on_modal_reintentar_pressed)

	if mundo_3d:
		if mundo_3d.astronauta:
			mundo_3d.astronauta.accion_fallida.connect(_on_accion_fallida)
			mundo_3d.astronauta.pieza_recogida.connect(_on_pieza_recogida)
			mundo_3d.astronauta.pieza_ensamblada.connect(_on_pieza_ensamblada)

func _on_ejecutar_pressed() -> void:
	if en_ejecucion: return
	var secuencia = lienzo.obtener_secuencia_comandos()
	if secuencia.is_empty():
		_actualizar_estado("El lienzo esta vacio. Arrastra al menos un bloque.")
		return

	en_ejecucion = true
	_bloquear_interfaz(true)
	errores_durante_ejecucion = 0
	_actualizar_estado("Ejecutando algoritmo...")

	var abortado = false
	for i in range(secuencia.size()):
		var bloque = secuencia[i]
		_actualizar_estado("Paso %d/%d: %s" % [i + 1, secuencia.size(), bloque.titulo])
		bloque.resaltar_ejecucion(true)

		var exito = await mundo_3d.astronauta.ejecutar_accion(bloque.id_comando)
		await get_tree().create_timer(0.12).timeout
		bloque.resaltar_ejecucion(false)

		if not exito:
			errores_durante_ejecucion += 1
			if bloque.id_comando in ["AVANZAR", "ENSAMBLAR"]:
				_actualizar_estado("El astronauta no pudo completar el paso %d." % (i + 1))
				abortado = true
				break

	en_ejecucion = false
	_bloquear_interfaz(false)

	# Evaluar si se cumplio la meta
	await get_tree().create_timer(0.2).timeout
	_evaluar_resultado_nivel(secuencia.size(), abortado)

func _evaluar_resultado_nivel(cant_bloques: int, abortado: bool) -> void:
	var nivel = niveles[indice_nivel_actual]
	var cumplido = mundo_3d.verificar_objetivo_completado()

	if cumplido:
		var estrellas = 1
		if errores_durante_ejecucion == 0 and not abortado:
			estrellas += 1
		if cant_bloques <= nivel.bloques_optimos:
			estrellas += 1

		_mostrar_victoria(estrellas, cant_bloques, nivel.bloques_optimos)
	else:
		_actualizar_estado("[FALLO] La meta no fue alcanzada. Revisa tu secuencia de bloques.")

func _mostrar_victoria(estrellas: int, cant_bloques: int, optimo: int) -> void:
	var texto_estrellas = ""
	for i in range(3):
		texto_estrellas += "[*] " if i < estrellas else "[ ] "

	label_estrellas.text = texto_estrellas
	label_victoria_detalle.text = (
		"Calificacion: %d/3 Estrellas\n" +
		"- Objetivo alcanzado con exito\n" +
		"- Errores cometidos: %d\n" +
		"- Bloques usados: %d (Optimo pedagogico: %d)"
	) % [estrellas, errores_durante_ejecucion, cant_bloques, optimo]

	btn_modal_siguiente.visible = (indice_nivel_actual < niveles.size() - 1)
	panel_victoria.visible = true

func _on_modal_siguiente_pressed() -> void:
	panel_victoria.visible = false
	cargar_nivel(indice_nivel_actual + 1)

func _on_modal_reintentar_pressed() -> void:
	panel_victoria.visible = false
	_on_reiniciar_pressed()

func _on_paso_pressed() -> void:
	if en_ejecucion: return
	var secuencia = lienzo.obtener_secuencia_comandos()
	if secuencia.is_empty():
		_actualizar_estado("Agrega bloques al lienzo para probar paso a paso.")
		return

	if indice_paso_actual >= secuencia.size():
		indice_paso_actual = 0

	var bloque = secuencia[indice_paso_actual]
	_actualizar_estado("Paso manual %d/%d: %s" % [indice_paso_actual + 1, secuencia.size(), bloque.titulo])

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
	errores_durante_ejecucion = 0
	await mundo_3d.reiniciar_mundo()
	_actualizar_estado("Nivel reiniciado. Prueba otra vez tu algoritmo.")

func _on_limpiar_pressed() -> void:
	if en_ejecucion: return
	lienzo.limpiar_todo()
	indice_paso_actual = 0
	_actualizar_estado("Lienzo vaciado.")

func _bloquear_interfaz(bloquear: bool) -> void:
	btn_ejecutar.disabled = bloquear
	btn_paso.disabled = bloquear
	btn_limpiar.disabled = bloquear
	btn_nivel_prev.disabled = bloquear or (indice_nivel_actual == 0)
	btn_nivel_next.disabled = bloquear or (indice_nivel_actual == niveles.size() - 1)

func _actualizar_estado(mensaje: String) -> void:
	if label_estado:
		label_estado.text = mensaje

func _on_accion_fallida(motivo: String) -> void:
	errores_durante_ejecucion += 1
	_actualizar_estado("[ALERTA] %s" % motivo)

func _on_pieza_recogida(nombre: String) -> void:
	_actualizar_estado("[ITEM] Astronauta tomo: %s" % nombre)

func _on_pieza_ensamblada(tipo: String) -> void:
	_actualizar_estado("[OK] Pieza %s montada en Spid" % tipo)
