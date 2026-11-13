class_name AstronautaIngeniero
extends Node3D

signal animacion_terminada
signal pieza_recogida(tipo_pieza: String)
signal pieza_ensamblada(tipo_pieza: String)
signal accion_fallida(motivo: String)

@export var tamano_celda: float = 2.0
@export var tiempo_movimiento: float = 0.4
@export var tiempo_giro: float = 0.35
@export var color_identidad: Color = Color(0.13, 0.77, 0.45)
@export var nombre_rol: String = "Ingeniero"

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
var luz_seleccion: OmniLight3D = null

func _ready() -> void:
	casco_visor = find_child("Visor", true, false) as MeshInstance3D
	_crear_luz_seleccion_si_falta()
	posicion_inicial = global_position
	rotacion_inicial = rotation
	grid_x_inicial = int(round(position.x / tamano_celda))
	grid_z_inicial = int(round(position.z / tamano_celda))
	grid_x = grid_x_inicial
	grid_z = grid_z_inicial
	_set_color_visor(color_identidad)

func _crear_luz_seleccion_si_falta() -> void:
	if not luz_seleccion:
		luz_seleccion = OmniLight3D.new()
		luz_seleccion.name = "LuzSeleccion"
		luz_seleccion.light_energy = 0.0
		luz_seleccion.omni_range = 2.2
		luz_seleccion.light_color = color_identidad
		luz_seleccion.position = Vector3(0, 1.8, 0)
		add_child(luz_seleccion)

func establecer_identidad(p_rol: String, p_color: Color) -> void:
	nombre_rol = p_rol
	color_identidad = p_color
	if luz_seleccion:
		luz_seleccion.light_color = p_color
	_set_color_visor(p_color)

func resaltar_seleccion(activo: bool) -> void:
	if not is_inside_tree() or not visible:
		return
	if luz_seleccion:
		var tw_luz = create_tween()
		tw_luz.tween_property(luz_seleccion, "light_energy", 1.8 if activo else 0.0, 0.2)

	if activo:
		_set_color_visor(color_identidad)
		var tween = create_tween()
		tween.tween_property(self, "position:y", position.y + 0.15, 0.12).set_trans(Tween.TRANS_SINE)
		tween.tween_property(self, "position:y", position.y, 0.12).set_trans(Tween.TRANS_BOUNCE)

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

func fijar_checkpoint_actual() -> void:
	grid_x_inicial = grid_x
	grid_z_inicial = grid_z
	orientacion_actual = int(round(-rad_to_deg(rotation.y) / 90.0)) % 4
	if orientacion_actual < 0: orientacion_actual += 4
	posicion_inicial = position
	rotacion_inicial = rotation

func reiniciar() -> void:
	if is_instance_valid(pieza_en_mano):
		pieza_en_mano.queue_free()
		pieza_en_mano = null

	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "position", posicion_inicial, 0.25)
	tween.tween_property(self, "rotation", rotacion_inicial, 0.25)
	await tween.finished

	grid_x = grid_x_inicial
	grid_z = grid_z_inicial
	orientacion_actual = int(round(-rad_to_deg(rotacion_inicial.y) / 90.0)) % 4
	if orientacion_actual < 0: orientacion_actual += 4
	_set_color_visor(color_identidad)

func ejecutar_accion(accion: String, parametro: int = 1) -> bool:
	match accion:
		"AVANZAR":
			var cantidad = max(1, parametro)
			var tiempo_paso = 0.28 if cantidad > 1 else -1.0
			for k in range(cantidad):
				var r = await avanzar(tiempo_paso)
				if not r: return false
			return true
		"AVANZAR_2":
			for k in range(2):
				var r = await avanzar(0.25)
				if not r: return false
			return true
		"AVANZAR_3":
			for k in range(3):
				var r = await avanzar(0.22)
				if not r: return false
			return true
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

