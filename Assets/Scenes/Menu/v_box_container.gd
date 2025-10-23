# main_menu.gd
extends Control

# --- Arraste a TUA CENA de configurações (.tscn) para esta variável no Inspetor ---
@export var settings_menu_scene: PackedScene

@onready var menu_principal_container = $MenuPrincipalContainer
@onready var audio_player = $AudioStreamPlayer

func _ready():
	# Garante que a música toque no canal "Musica"
	var musica_bus_idx = AudioServer.get_bus_index("Musica")
	if musica_bus_idx != -1:
		audio_player.bus = "Musica"
	audio_player.play()

func _on_jogar_pressed():
	get_tree().change_scene_to_file("res://Assets/Scenes/Areas/area_1.tscn")

func _on_configurações_pressed():
	# Verifica se já não há uma instância do menu de configurações aberta
	if get_node_or_null("SettingsMenuUI") != null:
		return

	# 1. Cria uma nova instância da cena de configurações
	var settings_instance = settings_menu_scene.instantiate()
	settings_instance.name = "SettingsMenuUI" # Dá um nome à instância
	
	# 2. Adiciona a nova cena ao menu principal
	add_child(settings_instance)
	
	# 3. Esconde os botões do menu principal
	menu_principal_container.hide()
	
	# 4. Conecta um sinal para saber quando as configurações fecharam
	settings_instance.closed.connect(_on_settings_menu_closed)

func _on_sair_pressed():
	get_tree().quit()

# Esta função é chamada quando a cena de configurações emite o sinal "closed"
func _on_settings_menu_closed():
	# Mostra os botões do menu principal novamente
	menu_principal_container.show()
