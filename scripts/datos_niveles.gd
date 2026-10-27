class_name DatosNiveles
extends RefCounted

static func obtener_niveles() -> Array[Dictionary]:
	return [
		{
			"id": 1,
			"titulo": "Nivel 1: Primeros Pasos",
			"subtitulo": "Secuencia Lineal Básica",
			"instruccion": "Un algoritmo ejecuta órdenes paso a paso en orden estricto. Arrastra 3 bloques 'Avanzar' al lienzo y presiona Ejecutar para llegar a la baliza de energía.",
			"concepto_clave": "Secuencia: Las computadoras siguen instrucciones una tras otra, de arriba a abajo.",
			"bloques_permitidos": ["AVANZAR"],
			"bloques_optimos": 3,
			"pos_astronauta": Vector2i(0, 2),
			"ori_astronauta": 0, # Norte (-Z)
			"tipo_meta": "BALIZA",
			"pos_baliza": Vector2i(0, -1),
			"mostrar_mesa": false,
			"piezas": []
		},
		{
			"id": 2,
			"titulo": "Nivel 2: Curva de Orientación",
			"subtitulo": "Giros y Perspectiva Espacial",
			"instruccion": "Para esquivar la zona de contención, debes doblar hacia el almacén este. Recuerda: la derecha y la izquierda son desde la perspectiva del astronauta.",
			"concepto_clave": "Orientación relativa: Girar cambia la dirección hacia donde se moverá tu siguiente 'Avanzar'.",
			"bloques_permitidos": ["AVANZAR", "GIRAR_DER", "GIRAR_IZQ"],
			"bloques_optimos": 5, # Avanzar -> Girar Der -> Avanzar 2 -> Girar Izq -> Avanzar (o ruta de 5 pasos)
			"pos_astronauta": Vector2i(-1, 2),
			"ori_astronauta": 0,
			"tipo_meta": "BALIZA",
			"pos_baliza": Vector2i(1, 0),
			"mostrar_mesa": false,
			"piezas": []
		},
		{
			"id": 3,
			"titulo": "Nivel 3: El Primer Componente",
			"subtitulo": "Estado e Interacción (Chasis de Spid)",
			"instruccion": "Avanza hacia el pedestal, toma el Chasis con 'Tomar Pieza', luego muévete frente al banco de montaje y colócalo con 'Ensamblar en Spid'.",
			"concepto_clave": "Precondición y Estado: No puedes ensamblar una pieza sin haberla recogido antes.",
			"bloques_permitidos": ["AVANZAR", "GIRAR_DER", "GIRAR_IZQ", "TOMAR_PIEZA", "ENSAMBLAR"],
			"bloques_optimos": 8,
			"pos_astronauta": Vector2i(0, 1),
			"ori_astronauta": 0,
			"tipo_meta": "ENSAMBLAJE",
			"mostrar_mesa": true,
			"pos_mesa": Vector2i(0, -2),
			"piezas": [
				{
					"tipo": "CHASIS",
					"celda": Vector2i(-2, 0)
				}
			]
		}
	]
