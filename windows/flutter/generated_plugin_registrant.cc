//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <app_links_windows/app_links_windows_plugin.h>
#include <connectivity_plus/connectivity_plus_windows_plugin.h>
#include <image_compression_flutter/image_compression_flutter_plugin.h>
#include <nb_utils/nb_utils_plugin.h>
#include <permission_handler_windows/permission_handler_windows_plugin.h>
#include <url_launcher_windows/url_launcher_windows.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  AppLinksWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("AppLinksWindowsPlugin"));
  ConnectivityPlusWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("ConnectivityPlusWindowsPlugin"));
  ImageCompressionFlutterPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("ImageCompressionFlutterPlugin"));
  NbUtilsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("NbUtilsPlugin"));
  PermissionHandlerWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("PermissionHandlerWindowsPlugin"));
  UrlLauncherWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("UrlLauncherWindows"));
}
