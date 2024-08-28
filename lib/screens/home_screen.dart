import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meu_music/constants/sheet_ids.dart';
import 'package:meu_music/controllers/google_sheets_controller.dart';
import 'package:meu_music/models/student.dart';
import 'package:meu_music/widgets/custom_drawer.dart';

class HomeScreen extends StatelessWidget {
  static const String routeName = '/home';

  const HomeScreen({super.key, required this.googleSheetsController});

  final GoogleSheetsController googleSheetsController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Sheets API Demo'),
      ),
      drawer: const CustomDrawer(),
      body: Center(
        child: Obx(() {
          if (googleSheetsController.loading.value) {
            return const CircularProgressIndicator();
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () async {
                  await googleSheetsController.fetchStudents(apiTestSheetId, 'Sayfa1!A:H');
                },
                child: const Text('Fetch Data'),
              ),
              ElevatedButton(
                onPressed: () async {
                  //TODO Example student adding here

                  var student = Student(
                    name: 'New Student', // Change to the new student name
                    tc: '12345678901', // Change to the new student tc
                    studentNumber: '12345678901', // Change to the new student number
                    phoneNumber: '12345678901', // Change to the new student phone number
                    department: 'New Department', // Change to the new student department
                    iban: 'Iban', // Change to the new student iban
                    addedDate: DateTime.now(), // Add the current date
                  );

                  await googleSheetsController.addStudents([
                    student,
                  ]);
                },
                child: const Text('Post Data'),
              ),
              ElevatedButton(
                onPressed: () async {
                  //TODO Example student editing here

                  // var student = googleSheetsController.students
                  //     .firstWhere((element) => element.rowNumber == 4);
                  // student = Student(
                  //   rowNumber: student.rowNumber,
                  //   name: 'New Name', // Change to the new name
                  //   tc: student.tc,
                  //   studentNumber: student.studentNumber,
                  //   phoneNumber: student.phoneNumber,
                  //   department: 'New Department', // Change to the new department
                  //   iban: "Iban",
                  //   optionalField: student.optionalField,
                  //   addedDate: DateTime.now(), // Add the current date
                  // );

                  // await googleSheetsController.editStudents([
                  //   student,
                  // ]);
                },
                child: const Text('Edit Data'),
              ),
              ElevatedButton(
                onPressed: () async {
                  //TODO Example student deleting here
                  await googleSheetsController.deleteStudents([597]);
                },
                child: const Text('Delete Data'),
              ),
            ],
          );
        }),
      ),
    );
  }
}
