import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'dart:async';
import 'package:zuruni_mobile_app/main.dart';
import 'package:zuruni_mobile_app/state/app_state.dart';
import 'package:zuruni_mobile_app/screens/auth/signup_screen.dart';
import 'package:zuruni_mobile_app/screens/auth/forgot_password_screen.dart';
import 'package:zuruni_mobile_app/screens/auth/otp_verification_screen.dart';
import 'package:zuruni_mobile_app/screens/auth/account_created_screen.dart';
import 'package:zuruni_mobile_app/screens/auth/reset_password_screen.dart';
import 'package:zuruni_mobile_app/screens/auth/login_screen.dart';

void main() {
  setUpAll(() {
    // Avoid loading fonts over network
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget buildTestWidget(AppState appState) {
    return ChangeNotifierProvider.value(
      value: appState,
      child: const ZuruniApp(),
    );
  }

  /// Pumps through the splash animation phases and the Hero navigation
  /// transition so that tests land on the LoginScreen.
  Future<void> pumpThroughSplash(WidgetTester tester) async {
    // Phase 1: logo animation (800ms)
    await tester.pump(const Duration(milliseconds: 850));
    // Phase 2: text reveal animation (700ms)
    await tester.pump(const Duration(milliseconds: 750));
    // Phase 3: brief pause (400ms) + pushReplacement triggers
    await tester.pump(const Duration(milliseconds: 450));
    // Hero page transition (700ms)
    await tester.pumpAndSettle();
    // Verify we are now on LoginScreen
    expect(find.byType(LoginScreen), findsOneWidget);
  }

  testWidgets('Signup flow verification: signup -> OTP -> Account Verified', (WidgetTester tester) async {
    debugNetworkImageHttpClientProvider = () => _MockHttpClient();
    try {
      // Set a realistic taller mobile screen size so everything is visible
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final appState = AppState();
      await tester.pumpWidget(buildTestWidget(appState));
      await pumpThroughSplash(tester);

      // 1. We start at LoginScreen. Click on "Sign Up" link to navigate to SignupScreen.
      final signUpLink = find.text('Sign Up');
      expect(signUpLink, findsOneWidget);
      await tester.ensureVisible(signUpLink);
      await tester.tap(signUpLink);
      await tester.pumpAndSettle();

      // Verify we are on SignupScreen
      expect(find.byType(SignupScreen), findsOneWidget);

      // Fill in signup credentials
      final nameField = find.widgetWithText(TextFormField, 'Enter your full name');
      final emailField = find.widgetWithText(TextFormField, 'Enter your email address');
      final phoneField = find.widgetWithText(TextFormField, 'Enter your phone number');
      final passwordField = find.byType(TextFormField).at(3); // Password field

      await tester.ensureVisible(nameField);
      await tester.enterText(nameField, 'John Doe');
      
      await tester.ensureVisible(emailField);
      await tester.enterText(emailField, 'john.doe@example.com');
      
      await tester.ensureVisible(phoneField);
      await tester.enterText(phoneField, '+1234567890');
      
      await tester.ensureVisible(passwordField);
      await tester.enterText(passwordField, 'Password123!');

      // Agree to terms checkbox
      final checkbox = find.byType(Checkbox);
      expect(checkbox, findsOneWidget);
      await tester.ensureVisible(checkbox);
      await tester.tap(checkbox);
      await tester.pumpAndSettle();

      // Tap "Create Account"
      final createAccountButton = find.widgetWithText(ElevatedButton, 'Create Account');
      expect(createAccountButton, findsOneWidget);
      await tester.ensureVisible(createAccountButton);
      await tester.tap(createAccountButton);
      await tester.pumpAndSettle();

      // 2. Verify we are on OtpVerificationScreen
      expect(find.byType(OtpVerificationScreen), findsOneWidget);
      expect(find.text('Verify Identity'), findsOneWidget);

      // Test the "Edit email or phone number" option redirects back to SignupScreen
      final editLink = find.text('Edit email or phone number');
      expect(editLink, findsOneWidget);
      await tester.ensureVisible(editLink);
      await tester.tap(editLink);
      await tester.pumpAndSettle();

      // Verify we are back on SignupScreen and fields are preserved
      expect(find.byType(SignupScreen), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('john.doe@example.com'), findsOneWidget);

      // Click "Create Account" again to go back to OTP screen
      final createAccountBtn2 = find.widgetWithText(ElevatedButton, 'Create Account');
      await tester.ensureVisible(createAccountBtn2);
      await tester.tap(createAccountBtn2);
      await tester.pumpAndSettle();

      // Now complete verification: enter 6 digit code
      expect(find.byType(OtpVerificationScreen), findsOneWidget);
      for (int i = 0; i < 6; i++) {
        final pinField = find.byType(TextFormField).at(i);
        await tester.ensureVisible(pinField);
        await tester.enterText(pinField, '1');
      }
      await tester.pumpAndSettle();

      // Tap "Verify & Continue"
      final verifyButton = find.widgetWithText(ElevatedButton, 'Verify & Continue');
      await tester.ensureVisible(verifyButton);
      await tester.tap(verifyButton);
      await tester.pumpAndSettle();

      // 3. Verify we are on AccountCreatedScreen (Account Verified)
      expect(find.byType(AccountCreatedScreen), findsOneWidget);
      expect(find.text('Account Verified'), findsOneWidget);

      // Tap "Go to Dashboard" to sign in and go to main shell
      final getStartedButton = find.widgetWithText(ElevatedButton, 'Go to Dashboard');
      expect(getStartedButton, findsOneWidget);
      await tester.ensureVisible(getStartedButton);
      await tester.tap(getStartedButton);
      await tester.pumpAndSettle();

      // Verify user is logged in
      expect(appState.isLoggedIn, isTrue);
      expect(appState.userName, 'John Doe');
    } finally {
      debugNetworkImageHttpClientProvider = null;
    }
  });

  testWidgets('ForgotPassword flow verification: forgot password -> OTP -> Reset Password', (WidgetTester tester) async {
    debugNetworkImageHttpClientProvider = () => _MockHttpClient();
    try {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final appState = AppState();
      await tester.pumpWidget(buildTestWidget(appState));
      await pumpThroughSplash(tester);

      // 1. From LoginScreen, tap "Forgot Password?"
      final forgotPasswordLink = find.text('Forgot Password?');
      expect(forgotPasswordLink, findsOneWidget);
      await tester.ensureVisible(forgotPasswordLink);
      await tester.tap(forgotPasswordLink);
      await tester.pumpAndSettle();

      // Verify we are on ForgotPasswordScreen
      expect(find.byType(ForgotPasswordScreen), findsOneWidget);

      // Fill in email or phone
      final identifierField = find.widgetWithText(TextFormField, 'Enter your email or phone number');
      await tester.ensureVisible(identifierField);
      await tester.enterText(identifierField, 'test@example.com');

      // Tap "Send Reset Code"
      final sendCodeButton = find.widgetWithText(ElevatedButton, 'Send Reset Code');
      expect(sendCodeButton, findsOneWidget);
      await tester.ensureVisible(sendCodeButton);
      await tester.tap(sendCodeButton);
      await tester.pumpAndSettle();

      // Dismiss the SnackBar if visible so it doesn't block future elements/taps
      // We wait 4 seconds for the mock SnackBar to disappear
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      // 2. Verify we are on OtpVerificationScreen
      expect(find.byType(OtpVerificationScreen), findsOneWidget);
      expect(find.text('Verify Identity'), findsOneWidget);

      // Test "Edit email or phone number" option redirects back to ForgotPasswordScreen
      final editLink = find.text('Edit email or phone number');
      expect(editLink, findsOneWidget);
      await tester.ensureVisible(editLink);
      await tester.tap(editLink);
      await tester.pumpAndSettle();

      // Verify we are back on ForgotPasswordScreen and the text is preserved
      expect(find.byType(ForgotPasswordScreen), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);

      // Click "Send Reset Code" again to go back to OTP screen
      final sendCodeBtn2 = find.widgetWithText(ElevatedButton, 'Send Reset Code');
      await tester.ensureVisible(sendCodeBtn2);
      await tester.tap(sendCodeBtn2);
      await tester.pumpAndSettle();

      // Dismiss snackbar again
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      // Enter 6 digit code
      expect(find.byType(OtpVerificationScreen), findsOneWidget);
      for (int i = 0; i < 6; i++) {
        final pinField = find.byType(TextFormField).at(i);
        await tester.ensureVisible(pinField);
        await tester.enterText(pinField, '2');
      }
      await tester.pumpAndSettle();

      // Tap "Verify & Continue"
      final verifyButton = find.widgetWithText(ElevatedButton, 'Verify & Continue');
      await tester.ensureVisible(verifyButton);
      await tester.tap(verifyButton);
      await tester.pumpAndSettle();

      // 3. Verify we are on ResetPasswordScreen
      expect(find.byType(ResetPasswordScreen), findsOneWidget);
      expect(find.text('Reset Password'), findsOneWidget);
    } finally {
      debugNetworkImageHttpClientProvider = null;
    }
  });
}

class _MockHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #getUrl || invocation.memberName == #get || invocation.memberName == #openUrl) {
      return _mockRequest();
    }
    throw UnimplementedError('No mock implementation for ${invocation.memberName}');
  }

  Future<HttpClientRequest> _mockRequest() async {
    return _MockHttpClientRequest();
  }
}

