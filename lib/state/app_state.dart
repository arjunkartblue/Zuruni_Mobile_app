import 'package:flutter/material.dart';

enum VerificationStatus { none, pending, verified }
enum UserRole { visitor, staff }

class Appointment {
  final String id;
  final String professionalName;
  final String organizationName;
  final String category;
  final String serviceName;
  final DateTime date;
  final String timeSlot;
  String status; // "Verified", "Pending", "Action Required", "Cancelled", "Completed"
  final String? tokenNumber; // Added for Token System
  
  // Visitor access & facility details
  final String? gateAccessCode;
  final String? doorAccessCode;
  final String? parkingBay;
  final List<String> timelineSteps;
  final int activeTimelineIndex;
  
  // Prescription details
  final String? prescriptionPdfUrl;
  final String? prescriptionName;
  
  Appointment({
    required this.id,
    required this.professionalName,
    required this.organizationName,
    required this.category,
    required this.serviceName,
    required this.date,
    required this.timeSlot,
    required this.status,
    this.tokenNumber,
    this.gateAccessCode,
    this.doorAccessCode,
    this.parkingBay,
    required this.timelineSteps,
    this.activeTimelineIndex = 0,
    this.prescriptionPdfUrl,
    this.prescriptionName,
  });

  Appointment copyWith({String? status, String? tokenNumber, String? prescriptionPdfUrl, String? prescriptionName}) {
    return Appointment(
      id: id,
      professionalName: professionalName,
      organizationName: organizationName,
      category: category,
      serviceName: serviceName,
      date: date,
      timeSlot: timeSlot,
      status: status ?? this.status,
      tokenNumber: tokenNumber ?? this.tokenNumber,
      gateAccessCode: gateAccessCode,
      doorAccessCode: doorAccessCode,
      parkingBay: parkingBay,
      timelineSteps: timelineSteps,
      activeTimelineIndex: activeTimelineIndex,
      prescriptionPdfUrl: prescriptionPdfUrl ?? this.prescriptionPdfUrl,
      prescriptionName: prescriptionName ?? this.prescriptionName,
    );
  }
}

class VerificationDocument {
  final String type;
  final String status; // "Verified", "Pending"
  final String idNumber;
  final String fileName;

  VerificationDocument({
    required this.type,
    required this.status,
    required this.idNumber,
    required this.fileName,
  });
}

class AppState extends ChangeNotifier {
  // Auth state
  bool _isLoggedIn = false;
  bool _isGuest = false;
  String _userName = "Alex Johnson";
  String _userEmail = "alex.j@example.com";
  String _userPhone = "+1 (555) 0199";
  String _userCountry = "India";
  UserRole _currentRole = UserRole.visitor;
  String _staffOrganization = "Zuruni Corporate HQ";

  // Staff Default Settings
  String _defaultApproval = "Auto";
  String _tokenCategory = "Priority A";

  // Staff Portal Mock Data
  final List<Map<String, dynamic>> _staffPendingApprovals = [
    {
      "id": "VIS-8924",
      "name": "Michael Chen",
      "avatar": "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=240",
      "type": "Interview",
      "time": "Today, 2:00 PM",
      "reason": "Q3 Strategy Alignment Meeting with the Executive Team. Requires projector access.",
      "status": "Pending",
      "token": "T-440",
      "arrived": false
    },
    {
      "id": "VIS-8925",
      "name": "Sarah Jenkins",
      "avatar": "",
      "type": "Delivery",
      "time": "Tomorrow, 10:00 AM",
      "reason": "IT Vendor - Network infrastructure maintenance and hardware delivery.",
      "status": "Pending",
      "token": "T-441",
      "arrived": false
    },
    {
      "id": "VIS-8927",
      "name": "Sarah Chen",
      "avatar": "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=240",
      "type": "Interview",
      "time": "Today, 10:30 AM",
      "reason": "UX Designer candidate interview with HR.",
      "status": "Pending",
      "token": "T-442",
      "arrived": false
    },
    {
      "id": "VIS-8926",
      "name": "Mark Miller",
      "avatar": "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=240",
      "type": "Delivery",
      "time": "Today, 11:15 AM",
      "reason": "Hardware supplies delivery for Floor 4.",
      "status": "Approved",
      "token": "T-445",
      "arrived": true
    }
  ];

