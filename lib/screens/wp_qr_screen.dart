import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meu_music/widgets/custom_drawer.dart';

class WpQrScreen extends StatefulWidget {
  const WpQrScreen({super.key});

  static const String routeName = '/wp_qr';

  @override
  State<WpQrScreen> createState() => _WpQrScreenState();
}

class _WpQrScreenState extends State<WpQrScreen> {
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
        title: const Text('Whatsapp QR Code'),
      ),
      body: Column(
        children: [
          const Spacer(),
          Image.asset(
            //TODO Change with whatsapp qr code
            'assets/images/discord_qr.png',
            fit: BoxFit.contain,
            width: double.infinity,
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Whatsapp grubumuza katılmak için QR kodunu tarayın',
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
