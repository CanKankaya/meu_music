import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meu_music/constants/sheet_ids.dart';
import 'package:meu_music/controllers/google_sheets_controller.dart';
import 'package:meu_music/models/student.dart';
import 'package:meu_music/widgets/custom_drawer.dart';
import 'package:meu_music/widgets/edit_dialog.dart';

class HomeScreen extends StatelessWidget {
  static const String routeName = '/home';

  const HomeScreen({super.key, required this.googleSheetsController});

  final GoogleSheetsController googleSheetsController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Öğrenci Listesi'),
      ),
      drawer: const CustomDrawer(),
      body: Center(
        child: Obx(() {
          if (googleSheetsController.loading.value) {
            return const CircularProgressIndicator();
          }
          return RefreshIndicator.adaptive(
            onRefresh: () async {
              googleSheetsController.fetchStudents(
                  apiTestSheetId, googleSheetsController.fullHeaderRange);
            },
            child: ListView.builder(
              itemCount: googleSheetsController.studentList.length,
              itemBuilder: (context, index) {
                final student = googleSheetsController.studentList[index];
                return Dismissible(
                  key: UniqueKey(),
                  direction: DismissDirection.horizontal,
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      // Handle delete
                      final bool? confirmDelete = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Silme İşlemini Onayla'),
                            content: const Text('Bu cihazı silmek istediğinizden emin misiniz?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Get.back(result: false),
                                child: const Text('İptal'),
                              ),
                              TextButton(
                                onPressed: () => Get.back(result: true),
                                child: const Text('Sil'),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirmDelete == true) {
                        googleSheetsController.deleteStudents([student.rowNumber!]);
                        return true;
                      } else {
                        return false;
                      }
                    } else if (direction == DismissDirection.startToEnd) {
                      // Handle edit
                      await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return EditDialog(student: student);
                        },
                      );

                      return false;
                    }
                    return false;
                  },
                  secondaryBackground: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  background: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Container(
                      color: Colors.green,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  child: StudentTile(student: student, controller: googleSheetsController),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}

class StudentTile extends StatelessWidget {
  const StudentTile({super.key, required this.student, required this.controller});

  final Student student;
  final GoogleSheetsController controller;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Get.bottomSheet(
          Wrap(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('İsim/Soyisim: ${student.name ?? 'İsimsiz'}'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('T.C: ${student.tc ?? 'TC Yok'}'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                          'Öğrenci Numarası: ${student.studentNumber ?? 'Öğrenci Numarası Yok'}'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                          'Telefon Numarası: ${student.phoneNumber ?? 'Telefon Numarası Yok'}'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Bölüm: ${student.department ?? 'Bölüm Yok'}'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          isDismissible: true,
          barrierColor: Colors.black.withOpacity(0.5),
          backgroundColor: Colors.white,
        );
      },
      title: Row(
        children: [
          Text(student.rowNumber.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 16),
          Text(student.name ?? 'İsimsiz'),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () {
          Get.defaultDialog(
            contentPadding: const EdgeInsets.all(16),
            title: 'Öğrenciyi Sil',
            middleText: 'Bu öğrenciyi silmek istediğinize emin misiniz?',
            textConfirm: 'Sil',
            textCancel: 'İptal',
            onConfirm: () {
              if (student.rowNumber != null) {
                controller.deleteStudents([student.rowNumber!]);
                Get.back();
              } else {
                Get.back();
                Get.snackbar('Hata', 'Öğrenci bulunamadı');
              }
            },
          );
        },
      ),
    );
  }
}
