import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meu_music/controllers/google_sheets_controller.dart';
import 'package:meu_music/models/student.dart';
import 'package:meu_music/services/connectivity_service.dart';
import 'package:meu_music/widgets/custom_drawer.dart';
import 'package:meu_music/widgets/edit_dialog.dart';

class HomeScreen extends StatelessWidget {
  static const String routeName = '/home';

  const HomeScreen({super.key, required this.googleSheetsController});

  final GoogleSheetsController googleSheetsController;

  //TODO Add a new home screen that display general info like student count etc.

  //TODO OPTIONAL: Integrate sayman raporu aswell

  //TODO IMPORTANT: Convert the list to a table view in a pdf with appropriate number of pages and with only the required columns. This is required in 2nd semester, for the Topluluk defteri Teslimi.

  //TODO Add Settings screen where the user can change the sheet id and instructions on how to get the sheet id and how to add the google service account to the sheet as an editor.

  @override
  Widget build(BuildContext context) {
    final connectivityService = Get.find<ConnectivityService>();
    final TextEditingController searchController = TextEditingController();
    final ValueNotifier<int> deletingIndex = ValueNotifier<int>(-1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Öğrenci Listesi'),
        actions: [
          const SizedBox(width: 56.0), // Padding the same size as the drawer button
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Icon(Icons.search),
                  ),
                  hintText: 'Öğrenci Ara...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  googleSheetsController.updateSearchQuery(value);
                },
              ),
            ),
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: Center(
        child: Obx(() {
          if (googleSheetsController.loading.value) {
            return const CircularProgressIndicator();
          }
          final pagedStudents = googleSheetsController.paginatedStudentList;

          return Column(
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
              Expanded(
                child: RefreshIndicator.adaptive(
                  onRefresh: () async {
                    googleSheetsController.fetchStudents(googleSheetsController.fullHeaderRange);
                  },
                  child: ListView(
                    children: [
                      if (googleSheetsController.studentList.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 30.0),
                            child: Text(
                              'Öğrenci bulunamadı.',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ...pagedStudents.map(
                        (student) => _buildStudentTile(deletingIndex, student),
                      ),
                    ],
                  ),
                ),
              ),
              _buildPageBar(),
            ],
          );
        }),
      ),
    );
  }

  ValueListenableBuilder<int> _buildStudentTile(ValueNotifier<int> deletingIndex, Student student) {
    return ValueListenableBuilder(
        valueListenable: deletingIndex,
        builder: (context, value, child) {
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
                      content: const Text(
                        'Bu öğrenciyi silmek istediğinizden emin misiniz?',
                      ),
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
                  deletingIndex.value = googleSheetsController.studentList.indexOf(student);
                  final result = await googleSheetsController.deleteStudents([student.rowNumber!]);
                  deletingIndex.value = -1;
                  if (result == null) {
                    return true;
                  } else {
                    Get.snackbar(
                      'Hata',
                      'Öğrenci silinirken bir hata oluştu',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                    return false;
                  }
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
            child: Stack(
              children: [
                ListTile(
                  onTap: () {
                    Get.bottomSheet(
                      Wrap(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text.rich(
                                    TextSpan(
                                      text: 'İsim/Soyisim: ',
                                      children: [
                                        TextSpan(
                                          text: student.name ?? 'İsimsiz',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text.rich(
                                    TextSpan(
                                      text: 'T.C: ',
                                      children: [
                                        TextSpan(
                                          text: student.tc ?? 'TC Yok',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text.rich(
                                    TextSpan(
                                      text: 'Öğrenci Numarası: ',
                                      children: [
                                        TextSpan(
                                          text: student.studentNumber ?? 'Öğrenci Numarası Yok',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text.rich(
                                    TextSpan(
                                      text: 'Telefon Numarası: ',
                                      children: [
                                        TextSpan(
                                          text: student.phoneNumber ?? 'Telefon Numarası Yok',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text.rich(
                                    TextSpan(
                                      text: 'Bölüm: ',
                                      children: [
                                        TextSpan(
                                          text: student.department ?? 'Bölüm Yok',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      isDismissible: true,
                      enableDrag: true,
                      elevation: 8,
                      backgroundColor: Get.theme.scaffoldBackgroundColor,
                    );
                  },
                  title: Row(
                    children: [
                      Text(student.rowNumber.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 16),
                      Text(student.name ?? 'İsimsiz'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      final bool? confirmDelete = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Silme İşlemini Onayla'),
                            content: const Text(
                              'Bu öğrenciyi silmek istediğinizden emin misiniz?',
                            ),
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
                        deletingIndex.value = googleSheetsController.studentList.indexOf(student);
                        final result =
                            await googleSheetsController.deleteStudents([student.rowNumber!]);
                        deletingIndex.value = -1;
                        if (result != null) {
                          Get.snackbar(
                            'Hata',
                            'Öğrenci silinirken bir hata oluştu',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        }
                      }
                    },
                  ),
                ),
                if (deletingIndex.value == googleSheetsController.studentList.indexOf(student))
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                        child: const Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Siliniyor',
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                              SizedBox(width: 20),
                              CircularProgressIndicator(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        });
  }

  //TODO add a dropdown to show how many items to show per page. Defaults to 100.
  Widget _buildPageBar() {
    return Obx(() {
      final currentPage = googleSheetsController.currentPage.value;
      final totalPages = googleSheetsController.totalPages;

      return Container(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: currentPage > 1 ? googleSheetsController.previousPage : null,
              borderRadius: BorderRadius.circular(8.0),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: currentPage > 1 ? null : Colors.grey,
                ),
              ),
            ),
            const Spacer(),
            Text('Sayfa $currentPage / $totalPages'),
            const Spacer(),
            InkWell(
              onTap: currentPage < totalPages ? googleSheetsController.nextPage : null,
              borderRadius: BorderRadius.circular(8.0),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: currentPage < totalPages ? null : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
