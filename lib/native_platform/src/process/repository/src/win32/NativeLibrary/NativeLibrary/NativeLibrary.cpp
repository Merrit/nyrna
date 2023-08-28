#include "pch.h"

#include "NativeLibrary.h"

namespace NativeLibrary
{
	/*
		Checks if a process is suspended

		@param pid The process ID to check
		@return true if the process is suspended, false otherwise
	*/
	bool IsProcessSuspended(int pid) {
		try {
			// Get the process status using the dotnet API
			System::Diagnostics::Process^ process = System::Diagnostics::Process::GetProcessById(pid);
			System::Diagnostics::ProcessThreadCollection^ threads = process->Threads;

			// Iterate over the threads and check if any of them are suspended
			for each (System::Diagnostics::ProcessThread ^ thread in threads) {
				if (thread->ThreadState == System::Diagnostics::ThreadState::Wait && thread->WaitReason == System::Diagnostics::ThreadWaitReason::Suspended) {
					return true;
				}
			}
		} catch (System::Exception^ e) {
			// If the process is not found, return false
			return false;
		}

		return false;
	}
}
