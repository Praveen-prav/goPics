import 'dart:core';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import "package:camera/camera.dart";
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

late String nameOwner, iD;
late bool uploaded;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
    // final size = MediaQuery.of(context).size;
    // var height = size.height;
    // var width = size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Take Picture"),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 40,
          ),
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
          const SizedBox(height: 35),
          Container(
            height: 90,
            width: 90,
            decoration: const BoxDecoration(
                color: Color.fromARGB(126, 158, 158, 158),
                borderRadius: BorderRadius.all(Radius.circular(30))),
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
              icon: const Icon(Icons.camera_alt),
              iconSize: 60,
            ),
          )
        ],
      ),
    );
  }
}

class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  State<DisplayPictureScreen> createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      body: Column(
        children: [
          Container(
              margin: const EdgeInsets.only(top: 20),
              child: Image.file(File(widget.imagePath))),
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
            height: 35,
          ),
          Container(
            decoration: const BoxDecoration(
                // borderRadius: BorderRadius.all(Radius.elliptical(20, 10)),
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
                  String filename =
                      "${nameOwner}_${iD}_${DateTime.now().millisecondsSinceEpoch}";
                  Reference referenceRoot = FirebaseStorage.instance.ref();
                  Reference refDir = referenceRoot.child('images');
                  Reference refImg = refDir.child(filename);
                  Map<String, String> custommetadata = {
                    "Owner": nameOwner,
                    "Animal ID": iD,
                    "name": filename,
                    "timecreated": DateTime.now().toString()
                  };
                  final task = refImg.putFile(File(widget.imagePath),
                      SettableMetadata(customMetadata: custommetadata));
                  task.whenComplete(() => {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                const MyHomePage(title: "goPics")))
                      });
                  const snackBar = SnackBar(
                    content: Text('Uploaded!'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
      title: 'goPics',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 152, 58, 183)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'goPics'),
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
  late bool nameO, id;

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
                    TextFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Name of the Owner",
                      ),
                      validator: (name) {
                        if (name!.isEmpty) {
                          const Dialog(
                            child: Text("Name Empty"),
                          );
                        }
                        return null;
                      },
                      onChanged: (name) {
                        setState(() {
                          nameO = true;
                        });
                        nameOwner = name;
                        if (kDebugMode) {
                          print(nameOwner);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: myController,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Unique ID of animal"),
                      validator: (id) {
                        if (id!.isEmpty) {
                          const Dialog(
                            child: Text("ID Empty"),
                          );
                        }
                        return null;
                      },
                      onChanged: (text) {
                        iD = text;
                        setState(() {
                          id = true;
                        });
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
                            if (nameO == true && id == true) {
                              await navigate(context);
                            }
                          },
                          child: const Text("Capture images")),
                    ),
                  ],
                ))));
  }

  Future<void> navigate(BuildContext context) async {
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
