/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fun>
#include <fakemeta>
#include <hamsandwich>
#include <engine>
#include <dhudmessage>
#include <OriginalGhost>

#define PLUGIN "Original Ghost v1.0"
#define VERSION "1.0"
#define AUTHOR "S.M/dtloc"

#define V_MODEL "models/v_blurred_knife.mdl"
#define C4_MODEL "models/v_blurred_c4.mdl"
#define FLASH_MODEL "models/v_blurred_flashbang.mdl"

#define SPEEDTASK 1231
#define BREATHTASK 2431
#define TASK_GHOST_BREATH 33542
#define m_iDefaultItems 120 //default weapon offset

new g_ghost[33] //player co phai ghost ko (bool)
new g_invis[33] //player co dang tang hinh ko(bool)
//new g_c4[33] //quen cmnr, thoi de day

new og_invisdamerate, og_visdamerate, og_ghostspeed, og_nadesdamerate,
og_maplight;

new const Ham:Ham_Player_ResetMaxSpeed = Ham_Item_PreFrame
new const m_rgpPlayerItems_CWeaponBox[6] = {34,35,...}

const XO_CWEAPONBOX = 4
const WEAPON_SUIT = 31
const WEAPON_SUIT_BIT = 1<<WEAPON_SUIT // vai cai offset

// Point
new g_playerMaxHealth[33]

new const GHOST_SOUND[] = "og/breath/breath_2.wav";

new g_MyMsgSync
new TeamWin

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	//register_event("CurWeapon", "CurWeapon", "be", "1=1") //check weapon, cai nay co the cai tien = Ham_ItemDeploy
	register_event("ResetHUD", "newround", "b")
	register_message(get_user_msgid("TextMsg") ,"message_TextMsg")
	//register_logevent("logevent_round_start", 2, "1=Round_Start")  
	
	RegisterHam(Ham_Spawn, "player", "HamSpawn", 1) //block default wpn at spawn
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage") //xu? li' ve` damage
	RegisterHam(Ham_Touch, "armoury_entity", "FwdHamPickupWeapon")
	RegisterHam(Ham_Touch, "weaponbox", "FwdHamPickupWeapon") //block ghost pick weapon
	RegisterHam(Ham_Item_Deploy, "weapon_knife", "fwReplaceModels", 1);
	RegisterHam(Ham_Item_Deploy, "weapon_c4", "fwReplaceModels", 1);
	RegisterHam(Ham_Item_Deploy, "weapon_flashbang", "fwReplaceModels", 1);
	RegisterHam(Ham_Player_ResetMaxSpeed, "player", "CBasePlayer_ResetMaxSpeed", 1 );
	register_forward(FM_EmitSound, "OnEmitSound", false)
	
	register_forward(FM_GetGameDescription, "GameDesc") //doi? game description
	register_forward(FM_CmdStart, "FMCmdStart")
	
	og_invisdamerate = register_cvar("og_ghost_invisdamerate", "0.5");
	og_visdamerate = register_cvar("og_ghost_visdamerate", "1.0");
	og_ghostspeed = register_cvar("og_ghost_speed", "500");
	og_nadesdamerate = register_cvar("og_nadesdamerate", "0.5");
	og_maplight = register_cvar("og_ghost_light", "d");
	
	set_msg_block(get_user_msgid("ShadowIdx"), BLOCK_SET) // remove shadow
	
	server_cmd("mp_roundtime 2.5")
	server_cmd("mp_buytime 0.25")
	server_cmd("mp_freezetime 3");
	server_cmd("mp_playerid 2");
	
	g_MyMsgSync = CreateHudSyncObj()
}
	
public plugin_natives() {
	register_native("og_get_user_maxhealth", "Get_User_MaxHealth", 1);
	register_native("og_set_user_maxhealth", "Set_User_MaxHealth", 1);
	register_native("og_get_maxplayers", "Get_MaxPlayers", 1);
	register_native("og_team_win", "Which_TeamWin", 1);
	register_native("og_is_invisible", "Check_Invisible", 1);
}

public Get_User_MaxHealth(id) {
	return g_playerMaxHealth[id]
}

public Set_User_MaxHealth(id, max_health) {
	set_user_health(id, max_health);
	g_playerMaxHealth[id] = max_health;
	
	return g_playerMaxHealth[id];
}

public Get_MaxPlayers() {
	return get_maxplayers();
}

public Which_TeamWin() {
	return TeamWin
}

public Check_Invisible(id) {
	if(cs_get_user_team(id) != CS_TEAM_CT) return 0;
	return g_invis[id]

}

public plugin_precache()
{
	precache_model(V_MODEL)
	precache_model(C4_MODEL)
	precache_model(FLASH_MODEL);
	//precache_model("models/player/ghost1/ghost1.mdl")
	precache_sound(GHOST_SOUND)
}

