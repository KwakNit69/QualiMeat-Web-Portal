import 'package:flutter/material.dart';
import 'package:quality_meat1/step3.dart'; // Ensure this matches your file name

class CutTypePage extends StatefulWidget {
  const CutTypePage({super.key});

  @override
  State<CutTypePage> createState() => _CutTypePageState();
}

class _CutTypePageState extends State<CutTypePage> {
  final Color primaryGreen = const Color(0xFF00E676);
  final Color darkCard = const Color(0xFF131E19);
  final Color lightGrey = const Color(0xFFF8F9FA);
  final Color labelColor = const Color(0xFF707B81);

  String selectedCut = "Liempo";

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
        title: const Column(
          children: [
            Text("NEW INSPECTION", style: TextStyle(color: Color(0xFF707B81), fontSize: 11, fontWeight: FontWeight.bold)),
            Text("Step 2: Cut Type", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Progress Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
            child: Row(
              children: [
                Expanded(child: Container(height: 4, decoration: BoxDecoration(color: primaryGreen, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(width: 8),
                Expanded(child: Container(height: 4, decoration: BoxDecoration(color: primaryGreen, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(width: 8),
                Expanded(child: Container(height: 4, decoration: BoxDecoration(color: lightGrey, borderRadius: BorderRadius.circular(2)))),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      _buildCutCard("Liempo", "BELLY CUT", Icons.layers_rounded),
                      _buildCutCard("Kasim", "SHOULDER", Icons.reorder_rounded),
                      _buildCutCard("Pata", "LEG CUT", Icons.park_rounded),
                      _buildCutCard("Pork Chop", "LOIN CUT", Icons.restaurant_menu_rounded),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildInspectionGuide(),
                ],
              ),
            ),
          ),

          // NAVIGATE TO STEP 3
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScannerPage(selectedCut: selectedCut),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("CONTINUE TO STEP 3", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCutCard(String name, String sub, IconData icon) {
    bool isSelected = selectedCut == name;
    return GestureDetector(
      onTap: () => setState(() => selectedCut = name),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? primaryGreen : lightGrey, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? primaryGreen : labelColor, size: 30),
            const SizedBox(height: 8),
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(sub, style: TextStyle(color: labelColor, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildInspectionGuide() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: darkCard, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("GUIDE FOR $selectedCut", style: TextStyle(color: primaryGreen, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Ensure lighting is bright and the meat is centered for AI accuracy.", style: TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }
}