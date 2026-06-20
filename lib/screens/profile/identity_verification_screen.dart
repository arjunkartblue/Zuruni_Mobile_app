import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/theme.dart';
import '../../state/app_state.dart';
import 'account_verified_screen.dart';

class IdentityVerificationScreen extends StatefulWidget {
  const IdentityVerificationScreen({Key? key}) : super(key: key);

  @override
  State<IdentityVerificationScreen> createState() => _IdentityVerificationScreenState();
}

class _IdentityVerificationScreenState extends State<IdentityVerificationScreen> {
  String _selectedDocType = "Aadhaar Card";
  bool _isUploading = false;
  String? _uploadedFileName;
  double _uploadProgress = 0.0;

  final List<String> _docTypes = [
    "Aadhaar Card",
    "Passport",
    "Driver's License",
    "Voter ID Card",
  ];

  void _simulateUpload() {
    setState(() {
      _isUploading = true;
      _uploadedFileName = null;
      _uploadProgress = 0.0;
    });

    // Simulate progress updates
    int steps = 20;
    int currentStep = 0;
    
    // We update progress every 100ms
    Stream.periodic(const Duration(milliseconds: 100)).take(steps).listen((_) {
      currentStep++;
      if (mounted) {
        setState(() {
          _uploadProgress = currentStep / steps;
        });
      }
      if (currentStep == steps) {
        if (mounted) {
          setState(() {
            _isUploading = false;
            _uploadedFileName = "${_selectedDocType.replaceAll(" ", "_").toLowerCase()}_front.jpg";
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Mock ID scanned and uploaded successfully!")),
          );
        }
      }
    });
  }

  void _submitForAudit(AppState appState) {
    if (_uploadedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please upload your document first"),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    // Call state action
    appState.uploadId(_selectedDocType, _uploadedFileName!);

    // Navigate to Celebration/Success screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AccountVerifiedScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.onSurfaceColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Identity Verification",
          style: GoogleFonts.hankenGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Secure Gate Clearance",
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Verify your account once to unlock automated door accesses, digital QR visitor passes, and reserved parking bays.",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.onSurfaceVariant,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 32),

              // Doc Type Dropdown
              Text(
                "Select Identification Type",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onSurfaceColor,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedDocType,
                items: _docTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedDocType = val!;
                    _uploadedFileName = null; // reset if type changes
                  });
                },
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.badge_outlined, color: AppTheme.outlineColor),
                ),
              ),
              const SizedBox(height: 28),

              // Upload Box (Interactive Card)
              Text(
                "Upload Document Photo",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onSurfaceColor,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: !_isUploading ? _simulateUpload : null,
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radius2Xl),
                    border: Border.all(
                      color: _uploadedFileName != null ? AppTheme.successColor : AppTheme.outlineColor,
                      style: BorderStyle.solid,
                      width: 1.5,
                    ),
                    boxShadow: AppTheme.ambientShadow,
                  ),
                  child: _buildUploadBoxContent(),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Upload files in JPG, PNG, or PDF formats. Max size limit: 5MB.",
                style: TextStyle(fontSize: 11, color: AppTheme.onSurfaceVariant),
              ),
              const SizedBox(height: 48),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _uploadedFileName != null && !_isUploading
                      ? () => _submitForAudit(appState)
                      : null,
                  child: const Text("SUBMIT FOR SECURE AUDIT"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadBoxContent() {
    if (_isUploading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                value: _uploadProgress,
                color: AppTheme.primaryColor,
                backgroundColor: AppTheme.surfaceContainerColor,
              ),
              const SizedBox(height: 16),
              Text(
                "Scanning and uploading ID... ${(100 * _uploadProgress).toInt()}%",
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    if (_uploadedFileName != null) {
      return Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: AppTheme.successColor, size: 48),
                const SizedBox(height: 8),
                Text(
                  _uploadedFileName!,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.onSurfaceColor),
                ),
                const SizedBox(height: 2),
                const Text("Photo attached successfully", style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant)),
              ],
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: CircleAvatar(
              backgroundColor: AppTheme.errorColor.withOpacity(0.1),
              radius: 16,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.delete, color: AppTheme.errorColor, size: 16),
                onPressed: () {
                  setState(() {
                    _uploadedFileName = null;
                  });
                },
              ),
            ),
          )
        ],
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppTheme.surfaceContainerColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cloud_upload_outlined, color: AppTheme.primaryColor, size: 28),
          ),
          const SizedBox(height: 12),
          const Text(
            "Click to upload front photo of ID",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.onSurfaceColor),
          ),
          const SizedBox(height: 2),
          const Text(
            "Passport, Aadhaar, or Driver's License",
            style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