public FMCmdStart(id, uc_handle, randseed) //~ prethink ~ postthink
{	//	set_hudmessage(0, 0, 200, HUD_EVENT_X, HUD_EVENT_Y, 0, 0.0, 3.0, 2.0, 1.0, -1)
	set_hudmessage(255, 255, 0, -1.0, 0.85, 0, 0.0, 0.1, 2.0, 1.0, -1);
	
	if(cs_get_user_team(id) == CS_TEAM_T) {
		static Float: fmove //forward move speed
		static Float: smove //side move speed
		get_uc(uc_handle, UC_ForwardMove, fmove)
		get_uc(uc_handle, UC_SideMove, smove)
		static Float: maxspeed
		pev(id, pev_maxspeed, maxspeed)
		static Float: walkspeed
		walkspeed = (0.52 * maxspeed)
		fmove = floatabs(fmove)
		smove = floatabs(smove)
		
		if(fmove <= walkspeed && smove <= walkspeed) //player is walking
		{
			//client_print(id, print_chat, "Invisible");
			g_invis[id] = true;
			set_user_rendering(id, kRenderFxNone, 0, 0, 0, kRenderTransTexture, 0);
			Make_Invisible(id);
			set_user_footsteps(id, 0);
			
		}
		else //player is running
		{
			g_invis[id] = false;
			set_user_rendering(id, kRenderFxNone, 0, 0, 0, kRenderTransTexture, 50);
			Make_Visible(id);
		}
		
		show_hudmessage(id, "[G-Points: %i][HP: %d]", og_get_user_GP(id), get_user_health(id));
	}
	else if(cs_get_user_team(id) == CS_TEAM_CT) {
		set_user_rendering(id, kRenderFxNone, 0, 0, 0, kRenderNormal, 0)
		g_invis[id] = 0;
		show_hudmessage(id, "[H-Points: %d][HP: %d]", og_get_user_HP(id), get_user_health(id));

	}
}

public fw_GhostBreath(id)
{
	id -= TASK_GHOST_BREATH;
		
	if (!is_user_alive(id) || cs_get_user_team(id) != CS_TEAM_T) {
		remove_task(id+TASK_GHOST_BREATH);
		return;
	}
	

	new Float:fVolume = 0.4

	emit_sound(id, CHAN_WEAPON, GHOST_SOUND, fVolume, ATTN_NORM, 0, 94);
}

// Set ghost speed to maxspeed again when changing weapon 
public CBasePlayer_ResetMaxSpeed (const id){
	if (is_user_alive(id))
	{	
		new Float:MaxSpeed = get_user_maxspeed(id);
		if (MaxSpeed != 1.0) {
			if(cs_get_user_team(id) == CS_TEAM_T)
				set_user_maxspeed(id, get_pcvar_float(og_ghostspeed));
					
			else if(cs_get_user_team(id) == CS_TEAM_CT) 
				set_user_maxspeed(id, 250.0);
		}
	}
	
}

public fwReplaceModels(ent) {
	static id; id = fm_cs_get_weapon_ent_owner(ent);
	// Valid owner?
	if (!pev_valid(id)) return;
    
	// Replace weapon models with custom ones
	if(!is_user_alive(id) || cs_get_user_team(id) == CS_TEAM_CT) return;
	
	switch(cs_get_weapon_id(ent)) {
		case CSW_KNIFE:
		{
			entity_set_string(id, EV_SZ_viewmodel, V_MODEL);	
		}
		case CSW_C4:
		{
			entity_set_string(id, EV_SZ_viewmodel, C4_MODEL)	
		}
		case CSW_FLASHBANG:
		{
			entity_set_string(id, EV_SZ_viewmodel, FLASH_MODEL);
		}
	}
}

// Block default weapon
public HamSpawn(id){
	if(is_user_alive(id)) {
		strip_user_weapons(id);
		give_item(id, "weapon_knife");
		client_cmd(id, "weapon_knife");
		/*
		if(cs_get_user_team(id) == CS_TEAM_T) {
			give_item(id, "weapon_knife");
			client_cmd(id, "weapon_knife");
		}
		else if(cs_get_user_team(id) == CS_TEAM_CT) {
			give_item(id, "weapon_knife");
		}
		*/
	}
}

public set_speed(id){
	set_user_maxspeed(id, get_pcvar_float(og_ghostspeed));
}

