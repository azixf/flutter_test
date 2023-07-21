import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const MyContainer(),
    );
  }
}

class MyContainer extends StatefulWidget {
  const MyContainer({super.key});

  @override
  State<MyContainer> createState() {
    return _MyContainerState();
  }
}

class _MyContainerState extends State<MyContainer> {
  bool _visible = true;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedOpacity(
            opacity: _visible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            child: Container(
              width: 200,
              height: 100,
              color: Colors.deepOrange,
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          ElevatedButton(
            child: const Icon(Icons.play_arrow),
            onPressed: () {
              setState(() {
                _visible = !_visible;
              });
            },
          ),
        ],
      ),
    );
  }
}
