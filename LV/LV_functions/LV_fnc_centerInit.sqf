//Create global center for selected side
//Params:
//0: side (0 = civilian, 1 = west, 2 = east, 3 = resistance)
private ["_side"];
_side = param [0,[]];

switch (_side) do {
	case 0: {
		if(isNil("LV_civiCenter"))then{LV_civiCenter = createCenter civilian;};
		LV_civiCenter
    };
    case 1: {
		if(isNil("LV_westCenter"))then{LV_westCenter = createCenter west;};
		LV_westCenter
    };
	case 2: {
        if(isNil("LV_eastCenter"))then{LV_eastCenter = createCenter east;};
		LV_eastCenter
    };
    default {
        if(isNil("LV_resiCenter"))then{LV_resiCenter = createCenter resistance;};
		LV_resiCenter
    };
};
