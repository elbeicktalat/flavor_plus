import 'package:flavor_plus/flavor_plus.dart';
import 'package:flutter/material.dart';

extension ExtraFlavorValues on FlavorValues {
  String get userStatus {
    switch (Flavor.instance.flavor) {
      case FlavorType.dev:
      case FlavorType.alpha:
        return 'Users angry';
      case FlavorType.beta:
      case FlavorType.prod:
        return 'Users happy';
    }
  }
}

String _getBaseUrl(FlavorType flavorType) {
  switch (flavorType) {
    case FlavorType.dev:
      return 'https://www.company.com/api/dev';
    case FlavorType.alpha:
      return 'https://www.company.com/api/alpha';
    case FlavorType.beta:
      return 'https://www.company.com/api/beta';
    case FlavorType.prod:
      return 'https://www.company.com/api';
  }
}

void main() {
  final FlavorType flavorType = FlavorType.dev;
  Flavor(
    flavorType: flavorType,
    values: FlavorValues(baseUrl: _getBaseUrl(flavorType)),
  );

  debugPrint('Is development environment: ${Flavor.isDevelopment}');
  debugPrint('Is alpha environment: ${Flavor.isAlpha}');
  debugPrint('Is beta environment: ${Flavor.isBeta}');
  debugPrint('Is production environment: ${Flavor.isProduction}');
  debugPrint(Flavor.instance.values.baseUrl);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlavorBanner(
      child: Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(Flavor.instance.values.baseUrl),
              Text(Flavor.instance.values.userStatus),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _incrementCounter,
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