public newround(id)
{
	if(is_user_alive(id) && cs_get_user_team(id) == CS_TEAM_T)
	{
		set_user_health(id, og_get_user_maxhealth(id));
		g_ghost[id] = 1;
		
		if(is_user_alive(id))
			set_task(get_cvar_float("mp_freezetime"), "set_speed", id);
	}
	if(is_user_alive(id) && cs_get_user_team(id) == CS_TEAM_CT)
	{
		set_user_health(id, 100);
		g_ghost[id] = 0
	}
	new light[1];
	get_pcvar_string(og_maplight, light, 1);
	set_lights(light[0]);
}
public fw_TakeDamage(victim, inflictor, attacker, Float:damage)
{
	client_print(0, print_chat, "%f", damage);
	if(victim != attacker && is_user_connected(attacker))
	{
		if(cs_get_user_team(attacker) == CS_TEAM_T)
		{

			if(g_invis[attacker] == 1)
			{
				SetHamParamFloat(4, damage * get_pcvar_float(og_invisdamerate)); //0.5x damage
			}
			if(g_invis[attacker] == 0)
			{
				SetHamParamFloat(4, damage * get_pcvar_float(og_visdamerate)); //normal damage
			}
		}
		
		if(cs_get_user_team(attacker) == CS_TEAM_CT)
		{
			if(get_user_weapon(attacker) == CSW_KNIFE)
			{
				SetHamParamFloat(4, damage * get_pcvar_float(og_visdamerate) * 0.6);
			}
			
			if(get_user_weapon(attacker) == CSW_HEGRENADE)
			{
				SetHamParamFloat(4, damage * get_pcvar_float(og_nadesdamerate));
			}
		}
	}
	//return HAM_HANDLED
}
public FwdHamPickupWeapon(ent, id) //block wpn pickup
{
	new iID = GetWeaponBoxWeaponType(ent)
	if(is_user_alive(id) && cs_get_user_team(id) == CS_TEAM_T && iID != CSW_C4)
	{
		return HAM_SUPERCEDE
	}
	return HAM_IGNORED
}
public GameDesc()
{
	forward_return(FMV_STRING, "NTC-GhostMode")
	return FMRES_SUPERCEDE
}


public client_putinserver(id) {
	g_playerMaxHealth[id] = 50;
}

public client_disconnect(id) {
	g_playerMaxHealth[id] = 50;
}

public message_TextMsg( const MsgId, const MsgDest, const MsgEntity )
{    
	static message[32]
	get_msg_arg_string(2, message, charsmax(message))
    
	if(equal(message, "#Terrorists_Win"))
	{
		TeamWin = GHOST_TEAM;
		set_msg_arg_string(2, "Ghost Team Win!!!");
	}
	else if(equal(message, "#CTs_Win"))
	{
		TeamWin = CT_TEAM;
		set_msg_arg_string(2, "F.R.I.S Team Win!!!")
	}
} 

GetWeaponBoxWeaponType( ent )
{
	new weapon;
	for(new i = 1; i<= 5; i++)
	{
		weapon = get_pdata_cbase(ent, m_rgpPlayerItems_CWeaponBox[i], XO_CWEAPONBOX);
		if( weapon > 0 )
		{
			return cs_get_weapon_id(weapon);
		}
	}
	
	return 0;
}  

Make_Invisible(id) {
	message_begin(MSG_ONE, get_user_msgid("ScreenFade"),_, id)
	write_short(4096 * 1)
	write_short(floatround(4096 * 0.5))
	write_short(0x0004)    // FADE OUT
	write_byte(153)
	write_byte(51)
	write_byte(255)
	write_byte(25)
	message_end()
	if(!og_have_nobreath(id)) {
		new Float:fRandomTime = random_float(1.5, 3.0)
	
		if (!task_exists(id + TASK_GHOST_BREATH))
			set_task(fRandomTime, "fw_GhostBreath", id+TASK_GHOST_BREATH)
	}
}
Make_Visible(id) {
	message_begin(MSG_ONE, get_user_msgid("ScreenFade"),_, id)
	write_short(4096 * 1)
	write_short(floatround(4096 * 0.5))
	write_short(0x0004)    // FADE OUT
	write_byte(0)
	write_byte(0)
	write_byte(0)
	write_byte(0)
	message_end();
	
	if(!og_have_nobreath(id)) {
		if (task_exists(id+TASK_GHOST_BREATH))
			remove_task(id+TASK_GHOST_BREATH)
	}
}
/*
stock Float:fm_get_ent_speed(id)
{
	if(!pev_valid(id))
		return 0.0;
	
	static Float:vVelocity[3];
	pev(id, pev_velocity, vVelocity);
	
	vVelocity[2] = 0.0;
	
	return vector_length(vVelocity);
}  
*/
stock fm_cs_get_weapon_ent_owner(ent)
{
    // Prevent server crash if entity's private data not initalized
    if (pev_valid(ent) != 2) return -1;

    return get_pdata_cbase(ent, 41, 4);
}  
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/