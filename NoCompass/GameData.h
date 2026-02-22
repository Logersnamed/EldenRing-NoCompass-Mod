#pragma once
namespace GameData {
    struct ChrData {
        char pad1[0x68];
        int level;
	};

    struct ChrIns {
        char pad1[0x580];
        ChrData* chrData;
    };

    struct Players {
        ChrIns* player0;
		char pad1[0x2];
        ChrIns* player1;
	};

    struct WorldChrMan {
        char pad1[0x10EF8];
        Players* players;
    };
}