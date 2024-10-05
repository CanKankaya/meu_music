import 'dart:developer';

import 'package:get/get.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:intl/intl.dart';
import 'package:meu_music/constants/private.dart';
import 'package:meu_music/models/student.dart';
import 'package:meu_music/services/text_helper.dart';

class GoogleSheetsController extends GetxController {
  final _scopes = [SheetsApi.spreadsheetsScope];
  final spreadsheetId = realSheetId20242025;
  final _credentials = {
    "type": "service_account",
    "project_id": "meumusic",
    "private_key_id": googleSheetsPrivateKeyId,
    "private_key":
        "-----BEGIN PRIVATE KEY-----\n$googleSheetsPrivateKey\n-----END PRIVATE KEY-----\n",
    "client_email": clientEmail,
    "client_id": "103070373050019561835",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url":
        "https://www.googleapis.com/robot/v1/metadata/x509/meumusic%40meumusic.iam.gserviceaccount.com"
  };
  var fullHeaderRange = 'Sayfa1!A:H';
  var excelOffset = 2;

  var loading = false.obs;
  var editLoading = false.obs;
  var addLoading = false.obs;
  var studentList = <Student>[].obs;

  var currentPage = 1.obs;
  var itemsPerPage = 100;

  var searchQuery = ''.obs;

  List<Student> get filteredStudentList {
    final lowerCaseQuery = searchQuery.value.toLowerCase().replaceAll(' ', '');
    return studentList.where((student) {
      final nameMatches = student.name?.toLowerCase().contains(lowerCaseQuery) ?? false;
      final studentNumberMatches =
          student.studentNumber?.toLowerCase().contains(lowerCaseQuery) ?? false;
      final departmentMatches = student.department?.toLowerCase().contains(lowerCaseQuery) ?? false;
      final phoneNumberMatches =
          student.phoneNumber?.replaceAll(' ', '').contains(lowerCaseQuery) ?? false;

      return nameMatches || studentNumberMatches || departmentMatches || phoneNumberMatches;
    }).toList();
  }

