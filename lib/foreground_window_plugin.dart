import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';

// Define constants
const int MAX_PATH = 260; // Standard Windows MAX_PATH length

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

class WindowInfo {
  final String windowTitle;
  final String processName;
  final int processId;

  WindowInfo({
    required this.windowTitle, 
    required this.processName, 
    required this.processId
  });

  @override
  String toString() {
    return 'WindowInfo(title: $windowTitle, process: $processName, pid: $processId)';
  }
}

class ForegroundWindowPlugin {
  static final DynamicLibrary _user32 = DynamicLibrary.open('user32.dll');
  static final DynamicLibrary _kernel32 = DynamicLibrary.open('kernel32.dll');
  static final DynamicLibrary _psapi = DynamicLibrary.open('psapi.dll');

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

  // Constant definitions
  static const int PROCESS_QUERY_INFORMATION = 0x0400;
  static const int PROCESS_VM_READ = 0x0010;

  static Future<WindowInfo> getForegroundWindowInfo() async {
    return await compute(_getForegroundWindowInfoNative, null);
  }

  static WindowInfo _getForegroundWindowInfoNative(dynamic _) {
    // Get foreground window handle
    final hwnd = _getForegroundWindow();
    if (hwnd == nullptr) {
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
      PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, 
      0, 
      processId
    );

    if (hProcess == nullptr) {
      throw Exception('Failed to open process');
    }

    // Get process name
    final processNamePtr = calloc<Char>(MAX_PATH);
    final result = _getModuleFileNameExA(hProcess, nullptr, processNamePtr, MAX_PATH);

    String processName;
    if (result > 0) {
      processName = processNamePtr.cast<Utf8>().toDartString(length: result);
    } else {
      processName = 'Unknown';
    }
    calloc.free(processNamePtr);

    return WindowInfo(
      windowTitle: windowTitle, 
      processName: processName, 
      processId: processId
    );
  }
}