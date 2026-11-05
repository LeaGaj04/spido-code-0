class_name BalizaMeta
extends Node3D

@export var celda_meta: Vector2i = Vector2i(0, -1)
@export var altura_suelo: float = 0.05

@onready var cilindro_luz: MeshInstance3D = $CilindroLuz
@onready var omni_light: OmniLight3D = $OmniLight3D

func _ready() -> void:
	posicionar_en_celda(celda_meta)
	_iniciar_pulso()

func posicionar_en_celda(celda: Vector2i) -> void:
	celda_meta = celda
	position = Vector3(celda.x * 2.0, altura_suelo, celda.y * 2.0)

func _iniciar_pulso() -> void:
	var tween = create_tween().set_loops()
	tween.tween_property(omni_light, "light_energy", 1.8, 1.0).set_trans(Tween.TRANS_SINE)
	tween.tween_property(omni_light, "light_energy", 0.6, 1.0).set_trans(Tween.TRANS_SINE)

func activar_exito() -> void:
	var tween = create_tween()
	tween.tween_property(omni_light, "light_energy", 4.0, 0.2)
	tween.tween_property(cilindro_luz, "scale:y", 2.0, 0.3).set_trans(Tween.TRANS_BACK)
	tween.tween_property(cilindro_luz, "scale:y", 1.0, 0.3)
	await tween.finished
