// linux/foreground_window_plugin.cc

#include "include/foreground_window/foreground_window_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>

#include <cstring>
#include <string>
#include <fstream>
#include <sstream>
#include <vector>
#include <algorithm>
#include <cctype>
#include <memory>
#include <dirent.h>
#include <unistd.h>
#include <sys/stat.h>

#include <X11/Xlib.h>
#include <X11/Xatom.h>
#include <X11/Xutil.h>

// ═══════════════════════════════════════════════
//  /proc helpers
// ═══════════════════════════════════════════════

static std::string read_proc_link(pid_t pid, const char* entry) {
    char path[128];
    snprintf(path, sizeof(path), "/proc/%d/%s", pid, entry);
    char resolved[4096] = {0};
    ssize_t len = readlink(path, resolved, sizeof(resolved) - 1);
    if (len > 0) {
        resolved[len] = '\0';
        return std::string(resolved);
    }
    return "";
}

static std::string get_process_exe_path(pid_t pid) {
    return read_proc_link(pid, "exe");
}

static std::string get_process_comm(pid_t pid) {
    char path[128];
    snprintf(path, sizeof(path), "/proc/%d/comm", pid);
    std::ifstream f(path);
    std::string comm;
    if (f.is_open() && std::getline(f, comm)) {
        while (!comm.empty() && (comm.back() == '\n' || comm.back() == '\r'))
            comm.pop_back();
        return comm;
    }
    return "";
}

static pid_t get_parent_pid(pid_t pid) {
    char path[128];
    snprintf(path, sizeof(path), "/proc/%d/status", pid);
    std::ifstream f(path);
    std::string line;
    while (std::getline(f, line)) {
        if (line.rfind("PPid:", 0) == 0) {
            try {
                return static_cast<pid_t>(std::stol(line.substr(5)));
            } catch (...) {
                return 0;
            }
        }
    }
    return 0;
}

static std::string extract_executable_name(const std::string& full_path) {
    size_t pos = full_path.find_last_of('/');
    if (pos != std::string::npos)
        return full_path.substr(pos + 1);
    return full_path;
}

// ═══════════════════════════════════════════════
//  .desktop file lookup for friendly app name
// ═══════════════════════════════════════════════

static bool ends_with(const std::string& s, const std::string& suffix) {
    if (suffix.size() > s.size()) return false;
    return s.compare(s.size() - suffix.size(), suffix.size(), suffix) == 0;
}

static std::string str_tolower(std::string s) {
    std::transform(s.begin(), s.end(), s.begin(),
                   [](unsigned char c) { return std::tolower(c); });
    return s;
}

// Recursively scan a directory for .desktop files
static void scan_desktop_dir(const std::string& dir_path,
                              const std::string& exec_lower,
                              std::string& out_name) {
    if (!out_name.empty()) return;

    DIR* dir = opendir(dir_path.c_str());
    if (!dir) return;

    struct dirent* entry;
    while ((entry = readdir(dir)) != nullptr) {
        if (!out_name.empty()) break;

        std::string name = entry->d_name;
        if (name == "." || name == "..") continue;

        std::string full = dir_path + "/" + name;

        struct stat st;
        if (stat(full.c_str(), &st) != 0) continue;

        if (S_ISDIR(st.st_mode)) {
            scan_desktop_dir(full, exec_lower, out_name);
            continue;
        }

        if (!ends_with(name, ".desktop")) continue;

        std::ifstream f(full);
        if (!f.is_open()) continue;

        std::string line;
        std::string desktop_name;
        std::string desktop_exec;
        bool in_desktop_entry = false;

        while (std::getline(f, line)) {
            while (!line.empty() && (line.back() == '\r' || line.back() == '\n'))
                line.pop_back();

            if (line == "[Desktop Entry]") {
                in_desktop_entry = true;
                continue;
            }
            if (!line.empty() && line[0] == '[') {
                in_desktop_entry = false;
                continue;
            }
            if (!in_desktop_entry) continue;

            if (line.rfind("Name=", 0) == 0 && desktop_name.empty()) {
                desktop_name = line.substr(5);
            } else if (line.rfind("Exec=", 0) == 0 && desktop_exec.empty()) {
                desktop_exec = line.substr(5);
            }
        }

        if (desktop_exec.empty()) continue;

        // Extract binary name from Exec= line
        // Remove env vars like "env VAR=val ..."
        std::string exec_cmd = desktop_exec;

        // Handle "env VAR=val command" pattern
        while (exec_cmd.rfind("env ", 0) == 0) {
            size_t sp = exec_cmd.find(' ', 4);
            if (sp == std::string::npos) break;
            exec_cmd = exec_cmd.substr(sp + 1);
        }

        // Remove field codes (%u %U %f %F etc.) and flags
        size_t space_pos = exec_cmd.find(' ');
        if (space_pos != std::string::npos) {
            exec_cmd = exec_cmd.substr(0, space_pos);
        }

        // Remove quotes
        if (exec_cmd.size() >= 2 && exec_cmd.front() == '"' && exec_cmd.back() == '"') {
            exec_cmd = exec_cmd.substr(1, exec_cmd.size() - 2);
        }

        std::string exec_binary = extract_executable_name(exec_cmd);
        std::string exec_binary_lower = str_tolower(exec_binary);

        if (exec_binary_lower == exec_lower && !desktop_name.empty()) {
            out_name = desktop_name;
            break;
        }
    }

    closedir(dir);
}

