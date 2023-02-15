#pragma newdecls required
#pragma semicolon 1

#include <sourcemod>
#include <faceit-api>

ConVar convar_Enabled;
ConVar convar_Required_Level;

public Plugin myinfo = {
	name = "[ANY] FACEIT - Server Access",
	author = "Drixevel",
	description = "A plugin which kicks players automatically based on if they don't have the proper FACEIT level.",
	version = "1.0.0",
	url = "https://drixevel.dev/"
};

public void OnPluginStart() {
	CreateConVar("sm_faceit_serveraccess_version", "1.0.0", "Version control for this plugin.", FCVAR_DONTRECORD);
	convar_Enabled = CreateConVar("sm_faceit_serveraccess_enabled", "1", "Should this plugin be enabled or disabled?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	convar_Required_Level = CreateConVar("sm_faceit_serveraccess_required_level", "5", "What's the required FACEIT level to join this server?", FCVAR_NOTIFY, true, 0.0);
	AutoExecConfig();
}

public void OnGetFACEITData(int client, JSONObject obj) {
	if (!convar_Enabled.BoolValue) {
		return;
	}

	if (FACEIT_GetSkillLevel(client) < convar_Required_Level.IntValue) {
		KickClient(client, "You must be FACEIT level %d or higher to join this server.", convar_Required_Level.IntValue);
	}
}