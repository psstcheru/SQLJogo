extends Control

var db

@onready var txt_expediente = $"Expediente texto"
@onready var txt_consola = $ConsolaSQL
@onready var txt_resultados = $TerminalResultado
@onready var btn_ejecutar = $Ejecutar

# Estados del Juego: "menu", "detective", "oficial"
var estado_actual = "menu"

# Progresión Modo Detective (1 al 20)
var nivel_actual = 1
const TOTAL_NIVELES = 20

# Progresión Modo Oficial (Rondas Procedurales Reales)
var ronda_oficial = 1
var casos_resueltos_ronda = 0
const META_RONDA = 25

# Ayudas activadas por defecto (True)
var mostrar_tutorial = true
var mostrar_pista = true

# Clave secreta de ascenso
const CLAVE_ASCENSO = "SQL_MASTER_2026"
var modo_oficial_desbloqueado = false

# Variables procedurales dinámicas
var usuario_objetivo = ""
var cuota_objetivo = ""
var rol_objetivo = ""
var tabla_objetivo = ""
var password_objetivo = ""

func _ready():
	mostrar_menu_principal()
	
	if not btn_ejecutar.pressed.is_connected(_on_ejecutar_pressed):
		btn_ejecutar.pressed.connect(_on_ejecutar_pressed)
		
	inicializar_db()

# --- MENÚ PRINCIPAL ---
func mostrar_menu_principal():
	estado_actual = "menu"
	var menu_ui = "[b]SISTEMA CENTRAL DE LA COMISARÍA SQL[/b]\n\n"
	menu_ui += "[color=#ffff66]Selecciona tu modo operativo:[/color]\n\n"
	menu_ui += "[color=#00ff66][ 1 ] MODO DETECTIVE (Academia 20 Niveles)[/color]\n"
	menu_ui += "Aprende desde cero la sintaxis y administración básica.\n\n"
	
	if modo_oficial_desbloqueado:
		menu_ui += "[color=#00ffff][ 2 ] MODO OFICIAL (Casos Reales / Procedurales)[/color]\n"
		menu_ui += "Rondas dinámicas con consultas aleatorias de campo.\n"
	else:
		menu_ui += "[color=#888888][ 2 ] MODO OFICIAL (BLOQUEADO)[/color]\n"
		menu_ui += "Requiere graduarse del Modo Detective.\n"
		
	txt_expediente.text = menu_ui
	txt_resultados.text = "[color=#00ff66]Escribe 'modo 1' o 'modo 2' en la consola y presiona Enter.[/color]"

func generar_caso_procedural():
	randomize()
	var lista_usuarios = ["Oficial_Rojas", "Agente_Perez", "Inspector_Mendez", "Cabo_Silva", "Teniente_Cruz", "Detective_Alanis", "Comisario_Gomez", "Oficial_Luna"]
	var lista_cuotas = ["2M", "3M", "5M", "10M", "15M", "20M"]
	var lista_roles = ["ROLE_INVESTIGADOR", "ROLE_OPERATIVO", "ROLE_ANALISTA", "ROLE_PATRULLA", "ROLE_AUDITOR", "ROLE_SISTEMAS"]
	var lista_tablas = ["persona", "agente", "sospechoso", "evidencia", "empleado", "bitacora", "multa"]
	var lista_passwords = ["1234", "secreto99", "passAdmin", "claveX", "omega77"]
	
	usuario_objetivo = lista_usuarios.pick_random()
	cuota_objetivo = lista_cuotas.pick_random()
	rol_objetivo = lista_roles.pick_random()
	tabla_objetivo = lista_tablas.pick_random()
	password_objetivo = lista_passwords.pick_random()
	
	if estado_actual == "detective":
		cargar_interfaz_mision()