static std::string find_desktop_name(const std::string& executable_name) {
    std::vector<std::string> search_dirs;

    // Standard dirs
    search_dirs.push_back("/usr/share/applications");
    search_dirs.push_back("/usr/local/share/applications");

    const char* home = getenv("HOME");
    if (home) {
        search_dirs.push_back(std::string(home) + "/.local/share/applications");
    }

    // Flatpak exports
    search_dirs.push_back("/var/lib/flatpak/exports/share/applications");
    if (home) {
        search_dirs.push_back(std::string(home) + "/.local/share/flatpak/exports/share/applications");
    }

    // Snap
    search_dirs.push_back("/var/lib/snapd/desktop/applications");

    // XDG_DATA_DIRS
    const char* xdg_data = getenv("XDG_DATA_DIRS");
    if (xdg_data) {
        std::istringstream stream(xdg_data);
        std::string dir;
        while (std::getline(stream, dir, ':')) {
            if (!dir.empty())
                search_dirs.push_back(dir + "/applications");
        }
    }

    std::string exec_lower = str_tolower(executable_name);
    std::string result;

    for (const auto& dir : search_dirs) {
        scan_desktop_dir(dir, exec_lower, result);
        if (!result.empty()) return result;
    }

    return "";
}

static std::string make_readable_name(const std::string& executable_name) {
    std::string name = executable_name;

    // Remove common extensions
    const char* extensions[] = {".bin", ".sh", ".py", ".AppImage", ".appimage"};
    for (const char* ext : extensions) {
        size_t pos = name.rfind(ext);
        if (pos != std::string::npos && pos + strlen(ext) == name.size()) {
            name = name.substr(0, pos);
        }
    }

    std::replace(name.begin(), name.end(), '_', ' ');
    std::replace(name.begin(), name.end(), '-', ' ');

    // Capitalize first letter of each word
    bool cap_next = true;
    for (size_t i = 0; i < name.size(); i++) {
        if (name[i] == ' ') {
            cap_next = true;
        } else if (cap_next) {
            name[i] = static_cast<char>(std::toupper(static_cast<unsigned char>(name[i])));
            cap_next = false;
        }
    }

    return name;
}

static std::string get_program_name(const std::string& full_process_path) {
    std::string exec_name = extract_executable_name(full_process_path);

    std::string desktop_name = find_desktop_name(exec_name);
    if (!desktop_name.empty()) return desktop_name;

    return make_readable_name(exec_name);
}

// ═══════════════════════════════════════════════
//  X11 helpers
// ═══════════════════════════════════════════════

struct X11Connection {
    Display* display;
    X11Connection() : display(XOpenDisplay(nullptr)) {}
    ~X11Connection() { if (display) XCloseDisplay(display); }
    operator bool() const { return display != nullptr; }
};

static Window x11_get_active_window(Display* display) {
    Atom active_atom = XInternAtom(display, "_NET_ACTIVE_WINDOW", True);
    if (active_atom == None) return 0;

    Window root = DefaultRootWindow(display);
    Atom actual_type;
    int actual_format;
    unsigned long nitems, bytes_after;
    unsigned char* prop = nullptr;

    int status = XGetWindowProperty(
        display, root, active_atom,
        0, 1, False, XA_WINDOW,
        &actual_type, &actual_format,
        &nitems, &bytes_after, &prop);

    Window active_window = 0;
    if (status == Success && prop && nitems > 0)
        active_window = *reinterpret_cast<Window*>(prop);
    if (prop) XFree(prop);

    return active_window;
}

