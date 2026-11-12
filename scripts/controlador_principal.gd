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
@onready var btn_velocidad: Button = %BtnVelocidad

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
const HitosSandboxClass = preload("res://scripts/hitos_sandbox.gd")

var hitos: Array[Dictionary] = []
var indice_hito_actual: int = 0
var hitos_completados: Array[int] = []

var en_ejecucion: bool = false
var modo_bucle: bool = false
var detener_solicitado: bool = false
var factor_velocidad: int = 1
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
	"ENSAMBLAR": {"tit": "Ensamblar en Spid", "prefijo": "[ENS]", "color": Color(0.435294, 0.686275, 0.470588, 1.0)},
	"DIAGNOSTICO": {"tit": "Diagnostico Spido", "prefijo": "[TEST]", "color": Color(0.2, 0.85, 1.0, 1.0)}
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = false
	hitos = HitosSandboxClass.obtener_hitos()
	indice_hito_actual = 0
	hitos_completados.clear()
	_conectar_senales()
	tabs_codigo.set_tab_title(0, "Astro 1: Ingeniero")
	tabs_codigo.set_tab_title(1, "Astro 2: Tracción")
	tabs_codigo.set_tab_title(2, "Astro 3: Sensores")
	tabs_codigo.set_tab_title(3, "Astro 4: Brazos")
	tabs_codigo.set_tab_title(4, "Astro 5: Energía")
	for i in range(1, 10):
		tabs_codigo.set_tab_hidden(i, true)
	panel_victoria.visible = false
	fondo_menu_pausa.visible = false
	menu_pausa.visible = false
	btn_duplicar.text = "Bucle: OFF"
	_aplicar_hito_actual()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_cambiar_estado_pausa(not menu_pausa.visible)
		get_viewport().set_input_as_handled()

func cambiar_hito(indice: int) -> void:
	if indice < 0 or indice >= hitos.size():
		return
	indice_hito_actual = indice
	_aplicar_hito_actual()

