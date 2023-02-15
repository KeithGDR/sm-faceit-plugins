#pragma newdecls required
#pragma semicolon 1

#include <sourcemod>

#define PLUGIN_VERSION "1.0.0"

ConVar convar_Enabled;

public Plugin myinfo = {
	name = "[ANY] FACEIT - Autobalance",
	author = "Drixevel",
	description = "A plugin which autobalances teams based on their FACEIT elo.",
	version = PLUGIN_VERSION,
	url = "https://drixevel.dev/"
};

public void OnPluginStart() {
	CreateConVar("sm_faceit_autobalance_version", PLUGIN_VERSION, "Version control for this plugin.", FCVAR_DONTRECORD);
	convar_Enabled = CreateConVar("sm_faceit_autobalance_enabled", "1", "Should this plugin be enabled or disabled?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	AutoExecConfig();

	HookEvent("round_start", Event_OnRoundStart);
}

public void Event_OnRoundStart(Event event, const char[] name, bool dontBroadcast) {
	if (!convar_Enabled.BoolValue) {
		return;
	}

	
}