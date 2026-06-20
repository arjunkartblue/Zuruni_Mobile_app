import 'package:flutter/material.dart';

enum VerificationStatus { none, pending, verified }

class Appointment {
  final String id;
  final String professionalName;
  final String organizationName;
  final String category;
  final DateTime date;
  final String timeSlot;
  String status; // "Verified", "Pending", "Action Required", "Cancelled"
  
  // Visitor access & facility details
  final String? gateAccessCode;
  final String? doorAccessCode;
  final String? parkingBay;
  final List<String> timelineSteps;
  final int activeTimelineIndex;
  
  Appointment({
    required this.id,
    required this.professionalName,
    required this.organizationName,
    required this.category,
    required this.date,
    required this.timeSlot,
    required this.status,
    this.gateAccessCode,
    this.doorAccessCode,
    this.parkingBay,
    required this.timelineSteps,
    this.activeTimelineIndex = 0,
  });

  Appointment copyWith({String? status}) {
    return Appointment(
      id: id,
      professionalName: professionalName,
      organizationName: organizationName,
      category: category,
      date: date,
      timeSlot: timeSlot,
      status: status ?? this.status,
      gateAccessCode: gateAccessCode,
      doorAccessCode: doorAccessCode,
      parkingBay: parkingBay,
      timelineSteps: timelineSteps,
      activeTimelineIndex: activeTimelineIndex,
    );
  }
}

class AppState extends ChangeNotifier {
  // Auth state
  bool _isLoggedIn = false;
  bool _isGuest = false;
  String _userName = "";
  String _userEmail = "";
  String _userPhone = "";
  
  // Profile verification state
  VerificationStatus _verificationStatus = VerificationStatus.none;
  String _uploadedDocType = "";
  String _uploadedDocName = "";

  // Mock list of appointments
  final List<Appointment> _appointments = [
    Appointment(
      id: "APT-99281",
      professionalName: "Dr. Aris Thorne",
      organizationName: "Vantage Medical Group",
      category: "Healthcare",
      date: DateTime.now().add(const Duration(days: 1)),
      timeSlot: "09:30 AM",
      status: "Verified",
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
      professionalName: "Studio Lumina",
      organizationName: "Studio Lumina Spa",
      category: "Beauty",
      date: DateTime.now().add(const Duration(days: 3)),
      timeSlot: "02:00 PM",
      status: "Pending",
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
  VerificationStatus get verificationStatus => _verificationStatus;
  String get uploadedDocType => _uploadedDocType;
  String get uploadedDocName => _uploadedDocName;
  List<Appointment> get appointments => _appointments.where((apt) => apt.status != "Cancelled").toList();
  List<Appointment> get cancelledAppointments => _appointments.where((apt) => apt.status == "Cancelled").toList();
  
  // Find active operational appointment (e.g. verified appointment happening soonest)
  Appointment? get activeOperationalAppointment {
    final active = _appointments.where((apt) => apt.status == "Verified").toList();
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
    _userName = "Alex Mercer";
    _userEmail = email;
    _userPhone = "+1 (555) 019-2834";
    notifyListeners();
  }

  void signup(String name, String email, String phone, String password) {
    _isLoggedIn = true;
    _isGuest = false;
    _userName = name;
    _userEmail = email;
    _userPhone = phone;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _isGuest = false;
    _userName = "";
    _userEmail = "";
    _userPhone = "";
    _verificationStatus = VerificationStatus.none;
    _uploadedDocType = "";
    _uploadedDocName = "";
    notifyListeners();
  }

  void updateProfile({required String name, required String phone, required String email}) {
    _userName = name;
    _userPhone = phone;
    _userEmail = email;
    notifyListeners();
  }

  void uploadId(String docType, String docName) {
    _verificationStatus = VerificationStatus.pending;
    _uploadedDocType = docType;
    _uploadedDocName = docName;
    notifyListeners();

    // Simulate auto-verification success after 5 seconds
    Future.delayed(const Duration(seconds: 6), () {
      if (_verificationStatus == VerificationStatus.pending) {
        _verificationStatus = VerificationStatus.verified;
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
