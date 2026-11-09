class_name DatosNiveles
extends RefCounted

static func obtener_niveles() -> Array[Dictionary]:
	return [
		{
			"id": 1,
			"titulo": "Nivel 1: Primeros Pasos",
			"subtitulo": "Secuencia Lineal Basica",
			"instruccion": "Un algoritmo ejecuta ordenes paso a paso en orden estricto. Arrastra 3 bloques 'Avanzar' al lienzo y presiona Ejecutar para llegar a la baliza de energia.",
			"concepto_clave": "Secuencia: Las computadoras siguen instrucciones una tras otra, de arriba a abajo.",
			"objetivo_aprendizaje": "Construir, ejecutar y corregir una secuencia de instrucciones.",
			"guiada": true,
			"bloques_permitidos": ["AVANZAR"],
			"bloques_optimos": 3,
			"pos_astronauta": Vector2i(0, 2),
			"ori_astronauta": 0,
			"tipo_meta": "BALIZA",
			"pos_baliza": Vector2i(0, -1),
			"mostrar_mesa": false,
			"piezas": []
		},
		{
			"id": 2,
			"titulo": "Nivel 2: Curva de Orientacion",
			"subtitulo": "Giros y Perspectiva Espacial",
			"instruccion": "Para esquivar la zona de contencion, debes doblar hacia el este. Recuerda: la derecha y la izquierda son relativas a la mirada del astronauta.",
			"concepto_clave": "Orientacion relativa: Girar cambia la direccion hacia donde se movera tu siguiente 'Avanzar'.",
			"bloques_permitidos": ["AVANZAR", "GIRAR_DER", "GIRAR_IZQ"],
			"bloques_optimos": 5,
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
			"subtitulo": "Estado e Interaccion (Chasis de Spid)",
			"instruccion": "Avanza hacia el pedestal, toma el Chasis con 'Tomar Pieza', luego muevete frente al banco de montaje y colocalo con 'Ensamblar en Spid'.",
			"concepto_clave": "Precondicion y Estado: No puedes ensamblar una pieza sin haberla recogido antes.",
			"bloques_permitidos": ["AVANZAR", "GIRAR_DER", "GIRAR_IZQ", "TOMAR_PIEZA", "ENSAMBLAR"],
			"bloques_optimos": 9,
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
		},
		{
			"id": 4,
			"titulo": "Nivel 4: Trabajo en Equipo",
			"subtitulo": "Divide y coordina tareas",
			"instruccion": "Programa una secuencia para cada astronauta. El primero montara el Chasis y el segundo montara las Ruedas.",
			"concepto_clave": "Descomposicion: divide una tarea grande en trabajos pequenos y coordina su orden.",
			"objetivo_aprendizaje": "Asignar tareas a dos astronautas y respetar el orden del ensamblaje.",
			"guiada": false,
			"bloques_permitidos": ["AVANZAR", "GIRAR_DER", "GIRAR_IZQ", "TOMAR_PIEZA", "ENSAMBLAR"],
			"bloques_optimos": 15,
			"pos_astronauta": Vector2i(0, 1),
			"ori_astronauta": 0,
			"cantidad_astronautas": 2,
			"pos_astronauta_2": Vector2i(1, 0),
			"ori_astronauta_2": 0,
			"tipo_meta": "ENSAMBLAJE_EQUIPO",
			"mostrar_mesa": true,
			"pos_mesa": Vector2i(0, -2),
			"piezas": [
				{"tipo": "CHASIS", "celda": Vector2i(-2, 0)},
				{"tipo": "RUEDAS", "celda": Vector2i(1, -1)}
			]
		},
		{
			"id": 5,
			"titulo": "Nivel 5: Cadena de Montaje",
			"subtitulo": "Tres roles, un objetivo",
			"instruccion": "Asigna una pieza a cada astronauta: Chasis, Ruedas y Sensor. El montaje debe respetar ese orden.",
			"concepto_clave": "Roles y dependencias: cada tarea aporta una parte y algunas deben ocurrir antes que otras.",
			"objetivo_aprendizaje": "Coordinar tres secuencias con responsabilidades distintas.",
			"guiada": false,
			"bloques_permitidos": ["AVANZAR", "GIRAR_DER", "GIRAR_IZQ", "TOMAR_PIEZA", "ENSAMBLAR"],
			"bloques_optimos": 21,
			"pos_astronauta": Vector2i(0, 1),
			"ori_astronauta": 0,
			"cantidad_astronautas": 3,
			"pos_astronauta_2": Vector2i(1, 0),
			"ori_astronauta_2": 0,
			"pos_astronauta_3": Vector2i(-1, 0),
			"ori_astronauta_3": 0,
			"tipo_meta": "ENSAMBLAJE_EQUIPO",
			"componentes_objetivo": 3,
			"mostrar_mesa": true,
			"pos_mesa": Vector2i(0, -2),
			"piezas": [
				{"tipo": "CHASIS", "celda": Vector2i(-2, 0)},
				{"tipo": "RUEDAS", "celda": Vector2i(1, -1)},
				{"tipo": "SENSOR", "celda": Vector2i(-1, -1)}
			]
		},
		{
			"id": 6,
			"titulo": "Nivel 6: Patron Reutilizable",
			"subtitulo": "Repite sin reconstruir",
			"instruccion": "Construye una secuencia de movimiento y usa Duplicar para reutilizarla antes de ajustarla a cada astronauta.",
			"concepto_clave": "Reutilizacion: un patron de acciones puede servir como base para otra tarea.",
			"objetivo_aprendizaje": "Reconocer y reutilizar patrones de instrucciones.",
			"guiada": false,
			"bloques_permitidos": ["AVANZAR", "GIRAR_DER", "GIRAR_IZQ", "TOMAR_PIEZA", "ENSAMBLAR"],
			"bloques_optimos": 21,
			"pos_astronauta": Vector2i(0, 1),
			"ori_astronauta": 0,
			"cantidad_astronautas": 3,
			"pos_astronauta_2": Vector2i(1, 0),
			"ori_astronauta_2": 0,
			"pos_astronauta_3": Vector2i(-1, 0),
			"ori_astronauta_3": 0,
			"tipo_meta": "ENSAMBLAJE_EQUIPO",
			"componentes_objetivo": 3,
			"mostrar_mesa": true,
			"pos_mesa": Vector2i(0, -2),
			"piezas": [
				{"tipo": "CHASIS", "celda": Vector2i(-2, 0)},
				{"tipo": "RUEDAS", "celda": Vector2i(1, -1)},
				{"tipo": "SENSOR", "celda": Vector2i(-1, -1)}
			]
		}
	]
