extends Node

var discord := DiscordRPC.new()
var application_id: int = 1063326299860504646
var timestamp = OS.get_unix_time()

func _ready() -> void:
	add_child(discord)
	discord.connect("rpc_ready", self, "_on_discord_ready")
	discord.establish_connection(application_id)
	#print("test")


func _on_discord_ready(user: Dictionary) -> void:
	var presence := RichPresence.new()
	
	presence.details = "Currently in:"
	presence.state = "Main Menu"

	presence.large_image_key = "icon"
	presence.large_image_text = "Anna Bananna"
	
	presence.start_timestamp = timestamp #OS.get_unix_time()
	
	discord.get_module("RichPresence").update_presence(presence)
	
func updateLevel(levelName, altDesc = "Currently in:"):
	var presence := RichPresence.new()
	presence.details = altDesc
	presence.state = levelName
	
	if (pg.playerCharacter[0].to_lower() == "darla"):
		presence.large_image_key = "unknown"
		presence.large_image_text = "Playing as: ???"
	else:
		presence.large_image_key = pg.playerCharacter[0].to_lower()
		presence.large_image_text = "Playing as: " + pg.playerCharacter[0]
	
	presence.start_timestamp = timestamp
	
	discord.get_module("RichPresence").update_presence(presence)
