import 'package:flavor_plus/src/device_info.dart';
import 'package:flutter/material.dart';

/// The available flavor types.
enum FlavorType {
  /// The development flavor.
  dev('DEV', color: Colors.red),

  /// The alpha flavor.
  alpha('ALPHA', color: Colors.orange),

  /// The bate flavor.
  beta('BETA', color: Colors.blue),

  /// The production flavor.
  prod('PROD');

  /// Flavor constructor.
  const FlavorType(this.name, {this.color});

  /// The name of the flavor.
  final String name;

  /// Default color of the banner.
  final Color? color;

  /// Parse any passed [String] value and returns an [FlavorType].
  static FlavorType parse(String env) {
    assert(env.isNotEmpty, 'Flavor.parse cannot receive an empty value.');
    assert(
      env == 'DEV' || env == 'ALPHA' || env == 'BETA' || env == 'PROD',
      'The passed value "$env"'
      ' must be one of the following'
      ' ${FlavorType.values.map((e) => e.name)} values.',
    );
    late FlavorType type;
    switch (env) {
      case 'DEV':
        type = FlavorType.dev;
        break;
      case 'ALPHA':
        type = FlavorType.alpha;
        break;
      case 'BETA':
        type = FlavorType.beta;
        break;
      case 'PROD':
        type = FlavorType.prod;
        break;
    }

    return type;
  }
}

/// Dedicated holder of all values whose can be different between flavors.
///
/// NOTE: since the [Flavor] is a singleton with static fields,
/// we cannot use generics, so to sink this class with other values you should
/// make use of [extension] methods.
///
/// ```dart
/// extension FlavorValuesExtension on FlavorValues {
///
/// String _getSomeValue(Flavor flavor) {
///   switch (flavor) {
///     case Flavor.dev:
///     case Flavor.alpha:
///       return 'Users angry';
///     case Flavor.beta:
///     case Flavor.prod:
///       return 'Users happy';
///   }
/// }
///
/// String get someValue => _getSomeValue(Environment.instance.environment);
///
/// }
/// ```
class FlavorValues {
  FlavorValues({required this.baseUrl})
    : assert(!baseUrl.endsWith('/'), 'BaseUrl should non end with /');

  final String baseUrl;
}

/// The holder of environment information.
///
/// This class must be called as first thing in your entry point, this will
/// allows you to use the [Flavor] with every things related to it.
class Flavor {
  factory Flavor({required FlavorType flavorType, required FlavorValues values, Color? color}) {
    color ??= flavorType.color;
    _instance ??= Flavor._internal(flavorType, values, color);
    return _instance!;
  }

  Flavor._internal(this.flavor, this.values, this.color);

  /// The current flavor type.
  final FlavorType flavor;

  /// Holder of the values that can depends on the actual flavor.
  final FlavorValues values;

  /// Defines the [FlavorBanner] color.
  final Color? color;

  /// The singleton instance of this class.
  static Flavor get instance => _instance!;
  static Flavor? _instance;

  /// Whether the current flavor is development.
  static bool get isDevelopment => instance.flavor == FlavorType.dev;

  /// Whether the current flavor is alpha.
  static bool get isAlpha => instance.flavor == FlavorType.alpha;

  /// Whether the current flavor is beta.
  static bool get isBeta => instance.flavor == FlavorType.beta;

  /// Whether the current flavor is production.
  static bool get isProduction => instance.flavor == FlavorType.prod;
}

/// The banner widget to use display information about the app and the OS.
///
/// This banner is similar to the flutter debug banner, but it will be displayed
/// on the other side.
class FlavorBanner extends StatelessWidget {
  const FlavorBanner({super.key, required this.child, this.showEnvironmentBanner = true});

  /// The widget on which the [FlavorBanner] will be shown.
  final Widget child;

  /// Whether showing the [FlavorBanner].
  final bool showEnvironmentBanner;

  @override
  Widget build(BuildContext context) {
    _BannerConfig? bannerConfig;
    if (Flavor.isProduction || !showEnvironmentBanner) {
      return child;
    }
    bannerConfig ??= _getDefaultBanner();
    return Stack(children: <Widget>[child, _buildBanner(context, bannerConfig)]);
  }

  _BannerConfig? _getDefaultBanner() {
    if (Flavor.instance.color != null) {
      return _BannerConfig(
        bannerName: Flavor.instance.flavor.name,
        bannerColor: Flavor.instance.color!,
      );
    }
    return null;
  }

  Widget _buildBanner(BuildContext context, _BannerConfig? bannerConfig) {
    if (bannerConfig?.bannerColor == null) return const SizedBox.shrink();

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const DeviceInfoDialog();
          },
        );
      },
      child: SizedBox(
        width: 50,
        height: 50,
        child: CustomPaint(
          painter: BannerPainter(
            message: bannerConfig!.bannerName,
            textDirection: Directionality.of(context),
            layoutDirection: Directionality.of(context),
            location: BannerLocation.topStart,
            color: bannerConfig.bannerColor,
          ),
        ),
      ),
    );
  }
}

class _BannerConfig {
  _BannerConfig({required this.bannerName, required this.bannerColor});

  final String bannerName;
  final Color bannerColor;
}
