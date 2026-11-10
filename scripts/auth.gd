extends Control

const ESCENA_MENU := "res://escenas/menu_inicio.tscn"

@onready var email_input: LineEdit = $Panel/Contenedor/Email
@onready var password_input: LineEdit = $Panel/Contenedor/Password
@onready var mensaje: Label = $Panel/Contenedor/Mensaje

func _ready() -> void:
	email_input.grab_focus()
	var panel := $Panel
	panel.modulate.a = 0.0
	panel.position.y += 12.0
	var tween := create_tween().set_parallel(true)
	tween.tween_property(panel, "modulate:a", 1.0, 0.25)
	tween.tween_property(panel, "position:y", panel.position.y - 12.0, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_iniciar_sesion_pressed() -> void:
	if _validar_campos():
		mensaje.text = "La conexión de cuentas estará disponible próximamente."

func _on_registrarse_pressed() -> void:
	if _validar_campos():
		mensaje.text = "El registro estará disponible próximamente."

func _on_recuperar_password_pressed() -> void:
	if email_input.text.strip_edges().is_empty():
		mensaje.text = "Escribe tu correo electrónico."
		return
	mensaje.text = "La recuperación de contraseña estará disponible próximamente."

func _on_volver_pressed() -> void:
	get_tree().change_scene_to_file(ESCENA_MENU)

func _validar_campos() -> bool:
	if email_input.text.strip_edges().is_empty():
		mensaje.text = "Escribe tu correo electrónico."
		return false
	if password_input.text.is_empty():
		mensaje.text = "Escribe tu contraseña."
		return false
	return true
