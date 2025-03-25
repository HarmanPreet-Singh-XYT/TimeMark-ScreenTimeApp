import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';

// Define constants
const int maxPath = 260; // Standard Windows maxPath length

// Native function signatures
typedef GetForegroundWindowNative = Pointer<Void> Function();
typedef GetForegroundWindowDart = Pointer<Void> Function();

typedef GetWindowTextNative = Int32 Function(
  Pointer<Void> hWnd, 
  Pointer<Char> lpString, 
  Int32 nMaxCount
);
typedef GetWindowTextDart = int Function(
  Pointer<Void> hWnd, 
  Pointer<Char> lpString, 
  int nMaxCount
);

typedef GetWindowThreadProcessIdNative = Int32 Function(
  Pointer<Void> hWnd, 
  Pointer<Uint32> lpdwProcessId
);
typedef GetWindowThreadProcessIdDart = int Function(
  Pointer<Void> hWnd, 
  Pointer<Uint32> lpdwProcessId
);

typedef OpenProcessNative = Pointer<Void> Function(
  Uint32 dwDesiredAccess, 
  Int32 bInheritHandle, 
  Uint32 dwProcessId
);
typedef OpenProcessDart = Pointer<Void> Function(
  int dwDesiredAccess, 
  int bInheritHandle, 
  int dwProcessId
);

typedef GetModuleFileNameExANative = Int32 Function(
  Pointer<Void> hProcess, 
  Pointer<Void> hModule, 
  Pointer<Char> lpFilename, 
  Uint32 nSize
);
typedef GetModuleFileNameExADart = int Function(
  Pointer<Void> hProcess, 
  Pointer<Void> hModule, 
  Pointer<Char> lpFilename, 
  int nSize
);

typedef CloseHandleNative = Int32 Function(Pointer<Void> hObject);
typedef CloseHandleDart = int Function(Pointer<Void> hObject);

typedef GetCurrentProcessNative = Pointer<Void> Function();
typedef GetCurrentProcessDart = Pointer<Void> Function();

typedef GetCurrentProcessIdNative = Uint32 Function();
typedef GetCurrentProcessIdDart = int Function();

typedef CreateToolhelp32SnapshotNative = Pointer<Void> Function(
  Uint32 dwFlags,
  Uint32 th32ProcessID
);
typedef CreateToolhelp32SnapshotDart = Pointer<Void> Function(
  int dwFlags,
  int th32ProcessID
);

// Process32First/Next structures and typedefs
base class PROCESSENTRY32 extends Struct {
  @Uint32()
  external int dwSize;
  @Uint32()
  external int cntUsage;
  @Uint32()
  external int th32ProcessID;
  @IntPtr()
  external int th32DefaultHeapID;
  @Uint32()
  external int th32ModuleID;
  @Uint32()
  external int cntThreads;
  @Uint32()
  external int th32ParentProcessID;
  @Int32()
  external int pcPriClassBase;
  @Uint32()
  external int dwFlags;
  @Array(maxPath)
  external Array<Char> szExeFile;
}

typedef Process32FirstNative = Int32 Function(
  Pointer<Void> hSnapshot,
  Pointer<PROCESSENTRY32> lppe
);
typedef Process32FirstDart = int Function(
  Pointer<Void> hSnapshot,
  Pointer<PROCESSENTRY32> lppe
);

typedef Process32NextNative = Int32 Function(
  Pointer<Void> hSnapshot,
  Pointer<PROCESSENTRY32> lppe
);
typedef Process32NextDart = int Function(
  Pointer<Void> hSnapshot,
  Pointer<PROCESSENTRY32> lppe
);

// Registry related function signatures
typedef RegOpenKeyExANative = Int32 Function(
  IntPtr hKey,
  Pointer<Char> lpSubKey,
  Uint32 ulOptions,
  Uint32 samDesired,
  Pointer<IntPtr> phkResult
);
typedef RegOpenKeyExADart = int Function(
  int hKey,
  Pointer<Char> lpSubKey,
  int ulOptions,
  int samDesired,
  Pointer<IntPtr> phkResult
);

