import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; //
import 'edit_profile_page.dart';
import 'security_settings_page.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Access the current logged-in user from Firebase Auth
  final User? user = FirebaseAuth.instance.currentUser; //

  final Color primaryGreen = const Color(0xFF00E676);
  final Color lightGreenBg = const Color(0xFFE8FDF1);
  final Color textColor = const Color(0xFF1E293B);
  final Color greyText = const Color(0xFF9E9E9E);

  // Logic to handle Logout
  Future<void> _handleLogout() async {
    await FirebaseAuth.instance.signOut(); //
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
      );
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
        title: Text(
          "Profile",
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      // 1. Wrap the body in a StreamBuilder to fetch Firestore data in real-time
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .snapshots(), //
        builder: (context, snapshot) {
          // Default fallbacks while loading or if data is missing
          String displayName = user?.displayName ?? "User Name";
          String displayEmail = user?.email ?? "email@example.com";
          String jobTitle = "SENIOR AUDITOR"; // Default if not in DB
          String? photoUrl = user?.photoURL;

          // 2. If Firestore has data, override the defaults
          if (snapshot.hasData && snapshot.data!.exists) {
            var data = snapshot.data!.data() as Map<String, dynamic>;
            displayName = data['fullName'] ?? displayName;
            displayEmail = data['email'] ?? displayEmail;
            jobTitle = data['jobTitle'] ?? jobTitle;
            // Use profilePicture from Firestore (Cloudinary link) if it exists
            photoUrl = data['profilePicture'] ?? photoUrl;
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Profile Avatar with dynamic Image
                Center(
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: primaryGreen, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: photoUrl != null
                              ? NetworkImage(photoUrl)
                              : null,
                          child: photoUrl == null
                              ? Icon(Icons.person, size: 50, color: greyText)
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryGreen,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 3. Dynamic Name
                Text(
                  displayName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 6),

                // 4. Dynamic Email
                Text(
                  displayEmail,
                  style: TextStyle(
                    fontSize: 14,
                    color: primaryGreen,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),

                // 5. Dynamic Role Badge (Job Title)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: lightGreenBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_rounded, color: primaryGreen, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        jobTitle.toUpperCase(),
                        style: TextStyle(
                          color: primaryGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Menu Options
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      _buildMenuOption(
                        title: "Edit Profile",
                        icon: Icons.person_rounded,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const EditProfilePage()),
                          );
                        },
                      ),
                      _buildMenuOption(
                        title: "My Reports",
                        icon: Icons.description_rounded,
                        onTap: () {},
                      ),
                      _buildMenuOption(
                        title: "Security Settings",
                        icon: Icons.shield_rounded,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SecuritySettingsPage()),
                          );
                        },
                      ),
                      _buildMenuOption(
                        title: "Help & Support",
                        icon: Icons.help_rounded,
                        onTap: () {},
                        showDivider: false,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Logout Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: _handleLogout,
                      icon: Icon(Icons.logout_rounded, color: primaryGreen),
                      label: Text(
                        "Logout",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryGreen,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: primaryGreen.withOpacity(0.3), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Version Text
                Text(
                  "VERSION 3.4.1 (BUILD 102)",
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          currentIndex: 3,
          selectedItemColor: primaryGreen,
          unselectedItemColor: greyText,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          onTap: (index) {
            if (index != 3) {
              Navigator.pop(context);
            }
          },
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
            const BottomNavigationBarItem(icon: Icon(Icons.assignment_rounded), label: 'Tasks'),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  const Icon(Icons.notifications),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 8, height: 8,
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    ),
                  ),
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

  Widget _buildMenuOption({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          onTap: onTap,
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: lightGreenBg, shape: BoxShape.circle),
            child: Icon(icon, color: primaryGreen, size: 22),
          ),
          title: Text(
            title,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textColor),
          ),
          trailing: Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey[400], size: 16),
        ),
        if (showDivider)
          Divider(color: Colors.grey[100], thickness: 1, indent: 60),
      ],
    );
  }
}