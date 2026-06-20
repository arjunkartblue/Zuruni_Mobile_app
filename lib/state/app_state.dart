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
  String get userCountry => _userCountry;
  List<VerificationDocument> get documents => _documents;

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
    _userName = "Alex Johnson";
    _userEmail = email.isNotEmpty ? email : "alex.j@example.com";
    _userPhone = "+1 (555) 0199";
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

  void signup(String name, String email, String phone, String password) {
    _isLoggedIn = true;
    _isGuest = false;
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
    _userName = "";
    _userEmail = "";
    _userPhone = "";
    _userCountry = "India";
    _documents.clear();
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
