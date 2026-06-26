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
      "time": "Today, 2:00 PM - 3:30 PM",
      "reason": "Q3 Strategy Alignment Meeting with the Executive Team. Requires projector access.",
      "status": "Pending"
    },
    {
      "id": "VIS-8925",
      "name": "Sarah Jenkins",
      "avatar": "",
      "type": "Delivery",
      "time": "Tomorrow, 10:00 AM - 11:00 AM",
      "reason": "IT Vendor - Network infrastructure maintenance and hardware delivery.",
      "status": "Pending"
    },
    {
      "id": "VIS-8926",
      "name": "Mark Miller",
      "avatar": "",
      "type": "Delivery",
      "time": "Today, 11:15 AM - 12:00 PM",
      "reason": "Hardware supplies delivery for Floor 4.",
      "status": "Pending"
    },
    {
      "id": "VIS-8927",
      "name": "Sarah Chen",
      "avatar": "",
      "type": "Interview",
      "time": "Today, 10:30 AM - 11:15 AM",
      "reason": "UX Designer candidate interview with HR.",
      "status": "Pending"
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

  List<Map<String, dynamic>> get staffPendingApprovals => 
      _staffPendingApprovals.where((item) => item["status"] == "Pending").toList();

  List<Map<String, dynamic>> get liveQueue => _liveQueue;

  List<Map<String, dynamic>> get recentTransactions => _recentTransactions;

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
    if (normalized == "manager@zuruni.com" || normalized == "staff@zuruni.com") {
      _currentRole = UserRole.staff;
      _userName = "Alex Rivers";
      _userEmail = email.isNotEmpty ? email : "manager@zuruni.com";
      _userPhone = "+1 (555) 0244";
      _userCountry = "USA";
    } else {
      _currentRole = UserRole.visitor;
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
      _userName = "Alex Rivers";
      _userEmail = "manager@zuruni.com";
      _userPhone = "+1 (555) 0244";
      _userCountry = "USA";
    } else {
      _currentRole = UserRole.visitor;
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
      _userName = "Alex Rivers";
      _userEmail = "manager@zuruni.com";
      _userPhone = "+1 (555) 0244";
      _userCountry = "USA";
    } else {
      _userName = "Alex Johnson";
      _userEmail = "alex.j@example.com";
      _userPhone = "+1 (555) 0199";
      _userCountry = "India";
    }
    notifyListeners();
  }

  void approveVisitorRequest(String id) {
    final index = _staffPendingApprovals.indexWhere((item) => item["id"] == id);
    if (index != -1) {
      _staffPendingApprovals[index]["status"] = "Approved";
      notifyListeners();
    }
  }

  void rejectVisitorRequest(String id) {
    final index = _staffPendingApprovals.indexWhere((item) => item["id"] == id);
    if (index != -1) {
      _staffPendingApprovals[index]["status"] = "Rejected";
      notifyListeners();
    }
  }

  void bulkApproveAll() {
    for (var item in _staffPendingApprovals) {
      item["status"] = "Approved";
    }
    notifyListeners();
  }

  void advanceToken() {
    if (_liveQueue.isNotEmpty) {
      final activeIndex = _liveQueue.indexWhere((item) => item["status"] == "Serving");
      if (activeIndex != -1 && activeIndex < _liveQueue.length - 1) {
        _liveQueue[activeIndex]["status"] = "Completed";
        
        // Find next candidate that is approaching or arrived
        final nextIndex = _liveQueue.indexWhere((item) => item["status"] == "Approaching" || item["status"] == "Arrived");
        if (nextIndex != -1) {
          _liveQueue[nextIndex]["status"] = "Serving";
        }
      } else {
        // None serving, set first one as serving
        _liveQueue[0]["status"] = "Serving";
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

  void cancelAppointment(String id) {
    final index = _appointments.indexWhere((apt) => apt.id == id);
    if (index != -1) {
      _appointments[index].status = "Cancelled";
      notifyListeners();
    }
  }
}
