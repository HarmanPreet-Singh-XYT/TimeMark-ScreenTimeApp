#include <windows.h>
#include <psapi.h>
#include <string>
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

private:
    void HandleMethodCall(
        const flutter::MethodCall<flutter::EncodableValue>& call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result
    ) {
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

            // Close process handle
            CloseHandle(hProcess);

            // Prepare result
            flutter::EncodableMap resultMap = {
                {"windowTitle", std::string(windowTitle)},
                {"processName", processNameLength > 0 ? std::string(processName) : "Unknown"},
                {"processId", static_cast<int>(processID)}
            };

            result->Success(resultMap);
        } else {
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