func _aplicar_hito_actual() -> void:
	if indice_hito_actual < 0 or indice_hito_actual >= hitos.size():
		return
	var hito = hitos[indice_hito_actual]

	# Actualizar cabecera didactica del hito actual
	label_nivel_titulo.text = "[HITO %d/%d] %s" % [hito.id, hitos.size(), hito.titulo]
	label_ada_texto.text = hito.descripcion
	label_concepto.text = "Objetivo: %s" % hito.meta_texto

	btn_nivel_prev.disabled = (indice_hito_actual == 0)
	btn_nivel_next.disabled = (indice_hito_actual == hitos.size() - 1)

	# Destello sutil en el titulo para avisar del hito activo
	if is_instance_valid(label_nivel_titulo):
		var tw_tit = create_tween()
		tw_tit.tween_property(label_nivel_titulo, "modulate", Color(0.35, 1.0, 0.65), 0.2)
		tw_tit.tween_property(label_nivel_titulo, "modulate", Color(0.95, 0.96, 0.95), 0.4)

	# Actualizar paleta con los bloques disponibles en esta fase
	_actualizar_paleta(hito.bloques_desbloqueados)

	# Visibilidad de pestañas segun la cantidad de astronautas
	var cant_astros = hito.get("cantidad_astronautas", 1)
	for i in range(1, 10):
		tabs_codigo.set_tab_hidden(i, i >= cant_astros)

	# Configurar mundo 3D sin resetear las posiciones ni el robot Spido
	if mundo_3d:
		# Baliza
		if mundo_3d.baliza_meta:
			var mostrar_b = hito.get("mostrar_baliza", false)
			mundo_3d.baliza_meta.visible = mostrar_b
			if mostrar_b:
				mundo_3d.baliza_meta.posicionar_en_celda(hito.get("pos_baliza", Vector2i(0, -1)))

		# Activacion progresiva de nuevos astronautas
		if cant_astros >= 2 and mundo_3d.astronauta_2 and not mundo_3d.astronauta_2.visible:
			mundo_3d.astronauta_2.visible = true
			mundo_3d.astronauta_2.configurar_inicio(hito.get("pos_astronauta_2", Vector2i(0, 2)), 0)
		if cant_astros >= 3 and mundo_3d.astronauta_3 and not mundo_3d.astronauta_3.visible:
			mundo_3d.astronauta_3.visible = true
			mundo_3d.astronauta_3.configurar_inicio(hito.get("pos_astronauta_3", Vector2i(-1, 2)), 0)
		if cant_astros >= 4 and mundo_3d.astronauta_4 and not mundo_3d.astronauta_4.visible:
			mundo_3d.astronauta_4.visible = true
			mundo_3d.astronauta_4.configurar_inicio(hito.get("pos_astronauta_4", Vector2i(1, 2)), 0)
		if cant_astros >= 5 and mundo_3d.astronauta_5 and not mundo_3d.astronauta_5.visible:
			mundo_3d.astronauta_5.visible = true
			mundo_3d.astronauta_5.configurar_inicio(hito.get("pos_astronauta_5", Vector2i(0, 2)), 0)

		# Piezas del hito en las bahias (sin borrar las ya montadas)
		if hito.has("piezas") and not hito.piezas.is_empty():
			mundo_3d._recrear_piezas(hito.piezas, true)

		# Fijar checkpoint actual en los astronautas activos para que si reinician no vuelvan al inicio de los tiempos
		if mundo_3d.astronauta:
			mundo_3d.astronauta.fijar_checkpoint_actual()
		if mundo_3d.astronauta_2 and mundo_3d.astronauta_2.visible:
			mundo_3d.astronauta_2.fijar_checkpoint_actual()
		if mundo_3d.astronauta_3 and mundo_3d.astronauta_3.visible:
			mundo_3d.astronauta_3.fijar_checkpoint_actual()
		if mundo_3d.astronauta_4 and mundo_3d.astronauta_4.visible:
			mundo_3d.astronauta_4.fijar_checkpoint_actual()
		if mundo_3d.astronauta_5 and mundo_3d.astronauta_5.visible:
			mundo_3d.astronauta_5.fijar_checkpoint_actual()

		mundo_3d.resaltar_astronauta_seleccionado(tabs_codigo.current_tab)

	_actualizar_estado("Mundo Sandbox Activo. Automatiza y programa a tus astronautas.")

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
	if btn_velocidad:
		btn_velocidad.pressed.connect(_on_velocidad_pressed)

	btn_nivel_prev.pressed.connect(func(): cambiar_hito(indice_hito_actual - 1))
	btn_nivel_next.pressed.connect(func(): cambiar_hito(indice_hito_actual + 1))

	btn_modal_siguiente.pressed.connect(_on_modal_siguiente_pressed)
	btn_modal_reintentar.pressed.connect(_on_modal_reintentar_pressed)
	btn_guia_continuar.pressed.connect(_on_guia_continuar_pressed)
	btn_pista.pressed.connect(_on_pista_pressed)
	btn_continuar.pressed.connect(_on_continuar_pressed)
	btn_volver_menu.pressed.connect(_on_volver_menu_pressed)
	btn_pista.disabled = true
	tabs_codigo.tab_changed.connect(_on_tab_codigo_changed)

	if mundo_3d:
		if mundo_3d.mesa_spid:
			mundo_3d.mesa_spid.spid_actualizado.connect(func(_e, _t, _m): _verificar_hitos_sandbox())
			mundo_3d.mesa_spid.spid_completado.connect(func(): _verificar_hitos_sandbox())
			mundo_3d.mesa_spid.diagnostico_realizado.connect(func(): _verificar_hitos_sandbox())

		var todos_astros = [
			mundo_3d.astronauta, mundo_3d.astronauta_2, mundo_3d.astronauta_3,
			mundo_3d.astronauta_4, mundo_3d.astronauta_5
		]
		for a in todos_astros:
			if a:
				a.accion_fallida.connect(_on_accion_fallida)
				a.pieza_recogida.connect(_on_pieza_recogida)
				a.pieza_ensamblada.connect(func(tipo): 
					_on_pieza_ensamblada(tipo)
					_verificar_hitos_sandbox()
				)

func _cambiar_estado_pausa(pausado: bool) -> void:
	fondo_menu_pausa.visible = pausado
	menu_pausa.visible = pausado
	get_tree().paused = pausado
	if pausado:
		btn_continuar.grab_focus()

func _on_continuar_pressed() -> void:
	_cambiar_estado_pausa(false)

func _on_volver_menu_pressed() -> void:
	Engine.time_scale = 1.0
	get_tree().paused = false
	get_tree().change_scene_to_file(ESCENA_MENU_PRINCIPAL)