static pid_t x11_get_window_pid(Display* display, Window window) {
    Atom pid_atom = XInternAtom(display, "_NET_WM_PID", True);
    if (pid_atom == None) return 0;

    Atom actual_type;
    int actual_format;
    unsigned long nitems, bytes_after;
    unsigned char* prop = nullptr;

    int status = XGetWindowProperty(
        display, window, pid_atom,
        0, 1, False, XA_CARDINAL,
        &actual_type, &actual_format,
        &nitems, &bytes_after, &prop);

    pid_t pid = 0;
    if (status == Success && prop && nitems > 0)
        pid = static_cast<pid_t>(*reinterpret_cast<unsigned long*>(prop));
    if (prop) XFree(prop);

    return pid;
}

static std::string x11_get_window_title(Display* display, Window window) {
    // Try _NET_WM_NAME (UTF-8)
    Atom net_name = XInternAtom(display, "_NET_WM_NAME", True);
    Atom utf8 = XInternAtom(display, "UTF8_STRING", True);

    if (net_name != None && utf8 != None) {
        Atom actual_type;
        int actual_format;
        unsigned long nitems, bytes_after;
        unsigned char* prop = nullptr;

        int status = XGetWindowProperty(
            display, window, net_name,
            0, 1024, False, utf8,
            &actual_type, &actual_format,
            &nitems, &bytes_after, &prop);

        if (status == Success && prop && nitems > 0) {
            std::string title(reinterpret_cast<char*>(prop));
            XFree(prop);
            return title;
        }
        if (prop) XFree(prop);
    }

    // Fallback: WM_NAME
    char* wm_name = nullptr;
    if (XFetchName(display, window, &wm_name) && wm_name) {
        std::string title(wm_name);
        XFree(wm_name);
        return title;
    }

    return "";
}

// ═══════════════════════════════════════════════
//  Foreground info struct
// ═══════════════════════════════════════════════

struct ForegroundInfo {
    std::string window_title;
    std::string process_path;
    std::string executable_name;
    std::string program_name;
    pid_t pid = 0;
    pid_t parent_pid = 0;
    std::string parent_process_path;
    bool success = false;
};

static void fill_process_info(ForegroundInfo& info) {
    if (info.pid <= 0) return;

    info.process_path = get_process_exe_path(info.pid);

    if (info.process_path.empty()) {
        // Fallback: use comm
        std::string comm = get_process_comm(info.pid);
        if (!comm.empty()) {
            info.executable_name = comm;
            info.program_name = find_desktop_name(comm);
            if (info.program_name.empty())
                info.program_name = make_readable_name(comm);
        }
    } else {
        info.executable_name = extract_executable_name(info.process_path);
        info.program_name = get_program_name(info.process_path);
    }

    info.parent_pid = get_parent_pid(info.pid);
    if (info.parent_pid > 0)
        info.parent_process_path = get_process_exe_path(info.parent_pid);
}

// ═══════════════════════════════════════════════
//  X11 path
// ═══════════════════════════════════════════════

static ForegroundInfo get_foreground_via_x11() {
    ForegroundInfo info;

    X11Connection conn;
    if (!conn) return info;

    Window active = x11_get_active_window(conn.display);
    if (active == 0) return info;

    info.window_title = x11_get_window_title(conn.display, active);
    info.pid = x11_get_window_pid(conn.display, active);
    fill_process_info(info);
    info.success = true;
    return info;
}

// ═══════════════════════════════════════════════
//  Shell command helper
// ═══════════════════════════════════════════════

static std::string exec_command(const char* cmd) {
    std::string result;
    FILE* pipe = popen(cmd, "r");
    if (!pipe) return result;

    char buffer[512];
    while (fgets(buffer, sizeof(buffer), pipe))
        result += buffer;
    pclose(pipe);

    while (!result.empty() &&
           (result.back() == '\n' || result.back() == '\r' || result.back() == ' '))
        result.pop_back();

    return result;
}

// ═══════════════════════════════════════════════
//  GNOME Wayland (gdbus Shell.Eval)
// ═══════════════════════════════════════════════

