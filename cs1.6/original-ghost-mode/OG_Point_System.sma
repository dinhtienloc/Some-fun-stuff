/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <nvault>
#include <fakemeta>
#include <dhudmessage>
#include <OriginalGhost>
#include <ColorChat>

#define PLUGIN "OG: Point System"
#define VERSION "1.0"
#define AUTHOR "dtloc"

#define LANG_FILE "OriginalGhost.txt"
#define GAME_LANG LANG_SERVER

new g_Vault               
new g_TempGhostPoint[33]
new g_TempHumanPoint[33]
new g_maxPlayers
new GameName[32]
new g_MsgSayText

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_dictionary(LANG_FILE)
	
	register_event("DeathMsg", "EventDeathMsg", "a");
	register_logevent("logevent_round_end", 2, "1=Round_End")
	
	g_maxPlayers = get_maxplayers();
	g_MsgSayText = get_user_msgid("SayText")
}

public plugin_natives() {
	register_native("og_get_user_HP", "Get_User_HumanPoint", 1);
	register_native("og_get_user_GP", "Get_User_GhostPoint", 1);
	register_native("og_set_user_HP", "Set_User_HumanPoint", 1);
	register_native("og_set_user_GP", "Set_User_GhostPoint", 1);
}

public plugin_cfg() {
	new g_Vault = nvault_open("OG Point System");
	
	if(g_Vault == INVALID_HANDLE)
		set_fail_state("Error opening vault");
	
	for(new id = 1; id <= g_maxPlayers; id++) {
		Load_Point(id);
	}
	
	formatex(GameName, sizeof(GameName), "%L", GAME_LANG, "GAME_NAME")
	
}

public Get_User_HumanPoint(id) {
	return g_TempHumanPoint[id];
}

public Get_User_GhostPoint(id) {
	return g_TempGhostPoint[id];
}

public Set_User_HumanPoint(id, point) {
	g_TempHumanPoint[id] -= point
}

public Set_User_GhostPoint(id, point) {
	g_TempGhostPoint[id] -= point
}

public plugin_end(){
	nvault_prune(g_Vault, 0, get_systime());
	nvault_close(g_Vault);
	
	return PLUGIN_HANDLED
}

public EventDeathMsg(id) {
	new iAttacker = read_data(1);
	new iVictim = read_data(2);
	
	new CsTeams:AtTeam = cs_get_user_team(iAttacker);
	new CsTeams:ViTeam = cs_get_user_team(iVictim);
	
	if(iAttacker == iVictim) {
		if(AtTeam == CS_TEAM_CT) g_TempHumanPoint[iAttacker]--;
		else if(AtTeam == CS_TEAM_T) g_TempGhostPoint[iAttacker]--;
	}
	else {
		if(AtTeam == CS_TEAM_CT) {
			if(ViTeam == CS_TEAM_CT) {
				g_TempHumanPoint[iAttacker]--;
				g_TempHumanPoint[iVictim]--;
			}
			else if(ViTeam  == CS_TEAM_T) {
				g_TempHumanPoint[iAttacker]++;
			}
		}
		else if(AtTeam == CS_TEAM_T) {
			if(ViTeam == CS_TEAM_T) {
				g_TempGhostPoint[iAttacker]--;
				g_TempGhostPoint[iVictim]--;
			}
			else if(ViTeam == CS_TEAM_CT) {
				g_TempGhostPoint[iAttacker]++;
			}
		}
	}
}

public logevent_round_end() {
	new OutputInfo[100]
	
	if(og_team_win() == CT_TEAM) {
		formatex(OutputInfo, sizeof(OutputInfo), "!g[%s]!n %L", GameName, GAME_LANG, "NOTICE_CT_WIN_AWARD")
		client_printc(0, OutputInfo);
		PointAwardCT();
	}
	else if(og_team_win() == GHOST_TEAM) {
		formatex(OutputInfo, sizeof(OutputInfo), "!g[%s]!n %L", GameName, GAME_LANG, "NOTICE_TS_WIN_AWARD")
		client_printc(0, OutputInfo);
		PointAwardTS();
	}
	else {
		formatex(OutputInfo, sizeof(OutputInfo), "!g[%s]!n %L", GameName, GAME_LANG, "NOTICE_DRAW")
		client_printc(0, OutputInfo);
	}
}		
	
public client_disconnect(id) {
	Save_Point(id)
}

Save_Point(id) {
	new szKey[40]
	new Name[32]
	new szPoint[4]
	get_user_name(id, Name, charsmax(Name));
	
	// Save human points
	formatex(szKey, charsmax(szKey), "%sHP:", Name);
	new iCurrentHP = nvault_get(g_Vault, szKey);
	formatex(szPoint, charsmax(szPoint), "%d", iCurrentHP + g_TempHumanPoint[id]);
	nvault_set(g_Vault, szKey, szPoint);
	
	// Save ghost points
	formatex(szKey, charsmax(szKey), "%sGP:", Name);
	new iCurrentGP = nvault_get(g_Vault, szKey);
	formatex(szPoint, charsmax(szPoint), "%d", iCurrentGP + g_TempGhostPoint[id]);
	nvault_set(g_Vault, szKey, szPoint);
}

Load_Point(id) {
	new szKey[40]
	new Name[32]
	
	get_user_name(id, Name, charsmax(Name));
	
	// Load human points
	formatex(szKey, charsmax(szKey), "%sHP:", Name);
	g_TempHumanPoint[id] = nvault_get(g_Vault, szKey);
	
	// Load ghost points
	formatex(szKey, charsmax(szKey), "%sGP:", Name);
	g_TempGhostPoint[id] = nvault_get(g_Vault, szKey);
}

PointAwardCT()
{
	new iAlive, id, OutputInfo[100]
	
	for (id = 1; id <= og_get_maxplayers(); id++)
	{
		formatex(OutputInfo, sizeof(OutputInfo), "!g[%s]!n %L", GameName, GAME_LANG, "NOTICE_AWARD")
		if (is_user_alive(id) && get_user_team(id) == 2) {
			client_printc(id, OutputInfo);
			g_TempHumanPoint[id]++;
		}
	}
	
	return iAlive;
}

PointAwardTS()
{
	new iAlive, id, OutputInfo[100]
	
	for (id = 1; id <= og_get_maxplayers(); id++)
	{
		formatex(OutputInfo, sizeof(OutputInfo), "!g[%s]!n %L", GameName, GAME_LANG, "NOTICE_AWARD")
		if (is_user_alive(id) && get_user_team(id) == 1) {
			client_printc(id, OutputInfo);
			g_TempGhostPoint[id]++;
		}
	}
	
	return iAlive;
}

stock client_printc(index, const text[], any:...)
{
	static szMsg[128]; vformat(szMsg, sizeof(szMsg) - 1, text, 3)
	
	replace_all(szMsg, sizeof(szMsg) - 1, "!g", "^x04")
	replace_all(szMsg, sizeof(szMsg) - 1, "!n", "^x01")
	replace_all(szMsg, sizeof(szMsg) - 1, "!t", "^x03")
	
	if(index)
	{
		message_begin(MSG_ONE_UNRELIABLE, g_MsgSayText, _, index);
		write_byte(index);
		write_string(szMsg);
		message_end();
	}
	else {
		ColorChat(0, GREEN, "%s", szMsg);
	}
		
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