func _on_ejecutar_pressed() -> void:
	if en_ejecucion:
		detener_solicitado = true
		_actualizar_estado("Deteniendo automatización...")
		btn_ejecutar.text = "Deteniendo..."
		return

	var secuencias = [
		lienzo.obtener_secuencia_comandos(),
		lienzo_a2.obtener_secuencia_comandos(),
		lienzo_a3.obtener_secuencia_comandos(),
		lienzo_a4.obtener_secuencia_comandos(),
		lienzo_a5.obtener_secuencia_comandos()
	]

	var hay_instrucciones = false
	for sec in secuencias:
		if not sec.is_empty():
			hay_instrucciones = true
			break

	if not hay_instrucciones:
		_actualizar_estado("Los lienzos están vacíos. Arrastra bloques de instrucciones para programar al equipo.")
		return

	en_ejecucion = true
	detener_solicitado = false
	_limpiar_error()
	btn_ejecutar.text = "Detener"
	btn_ejecutar.modulate = Color(0.9, 0.4, 0.4)
	_bloquear_interfaz(true)
	btn_ejecutar.disabled = false

	var ciclo = 1
	var astronautas = [
		mundo_3d.astronauta, mundo_3d.astronauta_2, mundo_3d.astronauta_3,
		mundo_3d.astronauta_4, mundo_3d.astronauta_5
	]

	while en_ejecucion and not detener_solicitado:
		errores_durante_ejecucion = 0
		_actualizar_estado("Automatización en marcha (Ciclo %d)..." % ciclo)

		var exito = await _ejecutar_equipo_paralelo(astronautas, secuencias)
		_verificar_hitos_sandbox()

		if not exito or not modo_bucle or detener_solicitado:
			break

		ciclo += 1
		await get_tree().create_timer(0.25).timeout

	en_ejecucion = false
	detener_solicitado = false
	btn_ejecutar.text = "Ejecutar"
	btn_ejecutar.modulate = Color.WHITE
	_bloquear_interfaz(false)
	_verificar_hitos_sandbox()

func _ejecutar_equipo_paralelo(astronautas: Array, secuencias: Array) -> bool:
	var max_pasos = 0
	for sec in secuencias:
		max_pasos = maxi(max_pasos, sec.size())

	for paso in range(max_pasos):
		if detener_solicitado:
			return false

		for idx in range(min(astronautas.size(), secuencias.size())):
			var astro: AstronautaIngeniero = astronautas[idx]
			var sec: Array = secuencias[idx]
			if paso >= sec.size() or not astro.visible:
				continue

			var bloque: BloqueItem = sec[paso]
			bloque.resaltar_ejecucion(true)
			var ok = await astro.ejecutar_accion(bloque.id_comando)
			bloque.resaltar_ejecucion(false)

			if not ok:
				errores_durante_ejecucion += 1
				bloque.resaltar_error(true)
				bloque_con_error = bloque
				_actualizar_estado("[ALERTA] %s se detuvo: %s" % [astro.nombre_rol, ultimo_error if not ultimo_error.is_empty() else "Acción bloqueada."])
				return false

		# Chequeo dinámico tras cada paso
		_verificar_hitos_sandbox()
		await get_tree().create_timer(0.06).timeout

	return true

func _verificar_hitos_sandbox() -> void:
	if indice_hito_actual >= hitos.size():
		return
	var hito = hitos[indice_hito_actual]
	var cumplido = false

	match hito.clave:
		"CALIBRACION":
			if mundo_3d and mundo_3d.astronauta:
				var pos_actual = Vector2i(mundo_3d.astronauta.grid_x, mundo_3d.astronauta.grid_z)
				if pos_actual == hito.get("pos_baliza", Vector2i(0, -1)):
					cumplido = true
		"MONTAR_CHASIS":
			if mundo_3d and mundo_3d.mesa_spid and "CHASIS" in mundo_3d.mesa_spid.etapas_completadas:
				cumplido = true
		"SUMINISTRO_RUEDAS":
			if mundo_3d and mundo_3d.mesa_spid and "RUEDAS" in mundo_3d.mesa_spid.etapas_completadas:
				cumplido = true
		"EQUIPO_CONCURRENTE":
			if mundo_3d and mundo_3d.mesa_spid and "SENSOR" in mundo_3d.mesa_spid.etapas_completadas:
				cumplido = true
		"CADENA_AUTOMATIZADA":
			if mundo_3d and mundo_3d.mesa_spid:
				if "BRAZOS" in mundo_3d.mesa_spid.etapas_completadas and "BATERIA" in mundo_3d.mesa_spid.etapas_completadas:
					cumplido = true
		"DESPERTAR_SPIDO":
			if mundo_3d and mundo_3d.mesa_spid and (mundo_3d.mesa_spid.diagnostico_ejecutado or mundo_3d.mesa_spid.etapas_completadas.size() >= 5):
				cumplido = true

	if cumplido and indice_hito_actual not in hitos_completados:
		hitos_completados.append(indice_hito_actual)
		_completar_hito_sandbox()

