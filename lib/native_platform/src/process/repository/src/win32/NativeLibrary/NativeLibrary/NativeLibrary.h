#pragma once

using namespace System;

namespace NativeLibrary {
	extern "C" {
		__declspec(dllexport) bool __stdcall IsProcessSuspended(int pid);
	}
}
