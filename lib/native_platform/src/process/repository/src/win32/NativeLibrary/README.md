NativeLibrary is a C++/CLI shared library dll that checks if a process (by PID)
is suspended or not.

The win32 api does not provide a means of checking a process' suspended state,
however C# does. Since Dart does not yet support interop with C#, this library
is a wrapper around that C# code that can itself be called from Dart via ffi.

Reference for C# support in Dart:
https://github.com/flutter/flutter/issues/74720