func avanzar(tiempo_custom: float = -1.0) -> bool:
	var t_mov = tiempo_custom if tiempo_custom > 0 else tiempo_movimiento
	var delta = _obtener_vector_orientacion(orientacion_actual)
	var nueva_x = grid_x + delta.x
	var nueva_z = grid_z + delta.y

	var mundo = get_parent()
	if mundo and mundo.has_method("es_celda_valida_para_movimiento"):
		if not mundo.es_celda_valida_para_movimiento(Vector2i(nueva_x, nueva_z)):
			await _animar_choque()
			if mundo.has_method("es_celda_solida") and mundo.es_celda_solida(Vector2i(nueva_x, nueva_z)):
				accion_fallida.emit("Hay un obstáculo o estación enfrente.")
			else:
				accion_fallida.emit("Límite del sector alcanzado. ¡Expande la nave en MEJORAS!")
			return false
	elif nueva_x < -6 or nueva_x > 5 or nueva_z < -6 or nueva_z > 5:
		await _animar_choque()
		accion_fallida.emit("El astronauta alcanzó el límite del tablero de 12x12.")
		return false

	grid_x = nueva_x
	grid_z = nueva_z
	var destino = Vector3(grid_x * tamano_celda, position.y, grid_z * tamano_celda)

	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "position:x", destino.x, t_mov).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:z", destino.z, t_mov).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	var tween_bob = create_tween()
	tween_bob.tween_property(self, "position:y", position.y + 0.18, t_mov * 0.5).set_trans(Tween.TRANS_SINE)
	tween_bob.tween_property(self, "position:y", position.y, t_mov * 0.5).set_trans(Tween.TRANS_SINE)

	var tween_roll = create_tween()
	tween_roll.tween_property(self, "rotation:z", deg_to_rad(4.0), t_mov * 0.5)
	tween_roll.tween_property(self, "rotation:z", 0.0, t_mov * 0.5)

	await tween.finished
	animacion_terminada.emit()
	return true

func retroceder() -> bool:
	var delta = _obtener_vector_orientacion(orientacion_actual)
	var nueva_x = grid_x - delta.x
	var nueva_z = grid_z - delta.y

	var mundo = get_parent()
	if mundo and mundo.has_method("es_celda_valida_para_movimiento"):
		if not mundo.es_celda_valida_para_movimiento(Vector2i(nueva_x, nueva_z)):
			await _animar_choque()
			accion_fallida.emit("Límite del sector alcanzado a espaldas del astronauta.")
			return false
	elif nueva_x < -6 or nueva_x > 5 or nueva_z < -6 or nueva_z > 5:
		await _animar_choque()
		accion_fallida.emit("Límite del tablero alcanzado.")
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

	if not pieza and mundo and mundo.has_method("obtener_producto_de_meson"):
		pieza = mundo.obtener_producto_de_meson(celda_objetivo)

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
	elif mundo and mundo.has_method("obtener_tolva_en") and mundo.obtener_tolva_en(celda_objetivo):
		var tipo_pieza = pieza_en_mano.get("tipo_pieza") if "tipo_pieza" in pieza_en_mano else "TUERCA"
		if tipo_pieza in ["TUERCA", "TORNILLO"]:
			pieza_en_mano.queue_free()
			pieza_en_mano = null
			_set_color_visor(Color(0.95, 0.8, 0.2))
			var tween = create_tween()
			tween.tween_property(self, "position:y", position.y + 0.12, 0.1)
			tween.tween_property(self, "position:y", position.y, 0.12)
			await tween.finished
			mundo.depositar_tuerca_en_tolva()
			pieza_ensamblada.emit(tipo_pieza)
			animacion_terminada.emit()
			return true
		else:
			accion_fallida.emit("El contenedor solo recibe Tuercas.")
			await _animar_duda()
			return false
	else:
		var meson = null
		if mundo and mundo.has_method("obtener_meson_en"):
			meson = mundo.obtener_meson_en(celda_objetivo)

		if meson:
			var tipo_pieza = pieza_en_mano.get("tipo_pieza") if "tipo_pieza" in pieza_en_mano else "COMPONENTE"
			var exito = meson.recibir_insumo(tipo_pieza)
			if exito:
				pieza_en_mano.queue_free()
				pieza_en_mano = null
				_set_color_visor(Color(0.2, 0.85, 1.0))
				var tween = create_tween()
				tween.tween_property(self, "position:y", position.y + 0.1, 0.1)
				tween.tween_property(self, "position:y", position.y, 0.1)
				await tween.finished
				pieza_ensamblada.emit(tipo_pieza)
				animacion_terminada.emit()
				return true
			else:
				accion_fallida.emit("El mesón no requiere este insumo o su bandeja de salida está llena.")
				await _animar_duda()
				return false
		else:
			accion_fallida.emit("No estás frente a ninguna estación de trabajo.")
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
	_set_color_visor(color_identidad)
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
