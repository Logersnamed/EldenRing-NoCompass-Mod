#include <Windows.h>
#include "ModUtils.h"
#include "GameData.h"
#include "Memory.h"

using namespace ModUtils;

extern "C" {
	void RemoveCompass();
	uintptr_t returnAddress = 0;
    volatile bool g_isAlone = true;
}

bool g_Running = true;

bool isPlayerAlone(uintptr_t worldChrSignature) {
    uintptr_t worldPtr = Memory::RPM<uintptr_t>(worldChrSignature);
    if (!worldPtr) return true;

	GameData::WorldChrMan* worldChar = reinterpret_cast<GameData::WorldChrMan*>(worldPtr);
    if (!worldChar->players) return true;

    return !worldChar->players->player1;
}

DWORD WINAPI MainThread(LPVOID lpParam) {
	Log("Activating NoCompass...");

	std::string aob = "0f 11 b3 80 00 00 00 0f 28 b4 24 80 00 00 00 f2 0f 11 bb 90 00 00 00 0f 28 7c 24 70 4c 8d 9c 24 90 00 00 00";
	uintptr_t hookAddress = AobScan(aob);

	if (hookAddress != 0) {
		returnAddress = hookAddress + 14 + 14;

		Hook(hookAddress, (uintptr_t)&RemoveCompass, 14);
	}

	uintptr_t worldChrSignature = Memory::Signature("48 8B 05 ? ? ? ? 48 85 C0 74 0F 48 39 88").Scan().Add(3).Rip().As<uint64_t>();
    if (worldChrSignature) {
        while (g_Running) {
            g_isAlone = isPlayerAlone(worldChrSignature);
			Sleep(3000);
        }
    }
    else {
		printf("Failed to find worldChrSignature\n");
    }

	CloseLog();
	return 0;
}

BOOL WINAPI DllMain(HINSTANCE module, DWORD reason, LPVOID) {
	switch (reason) {
		case (DLL_PROCESS_ATTACH):  
			DisableThreadLibraryCalls(module);
			CreateThread(0, 0, &MainThread, 0, 0, NULL);
			break;
		case (DLL_PROCESS_DETACH):  
			g_Running = FALSE; 
			break;
	}
	return TRUE;
}