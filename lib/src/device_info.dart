import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';

import 'flavor_config.dart';

enum BuildMode {
  debug('Build'),
  profile('Profile'),
  release('Release');

  final String value;

  // ignore: sort_constructors_first
  const BuildMode(this.value);
}

class _DeviceUtils {
  static BuildMode currentBuildMode() {
    if (const bool.fromEnvironment('dart.vm.product')) {
      return BuildMode.release;
    }
    BuildMode buildMode = BuildMode.profile;
    assert(() {
      buildMode = BuildMode.debug;
      return true;
    }());
    return buildMode;
  }

  static Future<AndroidDeviceInfo> androidDeviceInfo() async {
    DeviceInfoPlugin plugin = DeviceInfoPlugin();
    return plugin.androidInfo;
  }

  static Future<IosDeviceInfo> iosDeviceInfo() async {
    DeviceInfoPlugin plugin = DeviceInfoPlugin();
    return plugin.iosInfo;
  }
}

/// A dialog which shows information about the app and the device running on.
class DeviceInfoDialog extends StatelessWidget {
  const DeviceInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      contentPadding: const EdgeInsets.only(bottom: 10.0),
      title: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Flavor.instance.color,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.0),
            topRight: Radius.circular(10.0),
          ),
        ),
        child: const Text('Device Info', style: TextStyle(color: Colors.white)),
      ),
      titlePadding: const EdgeInsets.all(0),
      content: _getContent(),
    );
  }

  Widget _getContent() {
    if (Platform.isAndroid) {
      return _androidContent();
    }
    if (Platform.isIOS) {
      return _iOSContent();
    }
    return const Text("You're not on Android neither iOS");
  }

  Widget _iOSContent() {
    return FutureBuilder<IosDeviceInfo>(
      future: _DeviceUtils.iosDeviceInfo(),
      builder: (BuildContext context, AsyncSnapshot<IosDeviceInfo> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: Text('No available info'));
        }
        final IosDeviceInfo? device = snapshot.data;
        return SingleChildScrollView(
          child: Column(
            children: <Widget>[
              _buildTile('Environment:', Flavor.instance.flavor.name),
              _buildTile('Build Mode:', _DeviceUtils.currentBuildMode().name.toUpperCase()),
              _buildTile('Physical device?:', '${device?.isPhysicalDevice}'),
              _buildTile('Model:', '${device?.model}'),
              _buildTile('Name:', '${device?.name}'),
              _buildTile('OS Version:', '${device?.systemVersion}'),
            ],
          ),
        );
      },
    );
  }

  Widget _androidContent() {
    return FutureBuilder<AndroidDeviceInfo>(
      future: _DeviceUtils.androidDeviceInfo(),
      builder: (BuildContext context, AsyncSnapshot<AndroidDeviceInfo> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: Text('No available info'));
        }
        final AndroidDeviceInfo? device = snapshot.data;
        return SingleChildScrollView(
          child: Column(
            children: <Widget>[
              _buildTile('Environment:', Flavor.instance.flavor.name),
              _buildTile('Build Mode:', _DeviceUtils.currentBuildMode().name.toUpperCase()),
              _buildTile('Physical device?:', '${device?.isPhysicalDevice}'),
              _buildTile('Low RAM Device?:', '${device?.isLowRamDevice}'),
              _buildTile('Manufacturer:', '${device?.manufacturer}'),
              _buildTile('Model:', '${device?.model}'),
              _buildTile('Android version:', '${device?.version.release}'),
              _buildTile('Android SDK:', '${device?.version.sdkInt}'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTile(String key, String value) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Row(
        children: <Widget>[
          Text(key, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Text(value),
        ],
      ),
    );
  }
}
