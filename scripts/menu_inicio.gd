extends Control

const ESCENA_JUEGO := "res://escenas/principal.tscn"
const ESCENA_AUTH := "res://escenas/auth.tscn"

@onready var dialogo: AcceptDialog = $Dialogo

func _ready() -> void:
	$PanelMenu/ContenedorPrincipal/BotonJugar.grab_focus()

func _on_boton_jugar_pressed() -> void:
	get_tree().change_scene_to_file(ESCENA_JUEGO)

func _on_boton_login_pressed() -> void:
	get_tree().change_scene_to_file(ESCENA_AUTH)

func _on_boton_configuracion_pressed() -> void:
	dialogo.title = "Configuración"
	dialogo.dialog_text = "Las opciones de configuración estarán disponibles próximamente."
	dialogo.popup_centered()

func _on_boton_salir_pressed() -> void:
	get_tree().quit()
