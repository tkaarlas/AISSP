//LV_fnc_removeClasses.sqf - remove entries from array or nested array. Entries are partial texts from classnames.
//
//PARAMS
//0: array | nested array - classnames which we want to clean from unwanted classnames (ex: pilots, crewmembers, etc)
//1: array - case-sensitive text we use to identify the unwanted classnames (ex: ['pilot', 'Pilot', 'crew', 'Crew'])
//RETURNS
//Original array without the unwanted classnames
private ["_array","_wildcards","_subArray","_x1"];
_array = param [0,[]];
_wildcards = param [1,[]];

if(typeName (_array select 0) == "ARRAY")then{
	{
		_subArray = _x;
		{
			for[{_x1=0},{_x1 < (count _wildcards)},{_x1 = _x1 + 1;}]do{
				if(_x find (_wildcards select _x1) > -1)then{
					_subArray set [_forEachIndex, 999];
					break;
				};
				sleep 0.006;
			};
			sleep 0.002;
		}forEach _subArray;
		_subArray = _subArray - [999];
		_array set [_forEachIndex, _subArray];
		sleep 0.002;
	}forEach _array;
}else{
	{
		for[{_x1=0},{_x1 < (count _wildcards)},{_x1 = _x1 + 1;}]do{
			if(_x find (_wildcards select _x1) > -1)then{
				_array set [_forEachIndex, 999];
				break;
			};
			sleep 0.008;
		};
		sleep 0.002;
	}forEach _array;
	_array = _array - [999];
};

_array