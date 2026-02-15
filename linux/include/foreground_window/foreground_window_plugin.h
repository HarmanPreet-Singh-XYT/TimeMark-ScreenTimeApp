// linux/include/foreground_window/foreground_window_plugin.h

#ifndef FOREGROUND_WINDOW_PLUGIN_H_
#define FOREGROUND_WINDOW_PLUGIN_H_

#include <flutter_linux/flutter_linux.h>

G_BEGIN_DECLS

#ifdef FLUTTER_PLUGIN_IMPL
#define FLUTTER_PLUGIN_EXPORT __attribute__((visibility("default")))
#else
#define FLUTTER_PLUGIN_EXPORT
#endif

typedef struct _ForegroundWindowPlugin ForegroundWindowPlugin;
typedef struct {
    GObjectClass parent_class;
} ForegroundWindowPluginClass;

FLUTTER_PLUGIN_EXPORT GType foreground_window_plugin_get_type();

FLUTTER_PLUGIN_EXPORT void foreground_window_plugin_register_with_registrar(
    FlPluginRegistrar* registrar);

G_END_DECLS

#endif  // FOREGROUND_WINDOW_PLUGIN_H_