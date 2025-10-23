# main_menu.gd (VERSÃO FINAL COMPATÍVEL COM PC E MOBILE)
extends Control

# --- Referências aos teus nós ---
@onready var menu_principal_container = $MenuPrincipalContainer
@onready var configuracoes_container = $configuracoescontainer
@onready var audio_player = $AudioStreamPlayer

# Referências aos controlos de configurações
@onready var musica_slider = $configuracoescontainer/VBoxContainer/MusicaSlider
@onready var efeitos_slider = $configuracoescontainer/VBoxContainer/EfeitosSlider
@onready var fullscreen_check = $configuracoescontainer/VBoxContainer/FullscreenCheck
@onready var resolution_button = $configuracoescontainer/VBoxContainer/ResolutionButton
@onready var voltar_button = $configuracoescontainer/VBoxContainer/VoltarButton
@onready var sair_button = $MenuPrincipalContainer/sair

# Lista de resoluções (apenas para PC)
var resolutions = [Vector2i(1920, 1080), Vector2i(1280, 720), Vector2i(1600, 900)]

func _ready():
	# Garante que o painel de configurações comece escondido
	configuracoes_container.hide()

	# Toca a música no canal certo
	audio_player.bus = "Musica"
	audio_player.play()
	
	# Liga os sinais dos controlos de configurações às funções deste script
	musica_slider.value_changed.connect(_on_musica_slider_value_changed)
	efeitos_slider.value_changed.connect(_on_efeitos_slider_value_changed)
	fullscreen_check.toggled.connect(_on_fullscreen_check_toggled)
	resolution_button.item_selected.connect(_on_resolution_button_item_selected)
	voltar_button.pressed.connect(_on_voltar_button_pressed)
	
	# --- LÓGICA DE ADAPTAÇÃO PARA MOBILE ---
	# Verifica se estamos a correr num sistema operativo de computador
	var is_desktop = OS.get_name() in ["Windows", "macOS", "X11"]
	
	if not is_desktop:
		# Se não for PC (ou seja, é mobile), esconde as opções irrelevantes
		fullscreen_check.visible = false
		resolution_button.visible = false
		sair_button.visible = false
		
		# Tenta encontrar e esconder os labels associados, se existirem
		var label_efeitos = $configuracoescontainer/VBoxContainer.get_node_or_null("Labelefeitos")
		if label_efeitos:
			# Apenas como exemplo, podes esconder o que quiseres
			pass # Não vamos esconder os labels de volume
			
	# Carrega as configurações guardadas ou define os padrões
	carregar_configuracoes()

# --- Funções dos Botões do Menu Principal ---

func _on_jogar_pressed():
	get_tree().change_scene_to_file("res://Assets/Scenes/Areas/area_1.tscn")

func _on_configurações_pressed():
	menu_principal_container.hide()
	configuracoes_container.show()

func _on_sair_pressed():
	get_tree().quit()

# --- Função do Botão "Voltar" das Configurações ---
func _on_voltar_button_pressed():
	configuracoes_container.hide()
	menu_principal_container.show()
	guardar_configuracoes()

# --- Funções de Lógica das Configurações ---

func _on_musica_slider_value_changed(value_db):
	if value_db == -30:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Musica"), -80)
	else:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Musica"), value_db)

func _on_efeitos_slider_value_changed(value_db):
	if value_db == -30:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), -80)
	else:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), value_db)

func _on_fullscreen_check_toggled(toggled_on):
	if OS.get_name() in ["Windows", "macOS", "X11"]: # Garante que só funciona em PC
		if toggled_on:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_resolution_button_item_selected(index):
	if OS.get_name() in ["Windows", "macOS", "X11"]: # Garante que só funciona em PC
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		fullscreen_check.button_pressed = false
		DisplayServer.window_set_size(resolutions[index])

# --- Funções de Guardar e Carregar ---

func guardar_configuracoes():
	var config = ConfigFile.new()
	config.set_value("audio", "musica_volume_db", musica_slider.value)
	config.set_value("audio", "sfx_volume_db", efeitos_slider.value)
	
	if OS.get_name() in ["Windows", "macOS", "X11"]: # Só guarda as configs de display no PC
		config.set_value("display", "fullscreen", fullscreen_check.button_pressed)
		config.set_value("display", "resolucao_idx", resolution_button.selected)
	
	config.save("user://settings.cfg")

func carregar_configuracoes():
	var config = ConfigFile.new()
	# Prepara os sliders
	musica_slider.min_value = -30
	musica_slider.max_value = 5
	efeitos_slider.min_value = -30
	efeitos_slider.max_value = 5
	
	# Preenche as resoluções (apenas em PC)
	if OS.get_name() in ["Windows", "macOS", "X11"]:
		resolution_button.clear()
		for res in resolutions:
			resolution_button.add_item(str(res.x) + "x" + str(res.y))
	
	if config.load("user://settings.cfg") != OK:
		# Se não houver ficheiro, define os valores iniciais da UI
		musica_slider.value = 0.0
		efeitos_slider.value = 0.0
		if OS.get_name() in ["Windows", "macOS", "X11"]:
			fullscreen_check.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
			var current_res = DisplayServer.window_get_size()
			for i in range(resolutions.size()):
				if resolutions[i] == current_res:
					resolution_button.select(i)
					break
		return

	# Se houver ficheiro, carrega e aplica os valores
	musica_slider.value = config.get_value("audio", "musica_volume_db", 0.0)
	efeitos_slider.value = config.get_value("audio", "sfx_volume_db", 0.0)
	_on_musica_slider_value_changed(musica_slider.value)
	_on_efeitos_slider_value_changed(efeitos_slider.value)

	if OS.get_name() in ["Windows", "macOS", "X11"]:
		fullscreen_check.button_pressed = config.get_value("display", "fullscreen", false)
		_on_fullscreen_check_toggled(fullscreen_check.button_pressed)
		var res_idx = config.get_value("display", "resolucao_idx", 0)
		resolution_button.select(res_idx)
		_on_resolution_button_item_selected(res_idx)
