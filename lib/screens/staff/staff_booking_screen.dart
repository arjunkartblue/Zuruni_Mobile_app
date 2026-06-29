import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/theme.dart';
import '../../state/app_state.dart';

class StaffBookingScreen extends StatefulWidget {
  const StaffBookingScreen({super.key});

  @override
  State<StaffBookingScreen> createState() => _StaffBookingScreenState();
}

class _StaffBookingScreenState extends State<StaffBookingScreen> {
  String _selectedFilter = "All";
  String _searchQuery = "";

  void _showApprovalBottomSheet(BuildContext context, Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: _PendingApprovalBottomSheetContent(item: item),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    const activeBgColor = Color(0xFF290A45); // Dark Amethyst active chip
    const activeTextColor = Colors.white;
    const inactiveBgColor = Color(0xFFFAF1F9); // Light pinkish unselected chip
    const inactiveTextColor = AppTheme.onSurfaceVariant;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeBgColor : inactiveBgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? activeTextColor : inactiveTextColor,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final isPending = status.toLowerCase() == "pending";
    final bgColor = isPending ? const Color(0xFFFFFBEB) : const Color(0xFFECFDF5);
    final borderColor = isPending ? const Color(0xFFFDE68A) : const Color(0xFFA7F3D0);
    final textColor = isPending ? const Color(0xFFB45309) : const Color(0xFF047857);
    final dotColor = isPending ? const Color(0xFFF59E0B) : const Color(0xFF10B981);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: textColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialsAvatar(String initials) {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        color: Color(0xFFF1F5F9),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: const Color(0xFF475569),
        ),
      ),
    );
  }

  Widget _buildApprovalCard(BuildContext context, Map<String, dynamic> item) {
    final hasAvatar = item["avatar"].toString().isNotEmpty;
    final initials = item["name"]
        .toString()
        .split(" ")
        .map((s) => s.isNotEmpty ? s[0] : "")
        .join("");

    final String status = item["status"] ?? "Pending";
    final bool arrived = item["arrived"] ?? false;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: AppTheme.ambientShadow,
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top portion (tappable to view details / approve)
          InkWell(
            onTap: () {
              if (status == "Pending") {
                _showApprovalBottomSheet(context, item);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("${item['name']}'s request is already $status."),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar
                  if (hasAvatar)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.network(
                        item["avatar"],
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildInitialsAvatar(initials),
                      ),
                    )
                  else
                    _buildInitialsAvatar(initials),
                  const SizedBox(width: 12),
                  // Name, status, and time
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item["name"],
                                style: GoogleFonts.hankenGrotesk(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.onSurfaceColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildStatusBadge(status),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time_outlined, 
                              size: 14, 
                              color: AppTheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item["time"],
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Divider
          const Divider(
            color: Color(0xFFF1F5F9), 
            height: 1, 
            thickness: 1,
          ),
          
          // Bottom portion
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Token Info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "TOKEN",
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.onSurfaceVariant.withOpacity(0.5),
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "#${item['token'] ?? 'T-442'}",
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onSurfaceColor,
                      ),
                    ),
                  ],
                ),
                // Arrival Checkbox Toggle
                GestureDetector(
                  onTap: () {
                    if (status == "Pending") {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Visitor must be approved before check-in"),
                          backgroundColor: AppTheme.primaryColor,
                        ),
                      );
                    } else {
                      Provider.of<AppState>(context, listen: false).toggleArrivalStatus(item["id"]);
                    }
                  },
                  child: Row(
                    children: [
                      Icon(
                        arrived 
                            ? Icons.check_box_outlined 
                            : Icons.crop_square_outlined,
                        color: arrived ? const Color(0xFF10B981) : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        arrived ? "Arrived" : "Not Arrived",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: arrived ? const Color(0xFF059669) : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final allApprovals = appState.staffAllApprovals;

    // Filter logic
    final filteredList = allApprovals.where((item) {
      // 1. Filter by Chip
      if (_selectedFilter == "Pending") {
        if (item["status"] != "Pending") return false;
      } else if (_selectedFilter == "Approved") {
        if (item["status"] != "Approved") return false;
      } else if (_selectedFilter == "Upcoming") {
        if (item["status"] != "Pending" && item["status"] != "Approved") return false;
      }

      // 2. Filter by Search Query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final name = item["name"].toString().toLowerCase();
        final token = (item["token"] ?? "").toString().toLowerCase();
        if (!name.contains(query) && !token.contains(query)) return false;
      }

      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Search & Filter Container (fixed at top)
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 16.0, bottom: 8.0),
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.onSurfaceColor,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: "Search visitors or tokens...",
                      hintStyle: GoogleFonts.inter(
                        color: AppTheme.onSurfaceVariant.withOpacity(0.5),
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(Icons.search, color: AppTheme.onSurfaceVariant, size: 20),
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Color(0xFFEADDF0), width: 1.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Color(0xFFEADDF0), width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Horizontal Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildFilterChip("All"),
                        const SizedBox(width: 8),
                        _buildFilterChip("Upcoming"),
                        const SizedBox(width: 8),
                        _buildFilterChip("Pending"),
                        const SizedBox(width: 8),
                        _buildFilterChip("Approved"),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Separator/Spacing
            const SizedBox(height: 8),

            // Booking Cards Scroll Area
            Expanded(
              child: filteredList.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 60.0, horizontal: 20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFAF1F9),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.search_off_outlined, size: 48, color: AppTheme.primaryColor),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No Visitors Found",
                              style: GoogleFonts.hankenGrotesk(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.onSurfaceColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Try adjusting your filters or search query.",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                color: AppTheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                      physics: const BouncingScrollPhysics(),
                      itemCount: filteredList.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return _buildApprovalCard(context, filteredList[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingApprovalBottomSheetContent extends StatefulWidget {
  final Map<String, dynamic> item;
  const _PendingApprovalBottomSheetContent({required this.item});

  @override
  State<_PendingApprovalBottomSheetContent> createState() => _PendingApprovalBottomSheetContentState();
}

class _PendingApprovalBottomSheetContentState extends State<_PendingApprovalBottomSheetContent> {
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

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom, // Avoid keyboard overlap
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Review Visitor Request",
            style: GoogleFonts.hankenGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurfaceColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (hasAvatar)
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.network(
                    item["avatar"],
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildInitialsAvatar(initials),
                  ),
                )
              else
                _buildInitialsAvatar(initials),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item["name"],
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onSurfaceColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Token: #${item['token'] ?? 'T-442'}",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Reason box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
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
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryColor.withOpacity(0.6),
                    letterSpacing: 1.0,
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
          
          if (_showRejectInput) ...[
            const SizedBox(height: 20),
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
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          final reason = _selectedReason == "Custom Reason"
                              ? _customReasonController.text
                              : _selectedReason;
                          Provider.of<AppState>(context, listen: false)
                              .rejectVisitorRequest(item["id"]);
                          Navigator.pop(context);
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
                            borderRadius: BorderRadius.circular(12),
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
          ] else ...[
            const SizedBox(height: 24),
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
                        Navigator.pop(context);
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
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildInitialsAvatar(String initials) {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        color: Color(0xFFF1F5F9),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: const Color(0xFF475569),
        ),
      ),
    );
  }
}

