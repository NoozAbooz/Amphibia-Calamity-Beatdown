extends Node

var discord := DiscordRPC.new()
var application_id: int = 983557502568374282

func _ready() -> void:
	add_child(discord)
	discord.connect("rpc_ready", self, "_on_discord_ready")
	discord.establish_connection(application_id)
	#print("test")


func _on_discord_ready(user: Dictionary) -> void:
	var presence := RichPresence.new()
	presence.details = "In main menu"
	presence.state = "afk"
	
	presence.details = "Currently on:"
	presence.state = "Main Menu"

	presence.large_image_key = "icon"
	presence.large_image_text = ":smug_anne:"
	#presence.small_image_key = "mantis_stand"
	#presence.small_image_text = "Angy mantis"
	
	presence.start_timestamp = OS.get_unix_time()
	
	discord.get_module("RichPresence").update_presence(presence)