static ForegroundInfo get_foreground_via_gnome_dbus() {
    ForegroundInfo info;

    std::string output = exec_command(
        "gdbus call --session "
        "--dest org.gnome.Shell "
        "--object-path /org/gnome/Shell "
        "--method org.gnome.Shell.Eval "
        "\"global.display.focus_window ? "
        "global.display.focus_window.get_pid() + '|' + "
        "global.display.focus_window.get_title() : ''\" "
        "2>/dev/null");

    if (output.empty()) return info;

    // Parse: ('true', 'PID|Title')
    size_t last_q_end = output.rfind('\'');
    if (last_q_end == std::string::npos || last_q_end == 0) return info;
    size_t last_q_start = output.rfind('\'', last_q_end - 1);
    if (last_q_start == std::string::npos) return info;

    std::string content = output.substr(last_q_start + 1,
                                         last_q_end - last_q_start - 1);
    if (content.empty()) return info;

    size_t sep = content.find('|');
    if (sep == std::string::npos) return info;

    try {
        info.pid = static_cast<pid_t>(std::stol(content.substr(0, sep)));
    } catch (...) {
        return info;
    }
    info.window_title = content.substr(sep + 1);

    fill_process_info(info);
    info.success = true;
    return info;
}

// ═══════════════════════════════════════════════
//  Sway / wlroots / Hyprland
// ═══════════════════════════════════════════════

static ForegroundInfo get_foreground_via_sway() {
    ForegroundInfo info;

    // swaymsg -t get_tree with jq to find focused node
    std::string output = exec_command(
        "swaymsg -t get_tree 2>/dev/null | "
        "jq -r '.. | select(.focused? == true) | "
        "\"\\(.pid)|\\(.name)\"' 2>/dev/null | head -1");

    if (output.empty()) return info;

    size_t sep = output.find('|');
    if (sep == std::string::npos) return info;

    try {
        info.pid = static_cast<pid_t>(std::stol(output.substr(0, sep)));
    } catch (...) {
        return info;
    }
    info.window_title = output.substr(sep + 1);

    fill_process_info(info);
    info.success = true;
    return info;
}

static ForegroundInfo get_foreground_via_hyprland() {
    ForegroundInfo info;

    std::string output = exec_command(
        "hyprctl activewindow -j 2>/dev/null | "
        "jq -r '\"\\(.pid)|\\(.title)\"' 2>/dev/null");

    if (output.empty()) return info;

    size_t sep = output.find('|');
    if (sep == std::string::npos) return info;

    try {
        info.pid = static_cast<pid_t>(std::stol(output.substr(0, sep)));
    } catch (...) {
        return info;
    }
    info.window_title = output.substr(sep + 1);

    fill_process_info(info);
    info.success = true;
    return info;
}

// ═══════════════════════════════════════════════
//  KDE Plasma Wayland
// ═══════════════════════════════════════════════

static ForegroundInfo get_foreground_via_kde() {
    ForegroundInfo info;

    // kdotool approach
    std::string window_id = exec_command("kdotool getactivewindow 2>/dev/null");
    if (!window_id.empty()) {
        std::string cmd = "kdotool getwindowpid " + window_id + " 2>/dev/null";
        std::string pid_str = exec_command(cmd.c_str());

        cmd = "kdotool getwindowname " + window_id + " 2>/dev/null";
        std::string title = exec_command(cmd.c_str());

        if (!pid_str.empty()) {
            try {
                info.pid = static_cast<pid_t>(std::stol(pid_str));
                info.window_title = title;
                fill_process_info(info);
                info.success = true;
                return info;
            } catch (...) {}
        }
    }

    // qdbus fallback
    std::string output = exec_command(
        "qdbus org.kde.KWin /KWin org.kde.KWin.activeWindow 2>/dev/null");

    // KDE's qdbus path is more complex — this is best-effort
    return info;
}

// ═══════════════════════════════════════════════
//  Main dispatcher
// ═══════════════════════════════════════════════

