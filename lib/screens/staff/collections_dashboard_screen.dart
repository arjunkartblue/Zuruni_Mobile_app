import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/theme.dart';
import '../../state/app_state.dart';

class CollectionsDashboardScreen extends StatefulWidget {
  const CollectionsDashboardScreen({Key? key}) : super(key: key);

  @override
  State<CollectionsDashboardScreen> createState() => _CollectionsDashboardScreenState();
}

class _CollectionsDashboardScreenState extends State<CollectionsDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final transactions = appState.recentTransactions.where((tx) {
      final query = _searchQuery.toLowerCase();
      return tx["name"].toString().toLowerCase().contains(query) ||
          tx["id"].toString().toLowerCase().contains(query) ||
          tx["method"].toString().toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(
        title: Text(
          "Zuruni Booking",
          style: GoogleFonts.hankenGrotesk(
            fontWeight: FontWeight.bold,
            color: AppTheme.onSurfaceColor,
          ),
        ),
        elevation: 0.5,
        backgroundColor: AppTheme.surfaceColor,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.onSurfaceColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & Total Collections
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "TOTAL COLLECTIONS",
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.onSurfaceVariant.withOpacity(0.7),
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Today",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.onSurfaceVariant.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "\$1,240.00",
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.onSurfaceColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  // Date Picker Card - Pill Style
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerColor,
                      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                      border: Border.all(color: AppTheme.outlineVariantColor.withOpacity(0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 14, color: AppTheme.primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          "Oct 24, 2023",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Category Badges
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryBadge(
                      color: const Color(0xFF290A45), // primary-container
                      textColor: const Color(0xFFFAF1F9),
                      label: "DESK \$540",
                      icon: Icons.desk,
                    ),
                    const SizedBox(width: 8),
                    _buildCategoryBadge(
                      color: const Color(0xFF5D3287), // secondary-container
                      textColor: const Color(0xFFFAF1F9),
                      label: "WALLET \$620",
                      icon: Icons.account_balance_wallet,
                    ),
                    const SizedBox(width: 8),
                    _buildCategoryBadge(
                      color: const Color(0xFFE9E3ED), // surface-container-high
                      textColor: AppTheme.onSurfaceColor,
                      label: "PARKING \$80",
                      icon: Icons.local_parking,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Search Bar
              TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search visitors or transactions...",
                  prefixIcon: const Icon(Icons.search, color: AppTheme.onSurfaceVariant),
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                    borderSide: BorderSide(color: AppTheme.outlineVariantColor.withOpacity(0.4)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                    borderSide: BorderSide(color: AppTheme.outlineVariantColor.withOpacity(0.4)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                    borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Recent Activity Section
              Text(
                "Recent Activity",
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurfaceColor,
                ),
              ),
              const SizedBox(height: 12),

              transactions.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40.0),
                        child: Text(
                          "No transactions found",
                          style: GoogleFonts.inter(color: AppTheme.onSurfaceVariant),
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: transactions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final tx = transactions[index];
                        final hasDetails = tx["details"].toString().isNotEmpty;

                        // Alternating avatar background colors (secondary-fixed or primary-fixed styles)
                        final avatarBg = index % 2 == 0 ? const Color(0xFFF0E6FF) : const Color(0xFFFAF1F9);
                        final avatarIconColor = index % 2 == 0 ? const Color(0xFF764AA0) : AppTheme.primaryColor;

                        return Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                            boxShadow: AppTheme.ambientShadow,
                            border: Border.all(color: AppTheme.outlineVariantColor.withOpacity(0.15)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  // Person avatar icon
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: avatarBg,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.person, color: avatarIconColor),
                                  ),
                                  const SizedBox(width: 12),
                                  // Name and category
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tx["name"],
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: AppTheme.onSurfaceColor,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          "${tx['time']} — ${tx['method']}",
                                          style: GoogleFonts.inter(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: AppTheme.onSurfaceVariant.withOpacity(0.6),
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Paid amount status
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "\$${tx['amount'].toStringAsFixed(2)}",
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                          color: AppTheme.onSurfaceColor,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            width: 12,
                                            height: 12,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF10B981),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.check, size: 8, color: Colors.white),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "Paid",
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF10B981),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (hasDetails) ...[
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFAF1F9).withOpacity(0.5), // bg-surface-container-low/50
                                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        tx["details"].toString().split(" +")[0],
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: AppTheme.onSurfaceVariant,
                                        ),
                                      ),
                                      Text(
                                        "+${tx["details"].toString().split(" +").length > 1 ? tx["details"].toString().split(" +")[1] : ""}",
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),
                              const Divider(height: 1, color: Color(0xFFF1F5F9)),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.confirmation_number_outlined, size: 14, color: AppTheme.onSurfaceVariant),
                                      const SizedBox(width: 6),
                                      Text(
                                        tx["id"],
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Icon(Icons.chevron_right, size: 18, color: AppTheme.onSurfaceVariant),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBadge({
    required Color color,
    required Color textColor,
    required String label,
    IconData? icon,
    Widget? widgetIcon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppTheme.radius2Xl),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) Icon(icon, size: 14, color: textColor),
          if (widgetIcon != null) widgetIcon,
          if (icon != null || widgetIcon != null) const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
