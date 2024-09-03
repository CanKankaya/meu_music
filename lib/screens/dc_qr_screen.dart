import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meu_music/widgets/custom_drawer.dart';

class DcQrScreen extends StatefulWidget {
  const DcQrScreen({super.key});

  static const String routeName = '/dc_qr';

  @override
  State<DcQrScreen> createState() => _DcQrScreenState();
}

class _DcQrScreenState extends State<DcQrScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    // Reset preferred orientations to allow all orientations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const Text('Discord QR Code'),
      ),
      body: Column(
        children: [
          const Spacer(),
          Image.asset(
            'assets/images/discord_qr.png',
            fit: BoxFit.contain,
            width: double.infinity,
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Discord sunucumuza katılmak için QR kodunu tarayın',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
