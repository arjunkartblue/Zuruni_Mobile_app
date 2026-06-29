import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/theme.dart';
import '../../state/app_state.dart';

class StaffEditProfileScreen extends StatefulWidget {
  const StaffEditProfileScreen({Key? key}) : super(key: key);

  @override
  State<StaffEditProfileScreen> createState() => _StaffEditProfileScreenState();
}

class _StaffEditProfileScreenState extends State<StaffEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  
  String _selectedCountry = "USA";

  final List<String> _countries = [
    "USA",
    "India",
    "United Kingdom",
    "Canada",
    "Australia",
    "Singapore"
  ];

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _nameController = TextEditingController(text: appState.userName);
    _phoneController = TextEditingController(text: appState.userPhone);
    _emailController = TextEditingController(text: appState.userEmail);
    _selectedCountry = appState.userCountry.isNotEmpty ? appState.userCountry : "USA";
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveChanges(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final appState = Provider.of<AppState>(context, listen: false);
      
      // Update profile values in AppState
      appState.updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        country: _selectedCountry,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Staff profile changes saved successfully"),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0.5,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.onSurfaceColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Edit Staff Profile",
          style: GoogleFonts.hankenGrotesk(
            fontWeight: FontWeight.bold,
            color: AppTheme.onSurfaceColor,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => _saveChanges(context),
            child: const Text(
              "Save",
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // CARD 1: Profile Information
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radius2Xl),
                    border: Border.all(color: AppTheme.outlineVariantColor.withOpacity(0.15)),
                    boxShadow: AppTheme.ambientShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Photo Section
                      Center(
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: const Image(
                                    image: NetworkImage(
                                      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=240',
                                    ),
                                    width: 108,
                                    height: 108,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Photo picker simulation")),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(
                                        color: AppTheme.primaryColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Photo picker simulation")),
                                );
                              },
                              child: const Text(
                                "Change Photo",
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Divider(color: AppTheme.outlineVariantColor, height: 1),
                      const SizedBox(height: 20),

                      // Form Fields
                      _buildFieldLabel("Full Name"),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        validator: (value) => value == null || value.trim().isEmpty ? "Name cannot be empty" : null,
                        decoration: const InputDecoration(
                          hintText: "Enter your full name",
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildFieldLabel("Phone Number"),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _phoneController,
                        validator: (value) => value == null || value.trim().isEmpty ? "Phone number cannot be empty" : null,
                        decoration: const InputDecoration(
                          hintText: "Enter your phone number",
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildFieldLabel("Email Address"),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return "Email cannot be empty";
                          if (!value.contains("@")) return "Enter a valid email";
                          return null;
                        },
                        decoration: const InputDecoration(
                          hintText: "Enter your email address",
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      _buildFieldLabel("Country / Region"),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _selectedCountry,
                        items: _countries.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedCountry = val!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),

                // CARD 2: Professional Details (Read-only)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radius2Xl),
                    border: Border.all(color: AppTheme.outlineVariantColor.withOpacity(0.15)),
                    boxShadow: AppTheme.ambientShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Professional Details",
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.onSurfaceColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Your department and role details are managed by HR. Contact IT if updates are needed.",
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.onSurfaceVariant.withOpacity(0.8),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildReadOnlyField("Employee ID", "EMP-4920"),
                      const SizedBox(height: 14),
                      _buildReadOnlyField("Job Title", "Senior Manager"),
                      const SizedBox(height: 14),
                      _buildReadOnlyField("Department", "Human Resources"),
                      const SizedBox(height: 14),
                      _buildReadOnlyField("Workplace Location", "Zuruni HQ - Chicago"),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Save Profile Changes Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => _saveChanges(context),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                      ),
                    ),
                    child: const Text("Save Profile Changes"),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String labelText) {
    return Text(
      labelText,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: AppTheme.onSurfaceColor,
      ),
    );
  }

  Widget _buildReadOnlyField(String labelText, String valueText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppTheme.onSurfaceVariant.withOpacity(0.6),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerColor.withOpacity(0.4),
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            border: Border.all(color: AppTheme.outlineVariantColor.withOpacity(0.2)),
          ),
          child: Text(
            valueText,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.onSurfaceColor,
            ),
          ),
        ),
      ],
    );
  }
}
