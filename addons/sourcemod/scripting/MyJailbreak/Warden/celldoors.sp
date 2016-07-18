// Cell Door module for MyJailbreak - Warden

//Includes
#include <sourcemod>
#include <cstrike>
#include <warden>
#include <colors>
#include <autoexecconfig>
#include <myjailbreak>
#include <smartjaildoors>

//Compiler Options
#pragma semicolon 1
#pragma newdecls required

//ConVars
ConVar gc_bOpen;
ConVar gc_bOpenTimer;
ConVar gc_hOpenTimer;
ConVar gc_bOpenTimerWarden;

//Integers
int g_iOpenTimer;

//Handles
Handle OpenCounterTime = null;

public void CellDoors_OnPluginStart()
{
	//Client commands
	RegConsoleCmd("sm_open", Command_OpenDoors, "Allows the Warden to open the cell doors");
	RegConsoleCmd("sm_close", Command_CloseDoors, "Allows the Warden to close the cell doors");
	
	//AutoExecConfig
	gc_bOpen = AutoExecConfig_CreateConVar("sm_warden_open_enable", "1", "0 - disabled, 1 - warden can open/close cells", _, true,  0.0, true, 1.0);
	gc_hOpenTimer = AutoExecConfig_CreateConVar("sm_warden_open_time", "60", "Time in seconds for open doors on round start automaticly", _, true, 0.0); 
	gc_bOpenTimer = AutoExecConfig_CreateConVar("sm_warden_open_time_enable", "1", "should doors open automatic 0- no 1 yes", _, true,  0.0, true, 1.0);
	gc_bOpenTimerWarden = AutoExecConfig_CreateConVar("sm_warden_open_time_warden", "1", "should doors open automatic after sm_warden_open_time when there is a warden? needs sm_warden_open_time_enable 1", _, true,  0.0, true, 1.0);
	
	//Hooks
	HookEvent("round_start", CellDoors_RoundStart);
	
	//FindConVar
	g_bNoBlockSolid = FindConVar("mp_solid_teammates");
}

public void CellDoors_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if (OpenCounterTime != null)
		KillTimer(OpenCounterTime);
		
	OpenCounterTime = null;
	
	if(gc_bPlugin.BoolValue)
	{
		if (SJD_IsCurrentMapConfigured())
		{
			g_iOpenTimer = GetConVarInt(gc_hOpenTimer);
			OpenCounterTime = CreateTimer(1.0, Timer_OpenCounter, _, TIMER_REPEAT);
			if (RandomTimer != null)
			KillTimer(RandomTimer);
			
			RandomTimer = null;
		}
		else CPrintToChatAll("%t %t", "warden_tag" , "warden_openauto_unavailable"); 
	}
}

public Action Timer_OpenCounter(Handle timer, Handle pack)
{
	if(gc_bPlugin.BoolValue)
	{
		--g_iOpenTimer;
		if(g_iOpenTimer < 1)
		{
			if(!IsWardenExist)
			{
				if(gc_bOpenTimer.BoolValue)
				{
					SJD_OpenDoors(); 
					CPrintToChatAll("%t %t", "warden_tag" , "warden_openauto");
					
					if (OpenCounterTime != null)
						KillTimer(OpenCounterTime);
					
					OpenCounterTime = null;
				}
			}
			else if(gc_bOpenTimer.BoolValue)
			{
				if(gc_bOpenTimerWarden.BoolValue)
				{
					SJD_OpenDoors(); 
					CPrintToChatAll("%t %t", "warden_tag" , "warden_openauto");
				}
				else CPrintToChatAll("%t %t", "warden_tag" , "warden_opentime"); 
				if (OpenCounterTime != null)
					KillTimer(OpenCounterTime);
				OpenCounterTime = null;
			}
		}
	}
}

public Action Command_OpenDoors(int client, int args)
{
	if(gc_bPlugin.BoolValue)
	{
		if(gc_bOpen.BoolValue)
		{
			if (IsClientWarden(client))
			{
				if (SJD_IsCurrentMapConfigured())
				{
					CPrintToChatAll("%t %t", "warden_tag" , "warden_dooropen"); 
					SJD_OpenDoors();
					if (OpenCounterTime != null)
					KillTimer(OpenCounterTime);
					OpenCounterTime = null;
				}
				else CPrintToChat(client, "%t %t", "warden_tag" , "warden_dooropen_unavailable"); 
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden"); 
		}
	}
}

public Action Command_CloseDoors(int client, int args)
{
	if(gc_bPlugin.BoolValue)
	{
		if(gc_bOpen.BoolValue)
		{
			if (IsClientWarden(client))
			{
				if (SJD_IsCurrentMapConfigured()) 
				{
					CPrintToChatAll("%t %t", "warden_tag" , "warden_doorclose"); 
					SJD_CloseDoors();
				}
				else CPrintToChat(client, "%t %t", "warden_tag" , "warden_doorclose_unavailable"); 
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden"); 
		}
	}
}
