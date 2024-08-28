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
          const DrawerHeader(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Center(
                      child: Icon(Icons.construction),
                    )),
                Expanded(
                  child: Text(
                    'MEU Müzik Yönetim',
                    style: TextStyle(
                      color: Color(0xFF1C873F),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
                        color: Colors.green[800],
                      )
                    : Icon(
                        screen.icon,
                        color: Colors.green[800],
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
  // DrawerItem(dTitle: "Profil", dRoute: "/profile", icon: Icons.person),
  // DrawerItem(dTitle: "Cihaz Ayarlarım", dRoute: "/device-settings", icon: Icons.devices),
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