  // Hospital-specific Mock Appointments (for Dr. Aris Thorne at Vantage Medical Group)
  final List<Map<String, dynamic>> _hospitalPendingApprovals = [
    {
      "id": "VIS-1101",
      "name": "Alex Johnson",
      "avatar": "",
      "type": "Consultation",
      "time": "Today, 9:30 AM",
      "reason": "Routine hypertension check-up and renewal of prescription.",
      "status": "Approved",
      "token": "T-15",
      "arrived": true
    },
    {
      "id": "VIS-1102",
      "name": "Sarah Chen",
      "avatar": "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=240",
      "type": "Checkup",
      "time": "Today, 10:30 AM",
      "reason": "Chronic back pain evaluation, physical therapy follow-up.",
      "status": "Pending",
      "token": "T-16",
      "arrived": false
    },
    {
      "id": "VIS-1103",
      "name": "Michael Chen",
      "avatar": "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=240",
      "type": "Lab Test",
      "time": "Today, 2:00 PM",
      "reason": "Fasting blood sugar panel & thyroid profile check.",
      "status": "Pending",
      "token": "T-17",
      "arrived": false
    },
    {
      "id": "VIS-1104",
      "name": "David Kim",
      "avatar": "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=240",
      "type": "Consultation",
      "time": "Tomorrow, 10:00 AM",
      "reason": "Mild fever, cough, and throat infection assessment.",
      "status": "Approved",
      "token": "T-18",
      "arrived": false
    }
  ];

  final List<Map<String, dynamic>> _liveQueue = [
    {
      "token": "T-842",
      "name": "Sarah Jenkins",
      "type": "Consultation",
      "arrivalTime": "09:15 AM",
      "gate": "B2",
      "parking": "P-41",
      "waitTime": "4 Min",
      "status": "Serving"
    },
    {
      "token": "T-843",
      "name": "Michael Chen",
      "type": "Meeting",
      "arrivalTime": "09:20 AM",
      "gate": "B2",
      "parking": "P-41",
      "waitTime": "4 Min",
      "status": "Approaching"
    },
    {
      "token": "T-844",
      "name": "Elena Rodriguez",
      "type": "Visit",
      "arrivalTime": "09:30 AM",
      "gate": "A1",
      "parking": "P-12",
      "waitTime": "12m",
      "status": "Arrived"
    },
    {
      "token": "T-845",
      "name": "David Kim",
      "type": "Delivery",
      "arrivalTime": "09:35 AM",
      "gate": "C4",
      "parking": "--",
      "waitTime": "18m",
      "status": "Approaching"
    },
    {
      "token": "T-846",
      "name": "Aisha Patel",
      "type": "Interview",
      "arrivalTime": "09:42 AM",
      "gate": "--",
      "parking": "--",
      "waitTime": "25m",
      "status": "Pending"
    }
  ];

  // Hospital Live Token Queue
  final List<Map<String, dynamic>> _hospitalLiveQueue = [
    {
      "token": "T-15",
      "name": "Alex Johnson",
      "type": "Consultation",
      "arrivalTime": "09:20 AM",
      "gate": "G-7749",
      "parking": "B-12",
      "waitTime": "0 Min",
      "status": "Serving"
    },
    {
      "token": "T-16",
      "name": "Sarah Chen",
      "type": "Checkup",
      "arrivalTime": "09:45 AM",
      "gate": "G-7801",
      "parking": "B-15",
      "waitTime": "15 Min",
      "status": "Approaching"
    },
    {
      "token": "T-17",
      "name": "Michael Chen",
      "type": "Lab Test",
      "arrivalTime": "10:15 AM",
      "gate": "--",
      "parking": "--",
      "waitTime": "30 Min",
      "status": "Arrived"
    }
  ];