static ForegroundInfo get_foreground_window_info() {
    const char* session_type = getenv("XDG_SESSION_TYPE");
    const char* wayland_display = getenv("WAYLAND_DISPLAY");
    const char* desktop_env = getenv("XDG_CURRENT_DESKTOP");

    bool is_wayland = (session_type && strcmp(session_type, "wayland") == 0) ||
                      (wayland_display && strlen(wayland_display) > 0);

    // ── Pure X11 ──
    if (!is_wayland) {
        return get_foreground_via_x11();
    }

    // ── Wayland: try XWayland first ──
    const char* x_display = getenv("DISPLAY");
    if (x_display && strlen(x_display) > 0) {
        ForegroundInfo info = get_foreground_via_x11();
        if (info.success && info.pid > 0)
            return info;
    }

    // ── Detect DE and try native Wayland method ──
    std::string de = desktop_env ? str_tolower(std::string(desktop_env)) : "";

    // Hyprland
    if (de.find("hyprland") != std::string::npos || getenv("HYPRLAND_INSTANCE_SIGNATURE")) {
        ForegroundInfo info = get_foreground_via_hyprland();
        if (info.success) return info;
    }

    // Sway
    if (de.find("sway") != std::string::npos || getenv("SWAYSOCK")) {
        ForegroundInfo info = get_foreground_via_sway();
        if (info.success) return info;
    }

    // KDE
    if (de.find("kde") != std::string::npos || de.find("plasma") != std::string::npos) {
        ForegroundInfo info = get_foreground_via_kde();
        if (info.success) return info;
    }

    // GNOME / Ubuntu / Pop
    if (de.find("gnome") != std::string::npos ||
        de.find("ubuntu") != std::string::npos ||
        de.find("pop") != std::string::npos ||
        de.find("unity") != std::string::npos) {
        ForegroundInfo info = get_foreground_via_gnome_dbus();
        if (info.success) return info;
    }

    // ── Shotgun: try everything ──
    ForegroundInfo info;

    info = get_foreground_via_hyprland();
    if (info.success) return info;

    info = get_foreground_via_sway();
    if (info.success) return info;

    info = get_foreground_via_gnome_dbus();
    if (info.success) return info;

    info = get_foreground_via_kde();
    if (info.success) return info;

    return info; // success = false
}

// ═══════════════════════════════════════════════
//  Flutter plugin registration
// ═══════════════════════════════════════════════

struct _ForegroundWindowPlugin {
    GObject parent_instance;
};

G_DEFINE_TYPE(ForegroundWindowPlugin, foreground_window_plugin, g_object_get_type())

static void foreground_window_plugin_dispose(GObject* object) {
    G_OBJECT_CLASS(foreground_window_plugin_parent_class)->dispose(object);
}

static void foreground_window_plugin_class_init(ForegroundWindowPluginClass* klass) {
    G_OBJECT_CLASS(klass)->dispose = foreground_window_plugin_dispose;
}

static void foreground_window_plugin_init(ForegroundWindowPlugin* /*self*/) {}

static void method_call_handler(FlMethodChannel* /*channel*/,
                                 FlMethodCall* method_call,
                                 gpointer /*user_data*/) {
    const gchar* method = fl_method_call_get_name(method_call);

    if (strcmp(method, "getForegroundWindow") == 0) {
        ForegroundInfo info = get_foreground_window_info();

        if (!info.success) {
            g_autoptr(FlValue) error_details = fl_value_new_null();
            fl_method_call_respond_error(
                method_call, "NO_WINDOW",
                "Could not determine foreground window",
                error_details, nullptr);
            return;
        }

        g_autoptr(FlValue) result = fl_value_new_map();

        fl_value_set_string_take(result, "windowTitle",
            fl_value_new_string(info.window_title.c_str()));
        fl_value_set_string_take(result, "processName",
            fl_value_new_string(info.process_path.c_str()));
        fl_value_set_string_take(result, "executableName",
            fl_value_new_string(info.executable_name.c_str()));
        fl_value_set_string_take(result, "programName",
            fl_value_new_string(info.program_name.c_str()));
        fl_value_set_string_take(result, "processId",
            fl_value_new_int(static_cast<int64_t>(info.pid)));
        fl_value_set_string_take(result, "parentProcessId",
            fl_value_new_int(static_cast<int64_t>(info.parent_pid)));
        fl_value_set_string_take(result, "parentProcessName",
            fl_value_new_string(info.parent_process_path.c_str()));

        fl_method_call_respond_success(method_call, result, nullptr);
    } else {
        fl_method_call_respond_not_implemented(method_call, nullptr);
    }
}

void foreground_window_plugin_register_with_registrar(
    FlPluginRegistrar* registrar) {
    g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();

    g_autoptr(FlMethodChannel) channel = fl_method_channel_new(
        fl_plugin_registrar_get_messenger(registrar),
        "foreground_window_plugin",
        FL_METHOD_CODEC(codec));

    g_autoptr(ForegroundWindowPlugin) plugin = FOREGROUND_WINDOW_PLUGIN(
        g_object_new(foreground_window_plugin_get_type(), nullptr));

    fl_method_channel_set_method_call_handler(
        channel, method_call_handler,
        g_object_ref(plugin), g_object_unref);
}