typedef RegEnumValueANative = Int32 Function(
  IntPtr hKey,
  Uint32 dwIndex,
  Pointer<Char> lpValueName,
  Pointer<Uint32> lpcchValueName,
  Pointer<Uint32> lpReserved,
  Pointer<Uint32> lpType,
  Pointer<Uint8> lpData,
  Pointer<Uint32> lpcbData
);
typedef RegEnumValueADart = int Function(
  int hKey,
  int dwIndex,
  Pointer<Char> lpValueName,
  Pointer<Uint32> lpcchValueName,
  Pointer<Uint32> lpReserved,
  Pointer<Uint32> lpType,
  Pointer<Uint8> lpData,
  Pointer<Uint32> lpcbData
);

typedef RegCloseKeyNative = Int32 Function(IntPtr hKey);
typedef RegCloseKeyDart = int Function(int hKey);

// Process time related function signatures
typedef GetProcessTimesNative = Int32 Function(
  Pointer<Void> hProcess,
  Pointer<FILETIME> lpCreationTime,
  Pointer<FILETIME> lpExitTime,
  Pointer<FILETIME> lpKernelTime,
  Pointer<FILETIME> lpUserTime
);
typedef GetProcessTimesDart = int Function(
  Pointer<Void> hProcess,
  Pointer<FILETIME> lpCreationTime,
  Pointer<FILETIME> lpExitTime,
  Pointer<FILETIME> lpKernelTime,
  Pointer<FILETIME> lpUserTime
);

typedef GetSystemTimeAsFileTimeNative = Void Function(Pointer<FILETIME> lpSystemTimeAsFileTime);
typedef GetSystemTimeAsFileTimeDart = void Function(Pointer<FILETIME> lpSystemTimeAsFileTime);

typedef GetTickCount64Native = Uint64 Function();
typedef GetTickCount64Dart = int Function();

// Command line related function signatures
typedef GetCommandLineWNative = Pointer<Utf16> Function();
typedef GetCommandLineWDart = Pointer<Utf16> Function();

typedef CommandLineToArgvWNative = Pointer<Pointer<Utf16>> Function(
  Pointer<Utf16> lpCmdLine,
  Pointer<Int32> pNumArgs
);
typedef CommandLineToArgvWDart = Pointer<Pointer<Utf16>> Function(
  Pointer<Utf16> lpCmdLine,
  Pointer<Int32> pNumArgs
);

typedef LocalFreeNative = IntPtr Function(Pointer<Void> hMem);
typedef LocalFreeDart = int Function(Pointer<Void> hMem);

// File time structure
base class FILETIME extends Struct {
  @Uint32()
  external int dwLowDateTime;
  @Uint32()
  external int dwHighDateTime;
}

class WindowInfo {
  final String windowTitle;
  final String processName;
  final int processId;
  final int parentProcessId;
  final String parentProcessName;

  WindowInfo({
    required this.windowTitle, 
    required this.processName, 
    required this.processId,
    required this.parentProcessId,
    required this.parentProcessName,
  });

  @override
  String toString() {
    return 'WindowInfo(title: $windowTitle, process: $processName, pid: $processId, parent: $parentProcessName, parentPid: $parentProcessId)';
  }
}

class AppLaunchInfo {
  final int processId;
  final int parentProcessId;
  final String parentProcessName;
  final bool wasStartedWithSystem;
  final bool isSystemLaunched;
  final bool isRegisteredAutoStart;
  final List<String> commandLineArgs;
  final String launchType;

  AppLaunchInfo({
    required this.processId,
    required this.parentProcessId,
    required this.parentProcessName,
    required this.wasStartedWithSystem,
    required this.isSystemLaunched,
    required this.isRegisteredAutoStart,
    required this.commandLineArgs,
    required this.launchType,
  });

  @override
  String toString() {
    return 'AppLaunchInfo(processId: $processId, parentProcessId: $parentProcessId, parentProcessName: $parentProcessName, wasStartedWithSystem: $wasStartedWithSystem, isSystemLaunched: $isSystemLaunched, isRegisteredAutoStart: $isRegisteredAutoStart, commandLineArgs: $commandLineArgs, launchType: $launchType)';
  }
}

