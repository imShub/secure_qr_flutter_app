import 'package:flutter/material.dart';
import 'package:secure_qr_flutter/models/secure_person_model.dart';
import 'package:secure_qr_flutter/ui/theme.dart';

class ResultScreen extends StatelessWidget {
  final SecurePersonModel person;
  final bool isVerified;

  const ResultScreen({Key? key, required this.person, required this.isVerified})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Identity Verified'),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.background,
                  Color(0xFF141420),
                ],
              ),
            ),
          ),
          // Decorative Orbs
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.2),
                    blurRadius: 100,
                    spreadRadius: 50,
                  )
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isVerified
                    ? AppTheme.success.withOpacity(0.15)
                    : AppTheme.accent.withOpacity(0.15),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  // Photo & Status
                  Center(
                    child: Hero(
                      tag: 'profile_photo',
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                isVerified ? AppTheme.success : AppTheme.accent,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (isVerified
                                      ? AppTheme.success
                                      : AppTheme.accent)
                                  .withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 5,
                            )
                          ],
                          image: person.photoBytes != null &&
                                  person.photoBytes!.isNotEmpty
                              ? DecorationImage(
                                  image: MemoryImage(person.photoBytes!),
                                  fit: BoxFit.cover)
                              : null,
                        ),
                        child: person.photoBytes == null ||
                                person.photoBytes!.isEmpty
                            ? Icon(Icons.person,
                                size: 80, color: Colors.white54)
                            : null,
                      ),
                    ),
                  ),

                  SizedBox(height: 24),

                  GlassCard(
                    color: isVerified ? AppTheme.success : AppTheme.accent,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isVerified
                              ? Icons.verified_user_rounded
                              : Icons.gpp_bad_rounded,
                          color:
                              isVerified ? AppTheme.success : AppTheme.accent,
                          size: 28,
                        ),
                        SizedBox(width: 12),
                        Text(
                          isVerified
                              ? "SIGNATURE VERIFIED"
                              : "INVALID SIGNATURE",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 32),

                  // Details
                  GlassCard(
                    child: Column(
                      children: [
                        _buildDetailRow(
                            "Name", person.name, Icons.badge_rounded),
                        Divider(color: Colors.white10),
                        _buildDetailRow("DOB", person.dob, Icons.cake_rounded),
                        Divider(color: Colors.white10),
                        _buildDetailRow(
                            "Gender", person.gender, Icons.people_rounded),
                        Divider(color: Colors.white10),
                        _buildDetailRow("Reference ID", person.referenceId,
                            Icons.numbers_rounded),
                      ],
                    ),
                  ),

                  SizedBox(height: 16),

                  GlassCard(
                    child: Column(
                      children: [
                        _buildDetailRow(
                            "Address",
                            "${person.addressLine1} ${person.addressLine2}",
                            Icons.home_rounded),
                        Divider(color: Colors.white10),
                        _buildDetailRow(
                            "City/State",
                            "${person.city}, ${person.state}",
                            Icons.location_city_rounded),
                        Divider(color: Colors.white10),
                        _buildDetailRow(
                            "PIN", person.pin, Icons.pin_drop_rounded),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 20),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value.isNotEmpty ? value : "N/A",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
