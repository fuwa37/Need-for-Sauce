package io.flutter.plugins;

import io.flutter.plugin.common.PluginRegistry;
import xyz.justsoft.video_thumbnail.VideoThumbnailPlugin;

/**
 * Generated file. Do not edit.
 */
public final class GeneratedPluginRegistrant {
  public static void registerWith(PluginRegistry registry) {
    if (alreadyRegisteredWith(registry)) {
      return;
    }
    VideoThumbnailPlugin.registerWith(registry.registrarFor("xyz.justsoft.video_thumbnail.VideoThumbnailPlugin"));
  }

  private static boolean alreadyRegisteredWith(PluginRegistry registry) {
    final String key = GeneratedPluginRegistrant.class.getCanonicalName();
    if (registry.hasPlugin(key)) {
      return true;
    }
    registry.registrarFor(key);
    return false;
  }
}
