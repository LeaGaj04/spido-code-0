class_name Mundo3D
extends Node3D

@export var escena_pieza: PackedScene

@onready var astronauta: AstronautaIngeniero = $Astronauta
@onready var astronauta_2: AstronautaIngeniero = $Astronauta2
@onready var astronauta_3: AstronautaIngeniero = $Astronauta3
@onready var astronauta_4: AstronautaIngeniero = $Astronauta4
@onready var astronauta_5: AstronautaIngeniero = $Astronauta5
@onready var astronauta_6: AstronautaIngeniero = $Astronauta6
@onready var astronauta_7: AstronautaIngeniero = $Astronauta7
@onready var astronauta_8: AstronautaIngeniero = $Astronauta8
@onready var astronauta_9: AstronautaIngeniero = $Astronauta9
@onready var astronauta_10: AstronautaIngeniero = $Astronauta10
@onready var mesa_spid: MesaEnsamblaje = $MesaEnsamblaje
@onready var baliza_meta: BalizaMeta = $BalizaMeta
@onready var contenedor_piezas: Node3D = $ContenedorPiezas

const MesonSubensamblajeClass = preload("res://scripts/meson_subensamblaje.gd")

var piezas_por_celda: Dictionary = {}
var mesones_por_celda: Dictionary = {}
var config_nivel_actual: Dictionary = {}

var meson_patas: Node3D = null
var meson_sensores: Node3D = null

var cursor_seleccion: Node3D = null
var idx_astronauta_activo: int = 0
var contenedor_tablero: Node3D = null
var contenedor_decoracion: Node3D = null

func _ready() -> void:
	_inicializar_roles_astronautas()
	_inicializar_mesones()
	_construir_tablero_ajedrez()
	_construir_decoracion_nave()
	_crear_cursor_seleccion()

func _process(delta: float) -> void:
	_actualizar_cursor_seguimiento(delta)

func _inicializar_mesones() -> void:
	# Mesón de Patas & Tracción (Celda (-2, 0))
	if not meson_patas:
		meson_patas = MesonSubensamblajeClass.new()
		meson_patas.name = "MesonPatas"
		meson_patas.celda_mesa = Vector2i(-2, 0)
		meson_patas.tipo_estacion = "PATAS"
		meson_patas.insumo_requerido = "TORNILLO"
		meson_patas.cantidad_requerida = 1
		meson_patas.producto_salida = "RUEDAS"
		add_child(meson_patas)
		mesones_por_celda[Vector2i(-2, 0)] = meson_patas
		meson_patas.visible = false

	# Mesón de Sensores & Circuitos (Celda (2, 0))
	if not meson_sensores:
		meson_sensores = MesonSubensamblajeClass.new()
		meson_sensores.name = "MesonSensores"
		meson_sensores.celda_mesa = Vector2i(2, 0)
		meson_sensores.tipo_estacion = "SENSORES"
		meson_sensores.insumo_requerido = "MICROCHIP"
		meson_sensores.cantidad_requerida = 1
		meson_sensores.producto_salida = "SENSOR"
		add_child(meson_sensores)
		mesones_por_celda[Vector2i(2, 0)] = meson_sensores
		meson_sensores.visible = false

func _inicializar_roles_astronautas() -> void:
	if astronauta: astronauta.establecer_identidad("Ingeniero", Color(0.2, 0.85, 0.45))
	if astronauta_2: astronauta_2.establecer_identidad("Tracción", Color(0.2, 0.75, 0.95))
	if astronauta_3: astronauta_3.establecer_identidad("Sensores", Color(0.95, 0.8, 0.2))
	if astronauta_4: astronauta_4.establecer_identidad("Brazos", Color(0.95, 0.5, 0.15))
	if astronauta_5: astronauta_5.establecer_identidad("Energía", Color(0.85, 0.3, 0.85))

