#include <Windows.h>
#include "ModUtils.h"

using namespace ModUtils;

extern "C" {
	void RemoveCompass();
	uintptr_t returnAddress = 0;
}

DWORD WINAPI MainThread(LPVOID lpParam) {
	Log("Activating NoCompass...");
	std::string aob = "0f 11 b3 80 00 00 00 0f 28 b4 24 80 00 00 00 f2 0f 11 bb 90 00 00 00 0f 28 7c 24 70 4c 8d 9c 24 90 00 00 00";
	uintptr_t hookAddress = AobScan(aob);

	if (hookAddress != 0) {
		returnAddress = hookAddress + 14 + 14;

		Hook(hookAddress, (uintptr_t)&RemoveCompass, 14);
	}

	CloseLog();
	return 0;
}

BOOL WINAPI DllMain(HINSTANCE module, DWORD reason, LPVOID) {
	if (reason == DLL_PROCESS_ATTACH) {
		DisableThreadLibraryCalls(module);
		CreateThread(0, 0, &MainThread, 0, 0, NULL);
	}
	return TRUE;
}