class ForegroundWindowPlugin {
  static final DynamicLibrary _user32 = DynamicLibrary.open('user32.dll');
  static final DynamicLibrary _kernel32 = DynamicLibrary.open('kernel32.dll');
  static final DynamicLibrary _psapi = DynamicLibrary.open('psapi.dll');
  static final DynamicLibrary _advapi32 = DynamicLibrary.open('advapi32.dll');
  static final DynamicLibrary _shell32 = DynamicLibrary.open('shell32.dll');

  // Load native functions
  static final GetForegroundWindowDart _getForegroundWindow = 
    _user32.lookupFunction<GetForegroundWindowNative, GetForegroundWindowDart>('GetForegroundWindow');

  static final GetWindowTextDart _getWindowText = 
    _user32.lookupFunction<GetWindowTextNative, GetWindowTextDart>('GetWindowTextA');

  static final GetWindowThreadProcessIdDart _getWindowThreadProcessId = 
    _user32.lookupFunction<GetWindowThreadProcessIdNative, GetWindowThreadProcessIdDart>('GetWindowThreadProcessId');

  static final OpenProcessDart _openProcess = 
    _kernel32.lookupFunction<OpenProcessNative, OpenProcessDart>('OpenProcess');

  static final GetModuleFileNameExADart _getModuleFileNameExA = 
    _psapi.lookupFunction<GetModuleFileNameExANative, GetModuleFileNameExADart>('GetModuleFileNameExA');

  static final CloseHandleDart _closeHandle = 
    _kernel32.lookupFunction<CloseHandleNative, CloseHandleDart>('CloseHandle');

  static final GetCurrentProcessDart _getCurrentProcess = 
    _kernel32.lookupFunction<GetCurrentProcessNative, GetCurrentProcessDart>('GetCurrentProcess');

  static final GetCurrentProcessIdDart _getCurrentProcessId = 
    _kernel32.lookupFunction<GetCurrentProcessIdNative, GetCurrentProcessIdDart>('GetCurrentProcessId');

  static final CreateToolhelp32SnapshotDart _createToolhelp32Snapshot = 
    _kernel32.lookupFunction<CreateToolhelp32SnapshotNative, CreateToolhelp32SnapshotDart>('CreateToolhelp32Snapshot');

  static final Process32FirstDart _process32First = 
    _kernel32.lookupFunction<Process32FirstNative, Process32FirstDart>('Process32First');

  static final Process32NextDart _process32Next = 
    _kernel32.lookupFunction<Process32NextNative, Process32NextDart>('Process32Next');

  // Registry functions
  static final RegOpenKeyExADart _regOpenKeyExA = 
    _advapi32.lookupFunction<RegOpenKeyExANative, RegOpenKeyExADart>('RegOpenKeyExA');

  static final RegEnumValueADart _regEnumValueA = 
    _advapi32.lookupFunction<RegEnumValueANative, RegEnumValueADart>('RegEnumValueA');

  static final RegCloseKeyDart _regCloseKey = 
    _advapi32.lookupFunction<RegCloseKeyNative, RegCloseKeyDart>('RegCloseKey');

  // Process time functions
  static final GetProcessTimesDart _getProcessTimes = 
    _kernel32.lookupFunction<GetProcessTimesNative, GetProcessTimesDart>('GetProcessTimes');

  static final GetSystemTimeAsFileTimeDart _getSystemTimeAsFileTime = 
    _kernel32.lookupFunction<GetSystemTimeAsFileTimeNative, GetSystemTimeAsFileTimeDart>('GetSystemTimeAsFileTime');

  static final GetTickCount64Dart _getTickCount64 = 
    _kernel32.lookupFunction<GetTickCount64Native, GetTickCount64Dart>('GetTickCount64');

  // Command line functions
  static final GetCommandLineWDart _getCommandLineW = 
    _kernel32.lookupFunction<GetCommandLineWNative, GetCommandLineWDart>('GetCommandLineW');

  static final CommandLineToArgvWDart _commandLineToArgvW = 
    _shell32.lookupFunction<CommandLineToArgvWNative, CommandLineToArgvWDart>('CommandLineToArgvW');

