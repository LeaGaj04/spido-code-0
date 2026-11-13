class_name MesonSubensamblaje
extends Node3D

signal insumo_recibido(tipo: String, actual: int, requeridos: int)
signal producto_fabricado(tipo_producto: String)
signal producto_retirado(tipo_producto: String)

@export var celda_mesa: Vector2i = Vector2i(-2, 0)
@export var tipo_estacion: String = "PATAS" # PATAS, SENSORES, BRAZOS
@export var producto_salida: String = "RUEDAS"
@export var insumo_requerido: String = "TORNILLO"
@export var cantidad_requerida: int = 1

var insumos_actuales: int = 0
var producto_disponible: bool = false

var base_malla: MeshInstance3D
var luz_indicador: OmniLight3D
var soporte_salida: Node3D
var malla_producto_preview: MeshInstance3D

func _ready() -> void:
	_construir_visuales_si_faltan()
	position = Vector3(celda_mesa.x * 2.0, 0, celda_mesa.y * 2.0)
	_actualizar_estado_visual()

func _construir_visuales_si_faltan() -> void:
	if not base_malla:
		base_malla = MeshInstance3D.new()
		base_malla.name = "BaseMeson"
		var box = BoxMesh.new()
		box.size = Vector3(1.4, 0.75, 1.4)
		base_malla.mesh = box
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(0.2, 0.24, 0.28, 1)
		mat.metallic = 0.8
		mat.roughness = 0.4
		base_malla.material_override = mat
		base_malla.position = Vector3(0, 0.375, 0)
		add_child(base_malla)

	if not luz_indicador:
		luz_indicador = OmniLight3D.new()
		luz_indicador.name = "LuzIndicador"
		luz_indicador.position = Vector3(0, 1.1, 0)
		luz_indicador.omni_range = 3.0
		luz_indicador.light_energy = 1.2
		add_child(luz_indicador)

	if not soporte_salida:
		soporte_salida = Node3D.new()
		soporte_salida.name = "SoporteSalida"
		soporte_salida.position = Vector3(0, 0.85, 0)
		add_child(soporte_salida)

		malla_producto_preview = MeshInstance3D.new()
		var mesh_p = CylinderMesh.new()
		mesh_p.top_radius = 0.25
		mesh_p.bottom_radius = 0.25
		mesh_p.height = 0.2
		malla_producto_preview.mesh = mesh_p
		var mat_p = StandardMaterial3D.new()
		mat_p.albedo_color = Color(0.2, 0.8, 0.9, 1)
		mat_p.emission_enabled = true
		mat_p.emission = Color(0.2, 0.8, 0.9, 1)
		mat_p.emission_energy_multiplier = 1.5
		malla_producto_preview.material_override = mat_p
		soporte_salida.add_child(malla_producto_preview)

func recibir_insumo(tipo_pieza: String) -> bool:
	if producto_disponible:
		# La bandeja de salida está llena, primero deben retirar el producto
		return false

	if tipo_pieza != insumo_requerido and insumo_requerido != "CUALQUIERA":
		return false

	insumos_actuales += 1
	insumo_recibido.emit(tipo_pieza, insumos_actuales, cantidad_requerida)
	_animar_recepcion()

	if insumos_actuales >= cantidad_requerida:
		await _fabricar_producto()

	_actualizar_estado_visual()
	return true

func _animar_recepcion() -> void:
	if luz_indicador:
		var tw = create_tween()
		tw.tween_property(luz_indicador, "light_energy", 3.0, 0.15)
		tw.tween_property(luz_indicador, "light_energy", 1.2, 0.2)

func _fabricar_producto() -> void:
	insumos_actuales = 0
	# Efecto de fabricación con giro y escala
	if soporte_salida:
		soporte_salida.scale = Vector3.ZERO
		soporte_salida.visible = true
		var tw = create_tween().set_parallel(true)
		tw.tween_property(soporte_salida, "scale", Vector3.ONE, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(soporte_salida, "rotation:y", TAU, 0.4).as_relative()
		await tw.finished

	producto_disponible = true
	producto_fabricado.emit(producto_salida)
	_actualizar_estado_visual()

func tiene_producto_listo() -> bool:
	return producto_disponible

func retirar_producto() -> String:
	if not producto_disponible:
		return ""
	producto_disponible = false
	var prod = producto_salida
	if soporte_salida:
		soporte_salida.visible = false
	_actualizar_estado_visual()
	producto_retirado.emit(prod)
	return prod

func _actualizar_estado_visual() -> void:
	if not luz_indicador: return

	if producto_disponible:
		# Verde esmeralda: Producto terminado listo para recoger
		luz_indicador.light_color = Color(0.2, 1.0, 0.5)
		luz_indicador.light_energy = 2.0
		if soporte_salida: soporte_salida.visible = true
	elif insumos_actuales > 0:
		# Amarillo / Naranja: Recibiendo insumos
		luz_indicador.light_color = Color(0.95, 0.75, 0.15)
		luz_indicador.light_energy = 1.4
		if soporte_salida: soporte_salida.visible = false
	else:
		# Azul suave: Mesón en espera
		luz_indicador.light_color = Color(0.2, 0.5, 0.9)
		luz_indicador.light_energy = 0.8
		if soporte_salida: soporte_salida.visible = false

func reiniciar() -> void:
	insumos_actuales = 0
	producto_disponible = false
	if soporte_salida:
		soporte_salida.visible = false
	_actualizar_estado_visual()
