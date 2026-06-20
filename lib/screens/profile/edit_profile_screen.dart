import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/theme.dart';
import '../../state/app_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _idNumberController;
  
  String _selectedCountry = "India";
  String _selectedDocType = "Aadhaar Card";
  
  bool _isUploading = false;
  String? _uploadedFileName;
  double _uploadProgress = 0.0;

  final List<String> _countries = [
    "India",
    "United States",
    "United Kingdom",
    "Canada",
    "Australia",
    "Singapore"
  ];

  final List<String> _docTypes = [
    "Aadhaar Card",
    "Passport",
    "Driver's License",
    "Voter ID Card"
  ];

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _nameController = TextEditingController(text: appState.userName);
    _phoneController = TextEditingController(text: appState.userPhone);
    _idNumberController = TextEditingController();
    _selectedCountry = appState.userCountry.isNotEmpty ? appState.userCountry : "India";
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _idNumberController.dispose();
    super.dispose();
  }

  void _simulateUpload() {
    setState(() {
      _isUploading = true;
      _uploadedFileName = null;
      _uploadProgress = 0.0;
    });

    int steps = 15;
    int currentStep = 0;
    
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
            _uploadedFileName = "${_selectedDocType.replaceAll(" ", "_").toLowerCase()}_front_back.jpg";
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("ID Document photo attached successfully")),
          );
        }
      }
    });
  }

  void _saveChanges(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final appState = Provider.of<AppState>(context, listen: false);
      
      // Update profile text values
      appState.updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: appState.userEmail,
        country: _selectedCountry,
      );

      // If document is uploaded and ID is entered, save document
      if (_uploadedFileName != null && _idNumberController.text.trim().isNotEmpty) {
        appState.addOrUpdateDocument(
          type: _selectedDocType,
          idNumber: _idNumberController.text.trim(),
          fileName: _uploadedFileName!,
          status: "Pending",
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile changes saved successfully"),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.onSurfaceColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: SvgPicture.asset(
          'assets/images/zuruni_logo.svg',
          height: 24,
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Photo Section
                Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          const CircleAvatar(
                            radius: 54,
                            backgroundColor: AppTheme.surfaceContainerColor,
                            backgroundImage: NetworkImage(
                              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=240',
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: AppTheme.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 18,
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
                const SizedBox(height: 28),

                const Divider(color: AppTheme.outlineVariantColor),
                const SizedBox(height: 24),

                // Identity Verification Section
                Text(
                  "Identity Verification",
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurfaceColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Upload a valid government ID for automated gate-entry clearance.",
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.onSurfaceVariant.withOpacity(0.8),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 20),

                _buildFieldLabel("Select ID Document Type"),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedDocType,
                  items: _docTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedDocType = val!;
                      // Reset upload file when document type changes to avoid confusion
                      _uploadedFileName = null;
                    });
                  },
                ),
                const SizedBox(height: 16),

                _buildFieldLabel("Document ID Number"),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _idNumberController,
                  decoration: const InputDecoration(
                    hintText: "Enter ID number",
                  ),
                ),
                const SizedBox(height: 16),

                // Upload Box
                GestureDetector(
                  onTap: !_isUploading ? _simulateUpload : null,
                  child: CustomPaint(
                    painter: DashedBorderPainter(
                      color: _uploadedFileName != null ? AppTheme.successColor : AppTheme.outlineVariantColor,
                      strokeWidth: 1.5,
                      borderRadius: 12.0,
                    ),
                    child: Container(
                      width: double.infinity,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _buildUploadBoxContent(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Added Documents List
                if (appState.documents.isNotEmpty) ...[
                  ...appState.documents.map((doc) => _buildDocumentTile(doc)),
                  const SizedBox(height: 24),
                ],

                // Save Profile Changes Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => _saveChanges(context),
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

  Widget _buildUploadBoxContent() {
    if (_isUploading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                value: _uploadProgress,
                strokeWidth: 2,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Uploading... ${(100 * _uploadProgress).toInt()}%",
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
            )
          ],
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
                const Icon(Icons.check_circle, color: AppTheme.successColor, size: 28),
                const SizedBox(height: 6),
                Text(
                  _uploadedFileName!,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.onSurfaceColor),
                ),
                const Text(
                  "Photo attached successfully",
                  style: TextStyle(fontSize: 11, color: AppTheme.onSurfaceVariant),
                )
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: AppTheme.errorColor, size: 18),
              onPressed: () {
                setState(() {
                  _uploadedFileName = null;
                });
              },
            ),
          )
        ],
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_upload_outlined, color: AppTheme.outlineColor, size: 30),
          const SizedBox(height: 6),
          const Text(
            "Upload document photo (front & back)",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.onSurfaceVariant),
          ),
          Text(
            "• Max 5MB",
            style: TextStyle(fontSize: 11, color: AppTheme.onSurfaceVariant.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentTile(VerificationDocument doc) {
    final isVerified = doc.status == "Verified";
    final isAadhaar = doc.type.toLowerCase().contains("aadhaar");
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outlineVariantColor),
        boxShadow: AppTheme.ambientShadow,
      ),
      child: Row(
        children: [
          Icon(
            isAadhaar ? Icons.assignment_ind_outlined : Icons.menu_book_outlined,
            color: AppTheme.primaryColor,
            size: 24,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              doc.type,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.onSurfaceColor,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isVerified ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isVerified ? Icons.check_circle : Icons.watch_later,
                  color: isVerified ? const Color(0xFF059669) : const Color(0xFFD97706),
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  doc.status,
                  style: TextStyle(
                    color: isVerified ? const Color(0xFF059669) : const Color(0xFFD97706),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double dashLength;
  final double borderRadius;

  DashedBorderPainter({
    this.color = Colors.grey,
    this.strokeWidth = 1.0,
    this.gap = 4.0,
    this.dashLength = 6.0,
    this.borderRadius = 12.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(borderRadius),
      ));

    final dashPath = _buildDashedPath(path, dashLength, gap);
    canvas.drawPath(dashPath, paint);
  }

  Path _buildDashedPath(Path source, double dashLength, double gap) {
    final Path dest = Path();
    for (final PathMetric metric in source.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final double len = draw ? dashLength : gap;
        if (draw) {
          dest.addPath(
            metric.extractPath(distance, (distance + len).clamp(0.0, metric.length)),
            Offset.zero,
          );
        }
        distance += len;
        draw = !draw;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
