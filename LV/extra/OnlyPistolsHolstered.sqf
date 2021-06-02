private ["_unit","_pistols","_mags","_index","_pistol","_mag"];
_unit = _this select 0;

if(isNil "_unit")exitWith{};

if(_unit isKindOf "Man")then{
	_unit removeWeapon (primaryWeapon _unit);
	_unit removeWeapon (secondaryWeapon _unit);
	_unit removeWeapon (handgunWeapon _unit);

	_pistols = ["hgun_ACPC2_F","hgun_P07_F","hgun_Pistol_heavy_01_F","hgun_Pistol_heavy_02_F","hgun_Rook40_F"];
	_mags = ["9Rnd_45ACP_Mag","30Rnd_9x21_Mag","11Rnd_45ACP_Mag","6Rnd_45ACP_Cylinder","30Rnd_9x21_Mag"];

	_pistol = selectRandom _pistols;
	_index = _pistols find _pistol;
	_mag = _mags select _index;

	_unit addWeapon _pistol;
	_unit addMagazine [_mag, 4];

	null = [_unit] spawn {
		private ["_unit"];
		_unit = (_this select 0);

		sleep 1;

		_unit action ['SwitchWeapon', _unit, _unit, 100];
	};
};