  final List<Map<String, dynamic>> _recentTransactions = [
    {
      "id": "Visit #4029",
      "name": "Julianne Moore",
      "time": "10:30 AM",
      "method": "WALLET",
      "amount": 85.00,
      "details": ""
    },
    {
      "id": "Visit #4030",
      "name": "Marcus Sterling",
      "time": "11:15 AM",
      "method": "DESK",
      "amount": 112.50,
      "details": "Parking Fee (Level 2) +\$12.50"
    },
    {
      "id": "Visit #4031",
      "name": "Elena Rodriguez",
      "time": "11:45 AM",
      "method": "WALLET",
      "amount": 45.00,
      "details": ""
    },
    {
      "id": "Visit #4032",
      "name": "David Kim",
      "time": "12:10 PM",
      "method": "PARKING",
      "amount": 15.00,
      "details": ""
    }
  ];

  // Hospital Transactions (Dr. Aris Thorne Billing)
  final List<Map<String, dynamic>> _hospitalTransactions = [
    {
      "id": "Visit #8021",
      "name": "Alex Johnson",
      "time": "09:30 AM",
      "method": "WALLET",
      "amount": 150.00,
      "details": "Consultation Fee (Dr. Thorne)"
    },
    {
      "id": "Visit #8022",
      "name": "Sarah Chen",
      "time": "10:45 AM",
      "method": "DESK",
      "amount": 220.00,
      "details": "Lab Test + Pharmacy Fee"
    },
    {
      "id": "Visit #8023",
      "name": "Michael Chen",
      "time": "11:30 AM",
      "method": "WALLET",
      "amount": 90.00,
      "details": "Pharmacy Fee"
    }
  ];

  // Scheduled Meetings mock list
  final List<Map<String, dynamic>> _scheduledMeetings = [
    {
      "title": "Q3 Strategy Alignment",
      "time": "10:00 AM - 11:30 AM",
      "location": "Boardroom A",
      "type": "Internal",
      "dateGroup": "Today",
      "host": "Alex Rivers",
      "attendeeInitials": ["AR", "MW", "SJ", "RC"],
    },
    {
      "title": "Patient Consultation: Alex Johnson",
      "time": "09:30 AM - 10:00 AM",
      "location": "Consultation Room 4",
      "type": "Public",
      "dateGroup": "Today",
      "host": "Dr. Aris Thorne",
      "attendeeInitials": ["AT", "AJ"],
    },
    {
      "title": "Weekly Sprint Planning",
      "time": "02:00 PM - 03:00 PM",
      "location": "Conference Room B",
      "type": "Internal",
      "dateGroup": "Today",
      "host": "Sarah Chen",
      "attendeeInitials": ["SC", "DK", "MC", "AP"],
    },
    {
      "title": "Public Health Seminar Prep",
      "time": "09:00 AM - 10:30 AM",
      "location": "Auditorium 2",
      "type": "Public",
      "dateGroup": "Tomorrow",
      "host": "Dr. Sarah Amethyst",
      "attendeeInitials": ["SA", "AT", "RC"],
    },
    {
      "title": "Clinical Board Review",
      "time": "04:00 PM - 05:30 PM",
      "location": "Boardroom A",
      "type": "Internal",
      "dateGroup": "Tomorrow",
      "host": "Dr. Aris Thorne",
      "attendeeInitials": ["AT", "SA", "EL", "MC"],
    },
    {
      "title": "IT Infrastructure Sync",
      "time": "11:00 AM - 12:00 PM",
      "location": "Server Room Hub",
      "type": "Internal",
      "dateGroup": "Upcoming",
      "host": "Mark Miller",
      "attendeeInitials": ["MM", "SJ", "DK"],
    },
  ];
  
