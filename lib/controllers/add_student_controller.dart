import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meu_music/controllers/google_sheets_controller.dart';
import 'package:meu_music/services/text_helper.dart';

class AddStudentController extends GetxController {
  final nameController = TextEditingController();
  final tcController = TextEditingController();
  final studentNumberController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final departmentController = TextEditingController();
  final ibanChecked = false.obs;

  void extractText(String text) async {
    //error handling
    if (text.isEmpty) {
      log("Text is empty");
      return;
    }
    // Split the text into a list of strings
    List<String> texts = text.split('\n').map((e) => e.trim()).toList();

    // Define regular expressions for each piece of information
    final tcPattern = RegExp(r'kimlik ?no|TC|TRID|TR ID', caseSensitive: false);
    final namePattern = RegExp(r'soyad|Soyad|Name\s*Surname', caseSensitive: false);
    final studentIdPattern = RegExp(r'Öğrenci\s*no|student\s*ID', caseSensitive: false);
    final departmentPattern = RegExp(r'Bölüm|department', caseSensitive: false);

    // Initialize variables to hold the extracted information
    String? tcKimlikNo;
    String? nameSurname;
    String? studentId;
    String? department;

    // Find and assign the TC Kimlik No
    var index = texts.indexWhere((element) => tcPattern.hasMatch(element));
    if (index != -1 && index + 1 < texts.length) {
      tcKimlikNo = texts[index + 1].removeSpaces().removeNonDigits();
    }

    // Find and assign the Name/Surname
    index = texts.indexWhere((element) => namePattern.hasMatch(element));
    if (index != -1 && index + 1 < texts.length) {
      nameSurname = texts[index + 1];
    }

    // Find and assign the Student ID
    List<int> matches = [];
    for (int i = 0; i < texts.length; i++) {
      if (studentIdPattern.hasMatch(texts[i])) {
        matches.add(i);
      }
    }

    if (matches.length >= 2) {
      studentId = texts[matches[1] + 1].removeSpaces();
    } else if (matches.length == 1) {
      studentId = texts[matches[0] + 1].removeSpaces();
    }

    // Find and assign the Department
    index = texts.indexWhere((element) => departmentPattern.hasMatch(element));
    if (index != -1 && index + 1 < texts.length) {
      department = texts[index + 1];
    }

    //*logging for debug if the results are not exactly as expected
    final googleSheetsController = Get.find<GoogleSheetsController>();
    bool hasError = false;

    if (!isValidTcNo(tcKimlikNo)) {
      hasError = true;
      log("Invalid TC Kimlik No: $tcKimlikNo");
    }

    if (!isValidNameSurname(nameSurname)) {
      hasError = true;
      log("Invalid Name/Surname: $nameSurname");
    }

    if (!isValidStudentId(studentId)) {
      hasError = true;
      log("Invalid Student ID: $studentId");
    }

    if (!isValidDepartment(department)) {
      hasError = true;
      log("Invalid Department: $department");
    }

    if (hasError) {
      googleSheetsController.addDebugLog(
        tcKimlikNo ?? "",
        nameSurname ?? "",
        studentId ?? "",
        department ?? "",
        text,
      );
    }

    tcController.text = tcKimlikNo ?? "";
    nameController.text = nameSurname ?? "";
    studentNumberController.text = studentId ?? "";
    departmentController.text = department ?? "";
  }

  bool isValidTcNo(String? tcKimlikNo) {
    return tcKimlikNo != null &&
        tcKimlikNo.length == 11 &&
        RegExp(r'^\d{11}$').hasMatch(tcKimlikNo);
  }

  bool isValidNameSurname(String? nameSurname) {
    return nameSurname != null && nameSurname.isNotEmpty && !RegExp(r'\d').hasMatch(nameSurname);
  }

  bool isValidStudentId(String? studentId) {
    return studentId != null && studentId.length > 6 && RegExp(r'^\d+$').hasMatch(studentId);
  }

  bool isValidDepartment(String? department) {
    return department != null && department.isNotEmpty && !RegExp(r'\d').hasMatch(department);
  }
}
