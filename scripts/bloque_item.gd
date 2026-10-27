class_name BloqueItem
extends PanelContainer

signal solicitado_eliminar(bloque: BloqueItem)

@export var id_comando: String = "AVANZAR"
@export var titulo: String = "Avanzar 1 Paso"
@export var icono: String = "⬆️"
@export var color_tema: Color = Color(0.18, 0.53, 0.88)
@export var es_de_paleta: bool = false

@onready var label_icono: Label = $HBox/Icono
@onready var label_titulo: Label = $HBox/Titulo
@onready var btn_eliminar: Button = $HBox/BtnEliminar

var style_box_normal: StyleBoxFlat
var style_box_activo: StyleBoxFlat

func _ready() -> void:
	custom_minimum_size = Vector2(180, 44)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_configurar_estilos()
	actualizar_vista()

	if btn_eliminar:
		btn_eliminar.visible = not es_de_paleta
		btn_eliminar.pressed.connect(_on_btn_eliminar_pressed)

func configurar(p_id: String, p_titulo: String, p_icono: String, p_color: Color, p_paleta: bool = false) -> void:
	id_comando = p_id
	titulo = p_titulo
	icono = p_icono
	color_tema = p_color
	es_de_paleta = p_paleta
	_configurar_estilos()
	actualizar_vista()

func actualizar_vista() -> void:
	if is_instance_valid(label_icono):
		label_icono.text = icono
	if is_instance_valid(label_titulo):
		label_titulo.text = titulo
	if is_instance_valid(btn_eliminar):
		btn_eliminar.visible = not es_de_paleta

func _configurar_estilos() -> void:
	style_box_normal = StyleBoxFlat.new()
	style_box_normal.bg_color = color_tema
	style_box_normal.set_corner_radius_all(8)
	style_box_normal.set_content_margin_all(8)
	style_box_normal.border_width_left = 2
	style_box_normal.border_width_top = 2
	style_box_normal.border_width_right = 2
	style_box_normal.border_width_bottom = 2
	style_box_normal.border_color = color_tema.lightened(0.25)

	style_box_activo = style_box_normal.duplicate()
	style_box_activo.border_color = Color(1.0, 0.95, 0.2, 1.0) # Borde amarillo brillante
	style_box_activo.border_width_left = 4
	style_box_activo.border_width_top = 4
	style_box_activo.border_width_right = 4
	style_box_activo.border_width_bottom = 4

	add_theme_stylebox_override("panel", style_box_normal)

func resaltar_ejecucion(activo: bool) -> void:
	if activo:
		add_theme_stylebox_override("panel", style_box_activo)
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(1.04, 1.04), 0.1)
	else:
		add_theme_stylebox_override("panel", style_box_normal)
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2.ONE, 0.1)

func _get_drag_data(_at_position: Vector2) -> Variant:
	# Vista previa durante el arrastre
	var preview = PanelContainer.new()
	var st = style_box_normal.duplicate() as StyleBoxFlat
	st.bg_color.a = 0.8
	preview.add_theme_stylebox_override("panel", st)
	preview.custom_minimum_size = custom_minimum_size

	var hbox = HBoxContainer.new()
	var l_ico = Label.new()
	l_ico.text = icono
	var l_tit = Label.new()
	l_tit.text = titulo
	hbox.add_child(l_ico)
	hbox.add_child(l_tit)
	preview.add_child(hbox)

	set_drag_preview(preview)

	return {
		"tipo": "bloque_codigo",
		"id_comando": id_comando,
		"titulo": titulo,
		"icono": icono,
		"color": color_tema,
		"nodo_origen": self,
		"es_de_paleta": es_de_paleta
	}

func _on_btn_eliminar_pressed() -> void:
	solicitado_eliminar.emit(self)
