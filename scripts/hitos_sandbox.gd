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
			"descripcion": "¡Excelente! Ahora dirígete a la bahía este en (2, -1) usando un giro a la derecha y 'Avanzar', colócate frente a la pieza y recógela con 'Tomar Pieza'.",
			"meta_texto": "Llega a la bahía este (2, -1) y toma la pieza",
			"bloques_desbloqueados": ["AVANZAR", "GIRAR_IZQ", "GIRAR_DER", "TOMAR_PIEZA"],
			"cantidad_astronautas": 1,
			"mostrar_baliza": false,
			"piezas": [
				{"tipo": "CHASIS", "celda": Vector2i(2, -1)}
			]
		},
		{
			"id": 3,
			"clave": "ENSAMBLAR_EN_MESA",
			"titulo": "3. Transportar de Punto A a Punto B",
			"descripcion": "Con la pieza en manos, da media vuelta, regresa por el mismo camino a la mesa fija (Punto B) y monta el Chasis en Spido con el bloque 'Ensamblar'.",
			"meta_texto": "Regresa a la mesa fija y monta el Chasis",
			"bloques_desbloqueados": ["AVANZAR", "GIRAR_IZQ", "GIRAR_DER", "TOMAR_PIEZA", "ENSAMBLAR"],
			"cantidad_astronautas": 1,
			"mostrar_baliza": false,
			"piezas": [
				{"tipo": "CHASIS", "celda": Vector2i(2, -1)}
			]
		},
		{
			"id": 4,
			"clave": "AUTOMATIZAR_BUCLE",
			"titulo": "4. Automatización con Bucles (Loop)",
			"descripcion": "Ahora conecta todo el recorrido en un ciclo cerrado: [Girar Der, Avanzar 2, Tomar, Media Vuelta, Avanzar 2, Girar Der, Ensamblar]. ¡Activa 'Bucle: ON' y mira a tu astronauta repetir la ruta automáticamente!",
			"meta_texto": "Activa Bucle: ON y automatiza el ciclo de Ruedas",
			"bloques_desbloqueados": ["AVANZAR", "AVANZAR_2", "GIRAR_IZQ", "GIRAR_DER", "TOMAR_PIEZA", "ENSAMBLAR"],
			"cantidad_astronautas": 1,
			"mostrar_baliza": false,
			"piezas": [
				{"tipo": "RUEDAS", "celda": Vector2i(2, -1)}
			]
		},
		{
			"id": 5,
			"clave": "EQUIPO_CONCURRENTE",
			"titulo": "5. Trabajo Concurrente (2 Astronautas)",
			"descripcion": "¡Desbloqueo de Astronauta 2! Mientras Astro 1 sigue trabajando en bucle por el carril Este, cambia a la pestaña 'Astro 2' y prográmalo para abastecer por el carril Oeste (-2, -1). ¡Ambos trabajan al mismo tiempo!",
			"meta_texto": "Programa a Astro 2 mientras Astro 1 trabaja",
			"bloques_desbloqueados": ["AVANZAR", "AVANZAR_2", "AVANZAR_3", "GIRAR_IZQ", "GIRAR_DER", "TOMAR_PIEZA", "ENSAMBLAR"],
			"cantidad_astronautas": 2,
			"pos_astronauta_2": Vector2i(0, 0),
			"mostrar_baliza": false,
			"piezas": [
				{"tipo": "RUEDAS", "celda": Vector2i(2, -1)},
				{"tipo": "SENSOR", "celda": Vector2i(-2, -1)}
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