func cargar_interfaz_mision():
	var texto_ui = "[b]MODO DETECTIVE - CASO #" + str(nivel_actual).pad_zeros(2) + "[/b]\n\n"
	
	match nivel_actual:
		1:
			texto_ui += "[color=#ffff66]Contexto:[/color]\nEl sistema central no reconoce al oficial y se requiere registrar su cuenta en la base de datos de la comisaría.\n\n"
			if mostrar_tutorial:
				texto_ui += "[color=#ffff66]Tutorial:[/color]\nPara crear cuentas en una base de datos relacional se emplea la instrucción CREATE USER seguida del nombre del usuario y la cláusula IDENTIFIED BY para asignarle una contraseña de acceso.\n\n"
			texto_ui += "[color=#ff99ff]Tu Misión:[/color]\nRegistra al agente " + usuario_objetivo + " con la contraseña " + password_objetivo + ".\n\n"
			if mostrar_pista:
				texto_ui += "[color=#888888]Pista:\nCREATE USER " + usuario_objetivo + " IDENTIFIED BY " + password_objetivo + ";[/color]"

		2:
			texto_ui += "[color=#ffff66]Contexto:[/color]\nEl oficial " + usuario_objetivo + " intenta ingresar a la terminal pero el sistema le niega el acceso arrojando el error ORA-01045 porque carece de privilegios básicos de sesión.\n\n"
			if mostrar_tutorial:
				texto_ui += "[color=#ffff66]Tutorial:[/color]\nUn usuario recién creado en Oracle o sistemas de bases de datos no posee ningún permiso por defecto; ni siquiera el de conectarse. Es obligatorio otorgar el privilegio de sistema CREATE SESSION mediante la sentencia GRANT.\n\n"
			texto_ui += "[color=#ff99ff]Tu Misión:[/color]\nConcede el privilegio de inicio de sesión al usuario " + usuario_objetivo + ".\n\n"
			if mostrar_pista:
				texto_ui += "[color=#888888]Pista:\nGRANT CREATE SESSION TO " + usuario_objetivo + ";[/color]"

		3:
			texto_ui += "[color=#ffff66]Contexto:[/color]\nEl agente " + usuario_objetivo + " necesita permisos para delegar el acceso a otros elementos novatos de la estación.\n\n"
			if mostrar_tutorial:
				texto_ui += "[color=#ffff66]Tutorial:[/color]\nSi deseas que un usuario pueda heredar o conceder este mismo privilegio a terceros, debes añadir al final de la instrucción la cláusula WITH ADMIN OPTION.\n\n"
			texto_ui += "[color=#ff99ff]Tu Misión:[/color]\nOtorga el privilegio CREATE SESSION a " + usuario_objetivo + " permitiéndole delegarlo con WITH ADMIN OPTION.\n\n"
			if mostrar_pista:
				texto_ui += "[color=#888888]Pista:\nGRANT CREATE SESSION TO " + usuario_objetivo + " WITH ADMIN OPTION;[/color]"

		4:
			texto_ui += "[color=#ffff66]Contexto:[/color]\nEl agente " + usuario_objetivo + " requiere almacenar expedientes voluminosos en el servidor central sin restricciones de espacio.\n\n"
			if mostrar_tutorial:
				texto_ui += "[color=#ffff66]Tutorial:[/color]\nPara otorgar capacidad de almacenamiento ilimitada en todos los tablespaces de la base de datos, utilizamos un privilegio global especial llamado UNLIMITED TABLESPACE.\n\n"
			texto_ui += "[color=#ff99ff]Tu Misión:[/color]\nConcede el privilegio UNLIMITED TABLESPACE a " + usuario_objetivo + ".\n\n"
			if mostrar_pista:
				texto_ui += "[color=#888888]Pista:\nGRANT UNLIMITED TABLESPACE TO " + usuario_objetivo + ";[/color]"

		5:
			texto_ui += "[color=#ffff66]Contexto:[/color]\nSe requiere limitar estrictamente el uso de recursos físicos en disco para la cuenta del agente " + usuario_objetivo + ".\n\n"
			if mostrar_tutorial:
				texto_ui += "[color=#ffff66]Tutorial:[/color]\nModificamos el espacio asignado en disco empleando la instrucción ALTER USER complementada con la palabra reservada QUOTA y el tamaño máximo permitido sobre el tablespace USERS.\n\n"
			texto_ui += "[color=#ff99ff]Tu Misión:[/color]\nEstablece una cuota de " + cuota_objetivo + " en el tablespace USERS para " + usuario_objetivo + ".\n\n"
			if mostrar_pista:
				texto_ui += "[color=#888888]Pista:\nALTER USER " + usuario_objetivo + " QUOTA " + cuota_objetivo + " ON USERS;[/color]"

		6:
			texto_ui += "[color=#ffff66]Contexto:[/color]\nSe detectó actividad sospechosa bajo la cuenta de " + usuario_objetivo + " y el mando superior ordenó congelar su acceso inmediatamente.\n\n"
			if mostrar_tutorial:
				texto_ui += "[color=#ffff66]Tutorial:[/color]\nPara deshabilitar temporalmente una cuenta corporativa sin borrar sus datos, alteramos su estado operativo utilizando ACCOUNT LOCK.\n\n"
			texto_ui += "[color=#ff99ff]Tu Misión:[/color]\nBloquea administrativamente la cuenta del usuario " + usuario_objetivo + ".\n\n"
			if mostrar_pista:
				texto_ui += "[color=#888888]Pista:\nALTER USER " + usuario_objetivo + " ACCOUNT LOCK;[/color]"

		7:
			texto_ui += "[color=#ffff66]Contexto:[/color]\nLa investigación concluyó y se comprobó la inocencia del agente " + usuario_objetivo + "; es necesario restaurar su acceso operativo.\n\n"
			if mostrar_tutorial:
				texto_ui += "[color=#ffff66]Tutorial:[/color]\nPara revertir el estado de bloqueo de una cuenta y permitirle iniciar sesión con normalidad, utilizamos la instrucción ACCOUNT UNLOCK.\n\n"
			texto_ui += "[color=#ff99ff]Tu Misión:[/color]\nDesbloquea la cuenta del usuario " + usuario_objetivo + ".\n\n"
			if mostrar_pista:
				texto_ui += "[color=#888888]Pista:\nALTER USER " + usuario_objetivo + " ACCOUNT UNLOCK;[/color]"

		8:
			texto_ui += "[color=#ffff66]Contexto:[/color]\nPara optimizar la seguridad y evitar asignar permisos de manera individual a cada oficial, necesitamos un grupo centralizado.\n\n"
			if mostrar_tutorial:
				texto_ui += "[color=#ffff66]Tutorial:[/color]\nUn Rol es un objeto de base de datos que agrupa múltiples privilegios para administrarlos de forma ordenada. Lo creamos mediante la sentencia CREATE ROLE.\n\n"
			texto_ui += "[color=#ff99ff]Tu Misión:[/color]\nCrea un nuevo rol personalizado llamado " + rol_objetivo + ".\n\n"
			if mostrar_pista:
				texto_ui += "[color=#888888]Pista:\nCREATE ROLE " + rol_objetivo + ";[/color]"

		9:
			texto_ui += "[color=#ffff66]Contexto:[/color]\nEl rol operativo " + rol_objetivo + " ya existe, pero ahora debemos asignárselo formalmente al agente " + usuario_objetivo + ".\n\n"
			if mostrar_tutorial:
				texto_ui += "[color=#ffff66]Tutorial:[/color]\nLa asignación de roles a las cuentas de usuario se realiza utilizando el comando GRANT seguido del nombre del rol y la cláusula TO.\n\n"
			texto_ui += "[color=#ff99ff]Tu Misión:[/color]\nAsigna el rol " + rol_objetivo + " al usuario " + usuario_objetivo + ".\n\n"
			if mostrar_pista:
				texto_ui += "[color=#888888]Pista:\nGRANT " + rol_objetivo + " TO " + usuario_objetivo + ";[/color]"

		10:
			texto_ui += "[color=#ffff66]Contexto:[/color]\nEl archivo central requiere una nueva tabla de registros con normas estrictas de integridad para evitar valores vacíos y asegurar claves.\n\n"
			if mostrar_tutorial:
				texto_ui += "[color=#ffff66]Tutorial:[/color]\nEstructuramos tablas relacionales con la sentencia CREATE TABLE, definiendo columnas, tipos de datos como VARCHAR2 y restricciones lógicas como PRIMARY KEY y NOT NULL.\n\n"
			texto_ui += "[color=#ff99ff]Tu Misión:[/color]\nCrea la tabla " + tabla_objetivo + " con un campo id (PRIMARY KEY) y un campo nombre (VARCHAR2(20), NOT NULL).\n\n"
			if mostrar_pista:
				texto_ui += "[color=#888888]Pista:\nCREATE TABLE " + tabla_objetivo + " (id INT PRIMARY KEY, nombre VARCHAR2(20) NOT NULL);[/color]"

		11:
			texto_ui += "[color=#ffff66]Contexto:[/color]\nNecesitamos poblar el sistema insertando los primeros registros oficiales dentro de la tabla creada previamente.\n\n"
			if mostrar_tutorial:
				texto_ui += "[color=#ffff66]Tutorial:[/color]\nPara agregar filas nuevas a una relación utilizamos la instrucción INSERT INTO especificando la tabla y los valores correspondientes entre paréntesis.\n\n"
			texto_ui += "[color=#ff99ff]Tu Misión:[/color]\nInserta un registro con id 1 y nombre 'Juan' en la tabla " + tabla_objetivo + ".\n\n"
			if mostrar_pista:
				texto_ui += "[color=#888888]Pista:\nINSERT INTO " + tabla_objetivo + " VALUES (1, 'Juan');[/color]"

		12:
			texto_ui += "[color=#ffff66]Contexto:[/color]\nEl alto mando solicita verificar y auditar los registros almacenados actualmente en la base de datos de la comisaría.\n\n"
			if mostrar_tutorial:
				texto_ui += "[color=#ffff66]Tutorial:[/color]\nLa recuperación de información se realiza mediante consultas de proyección utilizando la sentencia SELECT combinada con el asterisco (*) para traer todas las columnas.\n\n"
			texto_ui += "[color=#ff99ff]Tu Misión:[/color]\nConsulta todos los registros almacenados en la tabla " + tabla_objetivo + ".\n\n"
			if mostrar_pista:
				texto_ui += "[color=#888888]Pista:\nSELECT * FROM " + tabla_objetivo + ";[/color]"

		13:
			texto_ui += "[color=#ffff66]Contexto:[/color]\nUn agente cambió de nombre oficial y necesitamos actualizar su registro dentro del sistema de personal.\n\n"
			if mostrar_tutorial:
				texto_ui += "[color=#ffff66]Tutorial:[/color]\nPara modificar datos existentes en una tabla se utiliza la instrucción UPDATE en conjunto con la cláusula SET y un filtro WHERE para no alterar toda la tabla.\n\n"
			texto_ui += "[color=#ff99ff]Tu Misión:[/color]\nActualiza el nombre a 'Carlos' donde el id sea 1 en la tabla " + tabla_objetivo + ".\n\n"
			if mostrar_pista:
				texto_ui += "[color=#888888]Pista:\nUPDATE " + tabla_objetivo + " SET nombre = 'Carlos' WHERE id = 1;[/color]"

		14:
			texto_ui += "[color=#ffff66]Contexto:[/color]\nUn elemento causó baja definitiva de la corporación y seu expediente debe ser removido de los registros activos.\n\n"
			if mostrar_tutorial:
				texto_ui += "[color=#ffff66]Tutorial:[/color]\nEliminamos filas específicas de una tabla utilizando la sentencia DELETE FROM acompañada obligatoriamente de una condición WHERE.\n\n"
			texto_ui += "[color=#ff99ff]Tu Misión:[/color]\nElimina el registro con id 1 de la tabla " + tabla_objetivo + ".\n\n"
			if mostrar_pista:
				texto_ui += "[color=#888888]Pista:\nDELETE FROM " + tabla_objetivo + " WHERE id = 1;[/color]"

		15:
			texto_ui += "[color=#ffff66]Contexto:[/color]\nRequerimos un generador automático de folios que incremente de forma continua para los nuevos casos de investigación.\n\n"
			if mostrar_tutorial:
				texto_ui += "[color=#ffff66]Tutorial:[/color]\nUna secuencia es un objeto de base de datos que genera números enteros secuenciales de forma automática mediante la instrucción CREATE SEQUENCE.\n\n"
			texto_ui += "[color=#ff99ff]Tu Misión:[/color]\nCrea una secuencia llamada sec_casos que inicie en 1.\n\n"
			if mostrar_pista:
				texto_ui += "[color=#888888]Pista:\nCREATE SEQUENCE sec_casos START WITH 1;[/color]"

		16:
			texto_ui += "[color=#ffff66]Contexto:[/color]\nQueremos consultar las vistas del sistema para auditar los roles que se encuentran activos en nuestra sesión actual.\n\n"
			if mostrar_tutorial:
				texto_ui += "[color=#ffff66]Tutorial:[/color]\nEl diccionario de datos de Oracle almacena metadatos del sistema. La vista USER_ROLE_PRIVS muestra los roles concedidos al usuario conectado.\n\n"
			texto_ui += "[color=#ff99ff]Tu Misión:[/color]\nConsulta la vista USER_ROLE_PRIVS.\n\n"
			if mostrar_pista:
				texto_ui += "[color=#888888]Pista:\nSELECT * FROM USER_ROLE_PRIVS;[/color]"

		17:
			texto_ui += "[color=#ffff66]Contexto:[/color]\nSe necesita otorgar un permiso específico de lectura sobre la tabla del caso a un rol operativo.\n\n"
			if mostrar_tutorial:
				texto_ui += "[color=#ffff66]Tutorial:[/color]\nPara conceder privilegios sobre objetos concretos a un rol, usamos GRANT seguido del permiso (SELECT), ON, la tabla, TO y el rol.\n\n"
			texto_ui += "[color=#ff99ff]Tu Misión:[/color]\nConcede SELECT sobre la tabla " + tabla_objetivo + " al rol " + rol_objetivo + ".\n\n"
			if mostrar_pista:
				texto_ui += "[color=#888888]Pista:\nGRANT SELECT ON " + tabla_objetivo + " TO " + rol_objetivo + ";[/color]"

		18:
			texto_ui += "[color=#ffff66]Contexto:[/color]\nUn rol operativo ya no formará parte de la estructura y debe ser eliminado permanentemente de la base de datos.\n\n"
			if mostrar_tutorial:
				texto_ui += "[color=#ffff66]Tutorial:[/color]\nDestruimos un rol del sistema mediante la sentencia DROP ROLE seguida del nombre del objeto.\n\n"
			texto_ui += "[color=#ff99ff]Tu Misión:[/color]\nElimina definitivamente el rol " + rol_objetivo + ".\n\n"
			if mostrar_pista:
				texto_ui += "[color=#888888]Pista:\nDROP ROLE " + rol_objetivo + ";[/color]"

		19:
			texto_ui += "[color=#ffff66]Contexto:[/color]\nAl eliminar un registro principal de la comisaría, los datos dependientes quedan huérfanos y comprometen la integridad referencial.\n\n"
			if mostrar_tutorial:
				texto_ui += "[color=#ffff66]Tutorial:[/color]\nConfiguramos llaves foráneas acompañadas de la regla ON DELETE CASCADE para automatizar la limpieza de registros hijos relacionados.\n\n"
			texto_ui += "[color=#ff99ff]Tu Misión:[/color]\nCrea una tabla dependiente con la cláusula ON DELETE CASCADE ligada a " + tabla_objetivo + ".\n\n"
			if mostrar_pista:
				texto_ui += "[color=#888888]Pista:\nCONSTRAINT fk FOREIGN KEY (id) REFERENCES " + tabla_objetivo + "(id) ON DELETE CASCADE[/color]"

		20:
			texto_ui += "[color=#ffff66]Contexto:[/color]\nÚltima auditoría de seguridad del sistema. Debes retirar el acceso completo a una cuenta de usuario problemática.\n\n"
			if mostrar_tutorial:
				texto_ui += "[color=#ffff66]Tutorial:[/color]\nRetiramos privilegios concedidos utilizando la instrucción REVOKE seguida del permiso y la entidad correspondiente.\n\n"
			texto_ui += "[color=#ff99ff]Tu Misión:[/color]\nRevoque el privilegio CREATE SESSION del usuario " + usuario_objetivo + ".\n\n"
			if mostrar_pista:
				texto_ui += "[color=#888888]Pista:\nREVOKE CREATE SESSION FROM " + usuario_objetivo + ";[/color]"

	texto_ui += "\n\n-----------------------------------\n"
	texto_ui += "[color=#00ffff][ Presiona 4 para Tutorial (" + ("ON" if mostrar_tutorial else "OFF") + ") ][/color]\n"
	texto_ui += "[color=#00ffff][ Presiona 5 para Pista (" + ("ON" if mostrar_pista else "OFF") + ") ][/color]"
	
	txt_expediente.text = texto_ui

