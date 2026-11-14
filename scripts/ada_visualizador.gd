class_name ADAVisualizador
extends Control

@export var color_primario: Color = Color(0.35, 0.95, 0.65, 0.9)
@export var color_secundario: Color = Color(0.2, 0.6, 0.45, 0.4)

var fase_radar: float = 0.0
var alturas_barras: Array[float] = [0.2, 0.5, 0.8, 0.4, 0.9, 0.6, 0.3, 0.7, 0.5, 0.8, 0.3, 0.6]

func _process(delta: float) -> void:
	fase_radar += delta * 1.8
	if fase_radar > 1.0:
		fase_radar -= 1.0

	var t = Time.get_ticks_msec() * 0.005
	for i in range(alturas_barras.size()):
		var target = 0.2 + 0.7 * abs(sin(t + i * 0.8))
		alturas_barras[i] = lerp(alturas_barras[i], target, clamp(delta * 12.0, 0.0, 1.0))

	queue_redraw()

func _draw() -> void:
	var ancho = size.x
	var alto = size.y
	if ancho < 10 or alto < 10:
		return

	# 1. Widget Radar Circular a la izquierda
	var centro_radar = Vector2(28, alto * 0.5)
	var radio_max = min(20.0, alto * 0.42)

	# Círculos concéntricos de referencia
	draw_arc(centro_radar, radio_max * 0.4, 0, TAU, 32, color_secundario, 1.2)
	draw_arc(centro_radar, radio_max * 0.8, 0, TAU, 32, color_secundario, 1.2)
	draw_arc(centro_radar, radio_max, 0, TAU, 32, color_primario, 1.6)

	# Onda radar pulsante
	var radio_pulso = radio_max * fase_radar
	var alfa_pulso = (1.0 - fase_radar) * 0.7
	var col_pulso = color_primario
	col_pulso.a = alfa_pulso
	draw_arc(centro_radar, radio_pulso, 0, TAU, 32, col_pulso, 2.0)

	# Punto central del radar
	draw_circle(centro_radar, 3.5, color_primario)

	# Cruz guía del radar
	draw_line(centro_radar - Vector2(radio_max + 4, 0), centro_radar + Vector2(radio_max + 4, 0), color_secundario, 1.0)
	draw_line(centro_radar - Vector2(0, radio_max + 4), centro_radar + Vector2(0, radio_max + 4), color_secundario, 1.0)

	# 2. Barras de frecuencia de audio ecualizador a la derecha
	var inicio_x = 64.0
	var espacio_disponible = ancho - inicio_x - 6.0
	var cant_barras = alturas_barras.size()
	var ancho_barra = max(3.0, (espacio_disponible / cant_barras) - 3.0)
	var base_y = alto * 0.5

	for i in range(cant_barras):
		var bx = inicio_x + i * (ancho_barra + 3.0)
		var h = alturas_barras[i] * (alto * 0.38)
		var rect_barra = Rect2(bx, base_y - h, ancho_barra, h * 2.0)
		var col_b = color_primario
		col_b.a = 0.5 + (alturas_barras[i] * 0.5)
		draw_rect(rect_barra, col_b, true)
