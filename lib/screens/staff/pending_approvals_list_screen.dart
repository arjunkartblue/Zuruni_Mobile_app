import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/theme.dart';
import '../../state/app_state.dart';

class PendingApprovalsListScreen extends StatelessWidget {
  const PendingApprovalsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    // Filter to show only pending requests
    final pendingList = appState.staffAllApprovals
        .where((item) => item["status"]?.toLowerCase() == "pending")
        .toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.onSurfaceColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Description Block
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Pending Approvals",
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurfaceColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Review and manage upcoming visitor requests.",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Bulk Approve Button
                  if (pendingList.isNotEmpty)
                    SizedBox(
                      height: 40,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          appState.bulkApproveAll();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("All pending requests approved successfully"),
                              backgroundColor: AppTheme.successColor,
                            ),
                          );
                        },
                        icon: const Icon(Icons.done_all, size: 18, color: Colors.white),
                        label: Text(
                          "Bulk Approve",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Scrollable List of Pending Approvals Cards
            Expanded(
              child: pendingList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFAF1F9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.verified_outlined, 
                              size: 48, 
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No Pending Approvals",
                            style: GoogleFonts.hankenGrotesk(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.onSurfaceColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "All visitor requests have been resolved.",
                            style: GoogleFonts.inter(
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                      physics: const BouncingScrollPhysics(),
                      itemCount: pendingList.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return _PendingApprovalListCard(
                          item: pendingList[index],
                          index: index,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingApprovalListCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final int index;
  const _PendingApprovalListCard({required this.item, required this.index});

  @override
  State<_PendingApprovalListCard> createState() => _PendingApprovalListCardState();
}

class _PendingApprovalListCardState extends State<_PendingApprovalListCard> {
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

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final hasAvatar = item["avatar"].toString().isNotEmpty;
    final initials = item["name"]
        .toString()
        .split(" ")
        .map((s) => s.isNotEmpty ? s[0] : "")
        .join("");

    // Alternate left borders: even indexes yellow, odd purple
    final leftBorderColor = widget.index % 2 == 0 ? const Color(0xFFF59E0B) : const Color(0xFF764AA0);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: leftBorderColor, width: 6),
            ),
          ),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header: Avatar, Name, ID, Time
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  if (hasAvatar)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(28),
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
                  
                  // Details
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
                            const Icon(
                              Icons.assignment_ind_outlined, 
                              size: 14, 
                              color: AppTheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "ID: ${item['id']}",
                              style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time_outlined, 
                              size: 14, 
                              color: AppTheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                item["time"],
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
              
              // Reason Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF1F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Reason for Visit",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.onSurfaceVariant.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item["reason"],
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppTheme.onSurfaceColor,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Action Buttons or Inline Rejection Inputs
              if (_showRejectInput) ...[
                const SizedBox(height: 16),
                const Divider(color: Color(0xFFF1F5F9), height: 1, thickness: 1),
                const SizedBox(height: 16),
                Text(
                  "REJECTION REASON",
                  style: GoogleFonts.inter(
                    fontSize: 10,
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
                      hintText: "Enter custom reason...",
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
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        final reason = _selectedReason == "Custom Reason"
                            ? _customReasonController.text
                            : _selectedReason;
                        Provider.of<AppState>(context, listen: false)
                            .rejectVisitorRequest(item["id"]);
                        setState(() {
                          _showRejectInput = false;
                        });
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Confirm Reject"),
                    ),
                  ],
                ),
              ] else ...[
                const SizedBox(height: 16),
                const Divider(color: Color(0xFFF1F5F9), height: 1, thickness: 1),
                const SizedBox(height: 16),
                // Approve Capsule Button (Black)
                SizedBox(
                  width: double.infinity,
                  height: 50,
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
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_outlined, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          "Approve",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Reject Capsule Button (Light grey)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showRejectInput = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEDE2EC), // Light grayish purple matching mockup
                      foregroundColor: AppTheme.onSurfaceColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cancel_outlined, size: 18, color: AppTheme.onSurfaceColor),
                        const SizedBox(width: 8),
                        Text(
                          "Reject",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppTheme.onSurfaceColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