# Generador de Casos Procedurales para Modo Oficial
func generar_caso_oficial():
	randomize()
	var lista_usuarios = ["Oficial_Rojas", "Agente_Perez", "Inspector_Mendez", "Cabo_Silva", "Teniente_Cruz", "Detective_Alanis"]
	var lista_tablas = ["persona", "agente", "sospechoso", "evidencia", "empleado", "bitacora", "multa"]
	usuario_objetivo = lista_usuarios.pick_random()
	tabla_objetivo = lista_tablas.pick_random()
	
	var tipo_reto = randi() % 4
	match tipo_reto:
		0:
			return {
				"contexto": "El fiscal general requiere una consulta abierta de todos los registros actuales en la tabla " + tabla_objetivo + ".",
				"mision": "Consulta todos los registros de la tabla " + tabla_objetivo + ".",
				"pista": "SELECT * FROM " + tabla_objetivo + ";",
				"validador": func(q): return "select" in q and tabla_objetivo in q
			}
		1:
			return {
				"contexto": "Se recolectó un nuevo elemento que debe registrarse de inmediato en la base de datos de la comisaría.",
				"mision": "Inserta un registro con id 99 en la tabla " + tabla_objetivo + ".",
				"pista": "INSERT INTO " + tabla_objetivo + " VALUES (99, 'Test');",
				"validador": func(q): return "insert into" in q and tabla_objetivo in q
			}
		2:
			return {
				"contexto": "El agente " + usuario_objetivo + " solicitó una corrección en los datos de la base central.",
				"mision": "Actualiza el registro con id 1 en la tabla " + tabla_objetivo + ".",
				"pista": "UPDATE " + tabla_objetivo + " SET nombre = 'Actualizado' WHERE id = 1;",
				"validador": func(q): return "update" in q and tabla_objetivo in q
			}
		3:
			return {
				"contexto": "Un archivo obsoleto o falso debe ser purgado de los registros oficiales de la comisaría.",
				"mision": "Elimina el registro con id 99 de la tabla " + tabla_objetivo + ".",
				"pista": "DELETE FROM " + tabla_objetivo + " WHERE id = 99;",
				"validador": func(q): return "delete from" in q and tabla_objetivo in q
			}

