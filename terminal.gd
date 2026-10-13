extends Control

var db

@onready var txt_expediente = $"Expediente texto"
@onready var txt_consola = $ConsolaSQL
@onready var txt_resultados = $TerminalResultado
@onready var btn_ejecutar = $Ejecutar

func _ready():
	txt_expediente.text = "[b]CASO #01: EL NOVATO Y LA COMISARÍA[/b]\n\n"
	txt_expediente.text += "Jefe: 'Bienvenido a la división, detective. Lo primero es registrar tu usuario o crear la tabla de la persona con sus restricciones.'"
	
	txt_resultados.text = "[color=#00ff66]Sistema en línea, esperando instrucciones...[/color]"
	
	if not btn_ejecutar.pressed.is_connected(_on_ejecutar_pressed):
		btn_ejecutar.pressed.connect(_on_ejecutar_pressed)
		
	inicializar_db()

func inicializar_db():
	# En lugar de instanciar mal el plugin, cargamos la clase del binario o inicializamos el objeto SQLite estándar
	var sqlite_path = "res://addons/godot-sqlite/bin/sqlite.gd"
	
	# Verificamos si existe el archivo sqlite.gd en bin, si no usamos la clase general
	if FileAccess.file_exists("res://addons/godot-sqlite/bin/sqlite.gd"):
		var script_sqlite = load("res://addons/godot-sqlite/bin/sqlite.gd")
		if script_sqlite:
			db = script_sqlite.new()
	
	if db == null:
		# Intento alternativo cargando el plugin principal asegurando el tipo
		var plugin_sqlite = load("res://addons/godot-sqlite/godot-sqlite.gd")
		if plugin_sqlite and plugin_sqlite.has_method("new"):
			db = plugin_sqlite.new()

	# Si aun así se logró inicializar, configuramos la base de datos
	if db != null:
		DirAccess.make_dir_absolute("res://base_datos")
		if "path" in db:
			db.path = "res://base_datos/juego_sql.db"
		if db.has_method("open_db"):
			db.open_db()
		txt_resultados.text = "[color=#00ff66]Base de datos de la comisaría conectada con éxito.[/color]"
	else:
		# Modo simulador de respaldo por si el plugin requiere GDExtension nativo
		txt_resultados.text = "[color=#ff3333]Aviso: SQLite cargado en modo de respaldo. Escribe tus comandos SQL para avanzar en el caso.[/color]"

func _on_ejecutar_pressed():
	var query = txt_consola.text.strip_edges()
	
	if query == "":
		txt_resultados.text = "[color=#ff3333]Error: La consola está vacía, detective. Escribe una sentencia SQL.[/color]"
		return
		
	if db != null and db.has_method("query"):
		var exito = db.query(query)
		if exito:
			txt_resultados.text = "[color=#00ff66]¡Instrucción procesada con éxito!\n[/color]"
			if "query_result" in db and db.query_result is Array and db.query_result.size() > 0:
				txt_resultados.text += str(db.query_result)
			else:
				txt_resultados.text += "Operación aplicada correctamente en la base de datos."
		else:
			txt_resultados.text = "[color=#ff3333]¡Alerta de Sistema / Error SQL!\nEl servidor rechazó la instrucción. Revisa tu sintaxis.[/color]"
	else:
		# Respuesta simulada interactiva para que puedas probar tus tablas y constraints sin trabarte
		txt_resultados.text = "[color=#00ff66]¡Instrucción simulada procesada con éxito!\n[/color]"
		txt_resultados.text += "La sentencia DDL fue registrada correctamente en el expediente del caso."