func _construir_tablero_ajedrez() -> void:
	if is_instance_valid(contenedor_tablero):
		contenedor_tablero.queue_free()

	contenedor_tablero = Node3D.new()
	contenedor_tablero.name = "ContenedorTablero"
	add_child(contenedor_tablero)

	# 1. Base / Marco perimetral del tablero 12x12
	# Rango: gx de -6 a 5 (12 casillas), gz de -6 a 5 (12 casillas)
	# Ancho total: 12 * 2.0 = 24.0. Centro: X = -1.0, Z = -1.0
	var mat_marco = StandardMaterial3D.new()
	mat_marco.albedo_color = Color(0.20, 0.24, 0.30)
	mat_marco.metallic = 0.5
	mat_marco.roughness = 0.4

	var marco_base = MeshInstance3D.new()
	var m_marco = BoxMesh.new()
	m_marco.size = Vector3(24.5, 0.12, 24.5)
	marco_base.mesh = m_marco
	marco_base.material_override = mat_marco
	marco_base.position = Vector3(-1.0, -0.07, -1.0)
	contenedor_tablero.add_child(marco_base)

	# 2. Las 2 placas de ajedrez (blanca/gris clara y gris más oscura)
	var mat_claro = StandardMaterial3D.new()
	mat_claro.albedo_color = Color(0.93, 0.95, 0.98) # Placa blanca/gris clara limpia
	mat_claro.metallic = 0.15
	mat_claro.roughness = 0.4

	var mat_oscuro = StandardMaterial3D.new()
	mat_oscuro.albedo_color = Color(0.55, 0.60, 0.68) # Placa gris intermedia contrastada
	mat_oscuro.metallic = 0.2
	mat_oscuro.roughness = 0.5

	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(1.98, 0.08, 1.98)

	# Generación exacta de 12x12 = 144 casillas
	for gx in range(-6, 6):
		for gz in range(-6, 6):
			var tile = MeshInstance3D.new()
			tile.mesh = box_mesh
			var es_par = ((gx + gz) % 2 == 0)
			tile.material_override = mat_claro if es_par else mat_oscuro
			# Centro exacto de la casilla en la cuadrícula
			tile.position = Vector3(gx * 2.0, -0.01, gz * 2.0)
			contenedor_tablero.add_child(tile)

	# 3. Rieles de acento neón en los 4 bordes del tablero 12x12
	var mat_borde = StandardMaterial3D.new()
	mat_borde.albedo_color = Color(0.85, 0.90, 0.95)
	mat_borde.emission_enabled = true
	mat_borde.emission = Color(0.3, 0.95, 0.65)
	mat_borde.emission_energy_multiplier = 0.8

	var m_rail_h = BoxMesh.new()
	m_rail_h.size = Vector3(24.5, 0.08, 0.1)

	var m_rail_v = BoxMesh.new()
	m_rail_v.size = Vector3(0.1, 0.08, 24.5)

	# Riel Norte (fondo Z = -13.15)
	var rail_norte = MeshInstance3D.new()
	rail_norte.mesh = m_rail_h
	rail_norte.material_override = mat_borde
	rail_norte.position = Vector3(-1.0, 0.03, -13.15)
	contenedor_tablero.add_child(rail_norte)

	# Riel Sur (frente Z = +11.15)
	var rail_sur = MeshInstance3D.new()
	rail_sur.mesh = m_rail_h
	rail_sur.material_override = mat_borde
	rail_sur.position = Vector3(-1.0, 0.03, 11.15)
	contenedor_tablero.add_child(rail_sur)

	# Riel Oeste (izquierda X = -13.15)
	var rail_oeste = MeshInstance3D.new()
	rail_oeste.mesh = m_rail_v
	rail_oeste.material_override = mat_borde
	rail_oeste.position = Vector3(-13.15, 0.03, -1.0)
	contenedor_tablero.add_child(rail_oeste)

	# Riel Este (derecha X = +11.15)
	var rail_este = MeshInstance3D.new()
	rail_este.mesh = m_rail_v
	rail_este.material_override = mat_borde
	rail_este.position = Vector3(11.15, 0.03, -1.0)
	contenedor_tablero.add_child(rail_este)

