import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Paint.enableDithering = true;
  if (Platform.isAndroid) {
    await FlutterDisplayMode.setHighRefreshRate();
  }
  runApp(const MyApp());
}

const routeHome = '/';
const routeSettings = '/settings';
const routePrefixDeviceSetup = '/setup/';
const routeDeviceSetupStart = '/setup/$routeDeviceSetupStartPage';
const routeDeviceSetupStartPage = 'find_devices';
const routeDeviceSetupSelectDevicePage = 'select_device';
const routeDeviceSetupConnectingPage = 'connecting';
const routeDeviceSetupFinishedPage = 'finished';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: kDebugMode,
      theme: ThemeData(
        colorSchemeSeed: Colors.blueAccent,
        useMaterial3: true,
      ),
      // home: const MyHomePage(),
      onGenerateRoute: (settings) {
        late Widget page;
        if (settings.name == routeHome) {
          page = const MyHomePage();
        } else if (settings.name == routeSettings) {
          page = const SettingsScreen();
        } else if (settings.name!.startsWith(routePrefixDeviceSetup)) {
          final subRoute =
              settings.name!.substring(routePrefixDeviceSetup.length);
          page = SetupFlow(setupPageRoute: subRoute);
        } else {
          throw Exception('Unknown route: ${settings.name}');
        }

        return MaterialPageRoute<dynamic>(
            builder: (_) => page, settings: settings);
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 250,
                height: 250,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Color(0xff222222)),
                child: Center(
                  child: Icon(
                    Icons.lightbulb,
                    size: 175,
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              const Text(
                'Add your first device',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(routeDeviceSetupStart);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Home'),
      actions: [
        IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(routeSettings);
            },
            icon: const Icon(Icons.settings))
      ],
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView.builder(
          itemCount: 20,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              leading: const FlutterLogo(),
              title: Text('Setting title ${index + 1}'),
              subtitle: Text('Settings subtitle #${index + 1}'),
            );
          }),
    );
  }
}

class SetupFlow extends StatefulWidget {
  const SetupFlow({super.key, required this.setupPageRoute});

  final String setupPageRoute;

  @override
  State<SetupFlow> createState() => _SetupFlowState();
}

class _SetupFlowState extends State<SetupFlow> {
  final _navigationKey = GlobalKey<NavigatorState>();

  Route _onGenerateRoute(RouteSettings settings) {
    late Widget page;
    switch (settings.name) {
      case routeDeviceSetupStartPage:
        page = WaitingPage(
          message: 'Searching for nearby ...',
          onWaitComplete: _onDiscoveryComplete,
        );
        break;

      case routeDeviceSetupSelectDevicePage:
        page = SelectDevicePage(onDeviceSelected: _onDeviceSelected);
        break;

      case routeDeviceSetupConnectingPage:
        page = WaitingPage(
            message: 'Connecting...', onWaitComplete: _onConnectEstablished);
        break;

      case routeDeviceSetupFinishedPage:
        page = FinishedPage(onFinishPressed: _exitSetup);
        break;
    }

    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }

  void _onDiscoveryComplete() {
    _navigationKey.currentState!.pushNamed(routeDeviceSetupSelectDevicePage);
  }

  void _onDeviceSelected(String deviceId) {
    _navigationKey.currentState!.pushNamed(routeDeviceSetupConnectingPage);
  }

  void _onConnectEstablished() {
    _navigationKey.currentState!.pushNamed(routeDeviceSetupFinishedPage);
  }

  Future<void> _onExitPressed() async {
    final isConfirmed = await _isExitDesired();
    if (isConfirmed && mounted) {
      _exitSetup();
    }
  }

  Future<bool> _isExitDesired() async {
    return await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Are you sure to exit?'),
                content: const Text(
                    'If you confirm to exit device setup, your profile will be lost!'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      child: const Text('Leave')),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      child: const Text('Stay')),
                ],
              );
            }) ??
        false;
  }

  void _exitSetup() {
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _isExitDesired,
      child: Scaffold(
        appBar: _buildFlowAppBar(),
        body: Navigator(
          key: _navigationKey,
          initialRoute: widget.setupPageRoute,
          onGenerateRoute: _onGenerateRoute,
        ),
      ),
    );
  }

  PreferredSizeWidget _buildFlowAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.chevron_left),
        onPressed: _onExitPressed,
      ),
      title: const Text('Bulb Setup'),
    );
  }
}

class WaitingPage extends StatefulWidget {
  const WaitingPage(
      {super.key, required this.message, required this.onWaitComplete});

  final String message;
  final VoidCallback onWaitComplete;

  @override
  State<WaitingPage> createState() => _WaitingPageState();
}

class _WaitingPageState extends State<WaitingPage> {
  @override
  void initState() {
    super.initState();
    _startWaiting();
  }

  Future<void> _startWaiting() async {
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      widget.onWaitComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(
                height: 32,
              ),
              Text(widget.message)
            ],
          ),
        ),
      ),
    );
  }
}

class SelectDevicePage extends StatelessWidget {
  const SelectDevicePage({super.key, required this.onDeviceSelected});

  final void Function(String deviceId) onDeviceSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(
              'Select a nearby device...',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(
              height: 24,
            ),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateColor.resolveWith(
                        (states) => const Color(0xFF222222))),
                onPressed: () {
                  onDeviceSelected('22n45yug5ask');
                },
                child: const Text(
                  '22n45yug5ask',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class FinishedPage extends StatelessWidget {
  final VoidCallback onFinishPressed;

  const FinishedPage({super.key, required this.onFinishPressed});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 250,
                height: 250,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF222222),
                ),
                child: const Center(
                  child: Icon(
                    Icons.lightbulb,
                    size: 175,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              const Text(
                'Buld Added!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 24,
              ),
              ElevatedButton(
                style: ButtonStyle(
                    padding: MaterialStateProperty.resolveWith(
                      (states) => const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    backgroundColor: MaterialStateColor.resolveWith(
                      (states) => const Color(0xFF222222),
                    ),
                    shape: MaterialStateProperty.resolveWith(
                        (states) => const StadiumBorder())),
                onPressed: onFinishPressed,
                child: const Text(
                  'Finish',
                  style: TextStyle(fontSize: 24),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