var caso_oficial_actual = {}

func cargar_interfaz_oficial():
	caso_oficial_actual = generar_caso_oficial()
	var texto_ui = "[b]MODO OFICIAL - RONDA " + str(ronda_oficial) + " (" + str(casos_resueltos_ronda + 1) + "/" + str(META_RONDA) + ")[/b]\n\n"
	texto_ui += "[color=#ffff66]Contexto:[/color]\n" + caso_oficial_actual["contexto"] + "\n\n"
	texto_ui += "[color=#ff99ff]Tu Misión Procedural:[/color]\n" + caso_oficial_actual["mision"] + "\n\n"
	if mostrar_pista:
		texto_ui += "[color=#888888]Pista:\n" + caso_oficial_actual["pista"] + "[/color]"
	
	texto_ui += "\n\n-----------------------------------\n"
	texto_ui += "[color=#00ffff][ Presiona 5 para Pista (" + ("ON" if mostrar_pista else "OFF") + ") ][/color]"
	txt_expediente.text = texto_ui

# Detección de teclas 4 y 5 para alternar ayudas
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_4 and estado_actual == "detective":
			mostrar_tutorial = not mostrar_tutorial
			cargar_interfaz_mision()
		elif event.keycode == KEY_5:
			mostrar_pista = not mostrar_pista
			if estado_actual == "detective": cargar_interfaz_mision()
			elif estado_actual == "oficial": cargar_interfaz_oficial()

