import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:meu_music/widgets/custom_clipper.dart';
import 'package:meu_music/widgets/simpler_custom_loading.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:meu_music/controllers/add_student_controller.dart';

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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    //To display camera feed we need to add WidgetsBindingObserver.
    WidgetsBinding.instance.addObserver(this);
    future = requestCameraPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    stopCamera();
    textRecogniser.close();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
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
          return Scaffold(
            appBar: AppBar(
              title: const Text('Öğrenci Kartını Taratın'),
            ),
            body: FutureBuilder<List<CameraDescription>>(
              future: availableCameras(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  initCameraController(snapshot.data!);
                  return Stack(
                    children: [
                      SizedBox(child: CameraPreview(cameraController!)),
                      const OverlayWithRectangleClipping(),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: IconButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    scanImage();
                                  },
                            icon: isLoading
                                ? const SimplerCustomLoader()
                                : const Icon(
                                    Icons.camera,
                                  ),
                            color: const Color.fromARGB(215, 255, 193, 7),
                            iconSize: 60,
                          ),
                        ),
                      )
                    ],
                  );
                } else {
                  return const Center(child: CircularProgressIndicator.adaptive());
                }
              },
            ),
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
    cameraController = CameraController(camera, ResolutionPreset.veryHigh, enableAudio: false);
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

      // const dummyText =
      //     "MERSİN ÜNİVERSİTESİ\n10403664082\nMERSIN UNIVERSITY\nÖĞRENcİ KİMLİK KARTI / STUDENT ID CARD\nLİSANS - ÖN LİSANS\nAd Soyad/ Name Surnarne\nEYYÜBCAN AYDEMİR\nÖğrenci No / Student ID\n22240020011\nBölüm/Department\nANTRENÖRLÜK EĞİTİMİ\nCOACHING EDUCATION\nFakülte - Yüksekokul / Faculty - School\nTC. Kimlik No/ TRID No SPOR BİLİMLERİ FAKÜLTESİ\nSPORTS SCIENCE FACULTY"; //* Fill the controller's fields accordingly, with logic
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