func _construir_decoracion_nave() -> void:
	if is_instance_valid(contenedor_decoracion):
		contenedor_decoracion.queue_free()

	contenedor_decoracion = Node3D.new()
	contenedor_decoracion.name = "ContenedorDecoracion"
	add_child(contenedor_decoracion)

	# 1. Servidor Principal / Mainframe Central al fondo (Vector3(-1.0, 0, -13.5))
	var nodo_mainframe = Node3D.new()
	nodo_mainframe.position = Vector3(-1.0, 0, -13.5)
	contenedor_decoracion.add_child(nodo_mainframe)

	var mat_gabinete = StandardMaterial3D.new()
	mat_gabinete.albedo_color = Color(0.91, 0.93, 0.96) # Blanco limpio de nave
	mat_gabinete.metallic = 0.25
	mat_gabinete.roughness = 0.25

	var gabinete = MeshInstance3D.new()
	var m_cab = BoxMesh.new()
	m_cab.size = Vector3(3.2, 3.6, 1.2)
	gabinete.mesh = m_cab
	gabinete.material_override = mat_gabinete
	gabinete.position = Vector3(0, 1.8, 0)
	nodo_mainframe.add_child(gabinete)

	# Pantalla principal con brillo verde sci-fi
	var mat_pantalla = StandardMaterial3D.new()
	mat_pantalla.albedo_color = Color(0.1, 0.35, 0.25)
	mat_pantalla.emission_enabled = true
	mat_pantalla.emission = Color(0.3, 0.95, 0.65)
	mat_pantalla.emission_energy_multiplier = 1.6

	var pantalla = MeshInstance3D.new()
	var m_screen = BoxMesh.new()
	m_screen.size = Vector3(2.4, 1.5, 0.06)
	pantalla.mesh = m_screen
	pantalla.material_override = mat_pantalla
	pantalla.position = Vector3(0, 2.0, 0.62)
	nodo_mainframe.add_child(pantalla)

	# Puertas laterales del servidor en verde menta como la referencia oficial
	var mat_puerta = StandardMaterial3D.new()
	mat_puerta.albedo_color = Color(0.42, 0.76, 0.58)
	mat_puerta.metallic = 0.2
	mat_puerta.roughness = 0.35

	for lado in [-1.0, 1.0]:
		var rack = MeshInstance3D.new()
		var m_rack = BoxMesh.new()
		m_rack.size = Vector3(0.65, 3.0, 0.7)
		rack.mesh = m_rack
		rack.material_override = mat_puerta
		rack.position = Vector3(lado * 2.1, 1.5, 0.2)
		nodo_mainframe.add_child(rack)

		var leds = MeshInstance3D.new()
		var m_leds = BoxMesh.new()
		m_leds.size = Vector3(0.15, 2.6, 0.04)
		leds.mesh = m_leds
		var mat_led = StandardMaterial3D.new()
		mat_led.albedo_color = Color(0.2, 0.8, 0.4)
		mat_led.emission_enabled = true
		mat_led.emission = Color(0.25, 0.9, 0.45)
		mat_led.emission_energy_multiplier = 2.0
		leds.material_override = mat_led
		leds.position = Vector3(lado * 2.1, 1.5, 0.58)
		nodo_mainframe.add_child(leds)

	# Antenas en la parte superior del mainframe
	for ax in [-0.7, 0.0, 0.7]:
		var antena = MeshInstance3D.new()
		var m_ant = CylinderMesh.new()
		m_ant.top_radius = 0.02
		m_ant.bottom_radius = 0.04
		m_ant.height = 0.8
		antena.mesh = m_ant
		antena.material_override = mat_gabinete
		antena.position = Vector3(ax, 3.8, 0)
		nodo_mainframe.add_child(antena)

	# 2. Cajas de Carga Sci-Fi (Naranjas con franjas LED verdes) en los laterales
	var mat_caja = StandardMaterial3D.new()
	mat_caja.albedo_color = Color(0.82, 0.42, 0.14)
	mat_caja.metallic = 0.6
	mat_caja.roughness = 0.4

	var mat_franja = StandardMaterial3D.new()
	mat_franja.albedo_color = Color(0.1, 0.6, 0.3)
	mat_franja.emission_enabled = true
	mat_franja.emission = Color(0.2, 0.9, 0.5)
	mat_franja.emission_energy_multiplier = 1.4

	var cajas_datos = [
		{"pos": Vector3(-12.0, 0.5, -4.0), "tam": Vector3(1.0, 1.0, 1.0)},
		{"pos": Vector3(-11.0, 0.4, -4.7), "tam": Vector3(0.8, 0.8, 0.8)},
		{"pos": Vector3(-11.8, 1.35, -4.1), "tam": Vector3(0.7, 0.7, 0.7)},
		{"pos": Vector3(10.0, 0.5, -4.0), "tam": Vector3(1.0, 1.0, 1.0)},
		{"pos": Vector3(9.2, 0.45, -4.7), "tam": Vector3(0.9, 0.9, 0.9)}
	]

	for c in cajas_datos:
		var nodo_caja = MeshInstance3D.new()
		var m_box = BoxMesh.new()
		m_box.size = c.tam
		nodo_caja.mesh = m_box
		nodo_caja.material_override = mat_caja
		nodo_caja.position = c.pos
		contenedor_decoracion.add_child(nodo_caja)

		var franja = MeshInstance3D.new()
		var m_fr = BoxMesh.new()
		m_fr.size = Vector3(c.tam.x + 0.02, 0.12, c.tam.z + 0.02)
		franja.mesh = m_fr
		franja.material_override = mat_franja
		franja.position = c.pos
		contenedor_decoracion.add_child(franja)

	# 3. Cristales de Energía en las esquinas traseras del tablero
	_crear_cluster_cristal(Vector3(-12.8, 0, -12.8), Color(0.95, 0.25, 0.75)) # Magenta
	_crear_cluster_cristal(Vector3(10.8, 0, -12.8), Color(0.2, 0.85, 0.95))   # Cyan

