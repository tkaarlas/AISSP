/*
	LV_fnc_findPosition - 1.0

	Params:
	0: center 			array  			objects that makes the center of this script
	1: maxDistance 		number 			maximum distance from center object(s)
	2: minDistance 		number 			minimum distance from center object(s)
	3: avoid 			boolean 		if true, script will avoid center objects (NOTE: check param 6: MP)
	4: avoidMarkers 	boolean 		if true, script will avoid ACavoid -markers (Read documentation regarding them)
	5: avoidAdditional 	false | array 	if array, then all objects in this array will also be avoided
	6: MP 				boolean 		if true, then param 0 (center) will automatically be all alive playable units
	7: checkPosition 	array 			if this position array is provided, script will only check if it pass the criteria (OPTIONAL)

	Returns:
	position 			array 			new position array
	  OR
	validation 			boolean			does the given parameter (7) pass the criterias
*/
private ["_center","_spotValid","_maxDistance","_perfectSpot","_centerPos","_mp","_range","_dir","_avoid","_minDistance","_avoidArray","_i","_m","_avoidMarkers","_avoidAdditional","_checkPosition"];
_center = param [0, [player]];
_maxDistance = param [1, 600];
_minDistance = param [2, 100];
_avoid = param [3, true];
_avoidMarkers = param [4, false];
_avoidAdditional = param [5, false];
_mp = param [6, false];
_checkPosition = param [7, false];

if(isNil("LV_IsInMarker"))then{LV_IsInMarker = compileFinal preprocessFile "LV\LV_functions\LV_fnc_isInMarker.sqf";};
if(_mp)then{
	if(isNil("LV_GetPlayers"))then{LV_GetPlayers = compileFinal preprocessFile "LV\LV_functions\LV_fnc_getPlayers.sqf";};
	_center = call LV_GetPlayers;
};

_spotValid = false;
while{!_spotValid}do{
	_spotValid = true;
	if(((typeName _center) == "ARRAY")||(_mp))then{
		_centerPos = getPos (_center call BIS_fnc_selectRandom);
	}else{
		_centerPos = getPos _center;
	};

	if((typeName _checkPosition) == "ARRAY")then{
		_perfectSpot = _checkPosition;
	}else{
		_range = (random(_maxDistance));
		_dir = random 360;
		_perfectSpot = [(_centerPos select 0) + (sin _dir) * _range, (_centerPos select 1) + (cos _dir) * _range, 0];
	};

	if(_avoid)then{
		if(_mp)then{
			_center = call LV_GetPlayers;
		};
		if(((typeName _center) == "ARRAY")||(_mp))then{
			{
				if((_x distance _perfectSpot) < _minDistance)exitWith{_spotValid = false;};
				sleep 0.003;
			}forEach _center;
		};
	};

	if((typeName _avoidAdditional) == "ARRAY")then{
		{
			if((_x distance _perfectSpot) < _minDistance)exitWith{_spotValid = false;};
			sleep 0.003;
		}forEach _avoidAdditional;
	};

	if(_avoidMarkers == true)then{
		_avoidArray = [];
		for "_i" from 0 to 30 do {
			if(_i == 0)then{_m = "ACavoid";}else{_m = ("ACavoid_" + str _i);};
			if(_m in allMapMarkers)then{_avoidArray set[(count _avoidArray),_m];};
			sleep 0.003;
		};
		{
			if([_perfectSpot,_x] call LV_IsInMarker)exitWith{_spotValid = false;};
			sleep 0.003;
		}forEach _avoidArray;
	};

	if((typeName _checkPosition) == "ARRAY")exitWith{};

	sleep 0.012;
};

if((typeName _checkPosition) == "ARRAY")then{
	_perfectSpot = _spotValid;
};

_perfectSpot