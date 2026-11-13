class_name HitosSandbox
extends RefCounted

static func obtener_hitos() -> Array[Dictionary]:
	return [
		{
			"id": 1,
			"clave": "CALIBRACION",
			"titulo": "1. Calibrar Terminal de Control",
			"descripcion": "Arrastra bloques 'Avanzar 1 Paso' al lienzo y presiona Ejecutar para mover al Astronauta Ingeniero hasta el terminal de energía.",
			"meta_texto": "Llega al terminal en (0, -1)",
			"bloques_desbloqueados": ["AVANZAR"],
			"cantidad_astronautas": 1,
			"pos_baliza": Vector2i(0, -1),
			"mostrar_baliza": true,
			"piezas_necesarias": []
		},
		{
			"id": 2,
			"clave": "MONTAR_CHASIS",
			"titulo": "2. Montar Estructura (Chasis de Spido)",
			"descripcion": "Terminal activo. Dirígete a la bahía oeste (-2, -1) usando giros, recoge el Chasis con 'Tomar Pieza' y llévalo a la mesa central para ensamblarlo en Spido.",
			"meta_texto": "Recoge el Chasis y móntalo en la mesa",
			"bloques_desbloqueados": ["AVANZAR", "GIRAR_IZQ", "GIRAR_DER", "TOMAR_PIEZA", "ENSAMBLAR"],
			"cantidad_astronautas": 1,
			"mostrar_baliza": false,
			"piezas": [
				{"tipo": "CHASIS", "celda": Vector2i(-3, -1)}
			],
			"componente_objetivo": "CHASIS"
		},
		{
			"id": 3,
			"clave": "SUMINISTRO_RUEDAS",
			"titulo": "3. Cadena de Sub-Ensamblaje & Mercado",
			"descripcion": "¡El Mesón de Patas está activo en (-2, 0)! Lleva tornillos desde la bahía este (3, -1) al mesón para fabricar ruedas mecánicas, y ábrete paso al 'Mercado' arriba para contratar más operarios o comprar bloques.",
			"meta_texto": "Fabrica o monta las Ruedas de Spido",
			"bloques_desbloqueados": ["AVANZAR", "AVANZAR_2", "GIRAR_IZQ", "GIRAR_DER", "TOMAR_PIEZA", "ENSAMBLAR"],
			"cantidad_astronautas": 1,
			"mostrar_baliza": false,
			"piezas": [
				{"tipo": "TORNILLO", "celda": Vector2i(3, -1)}
			],
			"componente_objetivo": "RUEDAS"
		},
		{
			"id": 4,
			"clave": "EQUIPO_CONCURRENTE",
			"titulo": "4. Trabajo en Equipo (Desbloqueo Astro 2: Tracción)",
			"descripcion": "¡Llega el Astronauta 2! Ahora tienes dos agentes en el hangar. Coordina a ambos: uno monta los Sensores ópticos y el otro apoya en la mesa.",
			"meta_texto": "Monta el Sensor óptico de Spido",
			"bloques_desbloqueados": ["AVANZAR", "AVANZAR_2", "AVANZAR_3", "GIRAR_IZQ", "GIRAR_DER", "TOMAR_PIEZA", "ENSAMBLAR"],
			"cantidad_astronautas": 2,
			"pos_astronauta_2": Vector2i(0, 2),
			"ori_astronauta_2": 0,
			"mostrar_baliza": false,
			"piezas": [
				{"tipo": "SENSOR", "celda": Vector2i(-3, 0)}
			],
			"componente_objetivo": "SENSOR"
		},
		{
			"id": 5,
			"clave": "CADENA_AUTOMATIZADA",
			"titulo": "5. Fábrica Coordinada (Astro 3, 4 y 5)",
			"descripcion": "¡Todo el escuadrón operativo! Desbloquea a los 5 astronautas. Automatiza el montaje de los Brazos y el Núcleo de Batería trabajando en paralelo.",
			"meta_texto": "Monta Brazos y Núcleo de Energía",
			"bloques_desbloqueados": ["AVANZAR", "AVANZAR_2", "AVANZAR_3", "GIRAR_IZQ", "GIRAR_DER", "TOMAR_PIEZA", "ENSAMBLAR"],
			"cantidad_astronautas": 5,
			"pos_astronauta_3": Vector2i(-1, 2),
			"pos_astronauta_4": Vector2i(1, 2),
			"pos_astronauta_5": Vector2i(0, 2),
			"mostrar_baliza": false,
			"piezas": [
				{"tipo": "BRAZOS", "celda": Vector2i(3, 0)},
				{"tipo": "BATERIA", "celda": Vector2i(-3, 1)}
			],
			"componente_objetivo": "BATERIA"
		},
		{
			"id": 6,
			"clave": "DESPERTAR_SPIDO",
			"titulo": "6. Despertar de Spido (Diagnóstico Final)",
			"descripcion": "Todos los sistemas físicos de Spido están acoplados. Ejecuta 'DIAGNOSTICO' frente a la mesa para energizar el procesador y ver a Spido cobrar vida.",
			"meta_texto": "Ejecuta DIAGNOSTICO frente a Spido",
			"bloques_desbloqueados": ["AVANZAR", "AVANZAR_2", "AVANZAR_3", "GIRAR_IZQ", "GIRAR_DER", "TOMAR_PIEZA", "ENSAMBLAR", "DIAGNOSTICO"],
			"cantidad_astronautas": 5,
			"mostrar_baliza": false,
			"piezas": [],
			"componente_objetivo": "DIAGNOSTICO"
		}
	]
