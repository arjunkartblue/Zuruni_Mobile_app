import 'package:flutter/material.dart';

enum VerificationStatus { none, pending, verified }

class Appointment {
  final String id;
  final String professionalName;
  final String organizationName;
  final String category;
  final String serviceName;
  final DateTime date;
  final String timeSlot;
  String status; // "Verified", "Pending", "Action Required", "Cancelled"
  final String? tokenNumber; // Added for Token System
  
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
  });

  Appointment copyWith({String? status, String? tokenNumber}) {
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
    final list = _appointments.where((apt) => apt.status != "Cancelled").toList();
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