class _MockHttpClientRequest implements HttpClientRequest {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #close || invocation.memberName == #done) {
      return _mockResponse();
    }
    if (invocation.memberName == #headers) {
      return _MockHttpHeaders();
    }
    return null;
  }

  Future<HttpClientResponse> _mockResponse() async {
    return _MockHttpClientResponse();
  }
}

class _MockHttpHeaders implements HttpHeaders {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockHttpClientResponse extends Stream<List<int>> implements HttpClientResponse {
  // 1x1 transparent PNG image data
  static const List<int> _kTransparentImage = [
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
    0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
    0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
    0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
    0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
    0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
  ];

  @override
  int get statusCode => HttpStatus.ok;

  @override
  int get contentLength => _kTransparentImage.length;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #statusCode) {
      return HttpStatus.ok;
    }
    if (invocation.memberName == #contentLength) {
      return _kTransparentImage.length;
    }
    if (invocation.memberName == #compressionState) {
      return HttpClientResponseCompressionState.notCompressed;
    }
    if (invocation.memberName == #listen) {
      final arguments = invocation.positionalArguments;
      final onData = arguments[0] as void Function(List<int>)?;
      final onError = invocation.namedArguments[#onError] as Function?;
      final onDone = invocation.namedArguments[#onDone] as void Function()?;
      final cancelOnError = invocation.namedArguments[#cancelOnError] as bool?;
      return Stream<List<int>>.fromIterable([_kTransparentImage]).listen(
        onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );
    }
    throw UnimplementedError('No mock implementation for ${invocation.memberName}');
  }
}
