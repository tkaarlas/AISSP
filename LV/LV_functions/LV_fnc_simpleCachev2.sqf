/*ARMA3 function LV_fnc_simpleCachev2 v0.3 - by Na_Palm +new fixes by SPUn
initial version by SPUn / lostvar

		This script caches fillHouse & militarize scripts.

	nul = [[script parameter list],[players],distance,keep count,MP] execVM "LV\LV_functions\LV_fnc_simpleCache.sqf";

	script parameter list	=	array of [scriptID, [parameter]]
								scriptID = 1: militarize, 2: fillHouse
								parameter = array of required parameters for the script
	players 				=	array of players (doesnt matter what you set here if you use MP mode)
	distance				=	distance between player(s) and militarize/fillHouse on where scripts will be activated
	keep count				=	true = script will count & save AI amounts, false = AI amount will be reseted on each time it activates again
	MP						=	true = all alive non-captive playableUnits will activate scripts, false = only units in players-array

	example:

	nul = [[[1, [parameter for 1]], [2, [parameter for 2]]],[playerUnit1],500,true,false] execVM "LV\LV_functions\LV_fnc_simpleCache.sqf";

*/
if (!isServer)exitWith{};
if(isNil("LV_fnc_removeGroupv2"))then{LV_fnc_removeGroupv2 = compileFinal preprocessFile "LV\LV_functions\LV_fnc_removeGroupv2.sqf";};

private [
"_distance",
"_grpname",
"_hndl",
"_keepCount",
"_MenCount",
"_mp",
"_needDespwn",
"_needSpwn",
"_posOfScriptMrkr",
"_scrptPara_list",
"_spwndSciptIdx_list",
"_units",
"_VehCount"
];

_scrptPara_list = _this select 0;
_units = _this select 1;
_distance = _this select 2;
_keepCount = _this select 3;
_mp = _this select 4;

if(_mp)then{if(isNil{LV_GetPlayers})then{LV_GetPlayers = compileFinal preprocessFile "LV\LV_functions\LV_fnc_getPlayers.sqf"; waitUntil {!isNil{LV_GetPlayers}};};};

if(isNil("LV_militarize"))then{LV_militarize = compileFinal preprocessFile "LV\militarize.sqf";};
if(isNil("LV_fillHouse"))then{LV_fillHouse = compileFinal preprocessFile "LV\fillHouse.sqf";};

//vars it needs
_spwndSciptIdx_list = [];

while{(count _scrptPara_list) > 0} do {
	//get actual players if MP
	if (_mp) then {_units = call LV_GetPlayers;};
	//check if a script needs to SPAWN, then do it
	{
		_needSpwn = false;
		//is it already spawned?
		if !(_forEachIndex in _spwndSciptIdx_list) then {
			//get position in accordance to type
			if ((_x select 1 select 0) in allMapMarkers) then {
				_posOfScriptMrkr = getMarkerPos (_x select 1 select 0);
			} else {
				if (typeName (_x select 1 select 0) == "ARRAY") then {
					_posOfScriptMrkr = (_x select 1 select 0);
				} else {
					_posOfScriptMrkr = getPos (_x select 1 select 0);
				};
			};
			//check if player near
			{
				if ((_x distance _posOfScriptMrkr) < _distance) exitWith {
					_needSpwn = true;
				};
				sleep 0.001;
			}forEach _units;
		};
		//spawn it
		if (_needSpwn) then {
			if ((_x select 0) == 1) then {
				_hndl = (_x select 1) spawn LV_militarize;
				waitUntil {scriptDone _hndl};
			} else {
				_hndl = (_x select 1) spawn LV_fillHouse;
				waitUntil {scriptDone _hndl};
			};
			_spwndSciptIdx_list set [count _spwndSciptIdx_list, _forEachIndex];
		};
		sleep 0.001;
	}forEach _scrptPara_list;
	//check if a spawned script needs to DESPAWN, then do it
	{
		_needDespwn = true;
		//is it already spawned?
		if (_forEachIndex in _spwndSciptIdx_list) then {
			//get position in accordance to type
			if ((_x select 1 select 0) in allMapMarkers) then {
				_posOfScriptMrkr = getMarkerPos (_x select 1 select 0);
			} else {
				if (typeName (_x select 1 select 0) == "ARRAY") then {
					_posOfScriptMrkr = (_x select 1 select 0);
				} else {
					_posOfScriptMrkr = getPos (_x select 1 select 0);
				};
			};
			//check if player near
			{
				if ((_x distance _posOfScriptMrkr) < _distance) exitWith {
					_needDespwn	= false;
				};
				sleep 0.001;
			}forEach _units;
		} else {
			_needDespwn	= false;
		};
		//despawn it
		if (_needDespwn) then {
			if ((_x select 0) == 1) then {
				call compile format["_grpname = LVgroup%1",(_x select 1 select 11)];
			} else {
				call compile format["_grpname = LVgroup%1",(_x select 1 select 9)];
			};
			[_grpname] call LV_fnc_removeGroupv2;
			_spwndSciptIdx_list = _spwndSciptIdx_list - [_forEachIndex];
		};
		sleep 0.001;
	}forEach _scrptPara_list;
	//check if to keep count
	if (_keepCount) then {
		{
			_grpname = grpNull;
			//is it already spawned?
			if (_forEachIndex in _spwndSciptIdx_list) then {
				_MenCount = 0;
				_VehCount = 0;
				//get groupname
				if ((_x select 0) == 1) then {
					call compile format["_grpname = LVgroup%1",(_x select 1 select 11)];
				} else {
					call compile format["_grpname = LVgroup%1",(_x select 1 select 9)];
				};
				//get unit/vehicle count in group
				_MenCount = ({alive _x} count units _grpname);
				if((_x select 0) == 1)then{
					{
						if(vehicle _x != _x)then{
							if((canMove (vehicle _x))&&(alive _x))then{
								_VehCount = _VehCount + 1;
								_MenCount = _MenCount - 1;
							};
						};
						sleep 0.001;
					}forEach units _grpname;
				};
				if ((_MenCount == 0) && (_VehCount == 0)) then {
					//script has no units left, so delete it from _scrptPara_list and DESPAWN
					if ((_x select 0) == 1) then {
						call compile format["_grpname = LVgroup%1",(_x select 1 select 11)];
					} else {
						call compile format["_grpname = LVgroup%1",(_x select 1 select 9)];
					};
					[_grpname] call LV_fnc_removeGroupv2;
					_spwndSciptIdx_list = _spwndSciptIdx_list - [_forEachIndex];
					_scrptPara_list set [_forEachIndex, 999];
					_scrptPara_list = _scrptPara_list - [999];
				} else {
					//change parameter array according to new counts
					if ((_x select 0) == 1) then {
						//militarize
						(_x select 1) set [6, [_MenCount, 0]];
						(_x select 1) set [7, [_VehCount, 0]];
					} else {
						//fillHouse
						(_x select 1) set [4, [_MenCount, 0]];
					};
				};
			};
			sleep 0.001;
		}forEach _scrptPara_list;
	};
	sleep 0.001;
	sleep 2;
};