  // Document verification list
  final List<VerificationDocument> _documents = [
    VerificationDocument(
      type: "Aadhaar Card",
      status: "Verified",
      idNumber: "1234-5678-9012",
      fileName: "aadhaar_front.jpg",
    ),
    VerificationDocument(
      type: "Passport",
      status: "Pending",
      idNumber: "Z1234567",
      fileName: "passport_front.jpg",
    ),
  ];

  // Mock list of appointments
  final List<Appointment> _appointments = [
    Appointment(
      id: "APT-99281",
      professionalName: "Dr. Aris Thorne",
      organizationName: "Vantage Medical Group",
      category: "Healthcare",
      serviceName: "General Consultation",
      date: DateTime.now(), // Testing: dated today
      timeSlot: "09:30 AM",
      status: "Verified",
      tokenNumber: "T-15", // Healthcare organization with token system enabled
      gateAccessCode: "G-7749",
      doorAccessCode: "D-9201",
      parkingBay: "B-12 (P2 Level)",
      timelineSteps: [
        "Gate Check-in Approved",
        "Vehicle Parked in Bay B-12",
        "Elevator Door Code Unlocked",
        "Checked-in at Reception",
        "Session in Progress",
        "Facility Exit Complete"
      ],
      activeTimelineIndex: 0,
    ),
    Appointment(
      id: "APT-88271",
      professionalName: "Elena Rostova",
      organizationName: "The Aesthetic Loft",
      category: "Beauty",
      serviceName: "HydraFacial Deluxe",
      date: DateTime.now().add(const Duration(days: 3)),
      timeSlot: "02:00 PM",
      status: "Pending",
      tokenNumber: null, // Beauty organization without token system
      gateAccessCode: null,
      doorAccessCode: null,
      parkingBay: null,
      timelineSteps: [
        "Pending Registration",
        "Gate Clearance Required",
        "Lobby Check-in",
        "Service Delivery",
        "Checkout"
      ],
      activeTimelineIndex: 0,
    ),
    Appointment(
      id: "APT-77110",
      professionalName: "Dr. Aris Thorne",
      organizationName: "Vantage Medical Group",
      category: "Healthcare",
      serviceName: "General Consultation",
      date: DateTime.now().subtract(const Duration(days: 5)),
      timeSlot: "10:00 AM",
      status: "Completed",
      tokenNumber: null,
      gateAccessCode: null,
      doorAccessCode: null,
      parkingBay: null,
      timelineSteps: ["Checkout"],
      activeTimelineIndex: 0,
      prescriptionPdfUrl: "prescription_vantage_77110.pdf",
      prescriptionName: "Rx_DrThorne_June19.pdf",
    ),
    Appointment(
      id: "APT-77120",
      professionalName: "Elena Rostova",
      organizationName: "The Aesthetic Loft",
      category: "Beauty",
      serviceName: "Consultation & Skincare",
      date: DateTime.now().subtract(const Duration(days: 10)),
      timeSlot: "11:30 AM",
      status: "Completed",
      tokenNumber: null,
      gateAccessCode: null,
      doorAccessCode: null,
      parkingBay: null,
      timelineSteps: ["Checkout"],
      activeTimelineIndex: 0,
    )
  ];

  // Booking Wizard states
  String? selectedCategory;
  Map<String, dynamic>? selectedOrg;
  String? selectedService;
  double? selectedServicePrice;
  DateTime? selectedDate;
  String? selectedTimeSlot;
  
  // Booking Wizard Step 3 states
  String visitorPurpose = "Professional Consultation";
  bool parkingNeeded = false;
  String vehicleNumber = "";
  List<String> visitorNames = [""];

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  bool get isGuest => _isGuest;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userPhone => _userPhone;
  String get userCountry => _userCountry;
  List<VerificationDocument> get documents => _documents;
  UserRole get currentRole => _currentRole;
  String get defaultApproval => _defaultApproval;
  String get tokenCategory => _tokenCategory;
  String get staffOrganization => _staffOrganization;
  bool get isHospitalStaff => _currentRole == UserRole.staff && _staffOrganization == "Vantage Medical Group";

