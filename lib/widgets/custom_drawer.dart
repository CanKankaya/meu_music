import 'package:flutter/material.dart';

import 'package:get/get.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Image.asset(
                    'assets/icons/icon.png',
                    width: 100,
                    height: 100,
                  ),
                ),
                const Text(
                  'MEU Müzik Yönetim',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ...screensInDrawer.map(
            (screen) {
              return ListTile(
                leading: screen.iconAsset != null
                    ? Image.asset(
                        screen.iconAsset!,
                        width: 24,
                        height: 24,
                      )
                    : Icon(
                        screen.icon,
                      ),
                title: Text(screen.dTitle),
                onTap: () async {
                  // Check if the current route is the same as the target route
                  if (Get.currentRoute == screen.dRoute) {
                    Get.back(); // Just close the drawer
                  } else {
                    Get.back();
                    Get.offAndToNamed(screen.dRoute); // Navigate to the new route
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class DrawerItem {
  final String dTitle;
  final String dRoute;
  final String? iconAsset; // Asset yolu, opsiyonel
  final IconData? icon; // Standart ikon, opsiyonel

  DrawerItem({
    required this.dTitle,
    required this.dRoute,
    this.iconAsset,
    this.icon,
  });
}

final List<DrawerItem> screensInDrawer = [
  DrawerItem(dTitle: "Ana Sayfa", dRoute: "/home", icon: Icons.home),
  DrawerItem(dTitle: "Öğrenci Ekle", dRoute: "/add-student", icon: Icons.person_add),
  DrawerItem(dTitle: "Discord QR", dRoute: "/dc_qr", iconAsset: 'assets/icons/discord_icon.png'),
  DrawerItem(dTitle: "Whatsapp QR", dRoute: "/wp_qr", iconAsset: 'assets/icons/whatsapp_icon.png'),
  // DrawerItem(dTitle: "Cihaz Raporlarım", dRoute: "/device_reports", icon: Icons.description),
  // DrawerItem(
  //     dTitle: "Cihaz İhlal Raporlarım", dRoute: "/device_violation_reports", icon: Icons.warning),
  // DrawerItem(dTitle: "Yeni Cihaz Kaydı", dRoute: "/new_device", icon: Icons.add),
  // DrawerItem(
  //     dTitle: "Cihaz Takip Ayarları", dRoute: "/device_tracking_settings", icon: Icons.settings),
  // DrawerItem(
  //     dTitle: "Bildirim Ayarları", dRoute: "/notification_settings", icon: Icons.notifications),
  // DrawerItem(dTitle: "Hakkımızda", dRoute: "/about", icon: Icons.info),
];
