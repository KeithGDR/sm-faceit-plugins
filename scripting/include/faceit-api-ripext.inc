#if defined _faceit_api_included
  #endinput
#endif
#define _faceit_api_included

#include <ripext>

////////////////////////////
//Natives

/**
* Retrieves whether the player is registered on FACEIT or not.
*
* param client		Client index.
*
* return			True if registered, false otherwise.
**/
native bool FACEIT_IsRegistered(int client);

/**
* Retrieves the FACEIT player id for the player.
*
* param client		Client index.
* param buffer		Buffer to store the string in.
* param size		Size of the buffer itself.
*
* noreturn
**/
native void FACEIT_GetPlayerID(int client, char[] buffer, int size);

/**
* Retrieves the FACEIT skill level for the player.
*
* param client		Client index.
*
* return			Skill level.
**/
native int FACEIT_GetSkillLevel(int client);

/**
* Retrieves the FACEIT elo for the player.
*
* param client		Client index.
*
* return			Elo.
**/
native int FACEIT_GetElo(int client);

////////////////////////////
//Forwards

/**
* Called after the FACEIT data has been retrieved for the player successfully.
*
* param client		Client index.
* param obj			JSONObject containing the data.
*
* noreturn
**/
forward void OnGetFACEITData(int client, bool registered, JSONObject obj);

#if !defined REQUIRE_PLUGIN
public void __pl_faceit_api_SetNTVOptional()
{
	MarkNativeAsOptional("FACEIT_IsRegistered");
	MarkNativeAsOptional("FACEIT_GetPlayerID");
	MarkNativeAsOptional("FACEIT_GetSkillLevel");
	MarkNativeAsOptional("FACEIT_GetElo");
}
#endif

public SharedPlugin __pl_faceit_api =
{
	name = "faceit-api",
	file = "faceit-api.smx",
#if defined REQUIRE_PLUGIN
	required = 1
#else
	required = 0
#endif
};