  static final LocalFreeDart _localFree = 
    _kernel32.lookupFunction<LocalFreeNative, LocalFreeDart>('LocalFree');

  // Constant definitions
  static const int processQueryInformation = 0x0400;
  static const int processVMRead = 0x0010;
  static const int th32csSnapProcess = 0x00000002;
  static const int invalidHandleValue = -1;
  static const int hkeyCurrentUser = 0x80000001;
  static const int hkeyLocalMachine = 0x80000002;
  static const int keyRead = 0x20019;
  static const int errorSuccess = 0;

  static Future<WindowInfo> getForegroundWindowInfo() async {
    return await compute(_getForegroundWindowInfoNative, null);
  }

  static WindowInfo _getForegroundWindowInfoNative(dynamic _) {
    // Get foreground window handle
    final hwnd = _getForegroundWindow();
    if (hwnd.address == 0) {
      throw Exception('No foreground window found');
    }

    // Get process ID
    final processIdPtr = calloc<Uint32>();
    _getWindowThreadProcessId(hwnd, processIdPtr);
    final processId = processIdPtr.value;
    calloc.free(processIdPtr);

    // Get window title
    final titlePtr = calloc<Char>(256);
    final titleLength = _getWindowText(hwnd, titlePtr, 256);
    final windowTitle = titlePtr.cast<Utf8>().toDartString(length: titleLength);
    calloc.free(titlePtr);

    // Open process
    final hProcess = _openProcess(
      processQueryInformation | processVMRead, 
      0, 
      processId
    );

    if (hProcess.address == 0) {
      throw Exception('Failed to open process');
    }

    // Get process name
    final processNamePtr = calloc<Char>(maxPath);
    final result = _getModuleFileNameExA(hProcess, nullptr, processNamePtr, maxPath);

    String processName;
    if (result > 0) {
      processName = processNamePtr.cast<Utf8>().toDartString(length: result);
    } else {
      processName = 'Unknown';
    }
    
    // Get parent process ID and name
    final parentProcessId = _getParentProcessId(processId);
    final parentProcessName = _getProcessName(parentProcessId);
    
    // Clean up
    calloc.free(processNamePtr);
    _closeHandle(hProcess);

    return WindowInfo(
      windowTitle: windowTitle, 
      processName: processName, 
      processId: processId,
      parentProcessId: parentProcessId,
      parentProcessName: parentProcessName
    );
  }

  static int _getParentProcessId(int processId) {
    int parentProcessId = 0;
    
    // Create snapshot of all processes
    final hSnapshot = _createToolhelp32Snapshot(th32csSnapProcess, 0);
    if (hSnapshot.address == invalidHandleValue) {
      return parentProcessId;
    }
    
    // Allocate and initialize PROCESSENTRY32 structure
    final processEntry = calloc<PROCESSENTRY32>();
    processEntry.ref.dwSize = sizeOf<PROCESSENTRY32>();
    
    // Loop through processes to find parent
    if (_process32First(hSnapshot, processEntry) != 0) {
      do {
        if (processEntry.ref.th32ProcessID == processId) {
          parentProcessId = processEntry.ref.th32ParentProcessID;
          break;
        }
      } while (_process32Next(hSnapshot, processEntry) != 0);
    }
    
    // Clean up
    calloc.free(processEntry);
    _closeHandle(hSnapshot);
    
    return parentProcessId;
  }

  static String _getProcessName(int processId) {
    if (processId == 0) return "System";
    
    final hProcess = _openProcess(processQueryInformation | processVMRead, 0, processId);
    if (hProcess.address == 0) {
      return "Unknown";
    }
    
    final processNamePtr = calloc<Char>(maxPath);
    final result = _getModuleFileNameExA(hProcess, nullptr, processNamePtr, maxPath);
    
    String processName;
    if (result > 0) {
      processName = processNamePtr.cast<Utf8>().toDartString(length: result);
    } else {
      processName = "Unknown";
    }
    
    // Clean up
    calloc.free(processNamePtr);
    _closeHandle(hProcess);
    
    return processName;
  }

