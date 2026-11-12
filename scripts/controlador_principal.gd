class_name ControladorPrincipal
extends Control

@export var escena_bloque: PackedScene

# Contenedores UI con Scene Unique Nodes (%)
@onready var paleta_contenedor: VBoxContainer = %ListaBloques
@onready var lienzo: LienzoCodigo = %LienzoAstronauta1
@onready var lienzo_a2: LienzoCodigo = %LienzoAstronauta2
@onready var lienzo_a3: LienzoCodigo = %LienzoAstronauta3
@onready var lienzo_a4: LienzoCodigo = %LienzoAstronauta4
@onready var lienzo_a5: LienzoCodigo = %LienzoAstronauta5
@onready var lienzo_a6: LienzoCodigo = %LienzoAstronauta6
@onready var lienzo_a7: LienzoCodigo = %LienzoAstronauta7
@onready var lienzo_a8: LienzoCodigo = %LienzoAstronauta8
@onready var lienzo_a9: LienzoCodigo = %LienzoAstronauta9
@onready var lienzo_a10: LienzoCodigo = %LienzoAstronauta10
@onready var tabs_codigo: TabContainer = %EquipoCodigo
@onready var mundo_3d: Mundo3D = %Mundo3D

# Elementos Didacticos
@onready var label_nivel_titulo: Label = %LabelNivelTitulo
@onready var btn_nivel_prev: Button = %BtnNivelPrev
@onready var btn_nivel_next: Button = %BtnNivelNext
@onready var label_ada_texto: Label = %LabelADATexto
@onready var label_concepto: Label = %LabelConcepto
@onready var label_estado: Label = %LabelEstado
@onready var btn_pista: Button = %BtnPista
@onready var panel_guia: PanelContainer = %PanelGuia
@onready var label_guia_texto: Label = %LabelGuiaTexto
@onready var btn_guia_continuar: Button = %BtnGuiaContinuar

# Botones de Ejecucion
@onready var btn_ejecutar: Button = %BtnEjecutar
@onready var btn_paso: Button = %BtnPaso
@onready var btn_reiniciar: Button = %BtnReiniciar
@onready var btn_limpiar: Button = %BtnLimpiar
@onready var btn_duplicar: Button = %BtnDuplicar

# Popup / Modal de Victoria
@onready var panel_victoria: PanelContainer = %ModalVictoria
@onready var label_estrellas: Label = %LabelEstrellas
@onready var label_victoria_detalle: Label = %LabelDetalle
@onready var btn_modal_siguiente: Button = %BtnModalSiguiente
@onready var btn_modal_reintentar: Button = %BtnModalReintentar

# Menu de pausa
@onready var fondo_menu_pausa: ColorRect = %FondoMenuPausa
@onready var menu_pausa: PanelContainer = %MenuPausa
@onready var btn_continuar: Button = %BtnContinuar
@onready var btn_volver_menu: Button = %BtnVolverMenu

const ESCENA_MENU_PRINCIPAL := "res://escenas/menu_inicio.tscn"

var niveles: Array[Dictionary] = []
var indice_nivel_actual: int = 0

var en_ejecucion: bool = false
var indice_paso_actual: int = 0
var errores_durante_ejecucion: int = 0
var guia_activa: bool = false
var paso_guia: int = 0
var ultimo_error: String = ""
var bloque_con_error: BloqueItem = null

const PASOS_GUIA = [
	{"titulo": "1. OBSERVA", "texto": "Tu Astronauta Ingeniero está en la posición inicial y la baliza brillante marca la meta de calibración."},
	{"titulo": "2. PREDICE", "texto": "Cada bloque 'Avanzar 1 Paso' mueve al astronauta una casilla hacia adelante. Cuenta cuántas casillas hay hasta la baliza."},
	{"titulo": "3. CONSTRUYE", "texto": "Arrastra 3 bloques 'Avanzar 1 Paso' desde la paleta izquierda hacia el lienzo del Astronauta 1."},
	{"titulo": "4. EJECUTA & DEPURA", "texto": "Presiona 'Ejecutar' para correr tu primer algoritmo. También puedes usar 'Paso a Paso' para probar instrucción por instrucción."}
]

