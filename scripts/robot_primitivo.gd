class_name RobotPrimitivo
extends Node3D

signal animacion_terminada
signal item_recolectado(nombre_item: String)
signal colision_detectada(mensaje: String)

@export var tamano_celda: float = 2.0
@export var tiempo_movimiento: float = 0.4
@export var tiempo_giro: float = 0.35

var grid_x: int = 0
var grid_z: int = 0
var orientacion_actual: int = 0 # 0: Hacia -Z (Norte), 1: Hacia +X (Este), 2: Hacia +Z (Sur), 3: Hacia -X (Oeste)

var posicion_inicial: Vector3
var rotacion_inicial: Vector3
var grid_x_inicial: int = 0
var grid_z_inicial: int = 0

var item_cargado: Node3D = null

@onready var chasis: MeshInstance3D = $Chasis
@onready var rueda_fl: MeshInstance3D = $RuedaFL
@onready var rueda_fr: MeshInstance3D = $RuedaFR
@onready var rueda_bl: MeshInstance3D = $RuedaBL
@onready var rueda_br: MeshInstance3D = $RuedaBR
@onready var slot_carga: Marker3D = $SlotCarga
@onready var sensor_luz: MeshInstance3D = $SensorLuz

func _ready() -> void:
	posicion_inicial = global_position
	rotacion_inicial = rotation
	grid_x_inicial = int(round(position.x / tamano_celda))
	grid_z_inicial = int(round(position.z / tamano_celda))
	grid_x = grid_x_inicial
	grid_z = grid_z_inicial

func reiniciar() -> void:
	if is_instance_valid(item_cargado):
		item_cargado.reparent(get_parent())
		if item_cargado.has_method("reiniciar"):
			item_cargado.reiniciar()
		item_cargado = null

	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "position", posicion_inicial, 0.2)
	tween.tween_property(self, "rotation", rotacion_inicial, 0.2)
	await tween.finished

	grid_x = grid_x_inicial
	grid_z = grid_z_inicial
	orientacion_actual = 0
	_actualizar_luz_sensor(Color(0.2, 0.8, 1.0)) # Cyan neutro

func ejecutar_accion(accion: String) -> bool:
	match accion:
		"AVANZAR":
			return await avanzar()
		"RETROCEDER":
			return await retroceder()
		"GIRAR_DER":
			return await girar(false)
		"GIRAR_IZQ":
			return await girar(true)
		"TOMAR":
			return await interactuar_o_tomar()
		_:
			push_warning("Acción no reconocida: %s" % accion)
			return false

func avanzar() -> bool:
	var delta = _obtener_vector_orientacion(orientacion_actual)
	var nueva_x = grid_x + delta.x
	var nueva_z = grid_z + delta.y

	# Límite básico del circuito (ej: -5 a 5)
	if abs(nueva_x) > 5 or abs(nueva_z) > 5:
		_animar_rebote_bloqueo()
		colision_detectada.emit("¡Límite del área alcanzado!")
		await animacion_terminada
		return false

	grid_x = nueva_x
	grid_z = nueva_z
	var destino = Vector3(grid_x * tamano_celda, position.y, grid_z * tamano_celda)

	var tween = create_tween()
	# Animación de marcha con un ligero bamboleo vertical para darle vida física
	tween.set_parallel(true)
	tween.tween_property(self, "position:x", destino.x, tiempo_movimiento).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:z", destino.z, tiempo_movimiento).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# Rebote vertical sutil
	var tween_bob = create_tween()
	tween_bob.tween_property(self, "position:y", position.y + 0.15, tiempo_movimiento * 0.5).set_trans(Tween.TRANS_SINE)
	tween_bob.tween_property(self, "position:y", position.y, tiempo_movimiento * 0.5).set_trans(Tween.TRANS_SINE)

	# Rodar las ruedas cilíndricas
	_rodar_ruedas(1.0, tiempo_movimiento)

	await tween.finished
	animacion_terminada.emit()
	return true

func retroceder() -> bool:
	var delta = _obtener_vector_orientacion(orientacion_actual)
	var nueva_x = grid_x - delta.x
	var nueva_z = grid_z - delta.y

	if abs(nueva_x) > 5 or abs(nueva_z) > 5:
		_animar_rebote_bloqueo()
		colision_detectada.emit("¡Límite del área alcanzado!")
		await animacion_terminada
		return false

	grid_x = nueva_x
	grid_z = nueva_z
	var destino = Vector3(grid_x * tamano_celda, position.y, grid_z * tamano_celda)

	var tween = create_tween()
	tween.tween_property(self, "position", destino, tiempo_movimiento).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_rodar_ruedas(-1.0, tiempo_movimiento)

	await tween.finished
	animacion_terminada.emit()
	return true

