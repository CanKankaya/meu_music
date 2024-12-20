import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

import 'package:meu_music/controllers/google_sheets_controller.dart';
import 'package:meu_music/screens/add_student_screen.dart';
import 'package:meu_music/screens/dc_qr_screen.dart';
import 'package:meu_music/screens/home_screen.dart';
import 'package:meu_music/screens/text_scanner_screen.dart';
import 'package:meu_music/screens/wp_qr_screen.dart';

import 'settings/settings_controller.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settingsController,
    required this.googleSheetsController,
  });

  final SettingsController settingsController;
  final GoogleSheetsController googleSheetsController;

  @override
  Widget build(BuildContext context) {
    // Glue the SettingsController to the MaterialApp.
    //
    // The ListenableBuilder Widget listens to the SettingsController for changes.
    // Whenever the user updates their settings, the MaterialApp is rebuilt.
    return ListenableBuilder(
      listenable: settingsController,
      builder: (BuildContext context, Widget? child) {
        return GetMaterialApp(
          // Providing a restorationScopeId allows the Navigator built by the
          // MaterialApp to restore the navigation stack when a user leaves and
          // returns to the app after it has been killed while running in the
          // background.

          // Provide the generated AppLocalizations to the MaterialApp. This
          // allows descendant Widgets to display the correct translations
          // depending on the user's locale.
          debugShowCheckedModeBanner: false,

          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English, no country code
          ],

          // Use AppLocalizations to configure the correct application title
          // depending on the user's locale.
          //
          // The appTitle is defined in .arb files found in the localization
          // directory.
          onGenerateTitle: (BuildContext context) => AppLocalizations.of(context)!.appTitle,

          // Define a light and dark color theme. Then, read the user's
          // preferred ThemeMode (light, dark, or system default) from the
          // SettingsController to display the correct theme.
          theme: ThemeData(),
          darkTheme: ThemeData.dark(),
          themeMode: settingsController.themeMode,
          initialRoute: HomeScreen.routeName,

          getPages: [
            GetPage(
              name: HomeScreen.routeName,
              page: () => HomeScreen(
                googleSheetsController: googleSheetsController,
              ),
            ),
            GetPage(
              name: AddStudentScreen.routeName,
              page: () => AddStudentScreen(
                googleSheetsController: googleSheetsController,
              ),
            ),
            GetPage(
              name: TextScannerScreen.routeName,
              page: () => const TextScannerScreen(),
            ),
            GetPage(
              name: DcQrScreen.routeName,
              page: () => const DcQrScreen(),
            ),
            GetPage(
              name: WpQrScreen.routeName,
              page: () => const WpQrScreen(),
            ),
          ],
        );
      },
    );
  }
}
