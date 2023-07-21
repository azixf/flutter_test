import 'dart:ffi';
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
      drawer: Drawer(
          child: SafeArea(
              child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text('header'),
          ),
          ...(([1,2,3,4,5,6,7,8,9,10,11,12,13].map((element) {
            return ListTile(
              title: Text('item - $element'),
              onTap: () {
                  Navigator.pop(context);
              },
            );
          })))
        ],
      ))),
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
  @override
  Widget build(BuildContext context) {
    return Center(
      child:
          ElevatedButton(
              child: const Text('打开菜单'),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
    );
  }
}