  static bool _isRegisteredForAutoStart() {
    bool result = false;
    
    // Get current executable path
    final exePathPtr = calloc<Char>(maxPath);
    final hProcess = _getCurrentProcess();
    final pathLength = _getModuleFileNameExA(hProcess, nullptr, exePathPtr, maxPath);
    
    if (pathLength == 0) {
      calloc.free(exePathPtr);
      return false;
    }
    
    final exePath = exePathPtr.cast<Utf8>().toDartString(length: pathLength);
    calloc.free(exePathPtr);
    
    // Check HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Run
    result = _checkRegistryKeyForAutostart(hkeyCurrentUser, exePath);
    
    // If not found in HKCU, check HKEY_LOCAL_MACHINE
    if (!result) {
      result = _checkRegistryKeyForAutostart(hkeyLocalMachine, exePath);
    }
    
    return result;
  }
  
  static bool _checkRegistryKeyForAutostart(int rootKey, String exePath) {
    final keyPtr = "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run".toNativeUtf8().cast<Char>();
    final keyHandlePtr = calloc<IntPtr>();
    
    try {
      if (_regOpenKeyExA(rootKey, keyPtr, 0, keyRead, keyHandlePtr) != errorSuccess) {
        return false;
      }
      
      final keyHandle = keyHandlePtr.value;
      final valueNamePtr = calloc<Char>(maxPath);
      final valueNameSizePtr = calloc<Uint32>();
      final valueDataPtr = calloc<Uint8>(maxPath);
      final valueDataSizePtr = calloc<Uint32>();
      final valueTypePtr = calloc<Uint32>();
      
      bool found = false;
      int index = 0;
      
      while (true) {
        valueNameSizePtr.value = maxPath;
        valueDataSizePtr.value = maxPath;
        
        final enumResult = _regEnumValueA(
          keyHandle, 
          index, 
          valueNamePtr, 
          valueNameSizePtr, 
          nullptr, 
          valueTypePtr, 
          valueDataPtr, 
          valueDataSizePtr
        );
        
        if (enumResult != errorSuccess) break;
        
        // Convert value data to string and check if it contains our exe path
        final data = valueDataPtr.cast<Utf8>().toDartString(length: valueDataSizePtr.value);
        if (data.contains(exePath)) {
          found = true;
          break;
        }
        
        index++;
      }
      
      _regCloseKey(keyHandle);
      
      calloc.free(valueNamePtr);
      calloc.free(valueNameSizePtr);
      calloc.free(valueDataPtr);
      calloc.free(valueDataSizePtr);
      calloc.free(valueTypePtr);
      
      return found;
    } finally {
      calloc.free(keyPtr);
      calloc.free(keyHandlePtr);
    }
  }
  
  static bool _wasStartedWithSystem() {
    // Get process creation time
    final hProcess = _getCurrentProcess();
    final creationTimePtr = calloc<FILETIME>();
    final exitTimePtr = calloc<FILETIME>();
    final kernelTimePtr = calloc<FILETIME>();
    final userTimePtr = calloc<FILETIME>();
    
    final result = _getProcessTimes(
      hProcess, 
      creationTimePtr, 
      exitTimePtr, 
      kernelTimePtr, 
      userTimePtr
    );
    
    if (result == 0) {
      calloc.free(creationTimePtr);
      calloc.free(exitTimePtr);
      calloc.free(kernelTimePtr);
      calloc.free(userTimePtr);
      return false;
    }
    
    // Get current system time
    final systemTimePtr = calloc<FILETIME>();
    _getSystemTimeAsFileTime(systemTimePtr);
    
    // Get system uptime in milliseconds
    final uptime = _getTickCount64();
    
    // Calculate system boot time by subtracting uptime from current time
    final systemTime = (systemTimePtr.ref.dwHighDateTime.toDouble() * 4294967296 + 
                       systemTimePtr.ref.dwLowDateTime);
    
    final processTime = (creationTimePtr.ref.dwHighDateTime.toDouble() * 4294967296 + 
                       creationTimePtr.ref.dwLowDateTime);
    
    // Convert uptime from milliseconds to 100-nanosecond intervals (FILETIME units)
    final uptimeInFileTime = uptime * 10000;
    final bootTime = systemTime - uptimeInFileTime;
    
    // If process started within 60 seconds of boot, it's likely auto-started
    // Calculate time difference in seconds (100-nanoseconds -> seconds)
    final diffInSeconds = (processTime - bootTime) / 10000000;
    
    calloc.free(creationTimePtr);
    calloc.free(exitTimePtr);
    calloc.free(kernelTimePtr);
    calloc.free(userTimePtr);
    calloc.free(systemTimePtr);
    
    return diffInSeconds < 60;
  }
  
