import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/theme.dart';
import '../../state/app_state.dart';

class LiveQueueScreen extends StatelessWidget {
  const LiveQueueScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final queueItems = appState.liveQueue;

    // Separate active (Serving) and upcoming
    final currentToken = queueItems.firstWhere(
      (item) => item["status"] == "Serving",
      orElse: () => queueItems.isNotEmpty ? queueItems.first : {},
    );

    final nextTokenIndex = queueItems.indexOf(currentToken) + 1;
    final nextToken = (nextTokenIndex < queueItems.length) ? queueItems[nextTokenIndex] : null;

    final waitingItems = queueItems.where((item) => item != currentToken).toList();

    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.onSurfaceColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Live Queue",
          style: GoogleFonts.hankenGrotesk(
            fontWeight: FontWeight.bold,
            color: AppTheme.onSurfaceColor,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Token Section (Dark Card)
              if (currentToken.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF290A45), // Deep Amethyst Container
                    borderRadius: BorderRadius.circular(AppTheme.radius2Xl),
                    boxShadow: AppTheme.ambientShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "CURRENT TOKEN",
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFD8C7FF),
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentToken["token"] ?? "",
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        currentToken["name"] ?? "",
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${currentToken['type']} • Arrival: ${currentToken['arrivalTime']}",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFFAF1F9).withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Provider.of<AppState>(context, listen: false).advanceToken();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Advance Token",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),

              // Next Token Preview Card
              if (nextToken != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radius2Xl),
                    boxShadow: AppTheme.ambientShadow,
                    border: Border.all(color: AppTheme.outlineVariantColor.withOpacity(0.15)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "NEXT TOKEN",
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.onSurfaceVariant.withOpacity(0.5),
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        nextToken["token"] ?? "",
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.onSurfaceColor,
                        ),
                      ),
                      const Divider(height: 24, color: Color(0xFFF1F5F9)),
                      Text(
                        nextToken["name"] ?? "",
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.onSurfaceColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildSmallInfoPill(
                            icon: Icons.vpn_key_outlined,
                            text: "GATE: ${nextToken['gate']}",
                          ),
                          const SizedBox(width: 8),
                          _buildSmallInfoPill(
                            text: "SPOT: ${nextToken['parking']}",
                            leadingWidget: Text(
                              "P",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildSmallInfoPill(
                            icon: Icons.access_time,
                            text: "EST: ${nextToken['waitTime']}",
                            color: const Color(0xFFFAF1F9),
                            textColor: AppTheme.primaryColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // Live Queue List Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Live Queue",
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurfaceColor,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF1F9),
                      borderRadius: BorderRadius.circular(AppTheme.radius2Xl),
                      border: Border.all(color: AppTheme.primaryColor.withOpacity(0.1)),
                    ),
                    child: Text(
                      "${waitingItems.length} Waiting",
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: waitingItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = waitingItems[index];
                  final statusStr = item["status"].toString();
                  final isApproaching = statusStr.toLowerCase() == "approaching";

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
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: const Color(0xFFF1F5F9), width: 2),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                item["token"].replaceAll("T-", ""),
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppTheme.onSurfaceColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item["name"],
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: AppTheme.onSurfaceColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  _buildStatusBadge(statusStr, isApproaching),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.only(top: 12),
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Color(0xFFF1F5F9)),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildGridStat("Arrival", item["arrivalTime"]),
                              _buildGridStat("Gate", item["gate"]),
                              _buildGridStat("Parking", item["parking"]),
                              _buildGridStat("Wait", item["waitTime"]),
                            ],
                          ),
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

  Widget _buildSmallInfoPill({
    IconData? icon,
    Widget? leadingWidget,
    required String text,
    Color color = const Color(0xFFF1F5F9),
    Color textColor = const Color(0xFF334155),
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) Icon(icon, size: 12, color: textColor.withOpacity(0.7)),
          if (leadingWidget != null) leadingWidget,
          if (icon != null || leadingWidget != null) const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: textColor,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, bool isApproaching) {
    final bgColor = isApproaching ? const Color(0xFFFAF1F9) : const Color(0xFFF1F5F9);
    final dotColor = isApproaching ? AppTheme.primaryColor : const Color(0xFF94A3B8);
    final textColor = isApproaching ? AppTheme.primaryColor : const Color(0xFF64748B);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
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
            status,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridStat(String title, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: AppTheme.onSurfaceVariant.withOpacity(0.5),
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          val,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppTheme.onSurfaceColor,
          ),
        ),
      ],
    );
  }
}
