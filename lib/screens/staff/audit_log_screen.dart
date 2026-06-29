import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/theme.dart';

class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key});

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  String _selectedTimeframe = "Last 7 Days";
  String _selectedStaff = "All Staff";
  bool _showModificationsOnly = true;
  final _searchController = TextEditingController();
  int _currentPage = 1;

  final List<String> _timeframes = ["Last 24 Hours", "Last 7 Days", "Last 30 Days", "All Time"];
  final List<String> _staffMembers = ["All Staff", "Sarah Jenkins", "Marcus Kline", "Alex Rivers", "System Auto"];

  // Mocked Log Data
  final List<Map<String, dynamic>> _allLogs = [
    {
      "timestamp": "2023-10-24 14:32:05 UTC",
      "name": "Sarah Jenkins",
      "avatar": "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=240",
      "action": "Modified Appointment Status",
      "actionColor": const Color(0xFFF59E0B), // Yellow/Amber
      "details": "Changed from 'Pending' to 'Confirmed'",
      "reference": "APT-8921A",
      "isModification": true,
    },
    {
      "timestamp": "2023-10-24 11:15:22 UTC",
      "name": "Marcus Kline",
      "initials": "MK",
      "avatar": "",
      "action": "Deleted Token Entry",
      "actionColor": const Color(0xFFEF4444), // Red
      "details": "Removed walk-in token from queue manually.",
      "reference": "TKN-004B",
      "isModification": false,
    },
    {
      "timestamp": "2023-10-24 09:05:10 UTC",
      "name": "Alex Rivers",
      "avatar": "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=240",
      "action": "Updated System Settings",
      "actionColor": const Color(0xFF3B0764), // Dark purple
      "details": "Adjust maximum daily token limit to 150.",
      "reference": "SYS-CFG",
      "isModification": true,
    },
    {
      "timestamp": "2023-10-23 16:45:01 UTC",
      "name": "System Auto",
      "isSystem": true,
      "avatar": "",
      "action": "Archived Old Records",
      "actionColor": const Color(0xFF64748B), // Grey
      "details": "Scheduled cleanup of appointments > 90 days.",
      "reference": "JOB-991",
      "isModification": true,
    },
    {
      "timestamp": "2023-10-23 14:02:11 UTC",
      "name": "Sarah Jenkins",
      "avatar": "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=240",
      "action": "Modified Appointment Details",
      "actionColor": const Color(0xFFF59E0B),
      "details": "Updated parking assignment for visitor.",
      "reference": "APT-8910B",
      "isModification": true,
    },
    {
      "timestamp": "2023-10-22 10:12:00 UTC",
      "name": "Marcus Kline",
      "initials": "MK",
      "avatar": "",
      "action": "Created Manual Booking",
      "actionColor": const Color(0xFF10B981), // Green
      "details": "Booked walk-in slot for VIP Client.",
      "reference": "APT-8901Z",
      "isModification": false,
    }
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildAvatar(Map<String, dynamic> log) {
    if (log["isSystem"] == true) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.android, color: Color(0xFF64748B), size: 22),
      );
    }
    
    if (log["avatar"].toString().isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(
          log["avatar"],
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildInitialsAvatar(log),
        ),
      );
    }

    return _buildInitialsAvatar(log);
  }

  Widget _buildInitialsAvatar(Map<String, dynamic> log) {
    final initials = log["initials"] ?? 
        log["name"]
            .toString()
            .split(" ")
            .map((s) => s.isNotEmpty ? s[0] : "")
            .join("");
            
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: Color(0xFFD8B4FE), // Light purple
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: const Color(0xFF581C87),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter logic
    final filteredLogs = _allLogs.where((log) {
      // 1. Timeframe mock filter (simple check)
      // 2. Staff filter
      if (_selectedStaff != "All Staff" && log["name"] != _selectedStaff) {
        return false;
      }
      // 3. Action Type: Modifications filter
      if (_showModificationsOnly && log["isModification"] != true) {
        return false;
      }
      // 4. Search query
      if (_searchController.text.isNotEmpty) {
        final query = _searchController.text.toLowerCase();
        final matchName = log["name"].toString().toLowerCase().contains(query);
        final matchAction = log["action"].toString().toLowerCase().contains(query);
        final matchDetails = log["details"].toString().toLowerCase().contains(query);
        final matchRef = log["reference"].toString().toLowerCase().contains(query);
        if (!matchName && !matchAction && !matchDetails && !matchRef) {
          return false;
        }
      }
      return true;
    }).toList();

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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Header
              Text(
                "Audit Log",
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurfaceColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "System activity and modifications.",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),

              // Export Log Button
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Audit logs exported successfully!"),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                },
                icon: const Icon(Icons.download, size: 16, color: Colors.white),
                label: Text(
                  "Export Log",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
              ),
              const SizedBox(height: 24),

              // Filter Controls Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radius2Xl),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                  border: Border.all(color: AppTheme.outlineVariantColor.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Filter by:",
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        // Timeframe Dropdown Pill
                        GestureDetector(
                          onTap: () {
                            _showDropdownPicker(
                              context, 
                              "Select Timeframe", 
                              _timeframes, 
                              _selectedTimeframe, 
                              (val) => setState(() => _selectedTimeframe = val),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_outlined, size: 13, color: AppTheme.onSurfaceColor),
                                const SizedBox(width: 6),
                                Text(
                                  _selectedTimeframe,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.onSurfaceColor,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_drop_down, size: 14, color: AppTheme.onSurfaceColor),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Staff Dropdown Pill
                    Row(
                      children: [
                        const SizedBox(width: 72),
                        GestureDetector(
                          onTap: () {
                            _showDropdownPicker(
                              context,
                              "Select Staff",
                              _staffMembers,
                              _selectedStaff,
                              (val) => setState(() => _selectedStaff = val),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.people_outline, size: 14, color: AppTheme.onSurfaceColor),
                                const SizedBox(width: 6),
                                Text(
                                  _selectedStaff,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.onSurfaceColor,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_drop_down, size: 14, color: AppTheme.onSurfaceColor),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Action Type Modification Chip
                    if (_showModificationsOnly)
                      Padding(
                        padding: const EdgeInsets.only(left: 72.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF290A45),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.tune, size: 13, color: Colors.white),
                              const SizedBox(width: 6),
                              Text(
                                "Action Type: Modifications",
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () => setState(() => _showModificationsOnly = false),
                                child: const Icon(Icons.close, size: 12, color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(left: 72.0),
                        child: TextButton.icon(
                          onPressed: () => setState(() => _showModificationsOnly = true),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          icon: const Icon(Icons.add, size: 14, color: AppTheme.primaryColor),
                          label: Text(
                            "Add filter: Modifications",
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Search input field
                    TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      style: GoogleFonts.inter(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: "Search references...",
                        hintStyle: GoogleFonts.inter(
                          color: AppTheme.onSurfaceVariant.withOpacity(0.5),
                          fontSize: 13,
                        ),
                        fillColor: const Color(0xFFEDE2EC).withOpacity(0.4),
                        filled: true,
                        prefixIcon: const Icon(Icons.search, size: 18, color: AppTheme.onSurfaceVariant),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Logs List Container
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radius2Xl),
                  border: Border.all(color: AppTheme.outlineVariantColor.withOpacity(0.2)),
                ),
                child: filteredLogs.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Center(
                          child: Text(
                            "No audit records found matching your filters.",
                            style: GoogleFonts.inter(
                              color: AppTheme.onSurfaceVariant,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredLogs.length,
                            separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                            itemBuilder: (context, index) {
                              final log = filteredLogs[index];
                              return Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Timestamp
                                    Text(
                                      log["timestamp"],
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.onSurfaceVariant.withOpacity(0.6),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // User Avatar & Name
                                    Row(
                                      children: [
                                        _buildAvatar(log),
                                        const SizedBox(width: 12),
                                        Text(
                                          log["name"],
                                          style: GoogleFonts.hankenGrotesk(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.onSurfaceColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    // Action
                                    Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: log["actionColor"],
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          log["action"],
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.onSurfaceColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),

                                    // Details
                                    Text(
                                      log["details"],
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: AppTheme.onSurfaceVariant,
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    // Reference Tag
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFAF1F9),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        log["reference"],
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          
                          // Pagination Footer
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Showing 1 to ${filteredLogs.length} of ${filteredLogs.length} entries",
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppTheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Row(
                                  children: [
                                    _buildPageButton(Icons.chevron_left, _currentPage > 1, () {
                                      setState(() => _currentPage--);
                                    }),
                                    const SizedBox(width: 8),
                                    _buildPageButton(Icons.chevron_right, false, () {}),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageButton(IconData icon, bool enabled, VoidCallback onTap) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 18,
          color: enabled ? AppTheme.onSurfaceColor : const Color(0xFFCBD5E1),
        ),
      ),
    );
  }

  void _showDropdownPicker(
    BuildContext context, 
    String title, 
    List<String> items, 
    String currentValue, 
    Function(String) onSelected,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurfaceColor,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isSelected = item == currentValue;
                    return ListTile(
                      title: Text(
                        item,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppTheme.primaryColor : AppTheme.onSurfaceColor,
                        ),
                      ),
                      trailing: isSelected ? const Icon(Icons.check, color: AppTheme.primaryColor) : null,
                      onTap: () {
                        onSelected(item);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
