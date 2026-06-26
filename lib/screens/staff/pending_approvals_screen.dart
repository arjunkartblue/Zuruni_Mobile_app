import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/theme.dart';
import '../../state/app_state.dart';

class PendingApprovalsScreen extends StatelessWidget {
  const PendingApprovalsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final pendingList = appState.staffPendingApprovals;

    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Section
              Text(
                "Pending Approvals",
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurfaceColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Review and manage upcoming visitor requests.",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),

              // Bulk Approve Button
              if (pendingList.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: () {
                    Provider.of<AppState>(context, listen: false).bulkApproveAll();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("All requests approved successfully!"),
                        backgroundColor: AppTheme.successColor,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.done_all, size: 18),
                  label: const Text(
                    "Bulk Approve All",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              const SizedBox(height: 24),

              // Cards List
              pendingList.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 60.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFAF1F9),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.done_all, size: 48, color: AppTheme.primaryColor),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "All Clear!",
                              style: GoogleFonts.hankenGrotesk(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.onSurfaceColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "No pending approvals remaining.",
                              style: GoogleFonts.inter(
                                color: AppTheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: pendingList.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 20),
                      itemBuilder: (context, index) {
                        return _PendingApprovalCard(
                          item: pendingList[index],
                          index: index,
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PendingApprovalCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final int index;

  const _PendingApprovalCard({
    Key? key,
    required this.item,
    required this.index,
  }) : super(key: key);

  @override
  State<_PendingApprovalCard> createState() => _PendingApprovalCardState();
}

class _PendingApprovalCardState extends State<_PendingApprovalCard> {
  bool _showRejectInput = false;
  String _selectedReason = "Schedule Conflict";
  final TextEditingController _customReasonController = TextEditingController();

  final List<String> _rejectionReasons = [
    "Schedule Conflict",
    "Security Concern",
    "Outside Visiting Hours",
    "Custom Reason",
  ];

  @override
  void dispose() {
    _customReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final hasAvatar = item["avatar"].toString().isNotEmpty;
    final initials = item["name"]
        .toString()
        .split(" ")
        .map((s) => s.isNotEmpty ? s[0] : "")
        .join("");

    final isEven = widget.index % 2 == 0;
    final borderLeftColor = isEven ? const Color(0xFFF59E0B) : const Color(0xFF764AA0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: AppTheme.ambientShadow,
          border: Border(
            left: BorderSide(color: borderLeftColor, width: 4),
            top: BorderSide(color: AppTheme.outlineVariantColor.withOpacity(0.15)),
            right: BorderSide(color: AppTheme.outlineVariantColor.withOpacity(0.15)),
            bottom: BorderSide(color: AppTheme.outlineVariantColor.withOpacity(0.15)),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  if (hasAvatar)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.network(
                        item["avatar"],
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildInitialsAvatar(initials),
                      ),
                    )
                  else
                    _buildInitialsAvatar(initials),
                  const SizedBox(width: 16),
                  // Title and ID
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item["name"],
                          style: GoogleFonts.hankenGrotesk(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.onSurfaceColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.assignment_ind_outlined, size: 14, color: AppTheme.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text(
                              "ID: ${item['id']}",
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 14, color: AppTheme.primaryColor),
                            const SizedBox(width: 4),
                            Text(
                              item["time"],
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Reason box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF1F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "REASON FOR VISIT",
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryColor.withOpacity(0.6),
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item["reason"],
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.onSurfaceColor.withOpacity(0.8),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              // Expanding Rejection Reason Form
              if (_showRejectInput) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200.withOpacity(0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "REJECTION REASON",
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Colors.red.shade900,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.outlineVariantColor),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedReason,
                            isExpanded: true,
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedReason = val;
                                });
                              }
                            },
                            items: _rejectionReasons.map((String reason) {
                              return DropdownMenuItem<String>(
                                value: reason,
                                child: Text(
                                  reason,
                                  style: GoogleFonts.inter(fontSize: 13),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      if (_selectedReason == "Custom Reason") ...[
                        const SizedBox(height: 12),
                        TextField(
                          controller: _customReasonController,
                          style: GoogleFonts.inter(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: "Enter custom reason for rejection...",
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _showRejectInput = false;
                              });
                            },
                            child: Text(
                              "Cancel",
                              style: GoogleFonts.inter(
                                color: AppTheme.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              final reason = _selectedReason == "Custom Reason"
                                  ? _customReasonController.text
                                  : _selectedReason;
                              Provider.of<AppState>(context, listen: false)
                                  .rejectVisitorRequest(item["id"]);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Rejected visitor ${item['name']} (Reason: $reason)"),
                                  backgroundColor: AppTheme.errorColor,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.errorColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              "Confirm Reject",
                              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),
              // Reject / Approve Actions
              if (!_showRejectInput)
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _showRejectInput = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF4EBF4),
                            foregroundColor: AppTheme.onSurfaceVariant,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Reject",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            Provider.of<AppState>(context, listen: false)
                                .approveVisitorRequest(item["id"]);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Approved visitor ${item['name']}"),
                                backgroundColor: AppTheme.successColor,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Approve",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitialsAvatar(String initials) {
    return Container(
      width: 56,
      height: 56,
      decoration: const BoxDecoration(
        color: Color(0xFFF1F5F9),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: const Color(0xFF475569),
        ),
      ),
    );
  }
}
