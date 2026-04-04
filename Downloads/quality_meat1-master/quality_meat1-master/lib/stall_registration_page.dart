import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart'; // Import for QR generation

class StallRegistrationPage extends StatefulWidget {
  const StallRegistrationPage({super.key});

  @override
  State<StallRegistrationPage> createState() => _StallRegistrationPageState();
}

class _StallRegistrationPageState extends State<StallRegistrationPage> {
  final Color primaryGreen = const Color(0xFF00E676);
  final Color lightGrey = const Color(0xFFF8F9FA);
  final Color labelColor = const Color(0xFF707B81);
  final Color fieldBorderColor = const Color(0xFFE9EDEF);

  final TextEditingController _stallController = TextEditingController();
  final TextEditingController _vendorController = TextEditingController();

  File? _stallImage;
  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;

  final String cloudName = "ddb0hj5rf";
  final String uploadPreset = "qualimeat_preset";

  Future<void> _showPickerOptions() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.photo_library, color: primaryGreen),
              title: const Text('Gallery'),
              onTap: () {
                _pickImage(ImageSource.gallery);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: primaryGreen),
              title: const Text('Camera'),
              onTap: () {
                _pickImage(ImageSource.camera);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() { _stallImage = File(image.path); });
    }
  }

  Future<String?> _uploadToCloudinary(File file) async {
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

  // --- UPDATED LOGIC TO SHOW QR CODE ---
  Future<void> _registerStall() async {
    if (_stallController.text.isEmpty || _vendorController.text.isEmpty || _stallImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields and provide a picture")),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      String? imageUrl = await _uploadToCloudinary(_stallImage!);

      // Save to Firestore
      await FirebaseFirestore.instance.collection('stalls').add({
        'stallNumber': _stallController.text.trim(),
        'vendorName': _vendorController.text.trim(),
        'stallImageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        // Generate QR Data string
        String qrData = "STALL:${_stallController.text.trim()},VENDOR:${_vendorController.text.trim()}";

        // Show Success and the QR Code
        _showQRCodeDialog(qrData);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showQRCodeDialog(String data) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Registration Successful", textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Scan this code later for quick inspection access."),
            const SizedBox(height: 20),
            // QR Image generation
            SizedBox(
              height: 200,
              width: 200,
              child: QrImageView(
                data: data,
                version: QrVersions.auto,
                size: 200.0,
                gapless: false,
              ),
            ),
            const SizedBox(height: 10),
            Text("Stall: ${_stallController.text}", style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to Dashboard
            },
            child: Text("Done", style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
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
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: labelColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Stall Registration", style: TextStyle(color: Color(0xFF1B1E28), fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Register New Vendor", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Enter stall information to add it to the system.", style: TextStyle(color: labelColor, fontSize: 15)),
            const SizedBox(height: 32),
            _buildLabel("STALL NUMBER"),
            _buildTextField("e.g. A-12", _stallController, Icons.storefront_outlined),
            const SizedBox(height: 24),
            _buildLabel("VENDOR NAME"),
            _buildTextField("e.g. Fresh Farms", _vendorController, Icons.person_outline),
            const SizedBox(height: 24),
            _buildLabel("STALL PICTURE"),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _showPickerOptions,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: lightGrey,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: fieldBorderColor),
                ),
                child: _stallImage != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(_stallImage!, fit: BoxFit.cover),
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo_outlined, color: primaryGreen, size: 40),
                    const SizedBox(height: 8),
                    Text("Upload or Take Stall Photo", style: TextStyle(color: labelColor, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _registerStall,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text("Register Stall", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(text, style: TextStyle(color: labelColor, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: Icon(icon, color: const Color(0xFFBCC8D2)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: fieldBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryGreen),
        ),
      ),
    );
  }
}