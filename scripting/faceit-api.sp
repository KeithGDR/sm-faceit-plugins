#pragma newdecls required
#pragma semicolon 1

#include <sourcemod>
#include <faceit-api>

#define PLUGIN_VERSION "1.0.0"

ConVar convar_Enabled;
ConVar convar_APIKey;

enum struct Player {
	bool registered;

	char player_id[128];
	int skill_level;
	int faceit_elo;

	void Clear() {
		this.registered = false;

		this.player_id[0] = '\0';
		this.skill_level = 0;
		this.faceit_elo = 0;
	}
}

Player g_Player[MAXPLAYERS + 1];

GlobalForward g_Forward_OnGetFACEITData;

public Plugin myinfo = {
	name = "[ANY] FACEIT - API",
	author = "Drixevel",
	description = "The main API plugin for FACEIT integration.",
	version = PLUGIN_VERSION,
	url = "https://drixevel.dev/"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
	RegPluginLibrary("faceit-api");

	CreateNative("FACEIT_IsRegistered", Native_IsRegistered);
	CreateNative("FACEIT_GetPlayerID", Native_GetPlayerID);
	CreateNative("FACEIT_GetSkillLevel", Native_GetSkillLevel);
	CreateNative("FACEIT_GetElo", Native_GetElo);

	g_Forward_OnGetFACEITData = new GlobalForward("OnGetFACEITData", ET_Ignore, Param_Cell, Param_Cell, Param_Cell);

	return APLRes_Success;
}

public void OnPluginStart() {

	CreateConVar("sm_faceit_api_version", PLUGIN_VERSION, "Version control for this plugin.", FCVAR_DONTRECORD);
	convar_Enabled = CreateConVar("sm_faceit_api_enabled", "1", "Should this plugin be enabled or disabled?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	convar_APIKey = CreateConVar("sm_faceit_api_key", "", "What's the API key?", FCVAR_PROTECTED);
	AutoExecConfig();

	char auth[64];
	for (int i = 1; i <= MaxClients; i++) {
		if (IsClientAuthorized(i) && GetClientAuthId(i, AuthId_Engine, auth, sizeof(auth))) {
			OnClientAuthorized(i, auth);
		}
	}
}

public void OnClientAuthorized(int client, const char[] auth) {
	if (!convar_Enabled.BoolValue) {
		return;
	}

	if (IsFakeClient(client)) {
		return;
	}

	char steamid64[64];
	if (!GetClientAuthId(client, AuthId_SteamID64, steamid64, sizeof(steamid64))) {
		return;
	}
	
	char apikey[64];
	convar_APIKey.GetString(apikey, sizeof(apikey));

	if (strlen(apikey) == 0) {
		ThrowError("[SM] Couldn't authorize FACEIT API request for %N: API key is empty.", client);
	}

	Format(apikey, sizeof(apikey), "Bearer %s", apikey);

	HTTPRequest request = new HTTPRequest("https://open.faceit.com/data/v4/players");
	request.ConnectTimeout = 10;

	request.AppendQueryParam("game", "csgo");
	request.AppendQueryParam("game_player_id", steamid64);

	request.SetHeader("accept", "application/json");
	request.SetHeader("Authorization", apikey);

	request.Get(OnGetFACEITAPIData, GetClientUserId(client));
}

public void OnGetFACEITAPIData(HTTPResponse response, any value)  {
	if (!convar_Enabled.BoolValue) {
		return;
	}

	if (response.Status != HTTPStatus_OK && response.Status != HTTPStatus_NotFound) {
		ThrowError("[SM] Error while fetching FACEIT data with Error Code '%i'.", response.Status);
	}

	int client;
	if ((client = GetClientOfUserId(value)) < 1) {
		return;
	}

	JSONObject obj = view_as<JSONObject>(response.Data);
	JSONObject games = view_as<JSONObject>(obj.Get("games"));
	JSONObject csgo = view_as<JSONObject>(games.Get("csgo"));

	g_Player[client].registered = response.Status != HTTPStatus_NotFound;
	obj.GetString("player_id", g_Player[client].player_id, sizeof(Player::player_id));
	g_Player[client].skill_level = csgo.GetInt("skill_level");
	g_Player[client].faceit_elo = csgo.GetInt("faceit_elo");

	Call_StartForward(g_Forward_OnGetFACEITData);
	Call_PushCell(client);
	Call_PushCell(g_Player[client].registered);
	Call_PushCell(obj); //Might need to duplicate this.
	Call_Finish();
}

public void OnClientDisconnect_Post(int client) {
	g_Player[client].Clear();
}

public int Native_IsRegistered(Handle plugin, int numParam) {
	if (!convar_Enabled.BoolValue) {
		return ThrowNativeError(SP_ERROR_NATIVE, "FACEIT API is disabled.");
	}

	int client = GetNativeCell(1);

	if (client < 1 || client > MaxClients) {
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index %i", client);
	}

	return g_Player[client].registered;
}

public int Native_GetPlayerID(Handle plugin, int numParam) {
	if (!convar_Enabled.BoolValue) {
		return ThrowNativeError(SP_ERROR_NATIVE, "FACEIT API is disabled.");
	}

	int client = GetNativeCell(1);

	if (client < 1 || client > MaxClients) {
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index %i", client);
	}

	SetNativeString(2, g_Player[client].player_id, sizeof(Player::player_id));
	return 1;
}

public int Native_GetSkillLevel(Handle plugin, int numParam) {
	if (!convar_Enabled.BoolValue) {
		return ThrowNativeError(SP_ERROR_NATIVE, "FACEIT API is disabled.");
	}

	int client = GetNativeCell(1);

	if (client < 1 || client > MaxClients) {
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index %i", client);
	}

	return g_Player[client].skill_level;
}

public int Native_GetElo(Handle plugin, int numParam) {
	if (!convar_Enabled.BoolValue) {
		return ThrowNativeError(SP_ERROR_NATIVE, "FACEIT API is disabled.");
	}
	
	int client = GetNativeCell(1);

	if (client < 1 || client > MaxClients) {
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index %i", client);
	}

	return g_Player[client].faceit_elo;
}