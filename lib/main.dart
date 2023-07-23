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
      home: DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Flutter Demo'),
              centerTitle: true,
              bottom: const TabBar(tabs: [
                Tab(
                  text: '全部',
                  icon: Icon(Icons.all_inclusive_rounded),
                ),
                Tab(
                  text: '中国',
                  icon: Icon(Icons.child_friendly),
                ),
                Tab(text: '其他国家', icon: Icon(Icons.mic_external_off))
              ]),
            ),
            body: const TabBarView(children: [
              Center(
                child: Icon(Icons.all_inclusive_outlined),
              ),
              Center(
                child: Icon(Icons.child_friendly),
              ),
              Center(
                child: Icon(Icons.mic_external_off),
              ),
            ]),
          )),
    );
  }
}
