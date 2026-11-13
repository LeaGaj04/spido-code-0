class_name HitosSandbox
extends RefCounted

static func obtener_hitos() -> Array[Dictionary]:
	return [
		{
			"id": 1,
			"clave": "PRIMEROS_PASOS",
			"titulo": "1. Avanzar y Recoger Tuerca",
			"descripcion": "Estás en el sector inicial de 3x3. Configura el bloque 'Avanzar' con 1 paso para llegar a la bahía en (0, 1) y tómala con 'Tomar Pieza'.",
			"meta_texto": "Toma la tuerca en la bahía (0, 1)",
			"bloques_disponibles": ["AVANZAR", "TOMAR_PIEZA"],
			"cantidad_astronautas": 1,
			"tamano_sector": 3,
			"pos_astronauta": Vector2i(0, 2),
			"ori_astronauta": 0, # Mirando al Norte (-Z)
			"mostrar_mesa": false,
			"mostrar_baliza": false,
			"tipo_meta": "TOMAR_PIEZA",
			"recompensa_creditos": 10,
			"mensaje_ada": "¡Tuerca asegurada! El comando Avanzar y Tomar funcionan a la perfección.",
			"pista": "Usa [Avanzar 1 Paso] y luego [Tomar Pieza].",
			"piezas": [
				{"tipo": "TUERCA", "celda": Vector2i(0, 1)}
			]
		},
		{
			"id": 2,
			"clave": "GIRO_Y_DEPOSITO",
			"titulo": "2. Girar y Depositar en el Contenedor",
			"descripcion": "Con la tuerca en manos, gira a la derecha hacia el contenedor de depósito en (1, 1), avanza y presiona 'Ensamblar / Depositar' para ganar tus primeras tuercas.",
			"meta_texto": "Lleva la tuerca al contenedor en (1, 1)",
			"bloques_disponibles": ["AVANZAR", "GIRAR_IZQ", "GIRAR_DER", "TOMAR_PIEZA", "ENSAMBLAR"],
			"cantidad_astronautas": 1,
			"tamano_sector": 3,
			"pos_astronauta": Vector2i(0, 2),
			"ori_astronauta": 0,
			"mostrar_mesa": false,
			"mostrar_baliza": false,
			"tipo_meta": "DEPOSITAR_TUERCA",
			"recompensa_creditos": 15,
			"mensaje_ada": "¡Primera tuerca depositada con éxito en el contenedor!",
			"pista": "Avanza, toma la tuerca, gira 90° a la derecha, avanza hacia el contenedor y usa Ensamblar.",
			"piezas": [
				{"tipo": "TUERCA", "celda": Vector2i(0, 1)}
			]
		},
		{
			"id": 3,
			"clave": "BUCLE_FARMEO",
			"titulo": "3. Automatizar Bucle de Tuercas",
			"descripcion": "La bahía repone tuercas infinitamente al recogerlas. Construye una ruta cerrada simétrica y activa 'Bucle: ON' para acumular 30 Tuercas y comprar la 'EXPANSIÓN 5x5' en MEJORAS.",
			"meta_texto": "Acumula 30 Tuercas y compra la Expansión 5x5",
			"bloques_disponibles": ["AVANZAR", "GIRAR_IZQ", "GIRAR_DER", "TOMAR_PIEZA", "ENSAMBLAR"],
			"cantidad_astronautas": 1,
			"tamano_sector": 3,
			"pos_astronauta": Vector2i(0, 2),
			"ori_astronauta": 0,
			"mostrar_mesa": false,
			"mostrar_baliza": false,
			"tipo_meta": "COMPRAR_EXPANSION_5X5",
			"recompensa_creditos": 20,
			"mensaje_ada": "¡Fantástico! Has descubierto el poder del bucle continuo para generar recursos sin esfuerzo manual.",
			"pista": "Asegúrate de que la última instrucción deje al astronauta exactamente en la posición (0, 2) mirando al Norte.",
			"piezas": [
				{"tipo": "TUERCA", "celda": Vector2i(0, 1)}
			]
		},
		{
			"id": 4,
			"clave": "EXPANSION_CHASIS",
			"titulo": "4. Expansión 5x5 y Montaje de Spido",
			"descripcion": "¡El hangar se expandió a 5x5 y la Mesa de Spido está activa al frente en (0, -2)! Transporta la placa de Chasis desde la bahía y acóplala en Spido.",
			"meta_texto": "Monta el Chasis en la Mesa Spido (0, -2)",
			"bloques_disponibles": ["AVANZAR", "GIRAR_IZQ", "GIRAR_DER", "TOMAR_PIEZA", "ENSAMBLAR"],
			"cantidad_astronautas": 1,
			"tamano_sector": 5,
			"pos_astronauta": Vector2i(0, 2),
			"ori_astronauta": 0,
			"mostrar_mesa": true,
			"pos_mesa": Vector2i(0, -2),
			"mostrar_baliza": false,
			"tipo_meta": "ENSAMBLAR",
			"piezas_requeridas": 1,
			"recompensa_creditos": 40,
			"mensaje_ada": "¡Chasis fijado a la mesa! El cuerpo de Spido comienza a tomar forma.",
			"pista": "Recoge el chasis en (2, 0) y llévalo frente a la mesa en (0, -1) para ensamblarlo.",
			"piezas": [
				{"tipo": "CHASIS", "celda": Vector2i(2, 0)}
			]
		},
		{
			"id": 5,
			"clave": "EQUIPO_CONCURRENTE",
			"titulo": "5. Sector 7x7 y 2º Astronauta (Mesón Patas)",
			"descripcion": "Expande a 7x7 en MEJORAS y activa a Astro 2. Mientras Astro 1 abastece con tuercas al Mesón de Patas en (-2, 0), programa a Astro 2 para llevar las patas a Spido.",
			"meta_texto": "Fabrica y monta las Ruedas/Patas en Spido",
			"bloques_disponibles": ["AVANZAR", "GIRAR_IZQ", "GIRAR_DER", "TOMAR_PIEZA", "ENSAMBLAR"],
			"cantidad_astronautas": 2,
			"tamano_sector": 7,
			"pos_astronauta": Vector2i(0, 2),
			"pos_astronauta_2": Vector2i(1, 0),
			"mostrar_mesa": true,
			"pos_mesa": Vector2i(0, -2),
			"tipo_meta": "ENSAMBLAR",
			"piezas_requeridas": 2,
			"recompensa_creditos": 60,
			"mensaje_ada": "¡Trabajo en equipo perfecto! Dos mentes de código funcionando en simultáneo.",
			"pista": "Astro 1 alimenta el mesón en (-2, 0) y Astro 2 retira las patas y las monta en Spido.",
			"piezas": [
				{"tipo": "TUERCA", "celda": Vector2i(-2, 2)}
			]
		},
		{
			"id": 6,
			"clave": "DESPERTAR_SPIDO",
			"titulo": "6. Hangar Total 12x12 y Despertar",
			"descripcion": "¡Hangar 12x12 completamente abierto! Todos los módulos están ensamblados. Coloca al astronauta frente a la mesa Spido y corre 'DIAGNOSTICO' para encender al robot.",
			"meta_texto": "Ejecuta DIAGNOSTICO frente a Spido",
			"bloques_disponibles": ["AVANZAR", "GIRAR_IZQ", "GIRAR_DER", "TOMAR_PIEZA", "ENSAMBLAR", "DIAGNOSTICO"],
			"cantidad_astronautas": 2,
			"tamano_sector": 12,
			"pos_astronauta": Vector2i(0, -1),
			"ori_astronauta": 0,
			"mostrar_mesa": true,
			"pos_mesa": Vector2i(0, -2),
			"tipo_meta": "DIAGNOSTICO",
			"recompensa_creditos": 100,
			"mensaje_ada": "¡Sistemas en línea! Spido ha despertado y la fábrica espacial es un éxito total.",
			"pista": "Párate en (0, -1) mirando al Norte y corre el bloque Diagnóstico.",
			"piezas": []
		}
	]
