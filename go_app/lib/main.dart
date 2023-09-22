import 'dart:core';
import 'package:flutter/material.dart';
import "package:camera/camera.dart";

Future<void> main() async {
  runApp(const MyApp());
}

class CamScreen extends StatefulWidget {
  const CamScreen({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  State<CamScreen> createState() => _CamScreenState();
}

class _CamScreenState extends State<CamScreen> {
  late CameraController controller;
  late Future<void> initconFut;
  @override
  void initState() {
    super.initState();
    controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );

    initconFut = controller.initialize();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Take Picture"),
      ),
      body: FutureBuilder<void>(
        future: initconFut,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(controller);
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 152, 58, 183)),
        useMaterial3: true,
      ),
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
  late String nameOwner, iD;
  final myController = TextEditingController();

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("goPics"),
        ),
        body: Center(
            child: SizedBox(
                height: 200,
                width: 300,
                child: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Name of the Owner"),
                      onSubmitted: (name) {
                        nameOwner = name;
                        print(nameOwner);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: myController,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Unique ID of animal"),
                      onSubmitted: (text) {
                        iD = text;
                        print(iD);
                      },
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: const BoxDecoration(
                          gradient: LinearGradient(
                        colors: <Color>[
                          Color.fromARGB(255, 131, 13, 161),
                          Color.fromARGB(255, 210, 25, 207),
                          Color.fromARGB(255, 245, 66, 221),
                        ]
                        ,
                      )),
                      child: TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(16.0),
                            textStyle: const TextStyle(fontSize: 20),
                          ),
                          onPressed: () async {
                            await navigate(context);
                          },
                          child: const Text("Capture images")),
                    ),
                  ],
                ))));
  }

  Future<void> navigate(BuildContext context) async {
    WidgetsFlutterBinding.ensureInitialized();
    final cameras = await availableCameras();
    final firstCam = cameras.first;
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CamScreen(
                camera: firstCam,
              )),
    );
  }
}
