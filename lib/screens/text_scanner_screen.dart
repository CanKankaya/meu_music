import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:meu_music/controllers/add_student_controller.dart';
import 'package:permission_handler/permission_handler.dart';

class TextScannerScreen extends StatefulWidget {
  const TextScannerScreen({super.key});

  static const routeName = '/text-scanner';

  @override
  State<TextScannerScreen> createState() => _TextScannerScreenState();
}

class _TextScannerScreenState extends State<TextScannerScreen> with WidgetsBindingObserver {
  bool isPermissionGranted = false;
  bool isLoading = false;
  late final Future<void> future;

  //For controlling camera
  CameraController? cameraController;
  final textRecogniser = TextRecognizer();

  @override
  void initState() {
    super.initState();
    //To display camera feed we need to add WidgetsBindingObserver.
    WidgetsBinding.instance.addObserver(this);
    future = requestCameraPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    stopCamera();
    textRecogniser.close();
    super.dispose();
  }

  //It'll check if app is in foreground or background
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      stopCamera();
    } else if (state == AppLifecycleState.resumed &&
        cameraController != null &&
        cameraController!.value.isInitialized) {
      startCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          return Stack(
            children: [
              //Show camera content behind everything
              if (isPermissionGranted)
                FutureBuilder<List<CameraDescription>>(
                    future: availableCameras(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        initCameraController(snapshot.data!);
                        return Center(
                          child: CameraPreview(cameraController!),
                        );
                      } else {
                        return const LinearProgressIndicator();
                      }
                    }),
              Scaffold(
                appBar: AppBar(
                  title: const Text('Text Recognition Sample'),
                ),
                backgroundColor: isPermissionGranted ? Colors.transparent : null,
                body: isPermissionGranted
                    ? Column(
                        children: [
                          Expanded(child: Container()),
                          Container(
                            padding: const EdgeInsets.only(bottom: 30),
                            child: ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        scanImage();
                                      },
                                child: isLoading
                                    ? const CircularProgressIndicator()
                                    : const Text('Scan Text')),
                          ),
                        ],
                      )
                    : Center(
                        child: Container(
                          padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                          child: const Text(
                            'Camera Permission Denied',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
              ),
            ],
          );
        });
  }

  Future<void> requestCameraPermission() async {
    final status = await Permission.camera.request();
    isPermissionGranted = status == PermissionStatus.granted;
  }

  //It is used to initialise the camera controller
  //It also check the available camera in your device
  //It also check if camera controller is initialised or not.
  void initCameraController(List<CameraDescription> cameras) {
    if (cameraController != null) {
      return;
    }
    //Select the first ream camera
    CameraDescription? camera;
    for (var a = 0; a < cameras.length; a++) {
      final CameraDescription current = cameras[a];
      if (current.lensDirection == CameraLensDirection.back) {
        camera = current;
        break;
      }
    }
    if (camera != null) {
      cameraSelected(camera);
    }
  }

  Future<void> cameraSelected(CameraDescription camera) async {
    cameraController = CameraController(camera, ResolutionPreset.max, enableAudio: false);
    await cameraController?.initialize();
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  //Start Camera
  void startCamera() {
    if (cameraController != null) {
      cameraSelected(cameraController!.description);
    }
  }

  //Stop Camera
  void stopCamera() {
    if (cameraController != null) {
      cameraController?.dispose();
    }
  }

  //It will take care of scanning text from image
  Future<void> scanImage() async {
    setState(() {
      isLoading = true;
    });

    if (cameraController == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }
    try {
      final pictureFile = await cameraController!.takePicture();
      final file = File(pictureFile.path);
      final inputImage = InputImage.fromFile(file);
      final recognizedText = await textRecogniser.processImage(inputImage);
      log(recognizedText.text);

      // final dummyText =
      //     "Avertidseds\nTC kimlik no/TRID No\n38074030128\nMersinÜniversitesi\nMersinUniversity\nÖğrenci kimlik karti/Studentid card\nlisans/önlisans\nAd Soyad/Name Surname\nCAN KANKAYA\nÖğrenci no/studentID\n21220030080\nBölüm/department\nBilgisayar müh\nComputer engineering\nFakülte/Yüksekokul/Faculty/school\nMühendislik Fakültesi\nEngineering faculty";

      //* Fill the controller's fields accordingly, with logic
      var addStudentController = Get.find<AddStudentController>();
      addStudentController.extractText(recognizedText.text);

      Get.back();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error while scanning text',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      setState(() {
        isLoading = false;
      });
    }
  }
}
