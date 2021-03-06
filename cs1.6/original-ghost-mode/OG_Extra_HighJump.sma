/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <amxmisc>
#include <fun>
#include <OriginalGhost>

#define PLUGIN "OG: Nhay cao"
#define VERSION "1.0"
#define AUTHOR "EloCee"

new g_extra_highjump

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_event("HLTV", "Event_NewRound", "a", "1=0", "2=0");
	g_extra_highjump = og_equip_register("Nhay cao", EQ_T, 0, 10000);
}

public og_equip_bought(id, itemid) {
	if(itemid == g_extra_highjump) {
		set_user_gravity(id, 0.5);
	}
}

public Event_NewRound() {
	for(new i = 1; i < og_get_maxplayers(); i++)
		if(get_user_team(i) == 1)
			set_user_gravity(i, 1.0);
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
