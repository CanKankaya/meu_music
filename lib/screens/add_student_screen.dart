import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meu_music/controllers/add_student_controller.dart';
import 'package:meu_music/controllers/google_sheets_controller.dart';
import 'package:meu_music/models/student.dart';
import 'package:meu_music/services/connectivity_service.dart';
import 'package:meu_music/widgets/custom_drawer.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/custom_textformfield.dart';
import '../services/text_helper.dart';

class AddStudentScreen extends StatefulWidget {
  static const String routeName = '/add-student';

  const AddStudentScreen({super.key, required this.googleSheetsController});

  final GoogleSheetsController googleSheetsController;

  @override
  AddStudentScreenState createState() => AddStudentScreenState();
}

class AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final AddStudentController controller = Get.put(AddStudentController());
  final connectivityService = Get.find<ConnectivityService>();

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Handle form submission
      // You can call your add student function here
      final result = await widget.googleSheetsController.addStudents([
        Student(
          name: controller.nameController.text,
          tc: controller.tcController.text,
          studentNumber: controller.studentNumberController.text,
          phoneNumber: controller.phoneNumberController.text,
          department: controller.departmentController.text,
          iban: controller.ibanChecked.value ? "Iban" : null,
          addedDate: DateTime.now(),
        )
      ]);

      if (result == null) {
        // Show success message
        Get.snackbar(
          'Başarılı',
          'Öğrenci başarıyla eklendi',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Clear form fields
        controller.nameController.clear();
        controller.tcController.clear();
        controller.studentNumberController.clear();
        controller.phoneNumberController.clear();
        controller.departmentController.clear();
        setState(() {
          controller.ibanChecked.value = false;
        });
      } else {
        // Show error message
        Get.snackbar(
          'Hata',
          'Öğrenci eklenirken bir hata oluştu',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Öğrenci Ekle'),
        ),
        drawer: const CustomDrawer(),
        body: Obx(
          () => Form(
            key: _formKey,
            child: ListView(
              children: [
                if (connectivityService.isConnected.value == false)
                  Container(
                    width: double.infinity,
                    color: Colors.red,
                    padding: const EdgeInsets.all(8.0),
                    child: const Text(
                      'İnternet bağlantısı yok',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                CustomTextFormField(
                  labelText: 'Ad Soyad',
                  controller: controller.nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen ad soyad girin';
                    }
                    return null;
                  },
                ),
                CustomTextFormField(
                  labelText: 'TC',
                  controller: controller.tcController,
                  input: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen TC girin';
                    }
                    return null;
                  },
                ),
                CustomTextFormField(
                  labelText: 'Öğrenci Numarası',
                  controller: controller.studentNumberController,
                  input: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen öğrenci numarası girin';
                    }
                    return null;
                  },
                ),
                CustomTextFormField(
                  labelText: 'Telefon Numarası',
                  controller: controller.phoneNumberController,
                  input: TextInputType.phone,
                  inputFormatters: [phoneMaskFormatter],
                  hintText: '5xx xxx xx xx',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen telefon numarasını girin';
                    }
                    return null;
                  },
                ),
                CustomTextFormField(
                  labelText: 'Bölüm',
                  controller: controller.departmentController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen bölümü girin';
                    }
                    return null;
                  },
                ),
                CheckboxListTile(
                  title: const Text('IBAN'),
                  value: controller.ibanChecked.value,
                  onChanged: (bool? value) {
                    setState(() {
                      controller.ibanChecked.value = value ?? false;
                    });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      // Ask for permissions
                      Permission.camera.request().then((status) {
                        if (status.isGranted) {
                          Get.toNamed('/text-scanner');
                        } else if (status.isDenied) {
                          Get.snackbar(
                            'Hata',
                            'Kamera izni verilmedi',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        } else if (status.isPermanentlyDenied) {
                          Get.snackbar(
                            'Hata',
                            'Kamera izni verilmedi.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                            duration: const Duration(seconds: 3),
                            mainButton: TextButton(
                              onPressed: () {
                                openAppSettings();
                              },
                              child: const Text(
                                'Ayarları Aç',
                              ),
                            ),
                          );
                        }
                      });
                    },
                    child: const Text('Öğrenci Kartı Tara'),
                  ),
                ),
                widget.googleSheetsController.addLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          child: const Text('Ekle'),
                        ),
                      ),
              ],
            ),
          ),
        ));
  }
}
