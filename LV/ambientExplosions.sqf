/*
				***		ARMA3 AMBIENT EXPLOSIONS SCRIPT v1.0 - by SPUn / Kaarto Media	***

*/
if (!isServer)exitWith{};

private ["_randDir","_randAlt","_mp","_center","_amount","_duration","_maxDistance","_avoidPlayers","_avoidAI","_planes","_cannonSFX","_endTime","_amountSleepMin","_amountSleepMax","_spotValid","_centerPos","_range","_dir","_spawnPos","_avoidArray","_minRange","_b","_i","_m","_veh","_hq","_grp","_side","_classModuleFilters","_planeDistance","_planeAltitude","_fromDirection","_pos","_plane","_crew","_flySpot","_wp0","_wp1","_avoidAdditional"];

_center = param [0, [player]];
_amount = param [1, 10]; //explosions per minute (avg)
_duration = param [2, 30];
_maxDistance = param [3, 600];
_minRange = param[4, 100];
_avoidPlayers = param [5, true];
_avoidAI = param [6, false];
_planes = param [7, [2,["ambientExplosionsPlanes"],1500,300,"random"]]; //false | [2,["random"],1500,300,0] //side, classname, distance, altitude, from_direction (int dir | "random")
_cannonSFX = param [8, false]; //false | [distance,direction]
_mp = param [9, false];

if(_mp)then{if(isNil("LV_GetPlayers"))then{LV_GetPlayers = compileFinal preprocessFile "LV\LV_functions\LV_fnc_getPlayers.sqf";};};
if(isNil("LV_IsInMarker"))then{LV_IsInMarker = compileFinal preprocessFile "LV\LV_functions\LV_fnc_isInMarker.sqf";};
if(isNil("LV_classnames"))then{LV_classnames = compileFinal preprocessFile "LV\LV_functions\LV_fnc_classnames.sqf";};
if(isNil("LV_validateClassArrays"))then{LV_validateClassArrays = compileFinal preprocessFile "LV\LV_functions\LV_fnc_validateClassArrays.sqf";};
if(isNil("LV_centerInit"))then{LV_centerInit = compileFinal preprocessFile "LV\LV_functions\LV_fnc_centerInit.sqf";};
if(isNil("LV_findPosition"))then{LV_findPosition = compileFinal preprocessFile "LV\LV_functions\LV_fnc_findPosition.sqf";};

if(typeName _planes == "ARRAY")then{
	_side = _planes param [0,2];
	_classModuleFilters = _planes param [1,["ALL"]];
	_planeDistance = _planes param [2,1500];
	_planeAltitude = _planes param [3,300];
	_fromDirection = _planes param [4,"random"];

	_veh = [];

	switch(_side)do{
		case 1:{
			_hq = [1] call LV_centerInit;
			_grp = createGroup west;
		};
		case 2:{
			_hq = [2] call LV_centerInit;
			_grp = createGroup east;
		};
		case 3:{
			_hq = [3] call LV_centerInit;
			_grp = createGroup resistance;
		};
	};
	_veh = ([_classModuleFilters,[(_side), 4]] call LV_classnames);

	_veh = [_veh] call LV_validateClassArrays;
	if((count _veh) == 0)then{
		_veh = ([[],[(_side), 4]] call LV_classnames);
	};

	_veh = selectRandom _veh;
	if(typeName _veh == "ARRAY")then{_veh = selectRandom _veh;};
};

_endTime = time + _duration;

