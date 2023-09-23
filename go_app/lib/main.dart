import 'dart:core';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import "package:camera/camera.dart";

late String nameOwner, iD;
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
      body: Column(
        children: [
          FutureBuilder<void>(
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
          const SizedBox(height: 16),
          Container(
            decoration: const BoxDecoration(
                color: Color.fromARGB(255, 251, 64, 232),
                borderRadius: BorderRadius.all(Radius.circular(20))),
            //
            child: IconButton(
                color: Colors.black,
                onPressed: () async {
                  try {
                    await initconFut;
                    final image = await controller.takePicture();
                    if (!mounted) return;
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DisplayPictureScreen(
                          imagePath: image.path,
                        ),
                      ),
                    );
                  } catch (e) {
                    if (kDebugMode) {
                      print(e);
                    }
                  }
                },
                icon: const Icon(Icons.camera_alt)),
          )
        ],
      ),
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      body: Column(
        children: [
          Image.file(File(imagePath)),
          const SizedBox(
            height: 16,
          ),
          Text(
            "Owner name: $nameOwner",
            style: const TextStyle(fontSize: 20),
            textAlign: TextAlign.left,
          ),
          const SizedBox(
            height: 16,
          ),
          Text(
            "Unique ID of animal: $iD",
            style: const TextStyle(fontSize: 20),
            textAlign: TextAlign.left,
          ),
          const SizedBox(
            height: 16,
          ),
          Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
              colors: <Color>[
                Color.fromARGB(255, 131, 13, 161),
                Color.fromARGB(255, 210, 25, 207),
                Color.fromARGB(255, 245, 66, 221),
              ],
            )),
            child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16.0),
                  textStyle: const TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  if (kDebugMode) {
                    print("upoload complete");
                  }
                },
                child: const Text("Upload")),
          ),
        ],
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
                height: 300,
                width: 300,
                child: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Name of the Owner"),
                      onChanged: (name) {
                        nameOwner = name;
                        if (kDebugMode) {
                          print(nameOwner);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: myController,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Unique ID of animal"),
                      onChanged: (text) {
                        iD = text;
                        if (kDebugMode) {
                          print(iD);
                        }
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
                        ],
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
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CamScreen(
                camera: firstCam,
              )),
    );
  }
}
