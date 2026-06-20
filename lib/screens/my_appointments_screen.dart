import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';
import '../state/app_state.dart';
import 'visitor_access/operational_dashboard_screen.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  String _filter = "Active"; // "Active", "Cancelled"

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    // Filter appointments
    final list = _filter == "Active" ? appState.appointments : appState.cancelledAppointments;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tab Filters
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              _buildFilterChip("Active", _filter == "Active"),
              const SizedBox(width: 8),
              _buildFilterChip("Cancelled", _filter == "Cancelled"),
            ],
          ),
        ),

        // List
        Expanded(
          child: list.isEmpty
              ? _buildEmptyState(theme)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  physics: const BouncingScrollPhysics(),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final appointment = list[index];
                    final isVerified = appointment.status == "Verified";
                    final isPending = appointment.status == "Pending";
                    final isCancelled = appointment.status == "Cancelled";

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                        border: Border.all(color: AppTheme.outlineVariantColor),
                        boxShadow: AppTheme.ambientShadow,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                          onTap: () {
                            if (isCancelled) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OperationalDashboardScreen(appointment: appointment),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top row: Org & status
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        appointment.organizationName,
                                        style: GoogleFonts.hankenGrotesk(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.onSurfaceColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isVerified
                                            ? AppTheme.successColor.withOpacity(0.1)
                                            : (isPending
                                                ? AppTheme.pendingColor.withOpacity(0.1)
                                                : AppTheme.errorColor.withOpacity(0.1)),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        appointment.status,
                                        style: TextStyle(
                                          color: isVerified
                                              ? AppTheme.successColor
                                              : (isPending ? AppTheme.pendingColor : AppTheme.errorColor),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                
                                // Category
                                Text(
                                  appointment.category.toUpperCase(),
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                    color: AppTheme.onSurfaceVariant,
                                  ),
                                ),
                                const Divider(height: 20),
                                
                                // Details
                                Row(
                                  children: [
                                    const Icon(Icons.person_outline, size: 14, color: AppTheme.outlineColor),
                                    const SizedBox(width: 6),
                                    Text(
                                      appointment.professionalName,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.onSurfaceColor),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today_outlined, size: 14, color: AppTheme.outlineColor),
                                    const SizedBox(width: 6),
                                    Text(
                                      "${appointment.date.month}/${appointment.date.day}/${appointment.date.year} at ${appointment.timeSlot}",
                                      style: const TextStyle(fontSize: 13, color: AppTheme.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                                
                                // Actions
                                if (!isCancelled) ...[
                                  const Divider(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      if (isVerified)
                                        Text(
                                          "✓ Passes Active: Gate ${appointment.gateAccessCode}",
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.successColor,
                                          ),
                                        )
                                      else
                                        const Text(
                                          "ID Verification needed for gate clearance",
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: AppTheme.pendingColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      
                                      TextButton(
                                        onPressed: () => _showCancelBottomSheet(context, appState, appointment.id),
                                        child: const Text(
                                          "Cancel Booking",
                                          style: TextStyle(
                                            color: AppTheme.errorColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ]
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppTheme.primaryColor,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? AppTheme.primaryColor : AppTheme.outlineVariantColor,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _filter = label;
          });
        }
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppTheme.surfaceContainerColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_today_outlined,
                size: 64,
                color: AppTheme.outlineColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "No Appointments Found",
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              "You don't have any bookings matching this filter. Schedule visits via the Explore tab.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.onSurfaceVariant,
                fontSize: 14,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelBottomSheet(BuildContext context, AppState appState, String id) {
    String? selectedReason;
    final List<String> reasons = [
      "Schedule Conflict",
      "No Longer Needed",
      "Rescheduling",
      "Other",
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radius2Xl)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Cancel Appointment",
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Are you sure you want to cancel this appointment? This action will void your facility gate pass.",
                      style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    
                    // Reasons Dropdown
                    Text(
                      "Reason for Cancellation",
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      hint: const Text("Select a reason"),
                      value: selectedReason,
                      items: reasons.map((r) {
                        return DropdownMenuItem(value: r, child: Text(r));
                      }).toList(),
                      onChanged: (val) {
                        setModalState(() {
                          selectedReason = val;
                        });
                      },
                      decoration: const InputDecoration(
                        fillColor: AppTheme.surfaceColor,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusXl)),
                              side: const BorderSide(color: AppTheme.outlineColor),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text("KEEP BOOKING", style: TextStyle(color: AppTheme.onSurfaceColor)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.errorColor,
                            ),
                            onPressed: selectedReason == null
                                ? null
                                : () {
                                    appState.cancelAppointment(id);
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Booking cancelled successfully"),
                                        backgroundColor: AppTheme.errorColor,
                                      ),
                                    );
                                  },
                            child: const Text("CANCEL NOW"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