while {time < _endtime} do {
	_amountSleepMin = (60 / _amount) / 2;
	_amountSleepMax = (60 / _amount) * 1.5;

	sleep (random(_amountSleepMax - _amountSleepMin + 1) + _amountSleepMin);

	if(_mp)then{ _center = call LV_GetPlayers;};
	if(((typeName _center) == "ARRAY")||(_mp))then{
		_centerPos = getPos (_center call BIS_fnc_selectRandom);
	}else{
		_centerPos = getPos _center;
	};

	if(_avoidAI)then{
		_avoidAdditional = allUnits select { !(isPlayer _x) && alive _x };
	}else{
		_avoidAdditional = false;
	};

	_spawnPos = [_center,_maxDistance,_minRange,_avoidPlayers,true,_avoidAdditional,_mp,false] call LV_findPosition;

	if(typeName _planes == "ARRAY")then{
		if(typeName _fromDirection == "STRING")then{_dir = random 360;}else{_dir = _fromDirection;};
		_randDir = random(20) - 10;
		_randAlt = random(100) - 50;
		_range = _planeDistance;
		_pos = [(_spawnPos select 0) + (sin (_dir + _randDir)) * _range, (_spawnPos select 1) + (cos (_dir + _randDir)) * _range, (_planeAltitude + _randAlt)];
		_plane = createVehicle [_veh, _pos, [], 0, "FLY"];
		_plane setPosATL [(_spawnPos select 0) + (sin (_dir + _randDir)) * _range, (_spawnPos select 1) + (cos (_dir + _randDir)) * _range, (_planeAltitude + _randAlt)];
		_plane setDir _dir + 180;
		_plane allowDamage false;
		_crew = [_plane,_grp] call bis_fnc_spawncrew;
		_plane setCaptive true;
		(driver _plane) setBehaviour "CARELESS";
		doStop _plane;
		_plane disableAI "TARGET";_plane disableAI "AUTOTARGET";_plane allowFleeing 0;_plane setBehaviour "CARELESS";
		{ _x setCaptive true; sleep 0.001; } forEach units _grp;

		_dir = ((_spawnPos select 0) - (_pos select 0)) atan2 ((_spawnPos select 1) - (_pos select 1));
		_flySpot = [(_spawnPos select 0) + (sin _dir) * _range, (_spawnPos select 1) + (cos _dir) * _range, _planeAltitude];

		_wp0 = _grp addWaypoint [_flySpot, 0, 1];
		[_grp,0] setWaypointBehaviour "CARELESS";
		[_grp,0] setWaypointForceBehaviour true;
		[_grp,0] setWaypointCompletionRadius 200;

		_plane flyInHeight _planeAltitude;
		_plane setVelocity [(sin (direction _plane) * 150),(cos (direction _plane) * 150),0];

		[_plane,_grp,_flySpot,_centerPos,_range] spawn {
			sleep 1;
			params ["_plane","_grp","_flySpot","_centerPos","_deleteRange"];
			while{(_plane distance2D _flySpot) > (_deleteRange * .5)}do{
				if(!alive _plane || !canMove _plane)exitWith{};
				sleep 5;
			};

			waitUntil{sleep 0.128;(_plane distance2D _centerPos) > _deleteRange};
			{ deleteVehicle _x; sleep 0.001; } forEach crew _plane;
			deleteVehicle _plane;
		};

		_spawnPos = [_center,_maxDistance,_minRange,_avoidPlayers,true,_avoidAdditional,_mp,false] call LV_findPosition;

		[_plane, _spawnPos,_center,_maxDistance,_minRange,_mp,_avoidPlayers,_avoidAdditional] spawn {
			sleep 1;
			params ["_plane","_spawnPos","_center","_maxDistance","_minRange","_mp","_avoidPlayers","_avoidAdditional"];
			waitUntil{sleep 0.028;(_plane distance2D _spawnPos) < 300};

			[_spawnPos,_center,_maxDistance,_minRange,_mp,_avoidPlayers,_avoidAdditional] spawn {
				params ["_spawnPos","_center","_maxDistance","_minRange","_mp","_avoidPlayers","_avoidAdditional"];
				sleep 5;

				if(([_center,_maxDistance,_minRange,_avoidPlayers,true,_avoidAdditional,_mp,_spawnPos] call LV_findPosition) == false)then{
					_spawnPos = [_center,_maxDistance,_minRange,_avoidPlayers,true,_avoidAdditional,_mp,false] call LV_findPosition;
				};

				_b = createVehicle ["Bo_GBU12_LGB", _spawnPos, [], 0, "CAN_COLLIDE"];
				_b setDamage 1;
			};
		};
	}else{
		if(_cannonSFX)then{
			playSound3D ["a3\sounds_f\ambient\battlefield\battlefield_explosions3.wss", (_center select 0), false, [(_spawnPos select 0) + (sin 0) * 500, (_spawnPos select 1) + (cos 0) * 500, 0], 5, 0, 0];
			[_spawnPos,_center,_maxDistance,_minRange,_mp,_avoidPlayers,_avoidAdditional] spawn {
				params ["_spawnPos","_center","_maxDistance","_minRange","_mp","_avoidPlayers","_avoidAdditional"];
				sleep 5;

				if(([_center,_maxDistance,_minRange,_avoidPlayers,true,_avoidAdditional,_mp,_spawnPos] call LV_findPosition) == false)then{
					_spawnPos = [_center,_maxDistance,_minRange,_avoidPlayers,true,_avoidAdditional,_mp,false] call LV_findPosition;
				};

				_b = createVehicle ["Bo_GBU12_LGB", _spawnPos, [], 0, "CAN_COLLIDE"];
				_b setDamage 1;
			};
		}else{
			_b = createVehicle ["Bo_GBU12_LGB", _spawnPos, [], 0, "CAN_COLLIDE"];
			_b setDamage 1;
		};
	};
};