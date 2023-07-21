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
  double _width = 50.0;
  double _height = 50.0;

  Color _color = Colors.green;
  BorderRadiusGeometry _borderRadiusGeometry = BorderRadius.circular(8);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            width: _width,
            height: _height,
            decoration: BoxDecoration(
                borderRadius: _borderRadiusGeometry, color: _color),
            duration: const Duration(seconds: 1),
            curve: Curves.fastOutSlowIn,
          ),
          const SizedBox(
            height: 12,
          ),
          ElevatedButton(
            child: const Icon(Icons.play_arrow),
            onPressed: () {
              setState(() {
                final random = Random();
                _width = random.nextInt(280).toDouble() + 20;
                _height = random.nextInt(280).toDouble() + 20;
                _color = Color.fromRGBO(random.nextInt(255),
                    random.nextInt(255), random.nextInt(255), 1);
                _borderRadiusGeometry =
                    BorderRadius.circular(random.nextInt(20).toDouble() + 4);
              });
            },
          ),
        ],
      ),
    );
  }
}