func inicializar_db():
	var sqlite_path = "res://addons/godot-sqlite/bin/sqlite.gd"
	if FileAccess.file_exists("res://addons/godot-sqlite/bin/sqlite.gd"):
		var script_sqlite = load("res://addons/godot-sqlite/bin/sqlite.gd")
		if script_sqlite:
			db = script_sqlite.new()
	
	if db == null:
		var plugin_sqlite = load("res://addons/godot-sqlite/godot-sqlite.gd")
		if plugin_sqlite and plugin_sqlite.has_method("new"):
			db = plugin_sqlite.new()

	if db != null:
		DirAccess.make_dir_absolute("res://base_datos")
		if "path" in db:
			db.path = "res://base_datos/juego_sql.db"
		if db.has_method("open_db"):
			db.open_db()
		txt_resultados.text = "[color=#00ff66]Base de datos lista. Selecciona un modo de juego.[/color]"
	else:
		txt_resultados.text = "[color=#00ff66]Sistema de simulación SQL activo.[/color]"

func _on_ejecutar_pressed():
	var query = txt_consola.text.strip_edges()
	
	if query == "":
		txt_resultados.text = "[color=#ff3333]Error: La consola está vacía, detective. Escribe una sentencia SQL.[/color]"
		return
		
	var q_lower = query.to_lower()
	
	if estado_actual == "menu":
		if q_lower == "modo 1" or q_lower == "1":
			estado_actual = "detective"
			nivel_actual = 1
			generar_caso_procedural()
			txt_resultados.text = "[color=#00ff66]Iniciando Academia de Detective...[/color]"
		elif (q_lower == "modo 2" or q_lower == "2") and modo_oficial_desbloqueado:
			estado_actual = "oficial"
			ronda_oficial = 1
			casos_resueltos_ronda = 0
			cargar_interfaz_oficial()
			txt_resultados.text = "[color=#00ff66]Entrando al campo de operaciones Modo Oficial...[/color]"
		else:
			txt_resultados.text = "[color=#ff3333]Comando inválido. Escribe '1' o '2' para seleccionar modo.[/color]"
		return
		
	elif estado_actual == "oficial":
		if caso_oficial_actual["validador"].call(q_lower):
			casos_resueltos_ronda += 1
			if casos_resueltos_ronda >= META_RONDA:
				ronda_oficial += 1
				casos_resueltos_ronda = 0
				txt_resultados.text = "[color=#00ff66]¡Ronda de campo superada con éxito![/color]"
			else:
				txt_resultados.text = "[color=#00ff66]¡Caso resuelto en el campo operativo![/color]"
			txt_consola.text = ""
			await get_tree().create_timer(1.5).timeout
			cargar_interfaz_oficial()
		else:
			txt_resultados.text = "[color=#ff3333]Rechazado en campo:[/color] La instrucción no resolvió la petición."
		return

	# Validador inteligente adaptado al Modo Detective (Niveles 1 al 20)
	match nivel_actual:
		1:
			if "create user" in q_lower and usuario_objetivo.to_lower() in q_lower:
				avanzar_nivel("¡Excelente! Usuario " + usuario_objetivo + " registrado correctamente.")
			else:
				txt_resultados.text = "[color=#ff3333]Rechazado:[/color] Usa CREATE USER para registrar a [color=#ffff66]" + usuario_objetivo + "[/color]."
		2:
			if "grant" in q_lower and "session" in q_lower and usuario_objetivo.to_lower() in q_lower:
				avanzar_nivel("¡Perfecto! Privilegio de sesión otorgado sin error ORA-01045.")
			else:
				txt_resultados.text = "[color=#ff3333]Rechazado:[/color] Otorga CREATE SESSION a [color=#ffff66]" + usuario_objetivo + "[/color]."
		3:
			if "grant" in q_lower and "session" in q_lower and "with admin option" in q_lower and usuario_objetivo.to_lower() in q_lower:
				avanzar_nivel("¡Muy bien! Permiso delegado con WITH ADMIN OPTION.")
			else:
				txt_resultados.text = "[color=#ff3333]Rechazado:[/color] Falta la cláusula WITH ADMIN OPTION."
		4:
			if "grant" in q_lower and "unlimited tablespace" in q_lower and usuario_objetivo.to_lower() in q_lower:
				avanzar_nivel("¡Excelente! Espacio ilimitado concedido.")
			else:
				txt_resultados.text = "[color=#ff3333]Rechazado:[/color] Otorga UNLIMITED TABLESPACE a [color=#ffff66]" + usuario_objetivo + "[/color]."
		5:
			if "alter user" in q_lower and usuario_objetivo.to_lower() in q_lower and cuota_objetivo.to_lower() in q_lower:
				avanzar_nivel("¡Cuota de " + cuota_objetivo + " asignada con éxito a " + usuario_objetivo + "!")
			else:
				txt_resultados.text = "[color=#ff3333]Rechazado:[/color] Asigna la cuota exacta de [color=#ffff66]" + cuota_objetivo + "[/color]."
		6:
			if "alter user" in q_lower and usuario_objetivo.to_lower() in q_lower and "lock" in q_lower:
				avanzar_nivel("¡Cuenta bloqueada correctamente!")
			else:
				txt_resultados.text = "[color=#ff3333]Rechazado:[/color] Usa ALTER USER ... ACCOUNT LOCK."
		7:
			if "alter user" in q_lower and usuario_objetivo.to_lower() in q_lower and "unlock" in q_lower:
				avanzar_nivel("¡Cuenta desbloqueada con éxito!")
			else:
				txt_resultados.text = "[color=#ff3333]Rechazado:[/color] Usa ALTER USER ... ACCOUNT UNLOCK."
		8:
			if "create role" in q_lower and rol_objetivo.to_lower() in q_lower:
				avanzar_nivel("¡Rol " + rol_objetivo + " creado con éxito!")
			else:
				txt_resultados.text = "[color=#ff3333]Rechazado:[/color] Crea el rol con CREATE ROLE [color=#ffff66]" + rol_objetivo + "[/color]."
		9:
			if "grant" in q_lower and rol_objetivo.to_lower() in q_lower and usuario_objetivo.to_lower() in q_lower:
				avanzar_nivel("¡Rol asignado al usuario correctamente!")
			else:
				txt_resultados.text = "[color=#ff3333]Rechazado:[/color] Asigna el rol con GRANT ... TO."
		10:
			if "create table" in q_lower and tabla_objetivo.to_lower() in q_lower and "primary key" in q_lower:
				avanzar_nivel("¡Tabla " + tabla_objetivo + " estructurada perfectamente!")
			else:
				txt_resultados.text = "[color=#ff3333]Rechazado:[/color] Define la tabla [color=#ffff66]" + tabla_objetivo + "[/color] con PRIMARY KEY."
		11:
			if "insert into" in q_lower and tabla_objetivo.to_lower() in q_lower:
				avanzar_nivel("¡Registro insertado con éxito!")
			else:
				txt_resultados.text = "[color=#ff3333]Rechazado:[/color] Usa INSERT INTO en la tabla [color=#ffff66]" + tabla_objetivo + "[/color]."
		12:
			if "select" in q_lower and tabla_objetivo.to_lower() in q_lower:
				avanzar_nivel("¡Consulta ejecutada correctamente!")
			else:
				txt_resultados.text = "[color=#ff3333]Rechazado:[/color] Usa SELECT * FROM [color=#ffff66]" + tabla_objetivo + "[/color]."
		13:
			if "update" in q_lower and tabla_objetivo.to_lower() in q_lower:
				avanzar_nivel("¡Registro actualizado con éxito!")
			else:
				txt_resultados.text = "[color=#ff3333]Rechazado:[/color] Usa UPDATE sobre la tabla [color=#ffff66]" + tabla_objetivo + "[/color]."
		14:
			if "delete from" in q_lower and tabla_objetivo.to_lower() in q_lower:
				avanzar_nivel("¡Registro eliminado de la base de datos!")
			else:
				txt_resultados.text = "[color=#ff3333]Rechazado:[/color] Usa DELETE FROM sobre la tabla [color=#ffff66]" + tabla_objetivo + "[/color]."
		15:
			if "create sequence" in q_lower:
				avanzar_nivel("¡Secuencia creada correctamente!")
			else:
				txt_resultados.text = "[color=#ff3333]Rechazado:[/color] Crea la secuencia usando CREATE SEQUENCE."
		16:
			if "select" in q_lower and "user_role_privs" in q_lower:
				avanzar_nivel("¡Diccionario de datos consultado con éxito!")
			else:
				txt_resultados.text = "[color=#ff3333]Rechazado:[/color] Consulta la vista USER_ROLE_PRIVS."
		17:
			if "grant" in q_lower and tabla_objetivo.to_lower() in q_lower and rol_objetivo.to_lower() in q_lower:
				avanzar_nivel("¡Permiso sobre objeto concedido al rol!")
			else:
				txt_resultados.text = "[color=#ff3333]Rechazado:[/color] Usa GRANT SELECT ON [color=#ffff66]" + tabla_objetivo + "[/color] TO [color=#ffff66]" + rol_objetivo + "[/color]."
		18:
			if "drop role" in q_lower and rol_objetivo.to_lower() in q_lower:
				avanzar_nivel("¡Rol eliminado permanentemente del sistema!")
			else:
				txt_resultados.text = "[color=#ff3333]Rechazado:[/color] Usa DROP ROLE [color=#ffff66]" + rol_objetivo + "[/color]."
		19:
			if "on delete cascade" in q_lower:
				avanzar_nivel("¡Integridad referencial en cascada configurada!")
			else:
				txt_resultados.text = "[color=#ff3333]Rechazado:[/color] Integra la cláusula ON DELETE CASCADE."
		20:
			if "revoke" in q_lower and "session" in q_lower and usuario_objetivo.to_lower() in q_lower:
				modo_oficial_desbloqueado = true
				txt_resultados.text = "[color=#00ff66]🏆 ¡GRADUACIÓN EXITOSA! 🏆[/color]\nClave de Ascenso Obtenida: [b]" + CLAVE_ASCENSO + "[/b]\n¡Modo Oficial desbloqueado en el menú principal!"
				await get_tree().create_timer(4.0).timeout
				mostrar_menu_principal()
			else:
				txt_resultados.text = "[color=#ff3333]Rechazado:[/color] Usa REVOKE CREATE SESSION FROM [color=#ffff66]" + usuario_objetivo + "[/color]."

func avanzar_nivel(mensaje_exito: String):
	txt_resultados.text = "[color=#00ff66]" + mensaje_exito + "[/color]\nNueva petición enviada a la terminal..."
	nivel_actual += 1
	txt_consola.text = ""
	await get_tree().create_timer(2.0).timeout
	
	if nivel_actual <= TOTAL_NIVELES:
		generar_caso_procedural()
		txt_resultados.text = "[color=#00ff66]¡Nueva petición enviada a la terminal![/color]"
	else:
		nivel_actual = TOTAL_NIVELES