  List<Map<String, dynamic>> get scheduledMeetings => _scheduledMeetings;

  List<Map<String, dynamic>> get _activeApprovalsList => 
      isHospitalStaff ? _hospitalPendingApprovals : _staffPendingApprovals;

  List<Map<String, dynamic>> get _activeLiveQueue => 
      isHospitalStaff ? _hospitalLiveQueue : _liveQueue;

  List<Map<String, dynamic>> get _activeTransactions => 
      isHospitalStaff ? _hospitalTransactions : _recentTransactions;

  List<Map<String, dynamic>> get staffPendingApprovals => 
      _activeApprovalsList.where((item) => item["status"] == "Pending").toList();

  List<Map<String, dynamic>> get staffAllApprovals => _activeApprovalsList;

  List<Map<String, dynamic>> get liveQueue => _activeLiveQueue;

  List<Map<String, dynamic>> get recentTransactions => _activeTransactions;

  /// Returns the next upcoming approval sorted chronologically by appointment time.
  /// Prefers today's entries that haven't passed yet, then falls back to the
  /// earliest overall entry. Returns null when there are no entries at all.
  Map<String, dynamic>? get nextUpcomingApproval {
    if (_activeApprovalsList.isEmpty) return null;

    final now = DateTime.now();

    DateTime? _parseTime(String timeStr) {
      // Expected formats: "Today, 10:30 AM"  /  "Tomorrow, 2:00 PM"  /  raw "10:00 AM"
      try {
        String t = timeStr.toLowerCase();
        DateTime base = DateTime(now.year, now.month, now.day);
        if (t.startsWith("tomorrow")) {
          base = base.add(const Duration(days: 1));
          t = t.replaceFirst(RegExp(r'^tomorrow,?\s*'), '');
        } else if (t.startsWith("today")) {
          t = t.replaceFirst(RegExp(r'^today,?\s*'), '');
        }
        // t is now like "10:30 am" or "2:00 pm"
        final parts = t.trim().split(RegExp(r'[\s:]'));
        // parts: ["10", "30", "am"] or ["2", "00", "pm"]
        int hour = int.parse(parts[0]);
        final int minute = int.parse(parts[1]);
        final String period = parts.length > 2 ? parts[2] : 'am';
        if (period == 'pm' && hour != 12) hour += 12;
        if (period == 'am' && hour == 12) hour = 0;
        return DateTime(base.year, base.month, base.day, hour, minute);
      } catch (_) {
        return null;
      }
    }

    // Sort a copy by parsed time (nulls go last)
    final sorted = List<Map<String, dynamic>>.from(_activeApprovalsList)
      ..sort((a, b) {
        final ta = _parseTime(a["time"] ?? "");
        final tb = _parseTime(b["time"] ?? "");
        if (ta == null && tb == null) return 0;
        if (ta == null) return 1;
        if (tb == null) return -1;
        return ta.compareTo(tb);
      });

    // Prefer the first entry that is still in the future (or happening now)
    for (final item in sorted) {
      final t = _parseTime(item["time"] ?? "");
      if (t != null && t.isAfter(now.subtract(const Duration(minutes: 30)))) {
        return item;
      }
    }
    // Fallback: return the first (earliest) entry if all are in the past
    return sorted.first;
  }


  VerificationStatus get verificationStatus {
    if (_documents.any((doc) => doc.status == "Verified")) {
      return VerificationStatus.verified;
    } else if (_documents.any((doc) => doc.status == "Pending")) {
      return VerificationStatus.pending;
    }
    return VerificationStatus.none;
  }
  
