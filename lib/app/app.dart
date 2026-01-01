import 'package:flutter/material.dart';
import 'package:secure_qr_flutter/generator/generator_screen.dart';
import 'package:secure_qr_flutter/scanner/qr_scanner_screen.dart';
import 'package:secure_qr_flutter/ui/theme.dart';

class SecureQrApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Secure QR',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    QrScannerScreen(),
    GeneratorScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border(top: BorderSide(color: Colors.white10)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: Colors.white38,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner_rounded),
              label: "Scan",
              activeIcon: Icon(Icons.qr_code_scanner_rounded, size: 30),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_2_rounded),
              label: "Generate",
              activeIcon: Icon(Icons.qr_code_2_rounded, size: 30),
            ),
          ],
        ),
      ),
    );
  }
}
