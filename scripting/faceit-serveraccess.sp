#pragma newdecls required
#pragma semicolon 1

#include <sourcemod>
#include <faceit-api>

#define PLUGIN_VERSION "1.0.0"

ConVar convar_Enabled;
ConVar convar_Required_Registered;
ConVar convar_Required_Level;
ConVar convar_Required_Elo;

public Plugin myinfo = {
	name = "[ANY] FACEIT - Server Access",
	author = "Drixevel",
	description = "A plugin which kicks players automatically based on if they don't have the proper FACEIT level.",
	version = PLUGIN_VERSION,
	url = "https://drixevel.dev/"
};

public void OnPluginStart() {
	LoadTranslations("faceit_serveraccess.phrases");
	
	CreateConVar("sm_faceit_serveraccess_version", PLUGIN_VERSION, "Version control for this plugin.", FCVAR_DONTRECORD);
	convar_Enabled = CreateConVar("sm_faceit_serveraccess_enabled", "1", "Should this plugin be enabled or disabled?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	convar_Required_Registered = CreateConVar("sm_faceit_serveraccess_required_registered", "1", "Are they required to be registered to join the server?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	convar_Required_Level = CreateConVar("sm_faceit_serveraccess_required_level", "5", "What's the required FACEIT level to join this server?\n(0 = disabled)", FCVAR_NOTIFY, true, 0.0);
	convar_Required_Elo = CreateConVar("sm_faceit_serveraccess_required_elo", "0", "What's the required FACEIT elo to join this server?\n(0 = disabled)", FCVAR_NOTIFY, true, 0.0);
	AutoExecConfig();
}

public void OnGetFACEITData(int client, bool registered, JSONObject obj) {
	if (!convar_Enabled.BoolValue) {
		return;
	}

	if (convar_Required_Registered.BoolValue && !registered) {
		KickClient(client, "%T", "not registered kick", client);
		LogMessage("[FACEIT] Kicked client %d for not being registered on FACEIT.", client);
		return;
	}

	if (convar_Required_Level.IntValue > 0 && FACEIT_GetSkillLevel(client) < convar_Required_Level.IntValue) {
		KickClient(client, "%T", "too low level kick", client, convar_Required_Level.IntValue);
		LogMessage("[FACEIT] Kicked client %d for not being level %d on FACEIT.", client, convar_Required_Level.IntValue);
		return;
	}

	if (convar_Required_Elo.IntValue > 0 && FACEIT_GetElo(client) < convar_Required_Elo.IntValue) {
		KickClient(client, "%T", "", client, convar_Required_Elo.IntValue);
		LogMessage("[FACEIT] Kicked client %d for not having an elo of %d on FACEIT.", client, convar_Required_Elo.IntValue);
	}
}