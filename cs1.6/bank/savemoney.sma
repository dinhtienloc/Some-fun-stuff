/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <amxmisc>
#include <nvault>
#include <cstrike>
#include <colorchat>

#define PLUGIN "CS-NTC Bank Service"
#define VERSION "1.0"
#define AUTHOR "Elo_Cee"

new g_Vault             
new g_Name[32][32]     


public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_clcmd("say", "say_handle");
	register_clcmd("say_team", "say_handle");
	register_clcmd("amx_bank_reset", "bank_reset", ADMIN_LEVEL_D);
	register_clcmd("amx_bank_check", "bank_check", ADMIN_LEVEL_D);
	register_clcmd("amx_bank_set", "bank_set", ADMIN_LEVEL_D);
}

public plugin_cfg(){
	new g_Vault = nvault_open("Bank System");
	
	if(g_Vault == INVALID_HANDLE){
		set_fail_state("Error opening vault");
	}
}

public plugin_end(){
	nvault_close(g_Vault);
}

public client_putinserver(id){
	get_user_name(id, g_Name[id], charsmax(g_Name[]));
}

public say_handle(id){
	new arg[32]
	new command[7]
	new input1[32]
	new input2[32]
	read_args(arg, charsmax(arg));
	remove_quotes(arg);
	parse(arg, command, charsmax(command), input1, charsmax(input1), input2, charsmax(input2));
	
	if(equali(command, "/check")){
		new szKey[40]
		
		formatex(szKey, charsmax(szKey), "%sMONEY", g_Name[id]);
		
		new iTotalMoney = nvault_get(g_Vault, szKey);
		
		ColorChat(id, NORMAL, "^x01[^x04 CS-NTC^x01 ] So tien trong tai khoan hien tai la ^x04%d$", iTotalMoney);
		return PLUGIN_HANDLED
	}
	else if(equali(command, "/save")){ 
		new szTotalMoney[17] 
		new szKey[40]
		
		formatex(szKey, charsmax(szKey), "%sMONEY", g_Name[id]);
		
		new iTotalMoney = nvault_get(g_Vault, szKey)
		new iSaveMoney
		new iCertainMoney = cs_get_user_money(id)
		
		if(!strlen(input1)) return PLUGIN_HANDLED
		
		if(equali(input1, "all")){
			iSaveMoney = cs_get_user_money(id);
		}
		else{
			iSaveMoney = str_to_num(input1);
		}	
		
		if(iSaveMoney > cs_get_user_money(id) || iSaveMoney <= 0){
			ColorChat(id, NORMAL, "^x01[^x04 CS-NTC^x01 ]^x04 Error:^x01So tien nhap vao khong chinh xac hoac vuot qua so tien trong tai khoan.");
			return PLUGIN_HANDLED
		}
		else{
			iTotalMoney += iSaveMoney;
			formatex(szTotalMoney, charsmax(szTotalMoney), "%d", iTotalMoney);
			nvault_set(g_Vault, szKey, szTotalMoney);
			cs_set_user_money(id, iCertainMoney - iSaveMoney, 1);
			
			ColorChat(id, NORMAL, "^x01[^x04 CS-NTC^x01 ] Da gui ^x04%d$ ^x01vao tai khoan cua ban", iSaveMoney);
			ColorChat(id, NORMAL, "^x01[^x04 CS-NTC^x01 ] So tien trong tai khoan hien tai la ^x04%d$", iTotalMoney);
		}
		return PLUGIN_HANDLED
	}
	else if(equali(command, "/get")){
		new szKey[40]
		new szTotalMoney[16]
		
		formatex(szKey, charsmax(szKey), "%sMONEY", g_Name[id]);
		
		new iTotalMoney = nvault_get(g_Vault, szKey);
		new iGetMoney
		new iCertainMoney = cs_get_user_money(id)
		if(!strlen(input1)) return PLUGIN_HANDLED
		
		if(equali(input1, "all")){
			iGetMoney = iTotalMoney;
		}
		else{
			iGetMoney = str_to_num(input1);
		}
		
		if(iGetMoney > iTotalMoney || iGetMoney <= 0){
			ColorChat(id, NORMAL, "^x01[^x04 CS-NTC^x01 ]^x04 Error:^x01So tien nhap vao khong chinh xac hoac vuot qua so tien trong tai khoan.");
			return PLUGIN_HANDLED
		}
		else{
			iTotalMoney -= iGetMoney;
			formatex(szTotalMoney, charsmax(szTotalMoney), "%d", iTotalMoney);
			nvault_set(g_Vault, szKey, szTotalMoney);
			cs_set_user_money(id, iCertainMoney + iGetMoney, 1);
			
			ColorChat(id, NORMAL, "^x01[^x04 CS-NTC^x01 ] Da rut ^x04%d$", iGetMoney);
			ColorChat(id, NORMAL, "^x01[^x04 CS-NTC^x01 ] So tien trong tai khoan hien tai la ^x04%d$", iTotalMoney);
		}
		return PLUGIN_HANDLED
	}
	else if(equali(command, "/trans")){
		new targetID = cmd_target(id, input1);
		if(!targetID){
			ColorChat(id, NORMAL, "^x01[^x04 CS-NTC^x01 ]^x04 Error:^x01Khong ton tai nguoi nhan");
			return PLUGIN_HANDLED
		}
		else{	
			if(targetID == id){
				ColorChat(id, NORMAL, "^x01[^x04 CS-NTC^x01 ]^x04 Error:^x01Khong the tu chuyen tien cho minh.");
				return PLUGIN_HANDLED
			}
			new iTransferMoney
			
			if(equali(input2, "all")){
				iTransferMoney = cs_get_user_money(id);
			}
			else{
				iTransferMoney = str_to_num(input2);
			}
			if(iTransferMoney <= 0){
				ColorChat(id, NORMAL, "^x01[^x04 CS-NTC^x01 ] So tien nhap vao khong chinh xac hoac vuot qua so tien hien co trong tai khoan");
				return PLUGIN_HANDLED
			}
			else{
				new iDesTotalMoney, iSourceTotalMoney
				new iCertainMoney = cs_get_user_money(id)
				new szDesTotalMoney[16], szSourceTotalMoney[16]
				new szDesKey[40], szSourceKey[40], szDesName[32]
				
				get_user_name(targetID, szDesName, charsmax(szDesName));
			
				formatex(szSourceKey, charsmax(szSourceKey), "%sMONEY", g_Name[id])
				formatex(szDesKey, charsmax(szDesKey), "%sMONEY", szDesName);
				
				iDesTotalMoney = nvault_get(g_Vault, szDesKey);
				iSourceTotalMoney = nvault_get(g_Vault, szSourceKey);
				
				if(iTransferMoney > cs_get_user_money(id) && iTransferMoney < iSourceTotalMoney){
					iDesTotalMoney += iTransferMoney;
					iSourceTotalMoney -= iTransferMoney;
				
					formatex(szDesTotalMoney, charsmax(szDesTotalMoney), "%d", iDesTotalMoney);
					formatex(szSourceTotalMoney, charsmax(szSourceTotalMoney), "%d", iSourceTotalMoney);
				
					nvault_set(g_Vault, szDesKey, szDesTotalMoney);
					nvault_set(g_Vault, szSourceKey, szSourceTotalMoney);
					
					if(cs_get_user_team(targetID) == CS_TEAM_T){
						ColorChat(id, RED, "^x01[^x04 CS-NTC^x01 ]Chuyen khoan thanh cong. Nguoi nhan: ^x03%s^x01. So tien: ^x04%d$",szDesName, iTransferMoney);
					}
					else if(cs_get_user_team(targetID) == CS_TEAM_CT){
						ColorChat(id, BLUE, "^x01[^x04 CS-NTC^x01 ]Chuyen khoan thanh cong. Nguoi nhan: ^x03%s^x01. So tien: ^x04%d$",szDesName, iTransferMoney);
					}
					else{
						ColorChat(id, GREY, "^x01[^x04 CS-NTC^x01 ]Chuyen khoan thanh cong. Nguoi nhan: ^x03%s^x01. So tien: ^x04%d$",szDesName, iTransferMoney);
					}
					ColorChat(id, NORMAL, "^x01[^x04 CS-NTC^x01 ]Tai khoan bi tru di ^x04%d$", iTransferMoney);
					ColorChat(id, NORMAL, "^x01[^x04 CS-NTC^x01 ]So tien trong tai khoan hien tai la ^x04%d$", iSourceTotalMoney);
					ColorChat(targetID, NORMAL, "^x01[^x04 CS-NTC^x01 ]Nguoi choi %s da chuyen vao tai khoan ban ^x04%d$", g_Name[id], iTransferMoney);
					ColorChat(targetID, NORMAL, "^x01[^x04 CS-NTC^x01 ]So tien trong tai khoan hien tai la ^x04%d$", iDesTotalMoney);
				}
				else if(iTransferMoney < cs_get_user_money(id)){
					cs_set_user_money(id, iCertainMoney - iTransferMoney, 1);
					iDesTotalMoney += iTransferMoney;
					
					formatex(szDesTotalMoney, charsmax(szDesTotalMoney), "%d", iDesTotalMoney);
					nvault_set(g_Vault, szDesKey, szDesTotalMoney);
					
					ColorChat(id, NORMAL, "^x01[^x04 CS-NTC^x01 ]Ban bi tru ^x04%d$", iTransferMoney);
					if(cs_get_user_team(targetID) == CS_TEAM_T){
						ColorChat(id, RED, "^x01[^x04 CS-NTC^x01 ]Chuyen khoan thanh cong. Nguoi nhan: ^x03%s^x01. So tien: ^x04%d$",szDesName, iTransferMoney);
						ColorChat(targetID, RED, "^x01[^x04 CS-NTC^x01 ]Nguoi choi ^x03%s^x01 da chuyen vao tai khoan ban ^x04%d$", g_Name[id], iTransferMoney);
					}
					else if(cs_get_user_team(targetID) == CS_TEAM_CT){
						ColorChat(id, BLUE, "^x01[^x04 CS-NTC^x01 ]Chuyen khoan thanh cong. Nguoi nhan: ^x03%s^x01. So tien: ^x04%d$",szDesName, iTransferMoney);
						ColorChat(targetID, BLUE, "^x01[^x04 CS-NTC^x01 ]Nguoi choi ^x03%s^x01 da chuyen vao tai khoan ban ^x04%d$", g_Name[id], iTransferMoney);
					}
					else{
						ColorChat(id, GREY, "^x01[^x04 CS-NTC^x01 ]Chuyen khoan thanh cong. Nguoi nhan: ^x03%s^x01. So tien: ^x04%d$",szDesName, iTransferMoney);
						ColorChat(targetID, GREY, "^x01[^x04 CS-NTC^x01 ]Nguoi choi ^x03%s^x01 da chuyen vao tai khoan ban ^x04%d$", g_Name[id], iTransferMoney);
					}
					ColorChat(id, NORMAL, "^x01[^x04 CS-NTC^x01 ]So tien trong tai khoan hien tai la ^x04%d$", iSourceTotalMoney);
					ColorChat(targetID, NORMAL, "^x01[^x04 CS-NTC^x01 ]So tien trong tai khoan hien tai la ^x04%d$", iDesTotalMoney);
				}
				else{
					ColorChat(id, NORMAL, "^x01[^x04 CS-NTC^x01 ] So tien nhap vao khong chinh xac hoac vuot qua so tien hien co trong tai khoan");
					return PLUGIN_HANDLED
				}
			}
		}
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public bank_reset(id, level, cid){
	if(!cmd_access(id, level, cid, 1)){
		return PLUGIN_HANDLED
	}
	console_print(id, "Bank system has been reset");
	nvault_prune(g_Vault, 0, get_systime());
	return PLUGIN_HANDLED
}

public bank_check(id, level, cid){
	if(!cmd_access(id, level, cid, 2)){
		return PLUGIN_HANDLED
	}
	new arg[8], pName[32]
	new szKey[40]
	new iTotalMoney
	read_args(arg, charsmax(arg));
	remove_quotes(arg);
	
	new pID = cmd_target(id, arg, 8);
	if(!pID){
		console_print(id, "Failed");
		return PLUGIN_HANDLED
	}
	get_user_name(pID, pName, charsmax(pName));
	
	formatex(szKey, charsmax(szKey), "%sMONEY", pName);
	iTotalMoney = nvault_get(g_Vault, szKey);
	
	console_print(id, "Player: %s", pName);
	console_print(id, "So tien: %d", iTotalMoney);
	return PLUGIN_HANDLED
}

public bank_set(id, level, cid){
	if(!cmd_access(id, level, cid, 3)){
		return PLUGIN_HANDLED
	}
	new arg[30], pName[32], szMount[16], szInput[8]
	new szKey[40]
	new iTotalMoney
	read_args(arg, charsmax(arg));
	remove_quotes(arg);
	
	parse(arg, szInput, charsmax(szInput), szMount, charsmax(szMount)); 
	new pID = cmd_target(id, szInput, 8);
	if(!pID){
		console_print(id, "Failed");
		return PLUGIN_HANDLED
	}
	get_user_name(pID, pName, charsmax(pName));
	formatex(szKey, charsmax(szKey), "%sMONEY", pName);
	
	iTotalMoney = str_to_num(szMount);
	if(iTotalMoney > 0){
		nvault_set(g_Vault, szKey, szMount);
		console_print(id, "Player: %s", pName);
		console_print(id, "Money: %d", iTotalMoney);
	}
	else console_print(id, "Failed");
	return PLUGIN_HANDLED
}
	
	
	

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
