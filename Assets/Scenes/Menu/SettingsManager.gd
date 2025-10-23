# SettingsManager.gd (DEVE SER CONFIGURADO COMO AUTOLOAD/SINGLETON)
extends Node

# Nome do ficheiro de salvamento
const SETTINGS_FILE = "user://game_settings.cfg"

# Configurações padrão
const DEFAULT_SETTINGS = {
	"audio": {
		"musica_volume_db": 0.0, # 0dB é o volume máximo
		"sfx_volume_db": 0.0,
	},
	"display": {
		"fullscreen": false,
		"resolution_x": 1920,
		"resolution_y": 1080,
	}
}

# Lista de resoluções suportadas
const RESOLUTIONS = [
	Vector2i(1920, 1080), # Full HD
	Vector2i(1280, 720),  # HD
	Vector2i(1600, 900)
]

var config = ConfigFile.new()

# A função _ready do Autoload é chamada uma vez quando o jogo inicia
func _ready():
	load_settings()

# ----------------- FUNÇÕES DE APLICAÇÃO GERAL -----------------

func set_volume(bus_name: String, volume_db: float):
	var bus_index = AudioServer.get_bus_index(bus_name)
	if bus_index != -1:
		AudioServer.set_bus_volume_db(bus_index, volume_db)

func set_fullscreen(enable: bool):
	if enable:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func set_resolution(res: Vector2i):
	# Só altera a resolução em plataformas de computador
	if OS.get_name() in ["Windows", "macOS", "X11"]:
		DisplayServer.window_set_size(res)
		# Centraliza a janela após a alteração
		DisplayServer.window_set_position(DisplayServer.screen_get_size() / 2 - res / 2)

# ----------------- FUNÇÕES DE SALVAMENTO E CARREGAMENTO -----------------

func load_settings():
	var err = config.load(SETTINGS_FILE)
	# Se o ficheiro não existir, aplica as configurações padrão
	if err != OK:
		apply_default_settings()
		return

	# Carrega os valores do ficheiro, usando os padrões como fallback
	var music_vol = config.get_value("audio", "musica_volume_db", DEFAULT_SETTINGS.audio.musica_volume_db)
	var sfx_vol = config.get_value("audio", "sfx_volume_db", DEFAULT_SETTINGS.audio.sfx_volume_db)
	set_volume("Musica", music_vol)
	set_volume("SFX", sfx_vol)

	var fullscreen = config.get_value("display", "fullscreen", DEFAULT_SETTINGS.display.fullscreen)
	set_fullscreen(fullscreen)

	var res_x = config.get_value("display", "resolution_x", DEFAULT_SETTINGS.display.resolution_x)
	var res_y = config.get_value("display", "resolution_y", DEFAULT_SETTINGS.display.resolution_y)
	set_resolution(Vector2i(res_x, res_y))


func save_settings():
	# Obtém os valores atuais do jogo e guarda-os
	config.set_value("audio", "musica_volume_db", AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Musica")))
	config.set_value("audio", "sfx_volume_db", AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX")))
	
	config.set_value("display", "fullscreen", DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	var current_res = DisplayServer.window_get_size()
	config.set_value("display", "resolution_x", current_res.x)
	config.set_value("display", "resolution_y", current_res.y)

	var err = config.save(SETTINGS_FILE)
	if err != OK:
		push_error("Erro ao salvar configurações: ", err)

func apply_default_settings():
	# Aplica os valores definidos na constante DEFAULT_SETTINGS
	set_volume("Musica", DEFAULT_SETTINGS.audio.musica_volume_db)
	set_volume("SFX", DEFAULT_SETTINGS.audio.sfx_volume_db)
	set_fullscreen(DEFAULT_SETTINGS.display.fullscreen)
	set_resolution(Vector2i(DEFAULT_SETTINGS.display.resolution_x, DEFAULT_SETTINGS.display.resolution_y))