  String get uploadedDocType => _documents.isNotEmpty ? _documents.last.type : "";
  String get uploadedDocName => _documents.isNotEmpty ? _documents.last.fileName : "";
  
  DateTime _combineDateAndTime(DateTime date, String timeSlot) {
    try {
      final parts = timeSlot.split(" ");
      final timeParts = parts[0].split(":");
      int hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      final period = parts[1].toUpperCase();

      if (period == "PM" && hour != 12) {
        hour += 12;
      } else if (period == "AM" && hour == 12) {
        hour = 0;
      }
      return DateTime(date.year, date.month, date.day, hour, minute);
    } catch (_) {
      return date;
    }
  }

  List<Appointment> get appointments {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final list = _appointments
        .where((apt) => apt.status != "Cancelled" && apt.status != "Completed" && (apt.date.isAfter(today) || apt.date.year == today.year && apt.date.month == today.month && apt.date.day == today.day))
        .toList();
    list.sort((a, b) {
      final aDateTime = _combineDateAndTime(a.date, a.timeSlot);
      final bDateTime = _combineDateAndTime(b.date, b.timeSlot);
      return aDateTime.compareTo(bDateTime);
    });
    return list;
  }

  List<Appointment> get cancelledAppointments {
    final list = _appointments.where((apt) => apt.status == "Cancelled").toList();
    list.sort((a, b) {
      final aDateTime = _combineDateAndTime(a.date, a.timeSlot);
      final bDateTime = _combineDateAndTime(b.date, b.timeSlot);
      return aDateTime.compareTo(bDateTime);
    });
    return list;
  }

  List<Appointment> get pastAndCancelledAppointments {
    final list = _appointments
        .where((apt) => apt.status == "Cancelled" || apt.status == "Completed")
        .toList();
    list.sort((a, b) {
      final aDateTime = _combineDateAndTime(a.date, a.timeSlot);
      final bDateTime = _combineDateAndTime(b.date, b.timeSlot);
      return bDateTime.compareTo(aDateTime); // Most recent first
    });
    return list;
  }

  List<Appointment> get prescriptionAppointments {
    final list = _appointments.where((apt) => apt.prescriptionPdfUrl != null).toList();
    list.sort((a, b) {
      final aDateTime = _combineDateAndTime(a.date, a.timeSlot);
      final bDateTime = _combineDateAndTime(b.date, b.timeSlot);
      return bDateTime.compareTo(aDateTime); // Most recent first
    });
    return list;
  }
  
  // Find active operational appointment (e.g. verified appointment happening soonest)
  Appointment? get activeOperationalAppointment {
    final active = appointments.where((apt) => apt.status == "Verified").toList();
    if (active.isEmpty) return null;
    return active.first;
  }

  // Setters & Actions
  void continueAsGuest() {
    _isGuest = true;
    _isLoggedIn = false;
    notifyListeners();
  }

  void login(String email, String password) {
    _isLoggedIn = true;
    _isGuest = false;
    
    final normalized = email.trim().toLowerCase();
    if (normalized == "doctor@vantage.com" || normalized == "doctor@zuruni.com") {
      _currentRole = UserRole.staff;
      _staffOrganization = "Vantage Medical Group";
      _userName = "Dr. Aris Thorne";
      _userEmail = email.isNotEmpty ? email : "doctor@vantage.com";
      _userPhone = "+1 (555) 0312";
      _userCountry = "USA";
    } else if (normalized == "manager@zuruni.com" || normalized == "staff@zuruni.com") {
      _currentRole = UserRole.staff;
      _staffOrganization = "Zuruni Corporate HQ";
      _userName = "Alex Rivers";
      _userEmail = email.isNotEmpty ? email : "manager@zuruni.com";
      _userPhone = "+1 (555) 0244";
      _userCountry = "USA";
    } else {
      _currentRole = UserRole.visitor;
      _staffOrganization = "Zuruni Corporate HQ";
      _userName = "Alex Johnson";
      _userEmail = email.isNotEmpty ? email : "alex.j@example.com";
      _userPhone = "+1 (555) 0199";
      _userCountry = "India";
    }
    
    _documents.clear();
    _documents.addAll([
      VerificationDocument(
        type: "Aadhaar Card",
        status: "Verified",
        idNumber: "1234-5678-9012",
        fileName: "aadhaar_front.jpg",
      ),
      VerificationDocument(
        type: "Passport",
        status: "Pending",
        idNumber: "Z1234567",
        fileName: "passport_front.jpg",
      ),
    ]);
    notifyListeners();
  }

