import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meu_music/controllers/google_sheets_controller.dart';
import 'package:meu_music/services/connectivity_service.dart';

import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

void main() async {
  final settingsController = SettingsController(SettingsService());

  await settingsController.loadSettings();

  final googleSheetsController = Get.put(GoogleSheetsController());
  Get.put(ConnectivityService());

  runApp(MyApp(
    settingsController: settingsController,
    googleSheetsController: googleSheetsController,
  ));
}
