import 'package:flutter/material.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final Color primaryGreen = const Color(0xFF00E676);
  final Color darkText = const Color(0xFF1B1E28);
  final Color greyText = const Color(0xFF707B81);
  final Color lightGrey = const Color(0xFFF8F9FA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 1. Curved Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 30),
            decoration: BoxDecoration(
              color: primaryGreen,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 20),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      "Reports",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 60), // Balanced spacing
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Search and Filter
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: lightGrey,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: const TextField(
                            decoration: InputDecoration(
                              hintText: "Search reports...",
                              prefixIcon: Icon(Icons.search),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8FDF1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.tune, color: primaryGreen),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // 3. Stats Cards
                  Row(
                    children: [
                      _buildStatCard(
                        icon: Icons.assignment_turned_in,
                        label: "TOTAL INSPECTIONS",
                        value: "1,248",
                        trend: "12%",
                        isPositive: true,
                      ),
                      const SizedBox(width: 16),
                      _buildStatCard(
                        icon: Icons.speed,
                        label: "AVG QUALITY",
                        value: "94.2%",
                        trend: "4%",
                        isPositive: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // 4. Recent Reports List
                  const Text(
                    "Recent Reports",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B1E28),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildReportItem("Daily Audit - Stall #14", "Oct 24, 2023 • 08:30 AM", 0.98, Colors.green),
                  _buildReportItem("Weekly Check - Storage A", "Oct 22, 2023 • 02:15 PM", 0.85, Colors.orange),
                  _buildReportItem("Supplier Delivery #802", "Oct 21, 2023 • 11:00 AM", 1.0, Colors.green),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required String trend,
    required bool isPositive,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey[100]!),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: primaryGreen, size: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8FDF1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.trending_up, size: 12, color: primaryGreen),
                      const SizedBox(width: 2),
                      Text(trend, style: TextStyle(color: primaryGreen, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            Text(label, style: TextStyle(color: greyText, fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(color: darkText, fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildReportItem(String title, String subtitle, double score, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: darkText, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: greyText, fontSize: 12)),
              ],
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 45,
                height: 45,
                child: CircularProgressIndicator(
                  value: score,
                  strokeWidth: 4,
                  backgroundColor: color.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Text(
                "${(score * 100).toInt()}%",
                style: TextStyle(color: darkText, fontSize: 11, fontWeight: FontWeight.bold),
              )
            ],
          )
        ],
      ),
    );
  }
}