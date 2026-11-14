class_name HitosSandbox
extends RefCounted

static func obtener_hitos() -> Array[Dictionary]:
	return [
		{
			"id": 1,
			"clave": "PRIMEROS_PASOS",
			"titulo": "1. Calibración: Avanzar y Recoger",
			"descripcion": "Estás en la plataforma base de 5x5 con centro en (0, 0). Programa a tu astronauta para avanzar 1 paso al oeste (-1, 0) y recolectar tu primera tuerca con [Tomar Pieza].",
			"meta_texto": "Toma la tuerca en la bahía (-1, 0)",
			"bloques_disponibles": ["AVANZAR", "TOMAR_PIEZA"],
			"cantidad_astronautas": 1,
			"tamano_sector": 5,
			"pos_astronauta": Vector2i(0, 0),
			"ori_astronauta": 3, # Mirando al Oeste (-X)
			"mostrar_mesa": false,
			"mostrar_baliza": false,
			"tipo_meta": "TOMAR_PIEZA",
			"recompensa_creditos": 15,
			"mensaje_ada": "¡Tuerca asegurada! El comando Avanzar y Tomar funcionan a la perfección.",
			"pista": "Usa [Avanzar 1 Paso] y luego [Tomar Pieza].",
			"piezas": [
				{"tipo": "TUERCA", "celda": Vector2i(-1, 0)}
			]
		},
		{
			"id": 2,
			"clave": "GIRO_Y_DEPOSITO",
			"titulo": "2. Circuito: Transportar y Depositar",
			"descripcion": "Con la tuerca en manos, gira hacia el contenedor en (1, 0) (usa [Girar Derecha 90°] dos veces), avanza 2 pasos y presiona [Ensamblar / Depositar] para vender la tuerca.",
			"meta_texto": "Deposita la tuerca en el contenedor (1, 0)",
			"bloques_disponibles": ["AVANZAR", "GIRAR_IZQ", "GIRAR_DER", "TOMAR_PIEZA", "ENSAMBLAR"],
			"cantidad_astronautas": 1,
			"tamano_sector": 5,
			"pos_astronauta": Vector2i(0, 0),
			"ori_astronauta": 3,
			"mostrar_mesa": false,
			"mostrar_baliza": false,
			"tipo_meta": "DEPOSITAR_TUERCA",
			"recompensa_creditos": 20,
			"mensaje_ada": "¡Primera tuerca depositada con éxito en el contenedor!",
			"pista": "Avanza, toma la tuerca, gira al este, camina al contenedor y usa Ensamblar/Depositar.",
			"piezas": [
				{"tipo": "TUERCA", "celda": Vector2i(-1, 0)}
			]
		},
		{
			"id": 3,
			"clave": "BUCLE_FARMEO",
			"titulo": "3. Automatización: Adquirir Bloque [LOOP]",
			"descripcion": "La bahía se reabastece sola. Abre MEJORAS y compra el 'Bloque [LOOP] Bucle Continuo' (20 Tuercas). Colócalo en tu rutina para recolectar y depositar sin parar.",
			"meta_texto": "Compra el Bloque [LOOP] y ejecuta un bucle continuo",
			"bloques_disponibles": ["AVANZAR", "GIRAR_IZQ", "GIRAR_DER", "TOMAR_PIEZA", "ENSAMBLAR"],
			"cantidad_astronautas": 1,
			"tamano_sector": 5,
			"pos_astronauta": Vector2i(0, 0),
			"ori_astronauta": 3,
			"mostrar_mesa": false,
			"mostrar_baliza": false,
			"tipo_meta": "ACTIVAR_BUCLE",
			"recompensa_creditos": 25,
			"mensaje_ada": "¡Fantástico! Has descubierto el poder del bucle algorítmico continuo para generar recursos de forma autónoma.",
			"pista": "Compra el bloque Bucle en MEJORAS y agrégalo a tu lista de instrucciones.",
			"piezas": [
				{"tipo": "TUERCA", "celda": Vector2i(-1, 0)}
			]
		},
		{
			"id": 4,
			"clave": "INSTALAR_SPIDO",
			"titulo": "4. Estación Spido: Montar el Chasis",
			"descripcion": "En MEJORAS compra la 'Mesa Central Spido' (30 Tuercas) que se instalará en (0, -2). Lleva la placa de chasis desde la bahía y móntala en Spido con [Ensamblar].",
			"meta_texto": "Instala la Mesa Spido y monta el Chasis",
			"bloques_disponibles": ["AVANZAR", "GIRAR_IZQ", "GIRAR_DER", "TOMAR_PIEZA", "ENSAMBLAR"],
			"cantidad_astronautas": 1,
			"tamano_sector": 5,
			"pos_astronauta": Vector2i(0, 0),
			"ori_astronauta": 3,
			"mostrar_mesa": true,
			"pos_mesa": Vector2i(0, -2),
			"mostrar_baliza": false,
			"tipo_meta": "ENSAMBLAR",
			"piezas_requeridas": 1,
			"recompensa_creditos": 40,
			"mensaje_ada": "¡Chasis fijado a la mesa central! El cuerpo de Spido comienza a tomar forma.",
			"pista": "Recoge el chasis en (-1, 0) y llévalo frente a la mesa en (0, -1) para ensamblarlo.",
			"piezas": [
				{"tipo": "CHASIS", "celda": Vector2i(-1, 0)}
			]
		},
		{
			"id": 5,
			"clave": "EQUIPO_CONCURRENTE",
			"titulo": "5. Expansión 7x7 y 2º Astronauta (Mesón Patas)",
			"descripcion": "Expande el terreno a 7x7 y adquiere a Astro 2 y el Mesón de Patas en MEJORAS. Mientras Astro 1 abastece el mesón en (-2, 0), Astro 2 traslada las patas a Spido.",
			"meta_texto": "Expande a 7x7 y ensambla las Ruedas/Patas en Spido",
			"bloques_disponibles": ["AVANZAR", "GIRAR_IZQ", "GIRAR_DER", "TOMAR_PIEZA", "ENSAMBLAR"],
			"cantidad_astronautas": 2,
			"tamano_sector": 7,
			"pos_astronauta": Vector2i(0, 0),
			"ori_astronauta": 3,
			"pos_astronauta_2": Vector2i(1, 0),
			"ori_astronauta_2": 0,
			"mostrar_mesa": true,
			"pos_mesa": Vector2i(0, -2),
			"tipo_meta": "ENSAMBLAR",
			"piezas_requeridas": 2,
			"recompensa_creditos": 60,
			"mensaje_ada": "¡Trabajo concurrente impecable! Dos astronautas colaborando en paralelo.",
			"pista": "Astro 1 alimenta el mesón en (-2, 0) y Astro 2 retira las patas y las monta en Spido.",
			"piezas": [
				{"tipo": "TUERCA", "celda": Vector2i(-2, 2)}
			]
		},
		{
			"id": 6,
			"clave": "DESPERTAR_SPIDO",
			"titulo": "6. Hangar Total 13x13 y Despertar",
			"descripcion": "¡Hangar 13x13 completamente abierto y perfectamente simétrico! Todos los módulos están ensamblados. Párate frente a Spido en (0, -1) y corre [DIAGNOSTICO] para encenderlo.",
			"meta_texto": "Ejecuta DIAGNOSTICO frente a Spido",
			"bloques_disponibles": ["AVANZAR", "GIRAR_IZQ", "GIRAR_DER", "TOMAR_PIEZA", "ENSAMBLAR", "DIAGNOSTICO"],
			"cantidad_astronautas": 2,
			"tamano_sector": 13,
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
