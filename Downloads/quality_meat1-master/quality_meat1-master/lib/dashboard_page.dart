import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Added Firebase Auth import
import 'package:quality_meat1/stall_registration_page.dart';
import 'profile_page.dart';
import 'inspection_page.dart'; // Import your Inspection Page
import 'view_reports_page.dart'; // Import your View Reports Page

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  // 1. Fetch current user from Firebase
  final User? user = FirebaseAuth.instance.currentUser;

  // Colors based on the design
  final Color primaryGreen = const Color(0xFF00E676);
  final Color darkText = const Color(0xFF1E293B);
  final Color greyText = const Color(0xFF9E9E9E);
  final Color lightGreenBg = const Color(0xFFE8FDF1);
  final Color borderColor = const Color(0xFFE9EDEF);

  void _onItemTapped(int index) {
    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Widget _getBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const Center(child: Text('Tasks Content', style: TextStyle(fontSize: 18, color: Colors.grey)));
      case 2:
        return const Center(child: Text('Alerts Content', style: TextStyle(fontSize: 18, color: Colors.grey)));
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. New Inspection Card
          _buildActionCard(
            title: "New Inspection",
            subtitle: "Start a new quality check session",
            icon: Icons.fact_check_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewInspectionPage()),
              );
            },
          ),
          const SizedBox(height: 16),

          // 2. View Reports Card
          _buildActionCard(
            title: "View Reports",
            subtitle: "Analyze performance and metrics",
            icon: Icons.bar_chart_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReportsPage()),
              );
            },
          ),
          const SizedBox(height: 16),

          // 3. NEW: Stall Registration Card
// Inside _buildHomeContent in dashboard_page.dart
          _buildActionCard(
            title: "Stall Registration",
            subtitle: "Register and manage vendor stalls",
            icon: Icons.app_registration_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StallRegistrationPage()),
              );
            },
          ),

          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Latest Updates",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(color: lightGreenBg, borderRadius: BorderRadius.circular(20)),
                child: Text("View All", style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildUpdateItem(
            title: "Inspection #402 Compl...",
            subtitle: "Passed with 98% quality score.",
            time: "10m ago",
            icon: Icons.check_circle_rounded,
            iconColor: primaryGreen,
            bgColor: lightGreenBg,
          ),
          const SizedBox(height: 12),
          _buildUpdateItem(
            title: "Stock Alert: Ribeye",
            subtitle: "Check current batch availability.",
            time: "1h ago",
            icon: Icons.warning_rounded,
            iconColor: Colors.orange,
            bgColor: Colors.orange.withOpacity(0.1),
          ),
          const SizedBox(height: 12),
          _buildUpdateItem(
            title: "Weekly Summary Ready",
            subtitle: "Download the latest PDF...",
            time: "2h ago",
            icon: Icons.description_rounded,
            iconColor: Colors.blueAccent,
            bgColor: Colors.blueAccent.withOpacity(0.1),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap, // Added onTap parameter
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24), // Matches container radius for ripple effect
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: primaryGreen.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: lightGreenBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: primaryGreen, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: darkText, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: greyText, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateItem({
    required String title,
    required String subtitle,
    required String time,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(title, style: TextStyle(color: darkText, fontSize: 14, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    Text(time, style: TextStyle(color: greyText, fontSize: 11, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: greyText, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 2. Extract Photo URL from Firebase user
    String? photoUrl = user?.photoURL;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 30),
            decoration: BoxDecoration(
              color: primaryGreen,
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              boxShadow: [BoxShadow(color: primaryGreen.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.verified_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("QualiMeat", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      Text("QUALITY MEAT CONTROL", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    ],
                  ),
                ),

                // 3. Dynamic Profile Picture Section
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey[300],
                        // Use photoUrl if available, otherwise show person icon
                        backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                        child: photoUrl == null ? const Icon(Icons.person, color: Colors.white, size: 20) : null,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 12, height: 12,
                        decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle, border: Border.all(color: primaryGreen, width: 2)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(child: _getBody()),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))]),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          selectedItemColor: primaryGreen,
          unselectedItemColor: greyText,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          onTap: _onItemTapped,
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
            const BottomNavigationBarItem(icon: Icon(Icons.assignment_rounded), label: 'Tasks'),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  const Icon(Icons.notifications),
                  Positioned(top: 0, right: 0, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle))),
                ],
              ),
              label: 'Alerts',
            ),
            const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}