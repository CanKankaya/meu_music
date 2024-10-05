import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meu_music/constants/private.dart';
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

  String? selectedPayment;
  bool showPaymentValidationMessage = false;

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Handle form submission

      if (selectedPayment == null) {
        setState(() {
          showPaymentValidationMessage = true;
        });
        return;
      } else {
        setState(() {
          showPaymentValidationMessage = false;
        });
      }
      // You can call your add student function here
      final result = await widget.googleSheetsController.addStudents([
        Student(
          name: controller.nameController.text,
          tc: controller.tcController.text,
          studentNumber: controller.studentNumberController.text,
          phoneNumber: controller.phoneNumberController.text,
          department: controller.departmentController.text,
          payment: selectedPayment ?? 'Ödeme Yapmadı',
          addedDate: DateTime.now(),
        )
      ]);

      if (result == null) {
        // Clear form fields
        controller.nameController.clear();
        controller.tcController.clear();
        controller.studentNumberController.clear();
        controller.phoneNumberController.clear();
        controller.departmentController.clear();
        setState(() {
          selectedPayment = null;
        });

        // Show success message with QR button
        Get.snackbar(
          'Başarılı',
          'Öğrenci başarıyla eklendi',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          mainButton: TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/whatsapp_qr.png',
                            fit: BoxFit.contain,
                            width: double.infinity,
                          ),
                          const SizedBox(height: 8.0),
                          const Text(
                            'Whatsapp grubumuza katılmak için QR kodunu taratabilirsiniz.',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          Row(
                            children: [
                              const Spacer(),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Kapat'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            child: const Text(
              'QR Kodu Göster',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      const Text('Ödeme:', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 16),
                      _buildPaymentOption('Iban'),
                      const SizedBox(width: 16),
                      _buildPaymentOption('Nakit'),
                    ],
                  ),
                ),
                if (showPaymentValidationMessage)
                  Padding(
                    padding: const EdgeInsets.only(left: 24.0),
                    child: Text(
                      'Lütfen bir ödeme seçeneği seçin',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          insetPadding: const EdgeInsets.all(16.0),
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/images/iban_qr.jpeg',
                                  fit: BoxFit.contain,
                                  width: double.infinity,
                                ),
                                const SizedBox(height: 8.0),
                                const Text(
                                  ibanName,
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16.0),
                                const Text(
                                  iban,
                                  style: TextStyle(
                                    fontSize: 16.0,
                                  ),
                                ),
                                const SizedBox(height: 16.0),
                                Row(
                                  children: [
                                    const Spacer(),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Kapat'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: const Text(
                    'IBAN Göster',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton.icon(
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
                    icon: const Icon(Icons.camera_alt),
                    label: const Text(
                      'Öğrenci Kartı Tara',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                widget.googleSheetsController.addLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          child: const Text(
                            'Ekle',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ));
  }

  Widget _buildPaymentOption(String paymentType) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (selectedPayment == paymentType) {
              selectedPayment = null;
            } else {
              selectedPayment = paymentType;
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            border: Border.all(
              color: selectedPayment == paymentType ? Colors.blue : Colors.grey,
              width: 3.0, // Make the border bigger
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Center(
            child: Text(
              paymentType,
              style: TextStyle(
                color: selectedPayment == paymentType ? Colors.blue : Colors.grey,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
