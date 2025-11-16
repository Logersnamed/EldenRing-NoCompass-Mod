#include <Windows.h>
#include "ModUtils.h"

using namespace ModUtils;

extern "C" {
	void RemoveCompass();
	uintptr_t returnAddress = 0;
	uintptr_t base = 0;
}

DWORD WINAPI MainThread(LPVOID lpParam) {
	Log("Activating NoCompass...");
	std::string aob = "f2 0f 11 bb 90 00 00 00";
	uintptr_t hookAddress = AobScan(aob);
	size_t offset = 15;

	if (hookAddress != 0) {
		hookAddress -= offset;

		base = GetProcessBaseAddress(GetCurrentProcessId());
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