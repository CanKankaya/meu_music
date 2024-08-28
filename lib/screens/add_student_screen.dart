import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meu_music/controllers/google_sheets_controller.dart';
import 'package:meu_music/models/student.dart';
import 'package:meu_music/widgets/custom_drawer.dart';
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
  final _nameController = TextEditingController();
  final _tcController = TextEditingController();
  final _studentNumberController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _departmentController = TextEditingController();
  bool _ibanChecked = false;

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Handle form submission
      // You can call your add student function here
      final result = await widget.googleSheetsController.addStudents([
        Student(
          name: _nameController.text,
          tc: _tcController.text,
          studentNumber: _studentNumberController.text,
          phoneNumber: _phoneNumberController.text,
          department: _departmentController.text,
          iban: _ibanChecked ? "Iban" : null,
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
        _nameController.clear();
        _tcController.clear();
        _studentNumberController.clear();
        _phoneNumberController.clear();
        _departmentController.clear();
        setState(() {
          _ibanChecked = false;
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CustomTextFormField(
                labelText: 'Name',
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen ismi girin';
                  }
                  return null;
                },
              ),
              CustomTextFormField(
                labelText: 'TC',
                controller: _tcController,
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
                controller: _studentNumberController,
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
                controller: _phoneNumberController,
                input: TextInputType.phone,
                inputFormatters: [phoneMaskFormatter],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen telefon numarasını girin';
                  }
                  return null;
                },
              ),
              CustomTextFormField(
                labelText: 'Bölüm',
                controller: _departmentController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen bölümü girin';
                  }
                  return null;
                },
              ),
              CheckboxListTile(
                title: const Text('IBAN'),
                value: _ibanChecked,
                onChanged: (bool? value) {
                  setState(() {
                    _ibanChecked = value ?? false;
                  });
                },
              ),
              Obx(
                () => widget.googleSheetsController.addLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _submitForm,
                        child: const Text('Ekle'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
