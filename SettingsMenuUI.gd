# SettingsMenuUI.gd
extends Control

# Sinal que avisará o menu principal quando esta cena fechar
signal closed

# Referências aos nós da UI (verifique se os nomes correspondem à sua cena)
@onready var music_slider = $VBoxContainer/MusicaSlider
@onready var efeitos_slider = $VBoxContainer/EfeitosSlider
@onready var fullscreen_check = $VBoxContainer/FullscreenCheck
@onready var resolution_button = $VBoxContainer/ResolutionButton
@onready var voltar_button = $VBoxContainer/VoltarButton

# Usa a constante de resoluções diretamente do nosso Singleton
const RESOLUTIONS = SettingsManager.RESOLUTIONS

func _ready():
	# Configura a UI com os valores atuais
	_update_ui_from_settings()

	# Conecta os sinais da UI às funções deste script
	music_slider.value_changed.connect(_on_music_slider_value_changed)
	efeitos_slider.value_changed.connect(_on_efeitos_slider_value_changed)
	fullscreen_check.toggled.connect(_on_fullscreen_check_toggled)
	resolution_button.item_selected.connect(_on_resolution_button_item_selected)
	voltar_button.pressed.connect(_on_voltar_button_pressed)

func _update_ui_from_settings():
	# Os sliders de volume no Godot vão de -80 (mudo) a 0 (máximo padrão)
	music_slider.min_value = -80
	music_slider.max_value = 0
	efeitos_slider.min_value = -80
	efeitos_slider.max_value = 0
	
	# --- CORREÇÃO APLICADA AQUI ---
	# Adicionamos um valor padrão (o terceiro argumento) a cada chamada get_value.
	# Se o valor não for encontrado no ficheiro, ele usará este valor em vez de dar erro.
	music_slider.value = SettingsManager.config.get_value("audio", "musica_volume_db", 0.0)
	efeitos_slider.value = SettingsManager.config.get_value("audio", "sfx_volume_db", 0.0)
	fullscreen_check.button_pressed = SettingsManager.config.get_value("display", "fullscreen", false)
	
	# Configura as opções de resolução
	resolution_button.clear()
	if OS.get_name() in ["Windows", "macOS", "X11"]:
		for res in RESOLUTIONS:
			resolution_button.add_item(str(res.x) + "x" + str(res.y))
			
		var current_res = DisplayServer.window_get_size()
		for i in range(RESOLUTIONS.size()):
			if RESOLUTIONS[i] == current_res:
				resolution_button.select(i)
				break
	else:
		# Se não for PC, esconde as opções de resolução
		resolution_button.visible = false
		# Assumindo que o teu label de gráficos se chama LabelGraficos
		var label_graficos = $VBoxContainer/LabelGraficos
		if label_graficos:
			label_graficos.visible = false

# --- Funções que respondem à interação do utilizador ---

func _on_music_slider_value_changed(value_db):
	SettingsManager.set_volume("Musica", value_db)

func _on_efeitos_slider_value_changed(value_db):
	SettingsManager.set_volume("SFX", value_db)

func _on_fullscreen_check_toggled(toggled_on):
	SettingsManager.set_fullscreen(toggled_on)

func _on_resolution_button_item_selected(index):
	var selected_res = RESOLUTIONS[index]
	SettingsManager.set_resolution(selected_res)

func _on_voltar_button_pressed():
	# 1. Salva todas as configurações
	SettingsManager.save_settings()
	# 2. Emite o sinal para avisar o menu principal que deve fechar
	emit_signal("closed")
	# 3. Destrói esta cena
	queue_free()
