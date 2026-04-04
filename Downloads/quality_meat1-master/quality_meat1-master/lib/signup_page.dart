import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _jobController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreedToTerms = false;
  bool _isLoading = false;

  // Image Picking
  File? _profileImage;
  File? _signatureImage;
  final ImagePicker _picker = ImagePicker();

  // Colors
  final Color primaryGreen = const Color(0xFF00E676);
  final Color labelColor = const Color(0xFF9E9E9E);
  final Color inputFillColor = const Color(0xFFF9FAFB);
  final Color darkText = const Color(0xFF101010);

  /// Helper to pick images
  Future<void> _pickImage(bool isProfile) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (isProfile) _profileImage = File(image.path);
        else _signatureImage = File(image.path);
      });
    }
  }

  /// Cloudinary Upload Logic (Same as Edit Profile)
  Future<String?> _uploadToCloudinary(File file) async {
    String cloudName = "ddb0hj5rf"; // Found on Cloudinary Dashboard
    String uploadPreset = "qualimeat_preset"; // The name of your unsigned preset

    var uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
    var request = http.MultipartRequest("POST", uri);
    request.fields['upload_preset'] = uploadPreset;
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    var response = await request.send();
    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      return jsonDecode(responseString)['secure_url'];
    }
    return null;
  }

  Future<void> _createAccount() async {
    // Validation
    if (_nameController.text.isEmpty || _emailController.text.isEmpty ||
        _phoneController.text.isEmpty || _jobController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill in all text fields")));
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("You must agree to the Terms")));
      return;
    }

    setState(() { _isLoading = true; });

    try {
      // 1. Create user in Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String uid = userCredential.user!.uid;
      String? profileUrl;
      String? signatureUrl;

      // 2. Upload images to Cloudinary if they exist
      if (_profileImage != null) profileUrl = await _uploadToCloudinary(_profileImage!);
      if (_signatureImage != null) signatureUrl = await _uploadToCloudinary(_signatureImage!);

      // 3. Update Auth display name
      await userCredential.user?.updateDisplayName(_nameController.text.trim());

      // 4. Save full profile to Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'fullName': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'jobTitle': _jobController.text.trim(),
        'profilePicture': profileUrl,
        'signatureUrl': signatureUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Account created successfully!")));
      if (mounted) Navigator.pop(context);

    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? "An error occurred")));
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _jobController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Create Account", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: darkText)),
              const SizedBox(height: 30),

              // Profile Picture Picker
              Center(
                child: GestureDetector(
                  onTap: () => _pickImage(true),
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: inputFillColor,
                        backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                        child: _profileImage == null ? Icon(Icons.add_a_photo, color: primaryGreen) : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              _buildLabel("FULL NAME"),
              _buildTextField(hintText: "John Doe", icon: Icons.person_outline, controller: _nameController),
              const SizedBox(height: 20),

              _buildLabel("EMAIL ADDRESS"),
              _buildTextField(hintText: "name@example.com", icon: Icons.mail_outline, keyboardType: TextInputType.emailAddress, controller: _emailController),
              const SizedBox(height: 20),

              _buildLabel("PHONE NUMBER"),
              _buildTextField(hintText: "+1 234 567 890", icon: Icons.phone_outlined, keyboardType: TextInputType.phone, controller: _phoneController),
              const SizedBox(height: 20),

              _buildLabel("JOB TITLE"),
              _buildTextField(hintText: "Senior Auditor", icon: Icons.badge_outlined, controller: _jobController),
              const SizedBox(height: 20),

              _buildLabel("PASSWORD"),
              _buildTextField(hintText: "••••••••", icon: Icons.lock_outline, isPassword: true, isVisible: _isPasswordVisible, controller: _passwordController, onVisibilityToggle: () => setState(() => _isPasswordVisible = !_isPasswordVisible)),
              const SizedBox(height: 20),

              _buildLabel("CONFIRM PASSWORD"),
              _buildTextField(hintText: "••••••••", icon: Icons.lock_reset, isPassword: true, isVisible: _isConfirmPasswordVisible, controller: _confirmPasswordController, onVisibilityToggle: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible)),
              const SizedBox(height: 25),

              _buildLabel("SIGNATURE"),
              GestureDetector(
                onTap: () => _pickImage(false),
                child: Container(
                  width: double.infinity, height: 100,
                  decoration: BoxDecoration(color: inputFillColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
                  child: _signatureImage != null ? Image.file(_signatureImage!) : Icon(Icons.border_color, color: Colors.grey[400]),
                ),
              ),
              const SizedBox(height: 25),

              // Terms and Conditions checkbox and Signup button...
              // (Keep your existing Checkbox and ElevatedButton code here)

              Row(
                children: [
                  SizedBox(height: 24, width: 24, child: Checkbox(value: _agreedToTerms, activeColor: primaryGreen, side: BorderSide(color: Colors.grey[400]!, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), onChanged: (value) { setState(() { _agreedToTerms = value ?? false; }); })),
                  const SizedBox(width: 12),
                  Expanded(child: RichText(text: TextSpan(text: "I agree to the ", style: TextStyle(color: Colors.grey[600], fontSize: 13), children: [TextSpan(text: "Terms of Service", style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold)), const TextSpan(text: " and "), TextSpan(text: "Privacy Policy", style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold))]))),
                ],
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createAccount,
                  style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text("Create Account", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(padding: const EdgeInsets.only(bottom: 8.0, left: 4.0), child: Text(text, style: TextStyle(color: labelColor, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5)));
  }

  Widget _buildTextField({required String hintText, required IconData icon, TextEditingController? controller, bool isPassword = false, bool? isVisible, VoidCallback? onVisibilityToggle, TextInputType keyboardType = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(color: inputFillColor, borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: controller,
        obscureText: isPassword && (isVisible == false),
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: Colors.grey[400], size: 22),
          suffixIcon: isPassword ? IconButton(icon: Icon(isVisible! ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey[400], size: 22), onPressed: onVisibilityToggle) : null,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }
}