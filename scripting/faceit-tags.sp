#pragma newdecls required
#pragma semicolon 1

#include <sourcemod>
#include <faceit-api>
#include <chat-processor>

#define PLUGIN_VERSION "1.0.0"

ConVar convar_Enabled;

public Plugin myinfo = {
	name = "[ANY] FACEIT - Tags",
	author = "Drixevel",
	description = "A plugin which automatically adds tags to players based on their FACEIT level and elo.",
	version = PLUGIN_VERSION,
	url = "https://drixevel.dev/"
};

public void OnPluginStart() {
	CreateConVar("sm_faceit_tags_version", PLUGIN_VERSION, "Version control for this plugin.", FCVAR_DONTRECORD);
	convar_Enabled = CreateConVar("sm_faceit_tags_enabled", "1", "Should this plugin be enabled or disabled?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	AutoExecConfig();
}

public Action CP_OnChatMessage(int& author, ArrayList recipients, char[] flagstring, char[] name, char[] message, bool & processcolors, bool & removecolors) {
	if (!convar_Enabled.BoolValue) {
		return Plugin_Continue;
	}

	if (!FACEIT_IsRegistered(author)) {
		return Plugin_Continue;
	}

	Format(name, MAXLENGTH_NAME, "[FACEIT Level: %i] %s", FACEIT_GetSkillLevel(author), name);
	return Plugin_Changed;
}