func _crear_cluster_cristal(pos_base: Vector3, col_energia: Color) -> void:
	var base_pedestal = MeshInstance3D.new()
	var m_ped = CylinderMesh.new()
	m_ped.top_radius = 0.6
	m_ped.bottom_radius = 0.75
	m_ped.height = 0.4
	base_pedestal.mesh = m_ped
	var mat_ped = StandardMaterial3D.new()
	mat_ped.albedo_color = Color(0.72, 0.76, 0.82)
	mat_ped.metallic = 0.3
	mat_ped.roughness = 0.5
	base_pedestal.material_override = mat_ped
	base_pedestal.position = pos_base + Vector3(0, 0.2, 0)
	contenedor_decoracion.add_child(base_pedestal)

	var mat_cristal = StandardMaterial3D.new()
	mat_cristal.albedo_color = col_energia
	mat_cristal.emission_enabled = true
	mat_cristal.emission = col_energia
	mat_cristal.emission_energy_multiplier = 2.4
	mat_cristal.roughness = 0.1

	var m_cris = PrismMesh.new()
	m_cris.size = Vector3(0.5, 1.6, 0.5)

	var c1 = MeshInstance3D.new()
	c1.mesh = m_cris
	c1.material_override = mat_cristal
	c1.position = pos_base + Vector3(0, 1.1, 0)
	contenedor_decoracion.add_child(c1)

	var c2 = MeshInstance3D.new()
	c2.mesh = m_cris
	c2.material_override = mat_cristal
	c2.position = pos_base + Vector3(-0.25, 0.85, 0.2)
	c2.rotation = Vector3(0.15, 0.4, -0.2)
	c2.scale = Vector3(0.7, 0.7, 0.7)
	contenedor_decoracion.add_child(c2)

	var c3 = MeshInstance3D.new()
	c3.mesh = m_cris
	c3.material_override = mat_cristal
	c3.position = pos_base + Vector3(0.25, 0.95, -0.2)
	c3.rotation = Vector3(-0.2, -0.3, 0.15)
	c3.scale = Vector3(0.8, 0.8, 0.8)
	contenedor_decoracion.add_child(c3)

	var luz = OmniLight3D.new()
	luz.light_color = col_energia
	luz.light_energy = 0.8
	luz.omni_range = 4.5
	luz.position = pos_base + Vector3(0, 1.2, 0)
	contenedor_decoracion.add_child(luz)