func _completar_hito_sandbox() -> void:
	var hito_terminado = hitos[indice_hito_actual]
	_actualizar_estado("⭐ ¡HITO LOGRADO: %s! ⭐ Desbloqueando nuevas capacidades..." % hito_terminado.titulo)

	if mundo_3d and mundo_3d.astronauta:
		mundo_3d.astronauta.resaltar_seleccion(true)

	if indice_hito_actual < hitos.size() - 1:
		indice_hito_actual += 1
		await get_tree().create_timer(1.2).timeout
		_aplicar_hito_actual()
	else:
		_actualizar_estado("🏆 ¡PROYECTO SPIDO COMPLETADO! Robot araña totalmente automatizado.")
		if mundo_3d and mundo_3d.mesa_spid:
			mundo_3d.mesa_spid.probar_sistemas()

func _on_duplicar_pressed() -> void:
	modo_bucle = not modo_bucle
	if modo_bucle:
		btn_duplicar.text = "Bucle: ON [AUTO]"
		btn_duplicar.modulate = Color(0.35, 0.95, 0.65)
		_actualizar_estado("Modo Automatización Bucle: ACTIVO. Tus astronautas repetirán su rutina continuamente.")
	else:
		btn_duplicar.text = "Bucle: OFF"
		btn_duplicar.modulate = Color.WHITE
		_actualizar_estado("Modo Bucle: INACTIVO. Ejecución de un solo ciclo.")

func _on_modal_siguiente_pressed() -> void:
	if indice_hito_actual < hitos.size() - 1:
		cambiar_hito(indice_hito_actual + 1)

func _on_modal_reintentar_pressed() -> void:
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
	_verificar_hitos_sandbox()

func _on_reiniciar_pressed() -> void:
	indice_paso_actual = 0
	errores_durante_ejecucion = 0
	detener_solicitado = true
	_limpiar_error()
	await mundo_3d.reiniciar_mundo(true)
	_actualizar_estado("Posiciones de astronautas reiniciadas. El robot Spido y tus bloques se mantienen intactos.")

func _on_velocidad_pressed() -> void:
	match factor_velocidad:
		1:
			factor_velocidad = 2
			Engine.time_scale = 2.0
			btn_velocidad.text = "Vel: 2x"
			btn_velocidad.modulate = Color(0.3, 0.9, 1.0)
			_actualizar_estado("Velocidad de simulación acelerada a 2x.")
		2:
			factor_velocidad = 3
			Engine.time_scale = 3.5
			btn_velocidad.text = "Vel: 3.5x"
			btn_velocidad.modulate = Color(1.0, 0.8, 0.2)
			_actualizar_estado("Velocidad de simulación máxima (3.5x).")
		_:
			factor_velocidad = 1
			Engine.time_scale = 1.0
			btn_velocidad.text = "Vel: 1x"
			btn_velocidad.modulate = Color.WHITE
			_actualizar_estado("Velocidad de simulación normal (1x).")

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

func _on_tab_codigo_changed(idx: int) -> void:
	if mundo_3d:
		mundo_3d.resaltar_astronauta_seleccionado(idx)
	var nombre_tab = tabs_codigo.get_tab_title(idx)
	_actualizar_estado("Programando secuencia para: %s" % nombre_tab)

func _bloquear_interfaz(bloquear: bool) -> void:
	btn_ejecutar.disabled = false
	btn_paso.disabled = bloquear
	btn_limpiar.disabled = bloquear
	btn_nivel_prev.disabled = bloquear or (indice_hito_actual == 0)
	btn_nivel_next.disabled = bloquear or (indice_hito_actual == hitos.size() - 1)
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
