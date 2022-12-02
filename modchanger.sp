#include <sourcemod>
#include <cstrike>
#include <multicolors>

new bool:g_bAllowRoundEnd = false;

public Plugin:myinfo =
{
	name = "CS.Center Deathmatch Plugin",
	author = "JLAX",
	description = "CS.Center Deahatmatch plugin by JLAX",
	version = "2.0",
	url = "https://cs.center"
}

public OnPluginStart()
{
	CreateTimer(1.0, CheckRemainingTime, INVALID_HANDLE, TIMER_REPEAT);
	HookEvent("round_start", OnRoundStart);
}
public void OnRoundStart(Handle event, const char[]name , bool dontBroadcast){
	ServerCommand("dm_load \"Game Modes\" Deathmatch");
	ServerCommand("dm_respawn_all");

}
stock int GetPlayerCount()
{
    int number = 0;
    for (new i=1; i<=MaxClients; i++)
    {
        if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) !=1)
            number++;
    }
    return number;
}

public void OnMapStart(){
	char mapname[128];
	GetCurrentMap(mapname, sizeof(mapname));
	if (!StrEqual(mapname, "de_dust2")){
		ServerCommand("sm_map de_dust2");
	}

}

public Action:CheckRemainingTime(Handle:timer)
{
	new Handle:hTmp;
	hTmp = FindConVar("mp_freezetime");
	new freeze_time = GetConVarInt(hTmp);
	new timeleft;
	GetMapTimeLeft(timeleft);

	timeleft = timeleft + freeze_time;

	int tabanca_modu = 60 * 10;
	if(timeleft > tabanca_modu && timeleft < tabanca_modu + 10){
		CPrintToChatAll("{green}Tabanca Modu{darkred} açılmasına son {green}%i{darkred} saniye",timeleft - tabanca_modu);
	}
	if(timeleft == tabanca_modu){
		ServerCommand("dm_load \"Game Modes\" \"Tabanca\"");
		ServerCommand("dm_respawn_all");
	}


	if(timeleft == 5){
		int TopFraggers[MAXPLAYERS+1];
		int TopClients[MAXPLAYERS+1];
		int i = 0;
		int j = 0;
		for(i = 0;i<=MAXPLAYERS;i++){
			TopFraggers[i] = 0;
			TopClients[i] = 0;
		}
		for (i = 1; i <= MaxClients; i++) {
			if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) !=1) {
				TopFraggers[i] = GetClientFrags(i);
				TopClients[i] = i;
				//  PrintToChatAll("%i",GetClientFrags(i));
			}
		}

		int tmp = 0;
		int enbuyuk = 0;

		for(i = 0;i<=MAXPLAYERS;i++){
			enbuyuk = i;
			for(j=i+1;j<=MAXPLAYERS;j++){
				if(TopFraggers[enbuyuk] < TopFraggers[j])
					enbuyuk = j;
			}

			tmp = TopFraggers[enbuyuk];
			TopFraggers[enbuyuk] = TopFraggers[i];
			TopFraggers[i] = tmp;

			tmp = TopClients[enbuyuk];
			TopClients[enbuyuk] = TopClients[i];
			TopClients[i] = tmp;
		}

		CPrintToChatAll("{orange}***********************************************************");
		CPrintToChatAll("{darkred}DM2.CS.Center (Favorilere eklemeyi unutmayın)");
		CPrintToChatAll("{green}Oyun bitti! Kendini daha çok geliştirmen lazım :)");
		CPrintToChatAll("{orange}***********************************************************");
		CPrintToChatAll("{orange}[3.]{green} %N (%i öldürme)",TopClients[2],TopFraggers[2]);
		CPrintToChatAll("{orange}[2.]{green} %N (%i öldürme)",TopClients[1],TopFraggers[1]);
		CPrintToChatAll("{orange}[1.]{green} %N (%i öldürme)",TopClients[0],TopFraggers[0]);
		CPrintToChatAll("{orange}***********************************************************");
		CPrintToChatAll("{purple}VIP (10₺) satın almak için TAB tuşuna basarak sol alttaki sunucu sitesine tıklayabilirsiniz");
		CPrintToChatAll("{orange}***********************************************************");
		ServerCommand("mp_restartgame 1");
	}


	if(timeleft < -3 && !g_bAllowRoundEnd)
	{
		g_bAllowRoundEnd = true;
		CS_TerminateRound(0.5, CSRoundEnd_TerroristWin, true);
	}

}

public Action:CS_OnTerminateRound(&Float:delay, &CSRoundEndReason:reason)
{
	g_bAllowRoundEnd = false;
	return Plugin_Continue;
}