func _crear_cursor_seleccion() -> void:
	if is_instance_valid(cursor_seleccion):
		cursor_seleccion.queue_free()

	cursor_seleccion = Node3D.new()
	cursor_seleccion.name = "CursorSeleccion"
	add_child(cursor_seleccion)

	# Casilla activa verde brillante centrada en la placa
	var suelo_cursor = MeshInstance3D.new()
	var m_cursor = BoxMesh.new()
	m_cursor.size = Vector3(1.92, 0.02, 1.92)
	suelo_cursor.mesh = m_cursor

	var mat_cursor = StandardMaterial3D.new()
	mat_cursor.albedo_color = Color(0.2, 0.85, 0.5, 0.45)
	mat_cursor.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat_cursor.emission_enabled = true
	mat_cursor.emission = Color(0.3, 0.95, 0.55)
	mat_cursor.emission_energy_multiplier = 1.3
	suelo_cursor.material_override = mat_cursor
	suelo_cursor.position = Vector3(0, 0.04, 0)
	cursor_seleccion.add_child(suelo_cursor)

	# Flecha apuntando hacia adelante en el centro de la casilla
	var flecha = MeshInstance3D.new()
	var m_fl = PrismMesh.new()
	m_fl.size = Vector3(0.5, 0.5, 0.04)
	flecha.mesh = m_fl
	flecha.material_override = mat_cursor
	flecha.rotation.x = -PI * 0.5
	flecha.position = Vector3(0, 0.05, -0.45)
	cursor_seleccion.add_child(flecha)

func _actualizar_cursor_seguimiento(delta: float) -> void:
	if not is_instance_valid(cursor_seleccion):
		return

	var astro = _obtener_astronauta_por_indice(idx_astronauta_activo)
	if is_instance_valid(astro) and astro.visible:
		cursor_seleccion.visible = true
		var target_pos = astro.position
		target_pos.y = 0.01
		cursor_seleccion.position = cursor_seleccion.position.lerp(target_pos, clamp(16.0 * delta, 0.0, 1.0))
		cursor_seleccion.rotation.y = lerp_angle(cursor_seleccion.rotation.y, astro.rotation.y, clamp(16.0 * delta, 0.0, 1.0))
	else:
		cursor_seleccion.visible = false

func _obtener_astronauta_por_indice(idx: int) -> AstronautaIngeniero:
	var lista = [astronauta, astronauta_2, astronauta_3, astronauta_4, astronauta_5, astronauta_6, astronauta_7, astronauta_8, astronauta_9, astronauta_10]
	if idx >= 0 and idx < lista.size():
		return lista[idx]
	return astronauta

func resaltar_astronauta_seleccionado(idx: int) -> void:
	idx_astronauta_activo = idx
	var lista = [astronauta, astronauta_2, astronauta_3, astronauta_4, astronauta_5, astronauta_6, astronauta_7, astronauta_8, astronauta_9, astronauta_10]
	for i in range(lista.size()):
		if is_instance_valid(lista[i]):
			lista[i].resaltar_seleccion(i == idx)

