import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // Styles
  final Color primaryGreen = const Color(0xFF00E676);
  final Color labelColor = const Color(0xFF707B81);
  final Color lightGreenBg = const Color(0xFFE8FDF1);
  final Color fieldBorderColor = const Color(0xFFE9EDEF);

  // Instances
  final User? user = FirebaseAuth.instance.currentUser;
  final ImagePicker _picker = ImagePicker();

  // Form Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _jobController = TextEditingController();

  File? _newProfileImage;
  File? _signatureImage;
  String? _currentProfileUrl;
  String? _currentSignatureUrl;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (user == null) return;
    _emailController.text = user?.email ?? "";

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        setState(() {
          _nameController.text = data['fullName'] ?? user?.displayName ?? "";
          _phoneController.text = data['phone'] ?? "";
          _jobController.text = data['jobTitle'] ?? "";
          _currentProfileUrl = data['profilePicture'];
          _currentSignatureUrl = data['signatureUrl'];
        });
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// REST API Upload to Cloudinary
  Future<String?> _uploadToCloudinary(File file) async {
    String cloudName = "ddb0hj5rf"; // Found on Cloudinary Dashboard
    String uploadPreset = "qualimeat_preset"; // The name of your unsigned preset

    var uri = Uri.parse("https://api.cloudinary.com/v1_1/ddb0hj5rf/image/upload");
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

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      String? profileUrl = _currentProfileUrl;
      String? signatureUrl = _currentSignatureUrl;

      if (_newProfileImage != null) profileUrl = await _uploadToCloudinary(_newProfileImage!);
      if (_signatureImage != null) signatureUrl = await _uploadToCloudinary(_signatureImage!);

      // Sync with Firebase Auth
      await user?.updateDisplayName(_nameController.text.trim());

      // Save all metadata to Firestore
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'fullName': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'jobTitle': _jobController.text.trim(),
        'profilePicture': profileUrl,
        'signatureUrl': signatureUrl,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile updated successfully!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _pickImage(bool isProfile) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (isProfile) _newProfileImage = File(image.path);
        else _signatureImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Edit Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildAvatarSection(),
            const SizedBox(height: 30),
            _buildInputField("FULL NAME", _nameController, Icons.person_outline),
            _buildInputField("EMAIL", _emailController, Icons.email_outlined, isReadOnly: true),
            _buildInputField("PHONE NUMBER", _phoneController, Icons.phone_outlined),
            _buildInputField("JOB TITLE", _jobController, Icons.work_outline),
            const SizedBox(height: 20),
            _buildSignatureSection(),
            const SizedBox(height: 40),
            _buildSaveButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return GestureDetector(
      onTap: () => _pickImage(true),
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: lightGreenBg,
            backgroundImage: _newProfileImage != null
                ? FileImage(_newProfileImage!) as ImageProvider
                : (_currentProfileUrl != null ? NetworkImage(_currentProfileUrl!) : null),
            child: (_newProfileImage == null && _currentProfileUrl == null) ? Icon(Icons.person, size: 50, color: primaryGreen) : null,
          ),
          Positioned(bottom: 0, right: 0, child: CircleAvatar(radius: 18, backgroundColor: primaryGreen, child: const Icon(Icons.camera_alt, color: Colors.white, size: 18))),
        ],
      ),
    );
  }

  Widget _buildSignatureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("SIGNATURE", style: TextStyle(color: labelColor, fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => _pickImage(false),
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(color: fieldBorderColor.withOpacity(0.3), borderRadius: BorderRadius.circular(16), border: Border.all(color: fieldBorderColor)),
            child: _signatureImage != null
                ? Image.file(_signatureImage!)
                : (_currentSignatureUrl != null ? Image.network(_currentSignatureUrl!) : Icon(Icons.draw, color: primaryGreen, size: 40)),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, IconData icon, {bool isReadOnly = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: labelColor, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            readOnly: isReadOnly,
            decoration: InputDecoration(
              suffixIcon: Icon(icon, color: labelColor),
              filled: true,
              fillColor: isReadOnly ? fieldBorderColor.withOpacity(0.5) : Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: fieldBorderColor)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveProfile,
        style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text("Save Changes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
      ),
    );
  }
}