  List<Student> get paginatedStudentList {
    final filteredStudents = filteredStudentList;
    final startIndex = (currentPage.value - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;
    return filteredStudents.sublist(
      startIndex,
      endIndex > filteredStudents.length ? filteredStudents.length : endIndex,
    );
  }

  int get totalPages {
    return (filteredStudentList.length / itemsPerPage).ceil();
  }

  void nextPage() {
    if ((currentPage.value * itemsPerPage) < filteredStudentList.length) {
      currentPage.value++;
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
    }
  }

  void goToPage(int page) {
    if (page > 0 && (page - 1) * itemsPerPage < filteredStudentList.length) {
      currentPage.value = page;
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    currentPage.value = 1; // Reset to the first page
  }

  @override
  void onInit() {
    fetchStudents(fullHeaderRange);
    super.onInit();
  }

  Future<SheetsApi> _getSheetsApi() async {
    final accountCredentials = ServiceAccountCredentials.fromJson(_credentials);
    final authClient = await clientViaServiceAccount(accountCredentials, _scopes);
    return SheetsApi(authClient);
  }

  //TODO Logic check for "BAHAR DÖNEMİ", "GÜZ DÖNEMİ" etc.
  Future<void> fetchStudents(String range) async {
    loading(true);
    try {
      final sheetsApi = await _getSheetsApi();
      final response = await sheetsApi.spreadsheets.values.get(spreadsheetId, range);
      final values = response.values ?? [];
      // log('Response Data: $values');

      // Skip the header row and filter out empty rows
      final fetchedStudents = values.skip(1).where((row) => row.isNotEmpty).map((row) {
        // Ensure each row has at least 8 columns
        final rowData = List<String?>.filled(8, null);
        for (int i = 0; i < row.length && i < rowData.length; i++) {
          rowData[i] = row[i]?.toString();
        }
        final index = values.indexOf(row) + 1; // +1 to account for header row
        return Student.fromList(rowData, index: index);
      }).toList();
      studentList.assignAll(fetchedStudents);

      log('Fetched students from sheet');
    } catch (e) {
      log('Error fetching students: $e');
    }
    loading(false);
  }

  Future<String?> addStudents(List<Student> students) async {
    addLoading(true);
    try {
      final sheetsApi = await _getSheetsApi();

      final values = students
          .map((student) => [
                student.name.capitalizeFirstLetterOfEachWord(),
                student.tc,
                student.studentNumber,
                student.phoneNumber,
                student.department.capitalizeFirstLetterOfEachWord(),
                student.payment ?? 'Ödeme Yapmadı',
                student.addedDate != null
                    ? DateFormat('dd.MM.yyyy').format(student.addedDate!)
                    : null,
                student.optionalField,
              ])
          .toList();

      // Debug log to verify the values being appended
      log('Appending values: $values');

      final valueRange = ValueRange(values: values);
      final response = await sheetsApi.spreadsheets.values.append(
        valueRange,
        spreadsheetId,
        fullHeaderRange,
        valueInputOption: 'RAW',
        insertDataOption: 'INSERT_ROWS',
      );

      // Debug log to verify the response from the API
      log('Append response: ${response.toJson()}');

      // Add Locally if successful
      addStudentsLocal(students);
      log('Added students: $students');

      return null;
    } catch (e) {
      log(e.toString());
      return 'Bir hata oluştu. Lütfen tekrar deneyin.';
    } finally {
      addLoading(false);
    }
  }

  void addStudentsLocal(List<Student> students) {
    for (var student in students) {
      log(students.length.toString());
      student.rowNumber = studentList.length + 1 + excelOffset;
      log(student.rowNumber.toString());

      // Capitalize the first letter of each word in the name and department
      student.name = student.name?.capitalizeFirstLetterOfEachWord();
      student.department = student.department?.capitalizeFirstLetterOfEachWord();
    }
    studentList.addAll(students);
  }

  Future<String?> editStudents(List<Student> students) async {
    editLoading(true);
    try {
      final sheetsApi = await _getSheetsApi();
      for (var student in students) {
        if (student.rowNumber != null) {
          final range = 'Sayfa1!A${student.rowNumber}:H${student.rowNumber}';
          final values = [
            [
              student.name,
              student.tc,
              student.studentNumber,
              student.phoneNumber,
              student.department,
              student.payment,
              student.optionalField,
              student.addedDate != null
                  ? '${student.addedDate!.day.toString().padLeft(2, '0')}.${student.addedDate!.month.toString().padLeft(2, '0')}.${student.addedDate!.year}'
                  : null
            ]
          ];
          final valueRange = ValueRange(values: values);
          await sheetsApi.spreadsheets.values
              .update(valueRange, spreadsheetId, range, valueInputOption: 'RAW');
        }
      }
      //* Edit Locally if successful
      editStudentsLocal(students);
      log('Edited students: $students');
      return null;
    } catch (e) {
      log(e.toString());
      return 'Bir hata oluştu. Lütfen tekrar deneyin.';
    } finally {
      editLoading(false);
    }
  }

  void editStudentsLocal(List<Student> students) {
    for (var student in students) {
      if (student.rowNumber != null) {
        studentList[student.rowNumber! - 1 - excelOffset] = student;
      }
    }
  }

  Future<String?> deleteStudents(List<int> rowNumbers) async {
    try {
      final sheetsApi = await _getSheetsApi();
      final requests = <Request>[];

      for (var rowNumber in rowNumbers) {
        requests.add(
          Request(
            deleteDimension: DeleteDimensionRequest(
              range: DimensionRange(
                sheetId: int.tryParse(spreadsheetId) ?? 0,
                dimension: 'ROWS',
                startIndex: rowNumber - 1, // Row numbers are 0-indexed
                endIndex: rowNumber,
              ),
            ),
          ),
        );
      }

      if (requests.isNotEmpty) {
        final batchUpdateRequest = BatchUpdateSpreadsheetRequest(requests: requests);
        await sheetsApi.spreadsheets.batchUpdate(batchUpdateRequest, spreadsheetId);
      }

      //* Delete Locally if successful
      deleteStudentsLocal(rowNumbers);
      log('Deleted students: $rowNumbers');
      return null;
    } catch (e) {
      log(e.toString());
      return 'Bir hata oluştu. Lütfen tekrar deneyin.';
    }
  }

  void deleteStudentsLocal(List<int> rowNumbers) {
    // Sort the rowNumbers in descending order to avoid index shifting issues
    rowNumbers.sort((a, b) => b.compareTo(a));

    for (var rowNumber in rowNumbers) {
      studentList.removeWhere((student) => student.rowNumber == rowNumber);
    }

    // Adjust the rowNumber of the remaining students
    for (var student in studentList) {
      for (var rowNumber in rowNumbers) {
        if (student.rowNumber! > rowNumber) {
          student.rowNumber = student.rowNumber! - 1;
        }
      }
    }
    if (paginatedStudentList.isEmpty && currentPage.value > 1) {
      previousPage();
    }
  }

  Future<void> addDebugLog(
      String tc, String name, String studentId, String department, String fullText) async {
    final logDate = DateFormat('dd.MM.yyyy').format(DateTime.now());
    try {
      final sheetsApi = await _getSheetsApi();
      final values = [
        [logDate, tc, name, studentId, department, fullText]
      ];
      final valueRange = ValueRange(values: values);
      await sheetsApi.spreadsheets.values
          .append(valueRange, apiTestSheetId, 'Debug!A:E', valueInputOption: 'RAW');
    } catch (e) {
      log(e.toString());
    }
  }
}