func cargar_nivel(config: Dictionary, preservar_estado: bool = false) -> void:
	config_nivel_actual = config

	# 1. Configurar astronauta principal (Ingeniero)
	var pos_astro = config.get("pos_astronauta", Vector2i(0, 2))
	var ori_astro = config.get("ori_astronauta", 0)
	if astronauta:
		if preservar_estado:
			astronauta.fijar_checkpoint_actual()
		else:
			astronauta.configurar_inicio(pos_astro, ori_astro)

	# 2. Configurar astronautas secundarios
	if astronauta_2:
		var mostrar_astronauta_2 = config.get("cantidad_astronautas", 1) >= 2
		var ya_estaba_activo = astronauta_2.visible
		astronauta_2.visible = mostrar_astronauta_2
		if mostrar_astronauta_2:
			if preservar_estado and ya_estaba_activo:
				astronauta_2.fijar_checkpoint_actual()
			else:
				astronauta_2.configurar_inicio(config.get("pos_astronauta_2", Vector2i(1, 0)), config.get("ori_astronauta_2", 0))

	if astronauta_3:
		var mostrar_astronauta_3 = config.get("cantidad_astronautas", 1) >= 3
		var ya_estaba_activo_3 = astronauta_3.visible
		astronauta_3.visible = mostrar_astronauta_3
		if mostrar_astronauta_3:
			if preservar_estado and ya_estaba_activo_3:
				astronauta_3.fijar_checkpoint_actual()
			else:
				astronauta_3.configurar_inicio(config.get("pos_astronauta_3", Vector2i(-1, 0)), config.get("ori_astronauta_3", 0))

	for par in [[astronauta_4, 4], [astronauta_5, 5]]:
		var extra: AstronautaIngeniero = par[0]
		var numero: int = par[1]
		if extra:
			var debe_mostrar = config.get("cantidad_astronautas", 1) >= numero
			var ya_activo = extra.visible
			extra.visible = debe_mostrar
			if debe_mostrar:
				if preservar_estado and ya_activo:
					extra.fijar_checkpoint_actual()
				else:
					extra.configurar_inicio(config.get("pos_astronauta_%d" % numero, Vector2i.ZERO), config.get("ori_astronauta_%d" % numero, 0))

	for par in [[astronauta_6, 6], [astronauta_7, 7]]:
		var extra: AstronautaIngeniero = par[0]
		var numero: int = par[1]
		if extra:
			var debe_mostrar = config.get("cantidad_astronautas", 1) >= numero
			var ya_activo = extra.visible
			extra.visible = debe_mostrar
			if debe_mostrar:
				if preservar_estado and ya_activo:
					extra.fijar_checkpoint_actual()
				else:
					extra.configurar_inicio(config.get("pos_astronauta_%d" % numero, Vector2i.ZERO), config.get("ori_astronauta_%d" % numero, 0))

	for par in [[astronauta_8, 8], [astronauta_9, 9], [astronauta_10, 10]]:
		var extra: AstronautaIngeniero = par[0]
		var numero: int = par[1]
		if extra:
			var debe_mostrar = config.get("cantidad_astronautas", 1) >= numero
			var ya_activo = extra.visible
			extra.visible = debe_mostrar
			if debe_mostrar:
				if preservar_estado and ya_activo:
					extra.fijar_checkpoint_actual()
				else:
					extra.configurar_inicio(config.get("pos_astronauta_%d" % numero, Vector2i.ZERO), config.get("ori_astronauta_%d" % numero, 0))

	# 3. Configurar mesa de ensamblaje
	var mostrar_mesa = config.get("mostrar_mesa", false)
	if mesa_spid:
		mesa_spid.visible = mostrar_mesa
		if mostrar_mesa:
			var pos_mesa = config.get("pos_mesa", Vector2i(0, -2))
			mesa_spid.celda_mesa = pos_mesa
			mesa_spid.position = Vector3(pos_mesa.x * 2.0, 0, pos_mesa.y * 2.0)
			if not preservar_estado:
				mesa_spid.reiniciar()

	# 4. Configurar baliza meta
	var tipo_meta = config.get("tipo_meta", "BALIZA")
	if baliza_meta:
		if tipo_meta == "BALIZA":
			baliza_meta.visible = true
			var pos_b = config.get("pos_baliza", Vector2i(0, -1))
			baliza_meta.posicionar_en_celda(pos_b)
		else:
			baliza_meta.visible = false

	# 5. Spawner de piezas
	_recrear_piezas(config.get("piezas", []))

func _recrear_piezas(lista_piezas: Array, filtrar_ya_ensambladas: bool = true) -> void:
	for child in contenedor_piezas.get_children():
		child.queue_free()
	piezas_por_celda.clear()

	for p_data in lista_piezas:
		var tipo = p_data.get("tipo", "CHASIS")
		if filtrar_ya_ensambladas and mesa_spid and tipo in mesa_spid.etapas_completadas:
			continue

		var p_nodo: PiezaTaller
		if escena_pieza:
			p_nodo = escena_pieza.instantiate() as PiezaTaller
		else:
			p_nodo = PiezaTaller.new()

		p_nodo.tipo_pieza = tipo
		p_nodo.celda_inicial = p_data.get("celda", Vector2i(0, 0))
		contenedor_piezas.add_child(p_nodo)

	await get_tree().process_frame
	registrar_piezas()

func registrar_piezas() -> void:
	piezas_por_celda.clear()
	for child in contenedor_piezas.get_children():
		if child is PiezaTaller and child.visible and not child.is_queued_for_deletion():
			var celda_calc = Vector2i(
				int(round(child.position.x / 2.0)),
				int(round(child.position.z / 2.0))
			)
			piezas_por_celda[child.celda_inicial] = child
			piezas_por_celda[celda_calc] = child

func es_celda_solida(celda: Vector2i) -> bool:
	if mesa_spid and mesa_spid.visible and mesa_spid.celda_mesa == celda:
		return true
	if mesones_por_celda.has(celda):
		var m = mesones_por_celda[celda]
		if is_instance_valid(m) and m.visible:
			return true
	return false

func obtener_meson_en(celda: Vector2i) -> Node3D:
	if mesones_por_celda.has(celda):
		var m = mesones_por_celda[celda]
		if is_instance_valid(m) and m.visible:
			return m
	return null

