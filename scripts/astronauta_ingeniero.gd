class_name AstronautaIngeniero
extends Node3D

signal animacion_terminada
signal pieza_recogida(tipo_pieza: String)
signal pieza_ensamblada(tipo_pieza: String)
signal accion_fallida(motivo: String)

@export var tamano_celda: float = 2.0
@export var tiempo_movimiento: float = 0.4
@export var tiempo_giro: float = 0.35

var grid_x: int = 0
var grid_z: int = 0
var orientacion_actual: int = 0 # 0: Norte (-Z), 1: Este (+X), 2: Sur (+Z), 3: Oeste (-X)

var posicion_inicial: Vector3
var rotacion_inicial: Vector3
var grid_x_inicial: int = 0
var grid_z_inicial: int = 0

var pieza_en_mano: Node3D = null

@onready var slot_manos: Marker3D = $SlotManos
var casco_visor: MeshInstance3D = null

func _ready() -> void:
	casco_visor = find_child("Visor", true, false) as MeshInstance3D
	posicion_inicial = global_position
	rotacion_inicial = rotation
	grid_x_inicial = int(round(position.x / tamano_celda))
	grid_z_inicial = int(round(position.z / tamano_celda))
	grid_x = grid_x_inicial
	grid_z = grid_z_inicial

func configurar_inicio(pos_grid: Vector2i, ori: int) -> void:
	grid_x_inicial = pos_grid.x
	grid_z_inicial = pos_grid.y
	grid_x = grid_x_inicial
	grid_z = grid_z_inicial
	orientacion_actual = ori
	posicion_inicial = Vector3(grid_x * tamano_celda, position.y, grid_z * tamano_celda)
	rotacion_inicial = Vector3(0, -deg_to_rad(ori * 90.0), 0)
	position = posicion_inicial
	rotation = rotacion_inicial

func reiniciar() -> void:
	if is_instance_valid(pieza_en_mano):
		pieza_en_mano.reparent(get_parent())
		if pieza_en_mano.has_method("reiniciar"):
			pieza_en_mano.reiniciar()
		pieza_en_mano = null

	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "position", posicion_inicial, 0.25)
	tween.tween_property(self, "rotation", rotacion_inicial, 0.25)
	await tween.finished

	grid_x = grid_x_inicial
	grid_z = grid_z_inicial
	orientacion_actual = 0
	_set_color_visor(Color(0.13, 0.77, 0.45))

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
		"TOMAR_PIEZA":
			return await tomar_pieza_cercana()
		"ENSAMBLAR":
			return await ensamblar_en_mesa()
		"DIAGNOSTICO":
			return await ejecutar_diagnostico()
		_:
			push_warning("Comando no reconocido: %s" % accion)
			return false

func avanzar() -> bool:
	var delta = _obtener_vector_orientacion(orientacion_actual)
	var nueva_x = grid_x + delta.x
	var nueva_z = grid_z + delta.y

	if abs(nueva_x) > 4 or abs(nueva_z) > 4:
		await _animar_choque()
		accion_fallida.emit("El astronauta alcanzo el limite de la zona.")
		return false

	var mundo = get_parent()
	if mundo and mundo.has_method("es_celda_solida") and mundo.es_celda_solida(Vector2i(nueva_x, nueva_z)):
		await _animar_choque()
		accion_fallida.emit("Hay una estacion de trabajo enfrente. No puedes caminar sobre ella.")
		return false

	grid_x = nueva_x
	grid_z = nueva_z
	var destino = Vector3(grid_x * tamano_celda, position.y, grid_z * tamano_celda)

	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "position:x", destino.x, tiempo_movimiento).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:z", destino.z, tiempo_movimiento).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	var tween_bob = create_tween()
	tween_bob.tween_property(self, "position:y", position.y + 0.18, tiempo_movimiento * 0.5).set_trans(Tween.TRANS_SINE)
	tween_bob.tween_property(self, "position:y", position.y, tiempo_movimiento * 0.5).set_trans(Tween.TRANS_SINE)

	var tween_roll = create_tween()
	tween_roll.tween_property(self, "rotation:z", deg_to_rad(4.0), tiempo_movimiento * 0.5)
	tween_roll.tween_property(self, "rotation:z", 0.0, tiempo_movimiento * 0.5)

	await tween.finished
	animacion_terminada.emit()
	return true

func retroceder() -> bool:
	var delta = _obtener_vector_orientacion(orientacion_actual)
	var nueva_x = grid_x - delta.x
	var nueva_z = grid_z - delta.y

	if abs(nueva_x) > 4 or abs(nueva_z) > 4:
		await _animar_choque()
		accion_fallida.emit("Limite del taller alcanzado.")
		return false

	var mundo = get_parent()
	if mundo and mundo.has_method("es_celda_solida") and mundo.es_celda_solida(Vector2i(nueva_x, nueva_z)):
		await _animar_choque()
		accion_fallida.emit("Obstaculo a espaldas del astronauta.")
		return false

	grid_x = nueva_x
	grid_z = nueva_z
	var destino = Vector3(grid_x * tamano_celda, position.y, grid_z * tamano_celda)

	var tween = create_tween()
	tween.tween_property(self, "position", destino, tiempo_movimiento).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
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

