import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddStudentController extends GetxController {
  final nameController = TextEditingController();
  final tcController = TextEditingController();
  final studentNumberController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final departmentController = TextEditingController();
  final ibanChecked = false.obs;

  void extractText(String text) {
    // Split the text into a list of strings
    List<String> texts = text.split('\n').map((e) => e.trim()).toList();

    // Define regular expressions for each piece of information
    final tcPattern = RegExp(r'kimlik|TC|TRID', caseSensitive: false);
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
      tcKimlikNo = texts[index + 1];
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
      studentId = texts[matches[1] + 1];
    } else if (matches.length == 1) {
      studentId = texts[matches[0] + 1];
    }

    // Find and assign the Department
    index = texts.indexWhere((element) => departmentPattern.hasMatch(element));
    if (index != -1 && index + 1 < texts.length) {
      department = texts[index + 1];
    }

    // Log the extracted information
    log("TC Kimlik No: $tcKimlikNo");
    log("Name/Surname: $nameSurname");
    log("Student ID: $studentId");
    log("Department: $department");

    // Assign the values to the respective controllers
    tcController.text = tcKimlikNo ?? "";
    nameController.text = nameSurname ?? "";
    studentNumberController.text = studentId ?? "";
    departmentController.text = department ?? "";
  }
}
