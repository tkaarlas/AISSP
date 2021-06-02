private ["_unit","_stuff"];

_unit = (_this select 0);

if(isNil "_unit")exitWith{};

if(_unit isKindOf "Man")then{
	_stuff = (vestItems _unit) + (uniformItems _unit) + (backpackItems _unit) + (assignedItems _unit);

	_unit unlinkItem "NVGoggles";
	_unit unlinkItem "NVGoggles_OPFOR";
	_unit unlinkItem "NVGoggles_INDEP";

	if("acc_pointer_IR" in _stuff)then{
		_unit removePrimaryWeaponItem "acc_pointer_IR";
	};

	_unit addPrimaryWeaponItem "acc_flashlight_smg_01";
	_unit addPrimaryWeaponItem "acc_flashlight";
	_unit addSecondaryWeaponItem "acc_flashlight_pistol";
	_unit enablegunlights "forceOn";
};

if(true)exitWith{};