# Paleta exacta del rediseño oficial de SpidoCode.
const COMANDOS_DISPONIBLES = {
	"AVANZAR": {"tit": "Avanzar 1 Paso", "prefijo": "[AVZ]", "color": Color(0.545098, 0.796078, 0.568627, 1.0)},
	"AVANZAR_2": {"tit": "Avanzar 2 Pasos (Auto)", "prefijo": "[2x AVZ]", "color": Color(0.35, 0.75, 0.85, 1.0)},
	"AVANZAR_3": {"tit": "Avanzar 3 Pasos (Auto)", "prefijo": "[3x AVZ]", "color": Color(0.25, 0.65, 0.85, 1.0)},
	"RETROCEDER": {"tit": "Retroceder 1 Paso", "prefijo": "[RET]", "color": Color(0.34902, 0.388235, 0.447059, 1.0)},
	"GIRAR_DER": {"tit": "Girar Derecha 90", "prefijo": "[DER]", "color": Color(0.631373, 0.85098, 0.65098, 1.0)},
	"GIRAR_IZQ": {"tit": "Girar Izquierda 90", "prefijo": "[IZQ]", "color": Color(0.631373, 0.85098, 0.65098, 1.0)},
	"TOMAR_PIEZA": {"tit": "Tomar Pieza", "prefijo": "[TOM]", "color": Color(0.545098, 0.796078, 0.568627, 1.0)},
	"ENSAMBLAR": {"tit": "Ensamblar en Spid", "prefijo": "[ENS]", "color": Color(0.435294, 0.686275, 0.470588, 1.0)}
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = false
	niveles = DatosNiveles.obtener_niveles()
	_conectar_senales()
	tabs_codigo.set_tab_title(0, "Astro 1: Ingeniero")
	tabs_codigo.set_tab_title(1, "Astro 2: Tracción")
	tabs_codigo.set_tab_title(2, "Astro 3: Sensores")
	tabs_codigo.set_tab_title(3, "Astro 4: Brazos")
	tabs_codigo.set_tab_title(4, "Astro 5: Energía")
	tabs_codigo.set_tab_title(5, "Astronauta 6")
	tabs_codigo.set_tab_title(6, "Astronauta 7")
	tabs_codigo.set_tab_title(7, "Astronauta 8")
	tabs_codigo.set_tab_title(8, "Astronauta 9")
	tabs_codigo.set_tab_title(9, "Astronauta 10")
	tabs_codigo.set_tab_hidden(1, true)
	tabs_codigo.set_tab_hidden(2, true)
	tabs_codigo.set_tab_hidden(3, true)
	tabs_codigo.set_tab_hidden(4, true)
	tabs_codigo.set_tab_hidden(5, true)
	tabs_codigo.set_tab_hidden(6, true)
	tabs_codigo.set_tab_hidden(7, true)
	tabs_codigo.set_tab_hidden(8, true)
	tabs_codigo.set_tab_hidden(9, true)
	panel_victoria.visible = false
	fondo_menu_pausa.visible = false
	menu_pausa.visible = false
	cargar_nivel(0)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_cambiar_estado_pausa(not menu_pausa.visible)
		get_viewport().set_input_as_handled()

func cargar_nivel(indice: int, continuo: bool = false) -> void:
	if indice < 0 or indice >= niveles.size():
		return

	indice_nivel_actual = indice
	var nivel = niveles[indice_nivel_actual]

	# Actualizar cabecera didactica con tipografia y colores de SpidoCode
	label_nivel_titulo.text = "[NIVEL %d] %s - %s" % [nivel.id, nivel.titulo, nivel.subtitulo]
	label_ada_texto.text = nivel.instruccion
	label_concepto.text = "Concepto: %s" % nivel.concepto_clave
	if nivel.get("puente_spidocode", false):
		label_concepto.text += "\nPuente a SpidoCode: Avanzar → spid.avanzar(), Girar → spid.girar(), Ensamblar → spid.ensamblar()"
	guia_activa = nivel.get("guiada", false)
	paso_guia = 0
	panel_guia.visible = guia_activa
	_actualizar_guia()

	btn_nivel_prev.disabled = (indice_nivel_actual == 0)
	btn_nivel_next.disabled = (indice_nivel_actual == niveles.size() - 1)

	# Actualizar paleta con SOLO los bloques autorizados en este nivel
	_actualizar_paleta(nivel.bloques_permitidos)
	tabs_codigo.set_tab_hidden(1, nivel.get("cantidad_astronautas", 1) < 2)
	tabs_codigo.set_tab_hidden(2, nivel.get("cantidad_astronautas", 1) < 3)
	tabs_codigo.set_tab_hidden(3, nivel.get("cantidad_astronautas", 1) < 4)
	tabs_codigo.set_tab_hidden(4, nivel.get("cantidad_astronautas", 1) < 5)
	tabs_codigo.set_tab_hidden(5, nivel.get("cantidad_astronautas", 1) < 6)
	tabs_codigo.set_tab_hidden(6, nivel.get("cantidad_astronautas", 1) < 7)
	tabs_codigo.set_tab_hidden(7, nivel.get("cantidad_astronautas", 1) < 8)
	tabs_codigo.set_tab_hidden(8, nivel.get("cantidad_astronautas", 1) < 9)
	tabs_codigo.set_tab_hidden(9, nivel.get("cantidad_astronautas", 1) < 10)

	# Limpiar lienzo y estado
	lienzo.limpiar_todo()
	lienzo_a2.limpiar_todo()
	lienzo_a3.limpiar_todo()
	lienzo_a4.limpiar_todo()
	lienzo_a5.limpiar_todo()
	lienzo_a6.limpiar_todo()
	lienzo_a7.limpiar_todo()
	lienzo_a8.limpiar_todo()
	lienzo_a9.limpiar_todo()
	lienzo_a10.limpiar_todo()
	_limpiar_error()
	panel_victoria.visible = false
	errores_durante_ejecucion = 0
	indice_paso_actual = 0

	# Cargar en el mundo 3D preservando el estado si es transicion continua
	mundo_3d.cargar_nivel(nivel, continuo)
	if continuo:
		_actualizar_estado("¡Mision continua! El equipo mantiene sus posiciones para la siguiente fase.")
	else:
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
	btn_duplicar.pressed.connect(_on_duplicar_pressed)

	btn_nivel_prev.pressed.connect(func(): cargar_nivel(indice_nivel_actual - 1))
	btn_nivel_next.pressed.connect(func(): cargar_nivel(indice_nivel_actual + 1))

	btn_modal_siguiente.pressed.connect(_on_modal_siguiente_pressed)
	btn_modal_reintentar.pressed.connect(_on_modal_reintentar_pressed)
	btn_guia_continuar.pressed.connect(_on_guia_continuar_pressed)
	btn_pista.pressed.connect(_on_pista_pressed)
	btn_continuar.pressed.connect(_on_continuar_pressed)
	btn_volver_menu.pressed.connect(_on_volver_menu_pressed)
	btn_pista.disabled = true
	if mundo_3d:
		if mundo_3d.astronauta:
			mundo_3d.astronauta.accion_fallida.connect(_on_accion_fallida)
			mundo_3d.astronauta.pieza_recogida.connect(_on_pieza_recogida)
			mundo_3d.astronauta.pieza_ensamblada.connect(_on_pieza_ensamblada)
		if mundo_3d.astronauta_2:
			mundo_3d.astronauta_2.accion_fallida.connect(_on_accion_fallida)
			mundo_3d.astronauta_2.pieza_recogida.connect(_on_pieza_recogida)
			mundo_3d.astronauta_2.pieza_ensamblada.connect(_on_pieza_ensamblada)
		if mundo_3d.astronauta_3:
			mundo_3d.astronauta_3.accion_fallida.connect(_on_accion_fallida)
			mundo_3d.astronauta_3.pieza_recogida.connect(_on_pieza_recogida)
			mundo_3d.astronauta_3.pieza_ensamblada.connect(_on_pieza_ensamblada)
		if mundo_3d.astronauta_4:
			mundo_3d.astronauta_4.accion_fallida.connect(_on_accion_fallida)
			mundo_3d.astronauta_4.pieza_recogida.connect(_on_pieza_recogida)
			mundo_3d.astronauta_4.pieza_ensamblada.connect(_on_pieza_ensamblada)
		if mundo_3d.astronauta_5:
			mundo_3d.astronauta_5.accion_fallida.connect(_on_accion_fallida)
			mundo_3d.astronauta_5.pieza_recogida.connect(_on_pieza_recogida)
			mundo_3d.astronauta_5.pieza_ensamblada.connect(_on_pieza_ensamblada)
		if mundo_3d.astronauta_6:
			mundo_3d.astronauta_6.accion_fallida.connect(_on_accion_fallida)
			mundo_3d.astronauta_6.pieza_recogida.connect(_on_pieza_recogida)
			mundo_3d.astronauta_6.pieza_ensamblada.connect(_on_pieza_ensamblada)
		if mundo_3d.astronauta_7:
			mundo_3d.astronauta_7.accion_fallida.connect(_on_accion_fallida)
			mundo_3d.astronauta_7.pieza_recogida.connect(_on_pieza_recogida)
			mundo_3d.astronauta_7.pieza_ensamblada.connect(_on_pieza_ensamblada)
		if mundo_3d.astronauta_8:
			mundo_3d.astronauta_8.accion_fallida.connect(_on_accion_fallida)
			mundo_3d.astronauta_8.pieza_recogida.connect(_on_pieza_recogida)
			mundo_3d.astronauta_8.pieza_ensamblada.connect(_on_pieza_ensamblada)
		if mundo_3d.astronauta_9:
			mundo_3d.astronauta_9.accion_fallida.connect(_on_accion_fallida)
			mundo_3d.astronauta_9.pieza_recogida.connect(_on_pieza_recogida)
			mundo_3d.astronauta_9.pieza_ensamblada.connect(_on_pieza_ensamblada)
		if mundo_3d.astronauta_10:
			mundo_3d.astronauta_10.accion_fallida.connect(_on_accion_fallida)
			mundo_3d.astronauta_10.pieza_recogida.connect(_on_pieza_recogida)
			mundo_3d.astronauta_10.pieza_ensamblada.connect(_on_pieza_ensamblada)

func _cambiar_estado_pausa(pausado: bool) -> void:
	fondo_menu_pausa.visible = pausado
	menu_pausa.visible = pausado
	get_tree().paused = pausado
	if pausado:
		btn_continuar.grab_focus()

func _on_continuar_pressed() -> void:
	_cambiar_estado_pausa(false)

func _on_volver_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(ESCENA_MENU_PRINCIPAL)

func _on_ejecutar_pressed() -> void:
	if en_ejecucion: return
	var secuencia_a1 = lienzo.obtener_secuencia_comandos()
	var secuencia_a2 = lienzo_a2.obtener_secuencia_comandos()
	var secuencia_a3 = lienzo_a3.obtener_secuencia_comandos()
	var secuencia_a4 = lienzo_a4.obtener_secuencia_comandos()
	var secuencia_a5 = lienzo_a5.obtener_secuencia_comandos()
	var secuencia_a6 = lienzo_a6.obtener_secuencia_comandos()
	var secuencia_a7 = lienzo_a7.obtener_secuencia_comandos()
	var secuencia_a8 = lienzo_a8.obtener_secuencia_comandos()
	var secuencia_a9 = lienzo_a9.obtener_secuencia_comandos()
	var secuencia_a10 = lienzo_a10.obtener_secuencia_comandos()
	if secuencia_a1.is_empty() and secuencia_a2.is_empty() and secuencia_a3.is_empty() and secuencia_a4.is_empty() and secuencia_a5.is_empty() and secuencia_a6.is_empty() and secuencia_a7.is_empty() and secuencia_a8.is_empty() and secuencia_a9.is_empty() and secuencia_a10.is_empty():
		_actualizar_estado("Los lienzos estan vacios. Arrastra bloques para programar al equipo.")
		return

	en_ejecucion = true
	_limpiar_error()
	_bloquear_interfaz(true)
	errores_durante_ejecucion = 0
	_actualizar_estado("Ejecutando las secuencias del equipo...")

	var abortado = false
	var nivel = niveles[indice_nivel_actual]
	if nivel.get("modo_paralelo", false):
		abortado = not await _ejecutar_equipo_paralelo(
			[mundo_3d.astronauta, mundo_3d.astronauta_2, mundo_3d.astronauta_3, mundo_3d.astronauta_4, mundo_3d.astronauta_5, mundo_3d.astronauta_6, mundo_3d.astronauta_7, mundo_3d.astronauta_8, mundo_3d.astronauta_9, mundo_3d.astronauta_10],
			[secuencia_a1, secuencia_a2, secuencia_a3, secuencia_a4, secuencia_a5, secuencia_a6, secuencia_a7, secuencia_a8, secuencia_a9, secuencia_a10]
		)
	else:
		if not secuencia_a1.is_empty():
			abortado = not await _ejecutar_secuencia(mundo_3d.astronauta, secuencia_a1, "Astronauta 1")
		if not abortado and not secuencia_a2.is_empty():
			abortado = not await _ejecutar_secuencia(mundo_3d.astronauta_2, secuencia_a2, "Astronauta 2")
		if not abortado and not secuencia_a3.is_empty():
			abortado = not await _ejecutar_secuencia(mundo_3d.astronauta_3, secuencia_a3, "Astronauta 3")
		if not abortado and not secuencia_a4.is_empty():
			abortado = not await _ejecutar_secuencia(mundo_3d.astronauta_4, secuencia_a4, "Astronauta 4")
		if not abortado and not secuencia_a5.is_empty():
			abortado = not await _ejecutar_secuencia(mundo_3d.astronauta_5, secuencia_a5, "Astronauta 5")
		if not abortado and not secuencia_a6.is_empty():
			abortado = not await _ejecutar_secuencia(mundo_3d.astronauta_6, secuencia_a6, "Astronauta 6")
		if not abortado and not secuencia_a7.is_empty():
			abortado = not await _ejecutar_secuencia(mundo_3d.astronauta_7, secuencia_a7, "Astronauta 7")
		if not abortado and not secuencia_a8.is_empty():
			abortado = not await _ejecutar_secuencia(mundo_3d.astronauta_8, secuencia_a8, "Astronauta 8")
		if not abortado and not secuencia_a9.is_empty():
			abortado = not await _ejecutar_secuencia(mundo_3d.astronauta_9, secuencia_a9, "Astronauta 9")
		if not abortado and not secuencia_a10.is_empty():
			abortado = not await _ejecutar_secuencia(mundo_3d.astronauta_10, secuencia_a10, "Astronauta 10")

	en_ejecucion = false
	_bloquear_interfaz(false)

	# Evaluar si se cumplio la meta
	await get_tree().create_timer(0.2).timeout
	_evaluar_resultado_nivel(secuencia_a1.size() + secuencia_a2.size() + secuencia_a3.size() + secuencia_a4.size() + secuencia_a5.size() + secuencia_a6.size() + secuencia_a7.size() + secuencia_a8.size() + secuencia_a9.size() + secuencia_a10.size(), abortado)

func _ejecutar_equipo_paralelo(astronautas: Array, secuencias: Array) -> bool:
	var max_pasos = 0
	for secuencia in secuencias:
		max_pasos = maxi(max_pasos, secuencia.size())
	for paso in range(max_pasos):
		for indice in range(astronautas.size()):
			var secuencia = secuencias[indice]
			if paso >= secuencia.size() or not astronautas[indice].visible:
				continue
			var bloque: BloqueItem = secuencia[paso]
			var etiqueta = "Astronauta %d" % (indice + 1)
			_actualizar_estado("%s - accion %d/%d" % [etiqueta, paso + 1, secuencia.size()])
			bloque.resaltar_ejecucion(true)
			var exito = await astronautas[indice].ejecutar_accion(bloque.id_comando)
			await get_tree().create_timer(0.08).timeout
			bloque.resaltar_ejecucion(false)
			if not exito:
				errores_durante_ejecucion += 1
				bloque.resaltar_error(true)
				bloque_con_error = bloque
				_actualizar_estado("[ERROR] %s: %s" % [etiqueta, ultimo_error if not ultimo_error.is_empty() else "La accion no pudo completarse."])
				return false
	return true

func _ejecutar_secuencia(astronauta: AstronautaIngeniero, secuencia: Array[BloqueItem], etiqueta: String) -> bool:
	for i in range(secuencia.size()):
		var bloque = secuencia[i]
		_actualizar_estado("%s - paso %d/%d: %s" % [etiqueta, i + 1, secuencia.size(), bloque.titulo])
		bloque.resaltar_ejecucion(true)
		var exito = await astronauta.ejecutar_accion(bloque.id_comando)
		await get_tree().create_timer(0.12).timeout
		bloque.resaltar_ejecucion(false)
		if not exito:
			errores_durante_ejecucion += 1
			bloque.resaltar_error(true)
			bloque_con_error = bloque
			_actualizar_estado("[ERROR] %s - paso %d: %s" % [etiqueta, i + 1, ultimo_error if not ultimo_error.is_empty() else "La accion no pudo completarse."])
			return false
	return true

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
		if nivel.get("tipo_meta", "BALIZA") == "BALIZA":
			var celda_actual = Vector2i(mundo_3d.astronauta.grid_x, mundo_3d.astronauta.grid_z)
			var celda_meta = nivel.get("pos_baliza", Vector2i(0, -1))
			if celda_actual.y > celda_meta.y:
				ultimo_error = "El astronauta se detuvo antes de alcanzar la baliza."
			elif celda_actual.y < celda_meta.y:
				ultimo_error = "El astronauta sobrepaso la baliza."
			else:
				ultimo_error = "El astronauta no se encuentra en la casilla de la baliza."
			btn_pista.disabled = false
		_actualizar_estado("[FALLO] La meta no fue alcanzada. Presiona 'Pista' si necesitas ayuda o 'Reiniciar' para volver a intentar.")

func _mostrar_victoria(estrellas: int, cant_bloques: int, optimo: int) -> void:
	var texto_estrellas = ""
	for i in range(3):
		texto_estrellas += "[*] " if i < estrellas else "[ ] "

	label_estrellas.text = texto_estrellas
	var detalle_aprendizaje = ""
	if niveles[indice_nivel_actual].get("guiada", false):
		detalle_aprendizaje = "\n\nAprendizaje: construiste y corregiste una secuencia."
	label_victoria_detalle.text = (
		"Calificacion: %d/3 Estrellas\n" +
		"- Objetivo alcanzado con exito\n" +
		"- Errores cometidos: %d\n" +
		"- Bloques usados: %d (Optimo pedagogico: %d)%s"
	) % [estrellas, errores_durante_ejecucion, cant_bloques, optimo, detalle_aprendizaje]

	btn_modal_siguiente.visible = (indice_nivel_actual < niveles.size() - 1)
	panel_victoria.visible = true

func _on_modal_siguiente_pressed() -> void:
	panel_victoria.visible = false
	cargar_nivel(indice_nivel_actual + 1, true)

func _on_modal_reintentar_pressed() -> void:
	panel_victoria.visible = false
	_on_reiniciar_pressed()

func _on_paso_pressed() -> void:
	if en_ejecucion: return
	var lienzo_actual = lienzo
	var astronauta_actual = mundo_3d.astronauta
	if tabs_codigo.current_tab == 1:
		lienzo_actual = lienzo_a2
		astronauta_actual = mundo_3d.astronauta_2
	elif tabs_codigo.current_tab == 2:
		lienzo_actual = lienzo_a3
		astronauta_actual = mundo_3d.astronauta_3
	elif tabs_codigo.current_tab == 3:
		lienzo_actual = lienzo_a4
		astronauta_actual = mundo_3d.astronauta_4
	elif tabs_codigo.current_tab == 4:
		lienzo_actual = lienzo_a5
		astronauta_actual = mundo_3d.astronauta_5
	elif tabs_codigo.current_tab == 5:
		lienzo_actual = lienzo_a6
		astronauta_actual = mundo_3d.astronauta_6
	elif tabs_codigo.current_tab == 6:
		lienzo_actual = lienzo_a7
		astronauta_actual = mundo_3d.astronauta_7
	elif tabs_codigo.current_tab == 7:
		lienzo_actual = lienzo_a8
		astronauta_actual = mundo_3d.astronauta_8
	elif tabs_codigo.current_tab == 8:
		lienzo_actual = lienzo_a9
		astronauta_actual = mundo_3d.astronauta_9
	elif tabs_codigo.current_tab == 9:
		lienzo_actual = lienzo_a10
		astronauta_actual = mundo_3d.astronauta_10
	var secuencia = lienzo_actual.obtener_secuencia_comandos()
	if secuencia.is_empty():
		_actualizar_estado("Agrega bloques al lienzo del astronauta seleccionado.")
		return

	if indice_paso_actual >= secuencia.size():
		indice_paso_actual = 0

	var bloque = secuencia[indice_paso_actual]
	_actualizar_estado("Paso manual %d/%d: %s" % [indice_paso_actual + 1, secuencia.size(), bloque.titulo])

	en_ejecucion = true
	_limpiar_error()
	_bloquear_interfaz(true)
	bloque.resaltar_ejecucion(true)

	var exito = await astronauta_actual.ejecutar_accion(bloque.id_comando)
	await get_tree().create_timer(0.08).timeout
	bloque.resaltar_ejecucion(false)
	if not exito:
		errores_durante_ejecucion += 1
		bloque.resaltar_error(true)
		bloque_con_error = bloque
		_actualizar_estado("[ERROR] Paso manual: %s" % (ultimo_error if not ultimo_error.is_empty() else "La accion no pudo completarse."))

	indice_paso_actual += 1
	en_ejecucion = false
	_bloquear_interfaz(false)

func _on_reiniciar_pressed() -> void:
	indice_paso_actual = 0
	errores_durante_ejecucion = 0
	_limpiar_error()
	await mundo_3d.reiniciar_mundo()
	_actualizar_estado("Nivel reiniciado. Prueba otra vez tu algoritmo.")

func _on_limpiar_pressed() -> void:
	if en_ejecucion: return
	lienzo.limpiar_todo()
	lienzo_a2.limpiar_todo()
	lienzo_a3.limpiar_todo()
	lienzo_a4.limpiar_todo()
	lienzo_a5.limpiar_todo()
	lienzo_a6.limpiar_todo()
	lienzo_a7.limpiar_todo()
	indice_paso_actual = 0
	_limpiar_error()
	_actualizar_estado("Lienzo vaciado.")

func _on_duplicar_pressed() -> void:
	if en_ejecucion:
		return
	var lienzo_actual = lienzo
	if tabs_codigo.current_tab == 1:
		lienzo_actual = lienzo_a2
	elif tabs_codigo.current_tab == 2:
		lienzo_actual = lienzo_a3
	elif tabs_codigo.current_tab == 3:
		lienzo_actual = lienzo_a4
	elif tabs_codigo.current_tab == 4:
		lienzo_actual = lienzo_a5
	elif tabs_codigo.current_tab == 5:
		lienzo_actual = lienzo_a6
	elif tabs_codigo.current_tab == 6:
		lienzo_actual = lienzo_a7
	elif tabs_codigo.current_tab == 7:
		lienzo_actual = lienzo_a8
	elif tabs_codigo.current_tab == 8:
		lienzo_actual = lienzo_a9
	elif tabs_codigo.current_tab == 9:
		lienzo_actual = lienzo_a10
	if lienzo_actual.duplicar_secuencia():
		_actualizar_estado("Secuencia duplicada. Ahora puedes reutilizarla o modificarla.")
	else:
		_actualizar_estado("No hay una secuencia para duplicar.")

func _bloquear_interfaz(bloquear: bool) -> void:
	btn_ejecutar.disabled = bloquear
	btn_paso.disabled = bloquear
	btn_limpiar.disabled = bloquear
	btn_duplicar.disabled = bloquear
	btn_nivel_prev.disabled = bloquear or (indice_nivel_actual == 0)
	btn_nivel_next.disabled = bloquear or (indice_nivel_actual == niveles.size() - 1)
	btn_guia_continuar.disabled = bloquear
	btn_pista.disabled = bloquear or ultimo_error.is_empty()

func _on_guia_continuar_pressed() -> void:
	if not guia_activa:
		return
	if paso_guia < PASOS_GUIA.size() - 1:
		paso_guia += 1
		_actualizar_guia()
	else:
		panel_guia.visible = false
		_actualizar_estado("Guia completada. Ahora construye y ejecuta tu propia secuencia.")

func _actualizar_guia() -> void:
	if not guia_activa or not is_instance_valid(label_guia_texto):
		return
	var paso = PASOS_GUIA[paso_guia]
	label_guia_texto.text = "%s\n%s" % [paso.titulo, paso.texto]
	btn_guia_continuar.text = "Comenzar" if paso_guia == PASOS_GUIA.size() - 1 else "Continuar"

func _limpiar_error() -> void:
	ultimo_error = ""
	if is_instance_valid(bloque_con_error):
		bloque_con_error.resaltar_error(false)
	bloque_con_error = null
	if is_instance_valid(btn_pista):
		btn_pista.disabled = true

func _on_pista_pressed() -> void:
	if ultimo_error.is_empty():
		return
	var pista = "Revisa la instruccion marcada y prueba otra vez."
	if "ninguna pieza frente" in ultimo_error:
		pista = "Pista: acerca al astronauta a la pieza y orientalo hacia ella antes de usar Tomar Pieza."
	elif "No tienes ninguna pieza" in ultimo_error:
		pista = "Pista: primero recoge una pieza; despues podras llevarla a la mesa."
	elif "No estas frente a la mesa" in ultimo_error:
		pista = "Pista: lleva la pieza hasta una casilla vecina a la mesa y orienta al astronauta hacia ella."
	elif "requiere otra pieza" in ultimo_error:
		pista = "Pista: revisa el orden de montaje; esta pieza todavia no corresponde a la siguiente etapa."
	elif "detuvo antes" in ultimo_error:
		pista = "Pista: Te faltaron pasos. El astronauta necesita avanzar exactamente 3 casillas hacia el norte para alcanzar la baliza."
	elif "sobrepaso" in ultimo_error:
		pista = "Pista: Colocaste demasiados bloques. Elimina los bloques que sobran para detenerte justo sobre la baliza."
	elif "no se encuentra en la casilla" in ultimo_error:
		pista = "Pista: El astronauta no llego a la baliza. Revisa la direccion y cantidad de bloques 'Avanzar'."
	_actualizar_estado(pista)

func _actualizar_estado(mensaje: String) -> void:
	if label_estado:
		label_estado.text = mensaje

func _on_accion_fallida(motivo: String) -> void:
	ultimo_error = motivo
	btn_pista.disabled = false
	_actualizar_estado("[ALERTA] %s" % motivo)

func _on_pieza_recogida(nombre: String) -> void:
	_actualizar_estado("[ITEM] Astronauta tomo: %s" % nombre)

func _on_pieza_ensamblada(tipo: String) -> void:
	_actualizar_estado("[OK] Pieza %s montada en Spid" % tipo)
