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

// Version Info related function signatures
typedef GetFileVersionInfoSizeANative = Uint32 Function(
  Pointer<Char> lptstrFilename,
  Pointer<Uint32> lpdwHandle
);
typedef GetFileVersionInfoSizeADart = int Function(
  Pointer<Char> lptstrFilename,
  Pointer<Uint32> lpdwHandle
);

typedef GetFileVersionInfoANative = Int32 Function(
  Pointer<Char> lptstrFilename,
  Uint32 dwHandle,
  Uint32 dwLen,
  Pointer<Void> lpData
);
typedef GetFileVersionInfoADart = int Function(
  Pointer<Char> lptstrFilename,
  int dwHandle,
  int dwLen,
  Pointer<Void> lpData
);

typedef VerQueryValueANative = Int32 Function(
  Pointer<Void> pBlock,
  Pointer<Char> lpSubBlock,
  Pointer<Pointer<Void>> lplpBuffer,
  Pointer<Uint32> puLen
);
typedef VerQueryValueADart = int Function(
  Pointer<Void> pBlock,
  Pointer<Char> lpSubBlock,
  Pointer<Pointer<Void>> lplpBuffer,
  Pointer<Uint32> puLen
);

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
  final String executableName;
  final String programName;
  final int processId;
  final int parentProcessId;
  final String parentProcessName;

  WindowInfo({
    required this.windowTitle, 
    required this.processName, 
    required this.executableName,
    required this.programName,
    required this.processId,
    required this.parentProcessId,
    required this.parentProcessName,
  });

  @override
  String toString() {
    return 'WindowInfo(title: $windowTitle, process: $processName, executable: $executableName, program: $programName, pid: $processId, parent: $parentProcessName, parentPid: $parentProcessId)';
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
  static String _safeDartString(Pointer<Char> ptr, {int? length}) {
    try {
      return ptr.cast<Utf8>().toDartString(length: length);
    } catch (e) {
      // Handle invalid UTF-8 encoding
      if (length != null) {
        // Try to manually convert bytes to string with replacement character
        final bytes = <int>[];
        for (int i = 0; i < length; i++) {
          final charCode = ptr[i];
          // Filter out invalid bytes or replace with Unicode replacement character
          bytes.add(charCode < 0 ? 0xFFFD : charCode);
        }
        return String.fromCharCodes(bytes);
      }
      return "Unknown";
    }
  }
  static final DynamicLibrary _user32 = DynamicLibrary.open('user32.dll');
  static final DynamicLibrary _kernel32 = DynamicLibrary.open('kernel32.dll');
  static final DynamicLibrary _psapi = DynamicLibrary.open('psapi.dll');
  static final DynamicLibrary _advapi32 = DynamicLibrary.open('advapi32.dll');
  static final DynamicLibrary _shell32 = DynamicLibrary.open('shell32.dll');
  static final DynamicLibrary _version = DynamicLibrary.open('version.dll');

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

  // Version info functions
  static final GetFileVersionInfoSizeADart _getFileVersionInfoSizeA = 
    _version.lookupFunction<GetFileVersionInfoSizeANative, GetFileVersionInfoSizeADart>('GetFileVersionInfoSizeA');

  static final GetFileVersionInfoADart _getFileVersionInfoA = 
    _version.lookupFunction<GetFileVersionInfoANative, GetFileVersionInfoADart>('GetFileVersionInfoA');

  static final VerQueryValueADart _verQueryValueA = 
    _version.lookupFunction<VerQueryValueANative, VerQueryValueADart>('VerQueryValueA');

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

    static String _extractExecutableName(String fullPath) {
    if (fullPath.isEmpty) return "Unknown";
    
    // Extract filename from path
    final lastSeparator = fullPath.lastIndexOf('\\');
    String fileName = (lastSeparator != -1 && lastSeparator < fullPath.length - 1)
        ? fullPath.substring(lastSeparator + 1)
        : fullPath;
    
    // Remove .exe extension if present (case-insensitive)
    if (fileName.toLowerCase().endsWith('.exe')) {
      fileName = fileName.substring(0, fileName.length - 4);
    }
    
    // Capitalize first letter
    if (fileName.isNotEmpty) {
      fileName = fileName[0].toUpperCase() + (fileName.length > 1 ? fileName.substring(1) : '');
    }
    
    // Make it more readable by replacing underscores and hyphens with spaces
    fileName = fileName.replaceAll('_', ' ').replaceAll('-', ' ');
    
    // Capitalize after spaces (for multi-word names)
    final words = fileName.split(' ');
    if (words.length > 1) {
      for (int i = 1; i < words.length; i++) {
        if (words[i].isNotEmpty) {
          words[i] = words[i][0].toUpperCase() + (words[i].length > 1 ? words[i].substring(1) : '');
        }
      }
      fileName = words.join(' ');
    }
    
    return fileName;
  }

  static String _cleanProgramName(String name) {
    if (name.isEmpty) return name;
    
    // Remove .exe extension if present (case-insensitive)
    String cleaned = name;
    if (cleaned.toLowerCase().endsWith('.exe')) {
      cleaned = cleaned.substring(0, cleaned.length - 4);
    }
    
    return cleaned;
  }

  static String _getProgramNameFromVersionInfo(String fullPath) {
    if (fullPath.isEmpty || fullPath == "Unknown") return fullPath;
    
    final pathPtr = fullPath.toNativeUtf8().cast<Char>();
    final handlePtr = calloc<Uint32>();
    
    try {
      final versionInfoSize = _getFileVersionInfoSizeA(pathPtr, handlePtr);
      if (versionInfoSize <= 0) {
        return _extractExecutableName(fullPath);
      }
      
      final versionInfoPtr = calloc<Uint8>(versionInfoSize);
      final result = _getFileVersionInfoA(pathPtr, 0, versionInfoSize, versionInfoPtr.cast());
      if (result == 0) {
        calloc.free(versionInfoPtr);
        return _extractExecutableName(fullPath);
      }
      
      // Try common language codes for FileDescription or ProductName
      final languageCodes = [
        "\\StringFileInfo\\040904B0", // English US
        "\\StringFileInfo\\040904E4", // English US
        "\\StringFileInfo\\080404B0", // Chinese PRC
        "\\StringFileInfo\\040704B0", // German
        "\\StringFileInfo\\040C04B0", // French
        "\\StringFileInfo\\041904B0", // Russian
        "\\StringFileInfo\\040A04B0", // Spanish
      ];
      
      for (final langCode in languageCodes) {
        // Try FileDescription first
        final fileDescPath = "$langCode\\FileDescription";
        final fileDescPathPtr = fileDescPath.toNativeUtf8().cast<Char>();
        final bufferPtr = calloc<Pointer<Void>>();
        final lengthPtr = calloc<Uint32>();
        
        try {
          if (_verQueryValueA(versionInfoPtr.cast(), fileDescPathPtr, bufferPtr, lengthPtr) != 0 && 
              lengthPtr.value > 0) {
            final programName = bufferPtr.value.cast<Utf8>().toDartString();
            calloc.free(versionInfoPtr);
            return _cleanProgramName(programName);
          }
        } finally {
          calloc.free(fileDescPathPtr);
          calloc.free(bufferPtr);
          calloc.free(lengthPtr);
        }
        
        // Try ProductName if FileDescription fails
        final productNamePath = "$langCode\\ProductName";
        final productNamePathPtr = productNamePath.toNativeUtf8().cast<Char>();
        final pBufferPtr = calloc<Pointer<Void>>();
        final pLengthPtr = calloc<Uint32>();
        
        try {
          if (_verQueryValueA(versionInfoPtr.cast(), productNamePathPtr, pBufferPtr, pLengthPtr) != 0 && 
              pLengthPtr.value > 0) {
            final programName = pBufferPtr.value.cast<Utf8>().toDartString();
            calloc.free(versionInfoPtr);
            return _cleanProgramName(programName);
          }
        } finally {
          calloc.free(productNamePathPtr);
          calloc.free(pBufferPtr);
          calloc.free(pLengthPtr);
        }
      }
      
      calloc.free(versionInfoPtr);
      return _extractExecutableName(fullPath);
    } catch (e) {
      return _extractExecutableName(fullPath);
    } finally {
      calloc.free(pathPtr);
      calloc.free(handlePtr);
    }
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
    final windowTitle = _safeDartString(titlePtr, length: titleLength);
    calloc.free(titlePtr);

    // Initialize variables with default values
    String processName = 'Unknown';
    String executableName = 'Unknown';
    String programName = 'Unknown';
    int parentProcessId = 0;
    String parentProcessName = 'Unknown';

    // Open process - handle potential failure
    final hProcess = _openProcess(
      processQueryInformation | processVMRead, 
      0, 
      processId
    );

    if (hProcess.address != 0) {
      // Process opened successfully - get detailed information
      final processNamePtr = calloc<Char>(maxPath);
      final result = _getModuleFileNameExA(hProcess, nullptr, processNamePtr, maxPath);

      if (result > 0) {
        processName = processNamePtr.cast<Utf8>().toDartString(length: result);
        // Extract executable name
        executableName = _extractExecutableName(processName);
        // Get program name from version info
        programName = _getProgramNameFromVersionInfo(processName);
      }
      
      calloc.free(processNamePtr);
      
      // Get parent process info if process handle is valid
      parentProcessId = _getParentProcessId(processId);
      parentProcessName = _getProcessName(parentProcessId);
      
      // Clean up
      _closeHandle(hProcess);
    } else {
      // Process can't be opened - likely due to privileges
      // Try alternative methods to get basic information

      // Get executable name from window class
      final classNamePtr = calloc<Char>(256);
      // _getClassName(hwnd, classNamePtr, 256);
      String className = classNamePtr.cast<Utf8>().toDartString();
      calloc.free(classNamePtr);

      // Some processes have recognizable class names
      if (className.contains('Chrome')) {
        executableName = 'chrome.exe';
        programName = 'Google Chrome';
      } else if (className.contains('Firefox')) {
        executableName = 'firefox.exe';
        programName = 'Mozilla Firefox';
      } else {
        // Use window title as a fallback for program name
        executableName = 'Unknown';
        programName = windowTitle.isNotEmpty ? windowTitle : 'Protected Application';
      }

      // Try getting process name and parent info using alternative methods
      // like WMI or Process Enumeration, but this would require additional code
      parentProcessId = 0; // We'll use 0 to indicate "unknown" for parent process ID
    }

    return WindowInfo(
      windowTitle: windowTitle, 
      processName: processName, 
      executableName: executableName,
      programName: programName,
      processId: processId,
      parentProcessId: parentProcessId,
      parentProcessName: parentProcessName,
      
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
}