func girar(hacia_izquierda: bool) -> bool:
	if hacia_izquierda:
		orientacion_actual = (orientacion_actual - 1 + 4) % 4
	else:
		orientacion_actual = (orientacion_actual + 1) % 4

	var angulo_meta = -deg_to_rad(orientacion_actual * 90.0)
	var tween = create_tween()
	tween.tween_property(self, "rotation:y", angulo_meta, tiempo_giro).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	await tween.finished
	animacion_terminada.emit()
	return true

func interactuar_o_tomar() -> bool:
	# Busca si hay un objeto recolectable delante
	var dir = _obtener_vector_orientacion(orientacion_actual)
	var celda_objetivo = Vector2i(grid_x + dir.x, grid_z + dir.y)

	var mundo = get_parent()
	var recolectable = null
	if mundo and mundo.has_method("obtener_recolectable_en"):
		recolectable = mundo.obtener_recolectable_en(celda_objetivo)

	if recolectable and not is_instance_valid(item_cargado):
		item_cargado = recolectable
		var tween = create_tween()
		tween.tween_property(recolectable, "global_position", slot_carga.global_position, 0.3).set_trans(Tween.TRANS_BOUNCE)
		await tween.finished
		recolectable.reparent(slot_carga)
		recolectable.position = Vector3.ZERO
		_actualizar_luz_sensor(Color(0.2, 1.0, 0.4)) # Verde éxito
		item_recolectado.emit(recolectable.name)
		animacion_terminada.emit()
		return true
	else:
		# Animación de escaneo fallido con luz roja
		_actualizar_luz_sensor(Color(1.0, 0.3, 0.2))
		var tween = create_tween()
		tween.tween_property(chasis, "scale", Vector3(1.1, 0.9, 1.1), 0.15)
		tween.tween_property(chasis, "scale", Vector3.ONE, 0.15)
		await tween.finished
		_actualizar_luz_sensor(Color(0.2, 0.8, 1.0))
		animacion_terminada.emit()
		return false

func _obtener_vector_orientacion(ori: int) -> Vector2i:
	match ori:
		0: return Vector2i(0, -1) # Norte (-Z)
		1: return Vector2i(1, 0)  # Este (+X)
		2: return Vector2i(0, 1)  # Sur (+Z)
		3: return Vector2i(-1, 0) # Oeste (-X)
		_: return Vector2i.ZERO

func _rodar_ruedas(sentido: float, duracion: float) -> void:
	var delta_rot = deg_to_rad(180.0 * sentido)
	var tween = create_tween().set_parallel(true)
	if rueda_fl: tween.tween_property(rueda_fl, "rotation:x", rueda_fl.rotation.x + delta_rot, duracion)
	if rueda_fr: tween.tween_property(rueda_fr, "rotation:x", rueda_fr.rotation.x + delta_rot, duracion)
	if rueda_bl: tween.tween_property(rueda_bl, "rotation:x", rueda_bl.rotation.x + delta_rot, duracion)
	if rueda_br: tween.tween_property(rueda_br, "rotation:x", rueda_br.rotation.x + delta_rot, duracion)

func _animar_rebote_bloqueo() -> void:
	_actualizar_luz_sensor(Color(1.0, 0.2, 0.2))
	var tween = create_tween()
	var pos_curr = position
	var avance_leve = _obtener_vector_orientacion(orientacion_actual)
	var pos_tope = pos_curr + Vector3(avance_leve.x * 0.3, 0, avance_leve.y * 0.3)
	tween.tween_property(self, "position", pos_tope, 0.1)
	tween.tween_property(self, "position", pos_curr, 0.15)
	await tween.finished
	_actualizar_luz_sensor(Color(0.2, 0.8, 1.0))
	animacion_terminada.emit()

func _actualizar_luz_sensor(color: Color) -> void:
	if not sensor_luz: return
	var mat = sensor_luz.get_surface_override_material(0)
	if mat is StandardMaterial3D:
		mat.albedo_color = color
		mat.emission = color
