import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'memories/memories_vault_screen.dart';
import 'memories/nfc_scan_screen.dart';
import 'profile/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  final int initialIndex;
  
  const MainNavigation({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int currentIndex;
  
  final List<Widget> screens = [
    MemoriesVaultScreen(),
    const NfcScanScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Memories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.nfc),
            label: 'NFC Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}