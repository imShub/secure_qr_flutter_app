import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:secure_qr_flutter/generator/secure_qr_generator.dart';
import 'package:secure_qr_flutter/models/secure_person_model.dart';
import 'package:secure_qr_flutter/ui/theme.dart';

class GeneratorScreen extends StatefulWidget {
  @override
  _GeneratorScreenState createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends State<GeneratorScreen> {
  // ... existing logic ...
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController(text: "John Doe");
  final _dobCtrl = TextEditingController(text: "01-01-2000");
  final _genderCtrl = TextEditingController(text: "M");
  final _pinCtrl = TextEditingController(text: "110001");

  String? _generatedQrData;

  void _generate() {
    FocusScope.of(context).unfocus();
    final person = SecurePersonModel(
      version: "V1",
      referenceId: "1234567890",
      name: _nameCtrl.text,
      dob: _dobCtrl.text,
      gender: _genderCtrl.text,
      city: "New Delhi",
      addressLine1: "123 Main St",
      pin: _pinCtrl.text,
      state: "Delhi",
      district: "Central",
    );

    // Dummy red dot
    String dummyJpegBase64 =
        "/9j/4AAQSkZJRgABAQEASABIAAD/2wBDAP//////////////////////////////////////////////////////////////////////////////////////wgALCAABAAEBAREA/8QAFBABAAAAAAAAAAAAAAAAAAAAAP/aAAgBAQABPxA=";
    final photoBytes = base64Decode(dummyJpegBase64);

    try {
      final qrData = SecureQrGenerator.generate(person, photoBytes);
      setState(() {
        _generatedQrData = qrData;
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: Text("Generate Identity")),
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color(0xFF2A2D3E),
                  AppTheme.background,
                ],
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  GlassCard(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text("Enter Details",
                              style: Theme.of(context).textTheme.titleLarge),
                          SizedBox(height: 20),
                          _buildInput(
                              _nameCtrl, "Full Name", Icons.person_outline),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                  child: _buildInput(
                                      _dobCtrl,
                                      "DOB (DD-MM-YYYY)",
                                      Icons.calendar_today_outlined)),
                              SizedBox(width: 16),
                              Expanded(
                                  child: _buildInput(_genderCtrl, "Gender",
                                      Icons.wc_outlined)),
                            ],
                          ),
                          SizedBox(height: 16),
                          _buildInput(
                              _pinCtrl, "Pincode", Icons.pin_drop_outlined),
                          SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: _generate,
                            child: Text("GENERATE SECURE QR"),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  if (_generatedQrData != null)
                    Column(
                      children: [
                        Text("Scan to Verify",
                            style: TextStyle(
                                color: Colors.white54, letterSpacing: 1.5)),
                        SizedBox(height: 16),
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                    color: AppTheme.primary.withOpacity(0.3),
                                    blurRadius: 30,
                                    spreadRadius: 5)
                              ]),
                          child: QrImageView(
                            data: _generatedQrData!,
                            version: QrVersions.auto,
                            size: 250.0,
                            // Embedded Logo? Maybe for V2.
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(TextEditingController ctrl, String label, IconData icon) {
    return TextFormField(
      controller: ctrl,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.white54),
      ),
    );
  }
}
