import 'package:flutter/material.dart';
import 'package:ibitf_app/singleton.dart';

class ModernAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String? profileImageUrl;
  final Function(String) handleClick;

  const ModernAppBar({
    super.key,
    required this.profileImageUrl,
    required this.handleClick,
  });

  @override
  _ModernAppBarState createState() => _ModernAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _ModernAppBarState extends State<ModernAppBar> {
  final List<bool> _languageSelection = [true, false]; // Default: English
  final List<bool> _roleSelection = [true, false]; // Default: Maid

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 4,
      titleSpacing: 5,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Image.asset(
          "assets/maidful__1_-removebg-preview.png",
          fit: BoxFit.contain,
          height: 40,
        ),
      ),
      title: const Text(
        'Maidful',
        style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: PopupMenuButton<String>(
            icon: CircleAvatar(
              backgroundColor: Colors.grey[300],
              foregroundImage: widget.profileImageUrl != null
                  ? NetworkImage(widget.profileImageUrl!)
                  : null,
              child: widget.profileImageUrl == null
                  ? Icon(Icons.person, color: Colors.black54)
                  : null,
            ),
            onSelected: widget.handleClick,
            itemBuilder: (context) => [
              _buildMenuItem("Logout", Icons.exit_to_app),
              _buildMenuItem("Pricing", Icons.currency_rupee),
              // _buildMenuItem("Settings", Icons.settings),
              _buildMenuItem("Contact Us", Icons.contact_mail),
              _buildLanguageToggle(),
              // _buildRoleToggle(),
            ],
          ),
        ),
      ],
    );
  }

  /// Helper function to create a menu item
  PopupMenuItem<String> _buildMenuItem(String value, IconData icon) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.black54),
          const SizedBox(width: 10),
          Text(value, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  /// Language Toggle Menu Item (Fix: Uses StatefulBuilder to persist state)
  PopupMenuItem<String> _buildLanguageToggle() {
    return PopupMenuItem<String>(
      enabled: false,
      child: StatefulBuilder(
        builder: (context, setState) {
          return _buildToggleGroup(
            title: "Language",
            options: ["English", "Khasi"],
            isSelected: _languageSelection,
            onPressed: (index) {
              setState(() {
                _languageSelection[0] = index == 0;
                _languageSelection[1] = index == 1;
                GlobalVariables.instance.selected = ["English", "Khasi"][index];
                GlobalVariables.instance.xmlHandler
                    .loadStrings(GlobalVariables.instance.selected.toString());
              });
            },
          );
        },
      ),
    );
  }

  /// Role Toggle Menu Item (Fix: Uses StatefulBuilder to persist state)
  PopupMenuItem<String> _buildRoleToggle() {
    return PopupMenuItem<String>(
      enabled: false,
      child: StatefulBuilder(
        builder: (context, setState) {
          return _buildToggleGroup(
            title: "Role",
            options: ["Maid", "Employer"],
            isSelected: _roleSelection,
            onPressed: (index) {
              setState(() {
                _roleSelection[0] = index == 0;
                _roleSelection[1] = index == 1;
                GlobalVariables.instance.userrole = index + 1;
                GlobalVariables.instance.xmlHandler
                    .loadStrings(GlobalVariables.instance.selected.toString());
              });
            },
          );
        },
      ),
    );
  }

  /// Helper function to create a toggle button group
  Widget _buildToggleGroup({
    required String title,
    required List<String> options,
    required List<bool> isSelected,
    required Function(int) onPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        ToggleButtons(
          isSelected: isSelected,
          onPressed: onPressed,
          borderRadius: BorderRadius.circular(12),
          borderColor: Colors.grey[400]!,
          selectedColor: Colors.white,
          fillColor: Colors.blue,
          color: Colors.black,
          children: options
              .map((text) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(text),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