  void signup(String name, String email, String phone, String password) {
    _isLoggedIn = true;
    _isGuest = false;
    _currentRole = UserRole.visitor;
    _staffOrganization = "Zuruni Corporate HQ";
    _userName = name;
    _userEmail = email;
    _userPhone = phone;
    _userCountry = "India";
    
    _documents.clear();
    _documents.addAll([
      VerificationDocument(
        type: "Aadhaar Card",
        status: "Verified",
        idNumber: "1234-5678-9012",
        fileName: "aadhaar_front.jpg",
      ),
      VerificationDocument(
        type: "Passport",
        status: "Pending",
        idNumber: "Z1234567",
        fileName: "passport_front.jpg",
      ),
    ]);
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _isGuest = false;
    _currentRole = UserRole.visitor;
    _staffOrganization = "Zuruni Corporate HQ";
    _userName = "";
    _userEmail = "";
    _userPhone = "";
    _userCountry = "India";
    _documents.clear();
    notifyListeners();
  }

  void toggleRoleForTesting() {
    if (_currentRole == UserRole.visitor) {
      _currentRole = UserRole.staff;
      _staffOrganization = "Zuruni Corporate HQ";
      _userName = "Alex Rivers";
      _userEmail = "manager@zuruni.com";
      _userPhone = "+1 (555) 0244";
      _userCountry = "USA";
    } else {
      _currentRole = UserRole.visitor;
      _staffOrganization = "Zuruni Corporate HQ";
      _userName = "Alex Johnson";
      _userEmail = "alex.j@example.com";
      _userPhone = "+1 (555) 0199";
      _userCountry = "India";
    }
    notifyListeners();
  }

  void setRole(UserRole role) {
    _currentRole = role;
    if (role == UserRole.staff) {
      _staffOrganization = "Zuruni Corporate HQ";
      _userName = "Alex Rivers";
      _userEmail = "manager@zuruni.com";
      _userPhone = "+1 (555) 0244";
      _userCountry = "USA";
    } else {
      _staffOrganization = "Zuruni Corporate HQ";
      _userName = "Alex Johnson";
      _userEmail = "alex.j@example.com";
      _userPhone = "+1 (555) 0199";
      _userCountry = "India";
    }
    notifyListeners();
  }

  void approveVisitorRequest(String id) {
    final index = _activeApprovalsList.indexWhere((item) => item["id"] == id);
    if (index != -1) {
      _activeApprovalsList[index]["status"] = "Approved";
      notifyListeners();
    }
  }

  void rejectVisitorRequest(String id) {
    final index = _activeApprovalsList.indexWhere((item) => item["id"] == id);
    if (index != -1) {
      _activeApprovalsList[index]["status"] = "Rejected";
      notifyListeners();
    }
  }

  void bulkApproveAll() {
    for (var item in _activeApprovalsList) {
      item["status"] = "Approved";
    }
    notifyListeners();
  }

