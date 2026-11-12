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

var piezas_por_celda: Dictionary = {}
var config_nivel_actual: Dictionary = {}

func _ready() -> void:
	_inicializar_roles_astronautas()

func _inicializar_roles_astronautas() -> void:
	if astronauta: astronauta.establecer_identidad("Ingeniero", Color(0.2, 0.85, 0.45))
	if astronauta_2: astronauta_2.establecer_identidad("Tracción", Color(0.2, 0.75, 0.95))
	if astronauta_3: astronauta_3.establecer_identidad("Sensores", Color(0.95, 0.8, 0.2))
	if astronauta_4: astronauta_4.establecer_identidad("Brazos", Color(0.95, 0.5, 0.15))
	if astronauta_5: astronauta_5.establecer_identidad("Energía", Color(0.85, 0.3, 0.85))

func resaltar_astronauta_seleccionado(idx: int) -> void:
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
		# Si la pieza ya fue ensamblada fisicamente en Spido, no la volvemos a generar en el piso
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

	# Registrar en el siguiente frame para que las posiciones queden calculadas
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
	return false

func obtener_pieza_en(celda: Vector2i) -> Node3D:
	if piezas_por_celda.has(celda):
		var pieza = piezas_por_celda[celda]
		piezas_por_celda.erase(celda)
		return pieza
	return null

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
