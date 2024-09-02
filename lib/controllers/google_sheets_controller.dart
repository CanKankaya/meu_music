import 'dart:developer';

import 'package:get/get.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:intl/intl.dart';
import 'package:meu_music/constants/private.dart';
import 'package:meu_music/constants/sheet_ids.dart';
import 'package:meu_music/models/student.dart';

class GoogleSheetsController extends GetxController {
  final _scopes = [SheetsApi.spreadsheetsScope];
  final spreadsheetId = apiTestSheetId;
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

  @override
  void onInit() {
    fetchStudents(spreadsheetId, fullHeaderRange);
    super.onInit();
  }

  Future<SheetsApi> _getSheetsApi() async {
    final accountCredentials = ServiceAccountCredentials.fromJson(_credentials);
    final authClient = await clientViaServiceAccount(accountCredentials, _scopes);
    return SheetsApi(authClient);
  }

  Future<void> fetchStudents(String spreadsheetId, String range) async {
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
                student.name,
                student.tc,
                student.studentNumber,
                student.phoneNumber,
                student.department,
                student.iban,
                student.optionalField,
                student.addedDate != null
                    ? DateFormat('dd.MM.yyyy').format(student.addedDate!)
                    : null,
              ])
          .toList();
      final valueRange = ValueRange(values: values);
      await sheetsApi.spreadsheets.values
          .append(valueRange, spreadsheetId, fullHeaderRange, valueInputOption: 'RAW');

      //*Add Locally if successful
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
    }
    studentList.addAll(students);
  }

  Future<void> editStudents(List<Student> students) async {
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
              student.iban,
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
      editLoading(false);
    } catch (e) {
      log(e.toString());
    }
  }

  void editStudentsLocal(List<Student> students) {
    for (var student in students) {
      if (student.rowNumber != null) {
        studentList[student.rowNumber! - 1 - excelOffset] = student;
      }
    }
  }

  Future<void> deleteStudents(List<int> rowNumbers) async {
    loading(true);
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

      fetchStudents(spreadsheetId, fullHeaderRange);
    } catch (e) {
      log(e.toString());
    }
    loading(false);
  }

  Future<void> addDebugLog(String tc, String name, String studentId, String department) async {
    final logDate = DateFormat('dd.MM.yyyy').format(DateTime.now());
    try {
      final sheetsApi = await _getSheetsApi();
      final values = [
        [logDate, tc, name, studentId, department]
      ];
      final valueRange = ValueRange(values: values);
      await sheetsApi.spreadsheets.values
          .append(valueRange, apiTestSheetId, 'Debug!A:E', valueInputOption: 'RAW');
    } catch (e) {
      log(e.toString());
    }
  }
}
