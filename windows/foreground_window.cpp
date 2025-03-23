#include "include/foreground_window/foreground_window_plugin.h"

#include <windows.h>
#include <psapi.h>
#include <tlhelp32.h>
#include <string>
#include <vector>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <flutter/encodable_value.h>

class ForegroundWindowPlugin : public flutter::Plugin {
public:
    static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar) {
        auto channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
            registrar->messenger(),
            "foreground_window_plugin",
            &flutter::StandardMethodCodec::GetInstance()
        );
        auto plugin = std::make_unique<ForegroundWindowPlugin>();
        channel->SetMethodCallHandler(
            [plugin = plugin.get()](const flutter::MethodCall<flutter::EncodableValue>& call,
               std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
                plugin->HandleMethodCall(call, std::move(result));
            }
        );
        registrar->AddPlugin(std::move(plugin));
    }

    ForegroundWindowPlugin() {}

private:
    // Get parent process ID
    DWORD GetParentProcessId(DWORD processId) {
        DWORD parentProcessId = 0;
        HANDLE hSnapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
        
        if (hSnapshot != INVALID_HANDLE_VALUE) {
            PROCESSENTRY32 pe32;
            pe32.dwSize = sizeof(PROCESSENTRY32);
            
            if (Process32First(hSnapshot, &pe32)) {
                do {
                    if (pe32.th32ProcessID == processId) {
                        parentProcessId = pe32.th32ParentProcessID;
                        break;
                    }
                } while (Process32Next(hSnapshot, &pe32));
            }
            CloseHandle(hSnapshot);
        }
        
        return parentProcessId;
    }

    // Check if app is registered for auto-start
    bool IsRegisteredForAutoStart() {
        HKEY hKey;
        bool result = false;
        
        // Get current executable path
        char exePath[MAX_PATH] = {0};
        GetModuleFileNameA(NULL, exePath, MAX_PATH);
        
        // Check HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run
        if (RegOpenKeyExA(HKEY_CURRENT_USER, "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run", 0, KEY_READ, &hKey) == ERROR_SUCCESS) {
            char value[MAX_PATH] = {0};
            DWORD valueSize = sizeof(value);
            
            char valueName[MAX_PATH];
            DWORD valueNameSize = MAX_PATH;
            DWORD index = 0;
            
            while (RegEnumValueA(hKey, index, valueName, &valueNameSize, NULL, NULL, (LPBYTE)value, &valueSize) == ERROR_SUCCESS) {
                if (strstr(value, exePath) != NULL) {
                    result = true;
                    break;
                }
                
                valueNameSize = MAX_PATH;
                valueSize = sizeof(value);
                index++;
            }
            
            RegCloseKey(hKey);
        }
        
        // Also check HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run
        if (!result && RegOpenKeyExA(HKEY_LOCAL_MACHINE, "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run", 0, KEY_READ, &hKey) == ERROR_SUCCESS) {
            char value[MAX_PATH] = {0};
            DWORD valueSize = sizeof(value);
            
            char valueName[MAX_PATH];
            DWORD valueNameSize = MAX_PATH;
            DWORD index = 0;
            
            while (RegEnumValueA(hKey, index, valueName, &valueNameSize, NULL, NULL, (LPBYTE)value, &valueSize) == ERROR_SUCCESS) {
                if (strstr(value, exePath) != NULL) {
                    result = true;
                    break;
                }
                
                valueNameSize = MAX_PATH;
                valueSize = sizeof(value);
                index++;
            }
            
            RegCloseKey(hKey);
        }
        
        return result;
    }

    // Check process start time relative to system boot
    bool WasStartedWithSystem() {
        FILETIME processTime, systemTime, exitTime, kernelTime, userTime;
        
        // Get process creation time
        HANDLE hProcess = GetCurrentProcess();
        GetProcessTimes(hProcess, &processTime, &exitTime, &kernelTime, &userTime);
        
        // Get current system time
        GetSystemTimeAsFileTime(&systemTime);
        
        // Get system uptime in milliseconds
        ULARGE_INTEGER uptime;
        uptime.QuadPart = GetTickCount64();
        
        // Calculate system boot time by subtracting uptime from current time
        ULARGE_INTEGER ulSystemTime, ulProcessTime, ulBootTime;
        ulSystemTime.LowPart = systemTime.dwLowDateTime;
        ulSystemTime.HighPart = systemTime.dwHighDateTime;
        
        ulProcessTime.LowPart = processTime.dwLowDateTime;
        ulProcessTime.HighPart = processTime.dwHighDateTime;
        
        // Convert uptime from milliseconds to 100-nanosecond intervals (FILETIME units)
        uptime.QuadPart *= 10000;
        ulBootTime.QuadPart = ulSystemTime.QuadPart - uptime.QuadPart;
        
        // If process started within 60 seconds of boot, it's likely auto-started
        // Calculate time difference in seconds
        ULONGLONG diffInSeconds = (ulProcessTime.QuadPart - ulBootTime.QuadPart) / 10000000;
        
        return diffInSeconds < 60;
    }

    // Get command line arguments
    std::vector<std::string> GetCommandLineArgs() {
        std::vector<std::string> args;
        LPWSTR commandLine = GetCommandLineW();
        int argc;
        LPWSTR* argv = CommandLineToArgvW(commandLine, &argc);
        
        if (argv) {
            for (int i = 0; i < argc; i++) {
                int size = WideCharToMultiByte(CP_UTF8, 0, argv[i], -1, nullptr, 0, nullptr, nullptr);
                std::string arg(size, 0);
                WideCharToMultiByte(CP_UTF8, 0, argv[i], -1, &arg[0], size, nullptr, nullptr);
                arg.resize(size - 1);  // Remove null terminator
                args.push_back(arg);
            }
            LocalFree(argv);
        }
        
        return args;
    }

    void HandleMethodCall(
        const flutter::MethodCall<flutter::EncodableValue>& call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) 
    {
        if (call.method_name() == "getForegroundWindow") {
            HWND hwnd = GetForegroundWindow();
            if (hwnd == NULL) {
                result->Error("NO_WINDOW", "No foreground window found");
                return;
            }
            
            // Get process ID
            DWORD processID;
            GetWindowThreadProcessId(hwnd, &processID);
            
            // Get window title
            char windowTitle[256] = {0};
            GetWindowTextA(hwnd, windowTitle, sizeof(windowTitle));
            
            // Open the process
            HANDLE hProcess = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, FALSE, processID);
            if (hProcess == NULL) {
                result->Error("PROCESS_ERROR", "Failed to open process");
                return;
            }
            
            // Get process name
            char processName[MAX_PATH] = {0};
            DWORD processNameLength = GetModuleFileNameExA(hProcess, NULL, processName, sizeof(processName));
            
            // Get parent process ID
            DWORD parentProcessId = GetParentProcessId(processID);
            
            // Get parent process name
            char parentProcessName[MAX_PATH] = {0};
            HANDLE hParentProcess = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, FALSE, parentProcessId);
            if (hParentProcess != NULL) {
                GetModuleFileNameExA(hParentProcess, NULL, parentProcessName, sizeof(parentProcessName));
                CloseHandle(hParentProcess);
            }
            
            // Close process handle
            CloseHandle(hProcess);
            
            // Prepare result
            flutter::EncodableMap resultMap = {
                {"windowTitle", std::string(windowTitle)},
                {"processName", processNameLength > 0 ? std::string(processName) : "Unknown"},
                {"processId", static_cast<int>(processID)},
                {"parentProcessId", static_cast<int>(parentProcessId)},
                {"parentProcessName", std::string(parentProcessName)}
            };
            
            result->Success(resultMap);
        } 
        else if (call.method_name() == "getAppLaunchInfo") {
            // Get current process ID
            DWORD processId = GetCurrentProcessId();
            
            // Get parent process details
            DWORD parentProcessId = GetParentProcessId(processId);
            char parentProcessName[MAX_PATH] = {0};
            HANDLE hParentProcess = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, FALSE, parentProcessId);
            if (hParentProcess != NULL) {
                GetModuleFileNameExA(hParentProcess, NULL, parentProcessName, sizeof(parentProcessName));
                CloseHandle(hParentProcess);
            }
            
            // Check auto-start registry
            bool isRegisteredAutoStart = IsRegisteredForAutoStart();
            
            // Check if started with system
            bool wasStartedWithSystem = WasStartedWithSystem();
            
            // Get command line args
            std::vector<std::string> args = GetCommandLineArgs();
            flutter::EncodableList argsList;
            for (const auto& arg : args) {
                argsList.push_back(arg);
            }
            
            // Make a launch type determination
            std::string launchType = "USER_LAUNCHED";
            
            // Check for common auto-start parent processes
            std::string parentName = std::string(parentProcessName);
            for (auto& c : parentName) {
                c = static_cast<char>(std::tolower(static_cast<unsigned char>(c)));
            }
            
            bool hasAutoStartParent = 
                parentName.find("explorer.exe") == std::string::npos && // Not launched by explorer (user click)
                (parentName.find("svchost.exe") != std::string::npos ||
                 parentName.find("winlogon.exe") != std::string::npos ||
                 parentName.find("userinit.exe") != std::string::npos ||
                 parentName.find("taskeng.exe") != std::string::npos ||
                 parentName.find("startmenuexperiencehost.exe") != std::string::npos);
            
            if (wasStartedWithSystem || isRegisteredAutoStart || hasAutoStartParent) {
                launchType = "SYSTEM_LAUNCHED";
            }
            
            // Prepare result
            flutter::EncodableMap resultMap = {
                {"processId", static_cast<int>(processId)},
                {"parentProcessId", static_cast<int>(parentProcessId)},
                {"parentProcessName", std::string(parentProcessName)},
                {"isRegisteredAutoStart", isRegisteredAutoStart},
                {"wasStartedWithSystem", wasStartedWithSystem},
                {"commandLineArgs", argsList},
                {"launchType", launchType}
            };
            
            result->Success(resultMap);
        }
        else {
            result->NotImplemented();
        }
    }
};

void ForegroundWindowPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  ForegroundWindowPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}