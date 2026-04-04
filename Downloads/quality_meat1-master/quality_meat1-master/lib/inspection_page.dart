import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quality_meat1/step2.dart';

class NewInspectionPage extends StatefulWidget {
  const NewInspectionPage({super.key});

  @override
  State<NewInspectionPage> createState() => _NewInspectionPageState();
}

class _NewInspectionPageState extends State<NewInspectionPage> {
  // Colors from the QualiMeat design
  final Color primaryGreen = const Color(0xFF00E676);
  final Color lightGrey = const Color(0xFFF8F9FA);
  final Color labelColor = const Color(0xFF707B81);

  // Controllers for form fields
  final TextEditingController _stallController = TextEditingController();
  final TextEditingController _vendorController = TextEditingController();
  final TextEditingController _inspectorController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch dynamic data on load
  }

  /// Fetches the logged-in user's name and job title
  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // 1. Get Name from Auth
      _inspectorController.text = user.displayName ?? "";

      // 2. Get Job Title from Firestore
      var doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && mounted) {
        setState(() {
          // Assuming 'jobTitle' was saved during profile edit or signup
          _jobTitleController.text = doc.data()?['jobTitle'] ?? "Senior Inspector";
        });
      }
    }
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
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: lightGrey, shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 16),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text("NEW INSPECTION", style: TextStyle(color: labelColor, fontSize: 12, fontWeight: FontWeight.bold)),
            const Text("Step 1: Details", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Step Progress Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
            child: Row(
              children: [
                Expanded(child: Container(height: 4, decoration: BoxDecoration(color: primaryGreen, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(width: 8),
                Expanded(child: Container(height: 4, decoration: BoxDecoration(color: lightGrey, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(width: 8),
                Expanded(child: Container(height: 4, decoration: BoxDecoration(color: lightGrey, borderRadius: BorderRadius.circular(2)))),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Inspection Details", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("Enter the following details to proceed with the assessment.",
                      style: TextStyle(color: labelColor, fontSize: 15)),

                  const SizedBox(height: 32),

                  _buildField("Stall Number", "e.g. A-12", _stallController),
                  _buildField("Vendor Name", "e.g. Fresh Farms", _vendorController),

                  // DYNAMIC FIELD: Inspector Name
                  _buildField("Inspector Name", "Fetching name...", _inspectorController, isReadOnly: true),

                  // DYNAMIC FIELD: Job Title
                  _buildField("Job Title", "Fetching title...", _jobTitleController, isReadOnly: true),
                ],
              ),
            ),
          ),

          // Bottom Action Button
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // 1. Validation Check
                  if (_stallController.text.trim().isEmpty ||
                      _vendorController.text.trim().isEmpty ||
                      _inspectorController.text.trim().isEmpty ||
                      _jobTitleController.text.trim().isEmpty) {

                    // 2. Show Error if fields are missing
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("All fields are required to continue"),
                        backgroundColor: Colors.redAccent,
                        behavior: SnackBarBehavior.floating,
                        margin: const EdgeInsets.all(20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  } else {
                    // 3. Navigate to Step 2 if valid
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CutTypePage()),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Continue to Step 2",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, String hint, TextEditingController controller, {bool isReadOnly = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            readOnly: isReadOnly,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: isReadOnly ? lightGrey.withOpacity(0.5) : Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryGreen),
              ),
            ),
          ),
        ],
      ),
    );
  }
}