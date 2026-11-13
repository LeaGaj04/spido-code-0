class_name HitosSandbox
extends RefCounted

static func obtener_hitos() -> Array[Dictionary]:
	return [
		{
			"id": 1,
			"clave": "CALIBRACION",
			"titulo": "1. Acercarse a la Mesa Fija",
			"descripcion": "La mesa de Spido está fija al frente en (0, -2). Arrastra 3 bloques 'Avanzar 1 Paso' al lienzo y presiona Ejecutar para mover a tu astronauta hasta quedar frente a la mesa.",
			"meta_texto": "Avanza hasta quedar frente a la mesa en (0, -1)",
			"bloques_desbloqueados": ["AVANZAR"],
			"cantidad_astronautas": 1,
			"pos_baliza": Vector2i(0, -1),
			"mostrar_baliza": true,
			"piezas": []
		},
		{
			"id": 2,
			"clave": "TOMAR_PIEZA",
			"titulo": "2. Navegar y Tomar una Pieza",
			"descripcion": "¡Excelente! Ahora dirígete a la bahía oeste (-3, -1) usando giros (Izquierda/Derecha), colócate frente a la pieza y recógela usando el bloque 'Tomar Pieza'.",
			"meta_texto": "Llega a la bahía oeste y toma la pieza",
			"bloques_desbloqueados": ["AVANZAR", "GIRAR_IZQ", "GIRAR_DER", "TOMAR_PIEZA"],
			"cantidad_astronautas": 1,
			"mostrar_baliza": false,
			"piezas": [
				{"tipo": "CHASIS", "celda": Vector2i(-3, -1)}
			]
		},
		{
			"id": 3,
			"clave": "ENSAMBLAR_EN_MESA",
			"titulo": "3. Transportar de Punto A a Punto B",
			"descripcion": "Lleva la pieza desde la bahía (Punto A) de regreso a la mesa fija de Spido (Punto B) y úsala para montar el Chasis con el bloque 'Ensamblar'.",
			"meta_texto": "Lleva la pieza a la mesa fija y ensámblala",
			"bloques_desbloqueados": ["AVANZAR", "GIRAR_IZQ", "GIRAR_DER", "TOMAR_PIEZA", "ENSAMBLAR"],
			"cantidad_astronautas": 1,
			"mostrar_baliza": false,
			"piezas": [
				{"tipo": "CHASIS", "celda": Vector2i(-3, -1)}
			]
		},
		{
			"id": 4,
			"clave": "AUTOMATIZAR_BUCLE",
			"titulo": "4. Automatización con Bucles (Loop)",
			"descripcion": "Spido necesita sus Ruedas. Programa la ruta completa de ida y vuelta a la bahía este (3, -1) y activa 'Bucle: ON' para que el astronauta repita el viaje automáticamente.",
			"meta_texto": "Activa Bucle: ON y monta las Ruedas",
			"bloques_desbloqueados": ["AVANZAR", "AVANZAR_2", "GIRAR_IZQ", "GIRAR_DER", "TOMAR_PIEZA", "ENSAMBLAR"],
			"cantidad_astronautas": 1,
			"mostrar_baliza": false,
			"piezas": [
				{"tipo": "RUEDAS", "celda": Vector2i(3, -1)}
			]
		},
		{
			"id": 5,
			"clave": "EQUIPO_CONCURRENTE",
			"titulo": "5. Trabajo en Equipo Concurrente (2 Astronautas)",
			"descripcion": "¡Llega el Astronauta 2! Ahora tienes dos operarios trabajando al mismo tiempo. Programa a ambos en paralelo para traer sensores y componentes a la mesa fija.",
			"meta_texto": "Coordina a ambos astronautas hacia la mesa",
			"bloques_desbloqueados": ["AVANZAR", "AVANZAR_2", "AVANZAR_3", "GIRAR_IZQ", "GIRAR_DER", "TOMAR_PIEZA", "ENSAMBLAR"],
			"cantidad_astronautas": 2,
			"pos_astronauta_2": Vector2i(0, 2),
			"mostrar_baliza": false,
			"piezas": [
				{"tipo": "SENSOR", "celda": Vector2i(-3, 0)}
			]
		},
		{
			"id": 6,
			"clave": "DESPERTAR_SPIDO",
			"titulo": "6. Despertar de Spido (Diagnóstico Final)",
			"descripcion": "Todos los módulos están acoplados en la mesa fija. Coloca al astronauta frente a la mesa y corre el comando 'DIAGNOSTICO' para darle vida al robot.",
			"meta_texto": "Ejecuta DIAGNOSTICO frente a Spido",
			"bloques_desbloqueados": ["AVANZAR", "AVANZAR_2", "AVANZAR_3", "GIRAR_IZQ", "GIRAR_DER", "TOMAR_PIEZA", "ENSAMBLAR", "DIAGNOSTICO"],
			"cantidad_astronautas": 2,
			"mostrar_baliza": false,
			"piezas": []
		}
	]