  void advanceToken() {
    final queue = _activeLiveQueue;
    if (queue.isNotEmpty) {
      final activeIndex = queue.indexWhere((item) => item["status"] == "Serving");
      if (activeIndex != -1 && activeIndex < queue.length - 1) {
        queue[activeIndex]["status"] = "Completed";
        
        // Find next candidate that is approaching or arrived
        final nextIndex = queue.indexWhere((item) => item["status"] == "Approaching" || item["status"] == "Arrived");
        if (nextIndex != -1) {
          queue[nextIndex]["status"] = "Serving";
        }
      } else {
        // None serving, set first one as serving
        queue[0]["status"] = "Serving";
      }
      notifyListeners();
    }
  }

  void updateMeetingDefaults({required String approval, required String category}) {
    _defaultApproval = approval;
    _tokenCategory = category;
    notifyListeners();
  }

  void updateProfile({
    required String name,
    required String phone,
    required String email,
    required String country,
  }) {
    _userName = name;
    _userPhone = phone;
    _userEmail = email;
    _userCountry = country;
    notifyListeners();
  }

  void addOrUpdateDocument({
    required String type,
    required String idNumber,
    required String fileName,
    required String status,
  }) {
    final index = _documents.indexWhere((doc) => 
      doc.type.toLowerCase() == type.toLowerCase() ||
      doc.type.replaceAll(" Card", "").toLowerCase() == type.replaceAll(" Card", "").toLowerCase()
    );

    final newDoc = VerificationDocument(
      type: type,
      status: status,
      idNumber: idNumber,
      fileName: fileName,
    );

    if (index != -1) {
      _documents[index] = newDoc;
    } else {
      _documents.add(newDoc);
    }
    notifyListeners();
  }

  void addPendingApproval(Map<String, dynamic> request) {
    if (!request.containsKey("token")) {
      final nextTokenNum = 440 + _activeApprovalsList.length;
      request["token"] = "T-$nextTokenNum";
    }
    if (!request.containsKey("arrived")) {
      request["arrived"] = false;
    }
    _activeApprovalsList.insert(0, request);
    notifyListeners();
  }

  void toggleArrivalStatus(String id) {
    final index = _activeApprovalsList.indexWhere((item) => item["id"] == id);
    if (index != -1) {
      final current = _activeApprovalsList[index]["arrived"] ?? false;
      _activeApprovalsList[index]["arrived"] = !current;
      notifyListeners();
    }
  }

  void uploadId(String docType, String docName, {String idNumber = ""}) {
    final formattedType = docType.endsWith("Card") || docType.toLowerCase() == "passport" 
        ? docType 
        : "$docType Card";
    
    addOrUpdateDocument(
      type: formattedType,
      idNumber: idNumber.isNotEmpty ? idNumber : "MOCK-${1000 + (DateTime.now().millisecond) % 9000}",
      fileName: docName,
      status: "Pending",
    );

    // Simulate auto-verification success after 6 seconds
    Future.delayed(const Duration(seconds: 6), () {
      final index = _documents.indexWhere((doc) => doc.type.toLowerCase() == formattedType.toLowerCase());
      if (index != -1 && _documents[index].status == "Pending") {
        final existing = _documents[index];
        _documents[index] = VerificationDocument(
          type: existing.type,
          status: "Verified",
          idNumber: existing.idNumber,
          fileName: existing.fileName,
        );
        notifyListeners();
      }
    });
  }

  void clearBookingWizard() {
    selectedOrg = null;
    selectedService = null;
    selectedServicePrice = null;
    selectedDate = null;
    selectedTimeSlot = null;
    visitorPurpose = "Professional Consultation";
    parkingNeeded = false;
    vehicleNumber = "";
    visitorNames = [""];
  }

  void addAppointment(Appointment appointment) {
    _appointments.insert(0, appointment);
    notifyListeners();
  }

  void addScheduledMeeting(Map<String, dynamic> meeting) {
    _scheduledMeetings.insert(0, meeting);
    notifyListeners();
  }

  void cancelAppointment(String id) {
    final index = _appointments.indexWhere((apt) => apt.id == id);
    if (index != -1) {
      _appointments[index].status = "Cancelled";
      notifyListeners();
    }
  }
}
