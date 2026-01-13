import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('te')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Guardrail'**
  String get appTitle;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Guardrail'**
  String get welcomeMessage;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get hindi;

  /// No description provided for @telugu.
  ///
  /// In en, this message translates to:
  /// **'Telugu'**
  String get telugu;

  /// No description provided for @biometrics.
  ///
  /// In en, this message translates to:
  /// **'Biometrics'**
  String get biometrics;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @resident.
  ///
  /// In en, this message translates to:
  /// **'Resident'**
  String get resident;

  /// No description provided for @guard.
  ///
  /// In en, this message translates to:
  /// **'Guard'**
  String get guard;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @residenceId.
  ///
  /// In en, this message translates to:
  /// **'Residence ID'**
  String get residenceId;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @gateControl.
  ///
  /// In en, this message translates to:
  /// **'Gate Control'**
  String get gateControl;

  /// No description provided for @visitorsLog.
  ///
  /// In en, this message translates to:
  /// **'Visitors Log'**
  String get visitorsLog;

  /// No description provided for @pendingApprovals.
  ///
  /// In en, this message translates to:
  /// **'Pending Approvals'**
  String get pendingApprovals;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @entryApproved.
  ///
  /// In en, this message translates to:
  /// **'Entry Approved'**
  String get entryApproved;

  /// No description provided for @entryRejected.
  ///
  /// In en, this message translates to:
  /// **'Entry Rejected'**
  String get entryRejected;

  /// No description provided for @scanId.
  ///
  /// In en, this message translates to:
  /// **'Scan ID'**
  String get scanId;

  /// No description provided for @enterDetails.
  ///
  /// In en, this message translates to:
  /// **'Enter Details'**
  String get enterDetails;

  /// No description provided for @visitorName.
  ///
  /// In en, this message translates to:
  /// **'Visitor Name'**
  String get visitorName;

  /// No description provided for @purpose.
  ///
  /// In en, this message translates to:
  /// **'Purpose'**
  String get purpose;

  /// No description provided for @vehicleNumber.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Number'**
  String get vehicleNumber;

  /// No description provided for @addVisitor.
  ///
  /// In en, this message translates to:
  /// **'Add Visitor'**
  String get addVisitor;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @accessAndSecurity.
  ///
  /// In en, this message translates to:
  /// **'Access & Security'**
  String get accessAndSecurity;

  /// No description provided for @visitorManagement.
  ///
  /// In en, this message translates to:
  /// **'Visitor Management'**
  String get visitorManagement;

  /// No description provided for @preApprovalsAndGuests.
  ///
  /// In en, this message translates to:
  /// **'Pre-approvals & Guests'**
  String get preApprovalsAndGuests;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @entryNotifications.
  ///
  /// In en, this message translates to:
  /// **'Entry Notifications'**
  String get entryNotifications;

  /// No description provided for @alertsForGateRequests.
  ///
  /// In en, this message translates to:
  /// **'Alerts for gate requests'**
  String get alertsForGateRequests;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @areYouSureLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get areYouSureLogout;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @fillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields'**
  String get fillAllFields;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please check your credentials.'**
  String get loginFailed;

  /// No description provided for @enterCredentials.
  ///
  /// In en, this message translates to:
  /// **'Please enter your credentials to continue'**
  String get enterCredentials;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get enterPassword;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @seamlessSecureAccess.
  ///
  /// In en, this message translates to:
  /// **'Seamless, secure access for your community.'**
  String get seamlessSecureAccess;

  /// No description provided for @agreeTerms.
  ///
  /// In en, this message translates to:
  /// **'By proceeding, you agree to our Terms & Privacy Policy.'**
  String get agreeTerms;

  /// No description provided for @biometricsUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update biometrics settings'**
  String get biometricsUpdateFailed;

  /// No description provided for @residentPortal.
  ///
  /// In en, this message translates to:
  /// **'Resident Portal'**
  String get residentPortal;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening,'**
  String get goodEvening;

  /// No description provided for @notificationCenterMessage.
  ///
  /// In en, this message translates to:
  /// **'We are adding a notification center to keep you updated on all activities.'**
  String get notificationCenterMessage;

  /// No description provided for @manageFamily.
  ///
  /// In en, this message translates to:
  /// **'Manage Family'**
  String get manageFamily;

  /// No description provided for @manageFlat.
  ///
  /// In en, this message translates to:
  /// **'Manage Flat'**
  String get manageFlat;

  /// No description provided for @newInvite.
  ///
  /// In en, this message translates to:
  /// **'New Invite'**
  String get newInvite;

  /// No description provided for @pendingRequest.
  ///
  /// In en, this message translates to:
  /// **'Pending Request'**
  String get pendingRequest;

  /// No description provided for @live.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get live;

  /// No description provided for @visitorApproved.
  ///
  /// In en, this message translates to:
  /// **'Visitor approved'**
  String get visitorApproved;

  /// No description provided for @visitorRejected.
  ///
  /// In en, this message translates to:
  /// **'Visitor rejected'**
  String get visitorRejected;

  /// No description provided for @recentHistory.
  ///
  /// In en, this message translates to:
  /// **'Recent History'**
  String get recentHistory;

  /// No description provided for @noRecentVisitors.
  ///
  /// In en, this message translates to:
  /// **'No recent visitors'**
  String get noRecentVisitors;

  /// No description provided for @wait.
  ///
  /// In en, this message translates to:
  /// **'Wait...'**
  String get wait;

  /// No description provided for @arrived.
  ///
  /// In en, this message translates to:
  /// **'Arrived'**
  String get arrived;

  /// No description provided for @ago.
  ///
  /// In en, this message translates to:
  /// **'ago'**
  String get ago;

  /// No description provided for @min.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get min;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @visitors.
  ///
  /// In en, this message translates to:
  /// **'Visitors'**
  String get visitors;

  /// No description provided for @guardChecks.
  ///
  /// In en, this message translates to:
  /// **'Guard Checks'**
  String get guardChecks;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @currentlyInside.
  ///
  /// In en, this message translates to:
  /// **'Currently Inside'**
  String get currentlyInside;

  /// No description provided for @noVisitorsFound.
  ///
  /// In en, this message translates to:
  /// **'No visitors found'**
  String get noVisitorsFound;

  /// No description provided for @registerVisitorMultiline.
  ///
  /// In en, this message translates to:
  /// **'Register\nVisitor'**
  String get registerVisitorMultiline;

  /// No description provided for @scanVisitorQRMultiline.
  ///
  /// In en, this message translates to:
  /// **'Scan\nVisitor QR'**
  String get scanVisitorQRMultiline;

  /// No description provided for @inside.
  ///
  /// In en, this message translates to:
  /// **'INSIDE'**
  String get inside;

  /// No description provided for @flat.
  ///
  /// In en, this message translates to:
  /// **'Flat'**
  String get flat;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @markExitTitle.
  ///
  /// In en, this message translates to:
  /// **'Mark Exit?'**
  String get markExitTitle;

  /// No description provided for @markExitMessage.
  ///
  /// In en, this message translates to:
  /// **'Mark {name} as exited?'**
  String markExitMessage(String name);

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @markExitAction.
  ///
  /// In en, this message translates to:
  /// **'Mark Exit'**
  String get markExitAction;

  /// No description provided for @adminPanel.
  ///
  /// In en, this message translates to:
  /// **'Admin Panel'**
  String get adminPanel;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @totalFlats.
  ///
  /// In en, this message translates to:
  /// **'Total Flats'**
  String get totalFlats;

  /// No description provided for @activeGuards.
  ///
  /// In en, this message translates to:
  /// **'Active Guards'**
  String get activeGuards;

  /// No description provided for @pendingFlats.
  ///
  /// In en, this message translates to:
  /// **'Pending Flats'**
  String get pendingFlats;

  /// No description provided for @analyticsMockData.
  ///
  /// In en, this message translates to:
  /// **'Analytics (Mock Data)'**
  String get analyticsMockData;

  /// No description provided for @weeklyVisitorCount.
  ///
  /// In en, this message translates to:
  /// **'Weekly Visitor Count'**
  String get weeklyVisitorCount;

  /// No description provided for @peakHours.
  ///
  /// In en, this message translates to:
  /// **'Peak Hours'**
  String get peakHours;

  /// No description provided for @guardStatus.
  ///
  /// In en, this message translates to:
  /// **'Guard Status'**
  String get guardStatus;

  /// No description provided for @approvalRates.
  ///
  /// In en, this message translates to:
  /// **'Approval Rates'**
  String get approvalRates;

  /// No description provided for @recentGuardChecks.
  ///
  /// In en, this message translates to:
  /// **'Recent Guard Checks'**
  String get recentGuardChecks;

  /// No description provided for @noRecentChecks.
  ///
  /// In en, this message translates to:
  /// **'No recent checks'**
  String get noRecentChecks;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @flats.
  ///
  /// In en, this message translates to:
  /// **'Flats'**
  String get flats;

  /// No description provided for @guards.
  ///
  /// In en, this message translates to:
  /// **'Guards'**
  String get guards;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @signUpToGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Sign up to get started'**
  String get signUpToGetStarted;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @createPassword.
  ///
  /// In en, this message translates to:
  /// **'Create a password'**
  String get createPassword;

  /// No description provided for @confirmYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get confirmYourPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @continueAs.
  ///
  /// In en, this message translates to:
  /// **'Continue as'**
  String get continueAs;

  /// No description provided for @residenceIdOptional.
  ///
  /// In en, this message translates to:
  /// **'Residence ID (Optional)'**
  String get residenceIdOptional;

  /// No description provided for @enterResidenceIdToJoin.
  ///
  /// In en, this message translates to:
  /// **'Enter Residence ID to join'**
  String get enterResidenceIdToJoin;

  /// No description provided for @leaveEmptyToCreateFlat.
  ///
  /// In en, this message translates to:
  /// **'Leave empty if you want to create a new flat'**
  String get leaveEmptyToCreateFlat;

  /// No description provided for @pleaseSelectRole.
  ///
  /// In en, this message translates to:
  /// **'Please select a role to continue'**
  String get pleaseSelectRole;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed. Please try again.'**
  String get registrationFailed;

  /// No description provided for @pleaseConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmPassword;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'your@email.com'**
  String get emailHint;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'John Doe'**
  String get nameHint;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'9876543210'**
  String get phoneHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'te'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
