#pragma newdecls required
#pragma semicolon 1

#include <sourcemod>
#include <faceit-api>
#include <colors>

#define PLUGIN_VERSION "1.0.1"

ConVar convar_Enabled;
ConVar convar_Command_Level;
ConVar convar_Command_Elo;

public Plugin myinfo = {
	name = "[ANY] FACEIT - Commands",
	author = "Drixevel",
	description = "A plugin which allows players to access FACEIT commands.",
	version = PLUGIN_VERSION,
	url = "https://drixevel.dev/"
};

public void OnPluginStart() {
	LoadTranslations("common.phrases");
	LoadTranslations("faceit_commands.phrases");

	CreateConVar("sm_faceit_commands_version", PLUGIN_VERSION, "Version control for this plugin.", FCVAR_DONTRECORD);
	convar_Enabled = CreateConVar("sm_faceit_commands_enabled", "1", "Should this plugin be enabled or disabled?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	convar_Command_Level = CreateConVar("sm_faceit_commands_enabled_level", "1", "Should the level command be enabled?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	convar_Command_Elo = CreateConVar("sm_faceit_commands_enabled_elo", "1", "Should the elo command be enabled?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	AutoExecConfig();

	RegConsoleCmd("sm_level", Command_Level, "Displays your FACEIT level.");
	RegConsoleCmd("sm_skilllevel", Command_Level, "Displays your FACEIT level.");
	RegConsoleCmd("sm_elo", Command_Elo, "Displays your FACEIT elo.");
}

public Action Command_Level(int client, int args) {
	if (!convar_Enabled.BoolValue || !convar_Command_Level.BoolValue) {
		return Plugin_Continue;
	}

	if (args == 0) {
		char command[64];
		GetCmdArg(0, command, sizeof(command));
		CReplyToCommand(client, "%T", "level usage", client, command);
		return Plugin_Handled;
	}

	char pattern[MAX_TARGET_LENGTH];
	GetCmdArgString(pattern, sizeof(pattern));

	int target = FindTarget(client, pattern, true, false);

	if (target < 1) {
		ReplyToTargetError(client, COMMAND_TARGET_NONE);
		return Plugin_Handled;
	}

	if (!FACEIT_IsRegistered(target)) {
		CReplyToCommand(client, "%T", "not registered", client, target);
		return Plugin_Handled;
	}

	CReplyToCommand(client, "%T", "show level", client, target, FACEIT_GetSkillLevel(target));

	return Plugin_Handled;
}

public Action Command_Elo(int client, int args) {
	if (!convar_Enabled.BoolValue || !convar_Command_Elo.BoolValue) {
		return Plugin_Continue;
	}

	if (args == 0) {
		char command[64];
		GetCmdArg(0, command, sizeof(command));
		CReplyToCommand(client, "%T", "elo usage", client, command);
		return Plugin_Handled;
	}

	char pattern[MAX_TARGET_LENGTH];
	GetCmdArgString(pattern, sizeof(pattern));

	int target = FindTarget(client, pattern, true, false);

	if (target < 1) {
		ReplyToTargetError(client, COMMAND_TARGET_NONE);
		return Plugin_Handled;
	}

	if (!FACEIT_IsRegistered(target)) {
		CReplyToCommand(client, "%T", "not registered", client, target);
		return Plugin_Handled;
	}

	CReplyToCommand(client, "%T", "show elo", client, target, FACEIT_GetElo(target));

	return Plugin_Handled;
}