func obtener_pieza_en(celda: Vector2i) -> PiezaTaller:
	if piezas_por_celda.has(celda):
		var p = piezas_por_celda[celda]
		if is_instance_valid(p) and p.visible and not p.is_queued_for_deletion():
			return p
	for child in contenedor_piezas.get_children():
		if child is PiezaTaller and child.visible and not child.is_queued_for_deletion():
			var celda_calc = Vector2i(
				int(round(child.position.x / 2.0)),
				int(round(child.position.z / 2.0))
			)
			if celda_calc == celda:
				return child
	return null

func remover_pieza_en(celda: Vector2i) -> void:
	var p = obtener_pieza_en(celda)
	if p:
		piezas_por_celda.erase(celda)
		p.visible = false
		p.queue_free()

	# Reabastecimiento automático en bucle continuo
	_reabastecer_bahia(celda)

func _reabastecer_bahia(celda_antigua: Vector2i) -> void:
	for p_data in config_nivel_actual.get("piezas", []):
		if p_data.get("celda") == celda_antigua:
			var tipo = p_data.get("tipo", "TORNILLO")
			await get_tree().create_timer(1.2).timeout
			if not is_instance_valid(self): return
			var p_nueva: PiezaTaller
			if escena_pieza:
				p_nueva = escena_pieza.instantiate() as PiezaTaller
			else:
				p_nueva = PiezaTaller.new()
			p_nueva.tipo_pieza = tipo
			p_nueva.celda_inicial = celda_antigua
			contenedor_piezas.add_child(p_nueva)
			await get_tree().process_frame
			registrar_piezas()
			break

func colocar_pieza_en(celda: Vector2i, tipo: String) -> PiezaTaller:
	var p_nodo: PiezaTaller
	if escena_pieza:
		p_nodo = escena_pieza.instantiate() as PiezaTaller
	else:
		p_nodo = PiezaTaller.new()

	p_nodo.tipo_pieza = tipo
	p_nodo.celda_inicial = celda
	contenedor_piezas.add_child(p_nodo)
	piezas_por_celda[celda] = p_nodo
	return p_nodo

func obtener_mesa_en(celda: Vector2i) -> MesaEnsamblaje:
	if mesa_spid and mesa_spid.visible and mesa_spid.celda_mesa == celda:
		return mesa_spid
	return null

func verificar_objetivo_completado() -> bool:
	var tipo_meta = config_nivel_actual.get("tipo_meta", "BALIZA")
	match tipo_meta:
		"BALIZA":
			var celda_actual = Vector2i(astronauta.grid_x, astronauta.grid_z)
			var celda_meta = config_nivel_actual.get("pos_baliza", Vector2i(0, -1))
			if celda_actual == celda_meta:
				if baliza_meta: baliza_meta.activar_exito()
				return true
			return false
		"ENSAMBLAJE":
			return mesa_spid and mesa_spid.etapas_completadas.size() > 0
		"ENSAMBLAJE_EQUIPO":
			return mesa_spid and mesa_spid.etapas_completadas.size() >= config_nivel_actual.get("componentes_objetivo", 2)
	return false

func reiniciar_mundo(preservar_spido: bool = true) -> void:
	if astronauta:
		await astronauta.reiniciar()
	if astronauta_2 and astronauta_2.visible:
		await astronauta_2.reiniciar()
	if astronauta_3 and astronauta_3.visible:
		await astronauta_3.reiniciar()
	if astronauta_4 and astronauta_4.visible:
		await astronauta_4.reiniciar()
	if astronauta_5 and astronauta_5.visible:
		await astronauta_5.reiniciar()
	if astronauta_6 and astronauta_6.visible:
		await astronauta_6.reiniciar()
	if astronauta_7 and astronauta_7.visible:
		await astronauta_7.reiniciar()
	if astronauta_8 and astronauta_8.visible:
		await astronauta_8.reiniciar()
	if astronauta_9 and astronauta_9.visible:
		await astronauta_9.reiniciar()
	if astronauta_10 and astronauta_10.visible:
		await astronauta_10.reiniciar()

	if not preservar_spido and mesa_spid and mesa_spid.visible:
		mesa_spid.reiniciar()

	_recrear_piezas(config_nivel_actual.get("piezas", []), preservar_spido)