  static List<String> _getCommandLineArgs() {
    final List<String> args = [];

    final cmdLine = _getCommandLineW();
    final argcPtr = calloc<Int32>();

    final argv = _commandLineToArgvW(cmdLine, argcPtr);
    if (argv != nullptr) {
      final argc = argcPtr.value;

      for (int i = 0; i < argc; i++) {
        final Pointer<Utf16> argPtr = argv[i]; // Use indexing instead of elementAt(i).value
        args.add(argPtr.toDartString()); // Convert Utf16 pointer to Dart string
      }

      _localFree(argv.cast());
    }

    calloc.free(argcPtr);
    return args;
  }


  static Future<AppLaunchInfo> getAppLaunchInfo() async {
    return await compute(_getAppLaunchInfoNative, null);
  }

  static AppLaunchInfo _getAppLaunchInfoNative(dynamic _) {
    // Get current process ID
    final processId = _getCurrentProcessId();
    
    // Get parent process ID and name
    final parentProcessId = _getParentProcessId(processId);
    final parentProcessName = _getProcessName(parentProcessId);
    
    // Check if registered for auto-start in registry
    final isRegisteredAutoStart = _isRegisteredForAutoStart();
    
    // Check if started with system boot
    final wasStartedWithSystem = _wasStartedWithSystem();
    
    // Get command line arguments
    final commandLineArgs = _getCommandLineArgs();
    
    // Determine if we were launched with Windows
    bool isSystemLaunched = false;
    
    // Check if the parent process is a system process
    final lowerParentName = parentProcessName.toLowerCase();
    if (lowerParentName.contains("svchost") || 
        lowerParentName.contains("winlogon") ||
        lowerParentName.contains("csrss") ||
        lowerParentName.contains("smss") ||
        lowerParentName.contains("services") ||
        lowerParentName.contains("wininit") ||
        lowerParentName.contains("userinit") ||
        lowerParentName.contains("taskeng") ||
        lowerParentName.contains("taskhost") ||
        lowerParentName.contains("dwm") ||
        lowerParentName.contains("startmenuexperiencehost")) {
      
      isSystemLaunched = true;
    }
    
    // If parent is explorer.exe, it's likely user-launched (by clicking)
    if (lowerParentName.contains("explorer.exe")) {
      isSystemLaunched = false;
    }
    
    // Make a launch type determination
    String launchType = "USER_LAUNCHED";
    
    bool hasAutoStartParent = 
        lowerParentName.isNotEmpty &&
        !lowerParentName.contains("explorer.exe") && 
        (lowerParentName.contains("svchost.exe") ||
         lowerParentName.contains("winlogon.exe") ||
         lowerParentName.contains("userinit.exe") ||
         lowerParentName.contains("taskeng.exe") ||
         lowerParentName.contains("startmenuexperiencehost.exe"));
    
    if (wasStartedWithSystem || isRegisteredAutoStart || hasAutoStartParent) {
      launchType = "SYSTEM_LAUNCHED";
    }
    
    return AppLaunchInfo(
      processId: processId,
      parentProcessId: parentProcessId,
      parentProcessName: parentProcessName,
      wasStartedWithSystem: wasStartedWithSystem,
      isSystemLaunched: isSystemLaunched,
      isRegisteredAutoStart: isRegisteredAutoStart,
      commandLineArgs: commandLineArgs,
      launchType: launchType,
    );
  }

  static Future<bool> wasLaunchedBySystem() async {
    final launchInfo = await getAppLaunchInfo();
    return launchInfo.isSystemLaunched;
  }
}