func tomar_pieza_cercana() -> bool:
	if is_instance_valid(pieza_en_mano):
		accion_fallida.emit("El astronauta ya lleva una pieza en sus manos.")
		await _animar_duda()
		return false

	var dir = _obtener_vector_orientacion(orientacion_actual)
	var celda_objetivo = Vector2i(grid_x + dir.x, grid_z + dir.y)

	var mundo = get_parent()
	var pieza = null
	if mundo and mundo.has_method("obtener_pieza_en"):
		pieza = mundo.obtener_pieza_en(celda_objetivo)

	if pieza:
		pieza_en_mano = pieza
		var tween = create_tween()
		tween.tween_property(pieza, "global_position", slot_manos.global_position, 0.25).set_trans(Tween.TRANS_CUBIC)
		await tween.finished
		pieza.reparent(slot_manos)
		pieza.position = Vector3.ZERO
		pieza.rotation = Vector3.ZERO
		_set_color_visor(Color(0.2, 1.0, 0.5))
		pieza_recogida.emit(pieza.name)
		animacion_terminada.emit()
		return true
	else:
		accion_fallida.emit("No hay ninguna pieza frente al astronauta.")
		await _animar_duda()
		return false

func ensamblar_en_mesa() -> bool:
	if not is_instance_valid(pieza_en_mano):
		accion_fallida.emit("No tienes ninguna pieza en las manos para ensamblar.")
		await _animar_duda()
		return false

	var dir = _obtener_vector_orientacion(orientacion_actual)
	var celda_objetivo = Vector2i(grid_x + dir.x, grid_z + dir.y)

	var mundo = get_parent()
	var mesa = null
	if mundo and mundo.has_method("obtener_mesa_en"):
		mesa = mundo.obtener_mesa_en(celda_objetivo)

	if mesa:
		var tipo_pieza = pieza_en_mano.get("tipo_pieza") if "tipo_pieza" in pieza_en_mano else "COMPONENTE"
		var exito = await mesa.ensamblar_componente(tipo_pieza)
		if exito:
			pieza_en_mano.queue_free()
			pieza_en_mano = null
			_set_color_visor(Color(0.3, 1.0, 0.6))
			var tween = create_tween()
			tween.tween_property(self, "position:y", position.y + 0.1, 0.1)
			tween.tween_property(self, "position:y", position.y, 0.1)
			await tween.finished
			pieza_ensamblada.emit(tipo_pieza)
			animacion_terminada.emit()
			return true
		else:
			accion_fallida.emit("La mesa requiere otra pieza en esta etapa.")
			await _animar_duda()
			return false
	else:
		accion_fallida.emit("No estas frente a la mesa de ensamblaje de Spid.")
		await _animar_duda()
		return false

func ejecutar_diagnostico() -> bool:
	var dir = _obtener_vector_orientacion(orientacion_actual)
	var celda_objetivo = Vector2i(grid_x + dir.x, grid_z + dir.y)
	var mundo = get_parent()
	var mesa = null
	if mundo and mundo.has_method("obtener_mesa_en"):
		mesa = mundo.obtener_mesa_en(celda_objetivo)

	if mesa:
		return await mesa.probar_sistemas()
	else:
		accion_fallida.emit("Apunta hacia la mesa de Spid para diagnosticar.")
		await _animar_duda()
		return false

func _obtener_vector_orientacion(ori: int) -> Vector2i:
	match ori:
		0: return Vector2i(0, -1) # Norte (-Z)
		1: return Vector2i(1, 0)  # Este (+X)
		2: return Vector2i(0, 1)  # Sur (+Z)
		3: return Vector2i(-1, 0) # Oeste (-X)
		_: return Vector2i.ZERO

func _animar_choque() -> void:
	_set_color_visor(Color(0.8, 0.3, 0.2))
	var tween = create_tween()
	var pos_curr = position
	var avance_leve = _obtener_vector_orientacion(orientacion_actual)
	var pos_tope = pos_curr + Vector3(avance_leve.x * 0.2, 0, avance_leve.y * 0.2)
	tween.tween_property(self, "position", pos_tope, 0.08)
	tween.tween_property(self, "position", pos_curr, 0.12)
	await tween.finished
	_set_color_visor(Color(0.13, 0.77, 0.45))
	animacion_terminada.emit()

func _animar_duda() -> void:
	var tween = create_tween()
	tween.tween_property(self, "rotation:y", rotation.y + deg_to_rad(15), 0.1)
	tween.tween_property(self, "rotation:y", rotation.y - deg_to_rad(15), 0.15)
	tween.tween_property(self, "rotation:y", rotation.y, 0.1)
	await tween.finished
	animacion_terminada.emit()

func _set_color_visor(c: Color) -> void:
	if not casco_visor:
		casco_visor = find_child("Visor", true, false) as MeshInstance3D
	if not casco_visor:
		return
	var mat = casco_visor.get_surface_override_material(0)
	if not (mat is StandardMaterial3D):
		mat = StandardMaterial3D.new()
		mat.roughness = 0.1
		mat.emission_enabled = true
		casco_visor.set_surface_override_material(0, mat)
	mat.albedo_color = c
	mat.emission = c
