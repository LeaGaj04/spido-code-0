class_name BloqueItem
extends PanelContainer

signal solicitado_eliminar(bloque: BloqueItem)

@export var id_comando: String = "AVANZAR"
@export var titulo: String = "Avanzar 1 Paso"
@export var prefijo: String = "[AVZ]"
@export var color_borde: Color = Color(0.372549, 0.592157, 0.419608, 0.95)
@export var es_de_paleta: bool = false

@onready var label_prefijo: Label = $HBox/Prefijo
@onready var label_titulo: Label = $HBox/Titulo
@onready var btn_eliminar: Button = $HBox/BtnEliminar

var style_box_normal: StyleBoxFlat
var style_box_activo: StyleBoxFlat

func _ready() -> void:
	custom_minimum_size = Vector2(200, 44)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_configurar_estilos()
	actualizar_vista()

	if btn_eliminar:
		btn_eliminar.visible = not es_de_paleta
		btn_eliminar.pressed.connect(_on_btn_eliminar_pressed)

func configurar(p_id: String, p_titulo: String, p_prefijo: String, p_color_borde: Color, p_paleta: bool = false) -> void:
	id_comando = p_id
	titulo = p_titulo
	prefijo = p_prefijo
	color_borde = p_color_borde
	es_de_paleta = p_paleta
	_configurar_estilos()
	actualizar_vista()

func actualizar_vista() -> void:
	if is_instance_valid(label_prefijo):
		label_prefijo.text = prefijo
		label_prefijo.modulate = color_borde
	if is_instance_valid(label_titulo):
		label_titulo.text = titulo
	if is_instance_valid(btn_eliminar):
		btn_eliminar.visible = not es_de_paleta

func _configurar_estilos() -> void:
	# Base de color gris grafito de SpidoCode (Color(0.082, 0.102, 0.098, 0.98))
	style_box_normal = StyleBoxFlat.new()
	style_box_normal.bg_color = Color(0.082, 0.102, 0.098, 0.98)
	style_box_normal.set_corner_radius_all(6)
	style_box_normal.set_content_margin_all(8)
	style_box_normal.border_width_left = 4
	style_box_normal.border_width_top = 1
	style_box_normal.border_width_right = 1
	style_box_normal.border_width_bottom = 1
	style_box_normal.border_color = color_borde
	style_box_normal.shadow_color = Color(0.00392, 0.0902, 0.01176, 0.65)
	style_box_normal.shadow_size = 2

	# Estado activo con el verde hover de SpidoCode
	style_box_activo = style_box_normal.duplicate()
	style_box_activo.bg_color = Color(0.015, 0.12, 0.025, 0.95)
	style_box_activo.border_color = Color(0.48, 0.76, 0.54, 1.0)
	style_box_activo.border_width_left = 6
	style_box_activo.border_width_top = 2
	style_box_activo.border_width_right = 2
	style_box_activo.border_width_bottom = 2

	add_theme_stylebox_override("panel", style_box_normal)

func resaltar_ejecucion(activo: bool) -> void:
	if activo:
		add_theme_stylebox_override("panel", style_box_activo)
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(1.03, 1.03), 0.1)
	else:
		add_theme_stylebox_override("panel", style_box_normal)
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2.ONE, 0.1)

func _get_drag_data(_at_position: Vector2) -> Variant:
	var preview = PanelContainer.new()
	var st = style_box_normal.duplicate() as StyleBoxFlat
	st.bg_color.a = 0.85
	preview.add_theme_stylebox_override("panel", st)
	preview.custom_minimum_size = custom_minimum_size

	var hbox = HBoxContainer.new()
	var l_pref = Label.new()
	l_pref.text = prefijo
	l_pref.modulate = color_borde
	var l_tit = Label.new()
	l_tit.text = titulo
	l_tit.modulate = Color(0.760784, 0.937255, 0.776471, 1.0)
	hbox.add_child(l_pref)
	hbox.add_child(l_tit)
	preview.add_child(hbox)

	set_drag_preview(preview)

	return {
		"tipo": "bloque_codigo",
		"id_comando": id_comando,
		"titulo": titulo,
		"prefijo": prefijo,
		"color_borde": color_borde,
		"nodo_origen": self,
		"es_de_paleta": es_de_paleta
	}

func _on_btn_eliminar_pressed() -> void:
	solicitado_eliminar.emit(self)
