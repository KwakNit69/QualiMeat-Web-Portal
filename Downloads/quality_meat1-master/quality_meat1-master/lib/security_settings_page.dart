import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Required for the iOS-style toggle switches

class SecuritySettingsPage extends StatefulWidget {
  const SecuritySettingsPage({super.key});

  @override
  State<SecuritySettingsPage> createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage> {
  // Colors for consistency
  final Color primaryGreen = const Color(0xFF00E676);
  final Color lightGreenBg = const Color(0xFFE8FDF1);
  final Color textColor = const Color(0xFF1E293B);
  final Color greyText = const Color(0xFF9E9E9E);
  final Color labelColor = const Color(0xFF8A94A6);
  final Color fieldBorderColor = const Color(0xFFE9EDEF);

  // State variables for toggles and password visibility
  bool _isBiometricEnabled = true;
  bool _is2faEnabled = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;

  // Controllers
  final TextEditingController _currentPasswordController = TextEditingController(text: "password123");
  final TextEditingController _newPasswordController = TextEditingController(text: "password123");

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1B1E28), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Security Settings",
          style: TextStyle(color: Color(0xFF1B1E28), fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Header Icon
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: lightGreenBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.shield_rounded, color: primaryGreen, size: 36),
              ),
            ),
            const SizedBox(height: 24),

            // Subtitle
            Center(
              child: Text(
                "Manage your account security and authentication\npreferences.",
                textAlign: TextAlign.center,
                style: TextStyle(color: labelColor, fontSize: 14, height: 1.5, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 40),

            // Authentication Section
            _buildSectionLabel("AUTHENTICATION"),
            const SizedBox(height: 16),

            _buildToggleRow(
              icon: Icons.fingerprint_rounded,
              title: "Biometric Login",
              value: _isBiometricEnabled,
              onChanged: (val) => setState(() => _isBiometricEnabled = val),
            ),
            const SizedBox(height: 20),
            _buildToggleRow(
              icon: Icons.smartphone_rounded,
              title: "Two-Factor Auth (OTP)",
              value: _is2faEnabled,
              onChanged: (val) => setState(() => _is2faEnabled = val),
            ),

            const SizedBox(height: 40),

            // Change Password Section
            _buildSectionLabel("CHANGE PASSWORD"),
            const SizedBox(height: 16),

            _buildPasswordField(
              label: "Current Password",
              controller: _currentPasswordController,
              isObscure: _obscureCurrent,
              onToggleVisibility: () => setState(() => _obscureCurrent = !_obscureCurrent),
            ),
            const SizedBox(height: 20),
            _buildPasswordField(
              label: "New Password",
              controller: _newPasswordController,
              isObscure: _obscureNew,
              onToggleVisibility: () => setState(() => _obscureNew = !_obscureNew),
            ),

            const SizedBox(height: 12),
            Text(
              "Password must be at least 8 characters long and include a mix of numbers and letters.",
              style: TextStyle(color: labelColor, fontSize: 11, height: 1.5),
            ),

            const SizedBox(height: 30),

            // Last Login Info Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: lightGreenBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_rounded, color: primaryGreen, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Last Login",
                          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Oct 24, 2023 at 09:41 AM from iPhone 15 Pro",
                          style: TextStyle(color: labelColor, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30), // Bottom padding to ensure content clears button
          ],
        ),
      ),

      // Fixed Bottom Button
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                // Add your logic to update passwords/settings
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Security Settings Updated!")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.black, // Dark text like the design
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "Update Security",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget for grey section titles
  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: labelColor,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
      ),
    );
  }

  // Helper widget for Biometric / 2FA toggles
  Widget _buildToggleRow({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF9CA3AF), size: 24),
        const SizedBox(width: 16),
        Text(
          title,
          style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        CupertinoSwitch(
          value: value,
          onChanged: onChanged,
          activeColor: primaryGreen,
        ),
      ],
    );
  }

  // Helper widget for Password input fields
  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool isObscure,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isObscure,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, letterSpacing: 2),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            suffixIcon: IconButton(
              icon: Icon(
                isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: const Color(0xFFBCC8D2),
                size: 20,
              ),
              onPressed: onToggleVisibility,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: fieldBorderColor, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: primaryGreen, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}