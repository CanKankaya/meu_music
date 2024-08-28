import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meu_music/controllers/google_sheets_controller.dart';
import '../widgets/custom_textformfield.dart';
import '../services/text_helper.dart';
import '../models/student.dart';

class EditDialog extends StatefulWidget {
  final Student student;

  const EditDialog({super.key, required this.student});

  @override
  EditDialogState createState() => EditDialogState();
}

class EditDialogState extends State<EditDialog> {
  late TextEditingController _nameController;
  late TextEditingController _tcController;
  late TextEditingController _studentNumberController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _departmentController;

  final GoogleSheetsController googleSheetsController = Get.find<GoogleSheetsController>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.student.name);
    _tcController = TextEditingController(text: widget.student.tc);
    _studentNumberController = TextEditingController(text: widget.student.studentNumber);
    _phoneNumberController = TextEditingController(text: widget.student.phoneNumber);
    _departmentController = TextEditingController(text: widget.student.department);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tcController.dispose();
    _studentNumberController.dispose();
    _phoneNumberController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Öğrenci Bilgilerini Düzenle'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextFormField(
              labelText: 'Name',
              controller: _nameController,
            ),
            CustomTextFormField(
              labelText: 'TC',
              controller: _tcController,
              input: TextInputType.number,
            ),
            CustomTextFormField(
              labelText: 'Öğrenci Numarası',
              controller: _studentNumberController,
              input: TextInputType.number,
            ),
            CustomTextFormField(
              labelText: 'Telefon Numarası',
              controller: _phoneNumberController,
              input: TextInputType.phone,
              inputFormatters: [phoneMaskFormatter],
            ),
            CustomTextFormField(
              labelText: 'Bölüm',
              controller: _departmentController,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Get.back(result: false),
          child: const Text('İptal'),
        ),
        Obx(() => TextButton(
              onPressed: googleSheetsController.editLoading.value
                  ? null
                  : () async {
                      // Update student details
                      widget.student.name = _nameController.text;
                      widget.student.tc = _tcController.text;
                      widget.student.studentNumber = _studentNumberController.text;
                      widget.student.phoneNumber = _phoneNumberController.text;
                      widget.student.department = _departmentController.text;

                      // Call update function here if needed
                      await googleSheetsController.editStudents([widget.student]);

                      Get.back(result: true);
                    },
              child: googleSheetsController.editLoading.value
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator())
                  : const Text('Kaydet'),
            )),
      ],
    );
  }
}
