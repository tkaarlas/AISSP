private ["_unit"];
_unit = _this select 0;

if(isNil "_unit")exitWith{};

if(_unit isKindOf "Man")then{

	while{vehicle _unit != _unit}do{ sleep 10; };

	while{alive _unit}do{
		if(damage _unit > 0)then{
			while{damage _unit > 0}do{
				sleep 6;
				_unit setDamage ((damage _unit) + 0.05);
			};
		};
		sleep 3;
	};

}