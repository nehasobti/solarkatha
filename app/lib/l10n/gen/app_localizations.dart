import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'SolarKatha'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Rooftop solar, from site visit to subsidy'**
  String get appTagline;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageHindi.
  ///
  /// In en, this message translates to:
  /// **'हिंदी'**
  String get languageHindi;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We will send a one-time code to your mobile number.'**
  String get loginSubtitle;

  /// No description provided for @loginEmailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Owners can sign in with a code sent to their email.'**
  String get loginEmailSubtitle;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get phoneLabel;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'10-digit mobile number'**
  String get phoneHint;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendOtp;

  /// No description provided for @otpLabel.
  ///
  /// In en, this message translates to:
  /// **'6-digit code'**
  String get otpLabel;

  /// No description provided for @verifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify and continue'**
  String get verifyOtp;

  /// No description provided for @otpSentTo.
  ///
  /// In en, this message translates to:
  /// **'Code sent to {destination}'**
  String otpSentTo(String destination);

  /// No description provided for @changeNumber.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get changeNumber;

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendOtp;

  /// No description provided for @useEmailInstead.
  ///
  /// In en, this message translates to:
  /// **'Owner? Sign in with email'**
  String get useEmailInstead;

  /// No description provided for @usePhoneInstead.
  ///
  /// In en, this message translates to:
  /// **'Sign in with mobile number'**
  String get usePhoneInstead;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 10-digit Indian mobile number'**
  String get invalidPhone;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @invalidOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code'**
  String get invalidOtp;

  /// No description provided for @otpIncorrect.
  ///
  /// In en, this message translates to:
  /// **'The code is wrong or has expired. Try again or resend.'**
  String get otpIncorrect;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your company'**
  String get onboardingTitle;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No team invite was found for this account. Create your company to continue as its owner. If your employer uses SolarKatha, ask them to invite this number.'**
  String get onboardingSubtitle;

  /// No description provided for @yourNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get yourNameLabel;

  /// No description provided for @companyNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Company name'**
  String get companyNameLabel;

  /// No description provided for @stateLabel.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get stateLabel;

  /// No description provided for @createCompany.
  ///
  /// In en, this message translates to:
  /// **'Create company'**
  String get createCompany;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @deactivatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Account deactivated'**
  String get deactivatedTitle;

  /// No description provided for @deactivatedBody.
  ///
  /// In en, this message translates to:
  /// **'Your company owner has deactivated this account. Contact them to get access again.'**
  String get deactivatedBody;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Check your network and try again.'**
  String get errorNetwork;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming in a later update'**
  String get comingSoon;

  /// No description provided for @roleOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get roleOwner;

  /// No description provided for @roleSales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get roleSales;

  /// No description provided for @roleInstaller.
  ///
  /// In en, this message translates to:
  /// **'Installer'**
  String get roleInstaller;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navLeads.
  ///
  /// In en, this message translates to:
  /// **'Leads'**
  String get navLeads;

  /// No description provided for @navProjects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get navProjects;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @navOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get navOverview;

  /// No description provided for @navSubsidy.
  ///
  /// In en, this message translates to:
  /// **'Subsidy tracker'**
  String get navSubsidy;

  /// No description provided for @navTeam.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get navTeam;

  /// No description provided for @navProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get navProducts;

  /// No description provided for @navConfig.
  ///
  /// In en, this message translates to:
  /// **'Config'**
  String get navConfig;

  /// No description provided for @navBranding.
  ///
  /// In en, this message translates to:
  /// **'Branding'**
  String get navBranding;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Namaste, {name}'**
  String greeting(String name);

  /// No description provided for @newLead.
  ///
  /// In en, this message translates to:
  /// **'New lead'**
  String get newLead;

  /// No description provided for @followUpsToday.
  ///
  /// In en, this message translates to:
  /// **'Today\'s follow-ups'**
  String get followUpsToday;

  /// No description provided for @noFollowUps.
  ///
  /// In en, this message translates to:
  /// **'No follow-ups today'**
  String get noFollowUps;

  /// No description provided for @leadsByStatus.
  ///
  /// In en, this message translates to:
  /// **'Leads by status'**
  String get leadsByStatus;

  /// No description provided for @statusNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get statusNew;

  /// No description provided for @statusSurveyed.
  ///
  /// In en, this message translates to:
  /// **'Surveyed'**
  String get statusSurveyed;

  /// No description provided for @statusProposalSent.
  ///
  /// In en, this message translates to:
  /// **'Proposal sent'**
  String get statusProposalSent;

  /// No description provided for @statusWon.
  ///
  /// In en, this message translates to:
  /// **'Won'**
  String get statusWon;

  /// No description provided for @statusLost.
  ///
  /// In en, this message translates to:
  /// **'Lost'**
  String get statusLost;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @searchLeads.
  ///
  /// In en, this message translates to:
  /// **'Search by name or phone'**
  String get searchLeads;

  /// No description provided for @leadsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No leads yet'**
  String get leadsEmptyTitle;

  /// No description provided for @leadsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Leads you add will appear here, even when you are offline.'**
  String get leadsEmptyBody;

  /// No description provided for @projectsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No projects yet'**
  String get projectsEmptyTitle;

  /// No description provided for @projectsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Projects appear here once a customer signs a proposal and you are assigned to it.'**
  String get projectsEmptyBody;

  /// No description provided for @kpiLeadsThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Leads this month'**
  String get kpiLeadsThisMonth;

  /// No description provided for @kpiConversion.
  ///
  /// In en, this message translates to:
  /// **'Conversion rate'**
  String get kpiConversion;

  /// No description provided for @kpiKwSold.
  ///
  /// In en, this message translates to:
  /// **'kW sold'**
  String get kpiKwSold;

  /// No description provided for @kpiRevenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get kpiRevenue;

  /// No description provided for @kpiSubsidiesPending.
  ///
  /// In en, this message translates to:
  /// **'Subsidies pending'**
  String get kpiSubsidiesPending;

  /// No description provided for @pipelineTitle.
  ///
  /// In en, this message translates to:
  /// **'Pipeline'**
  String get pipelineTitle;

  /// No description provided for @dashboardEmpty.
  ///
  /// In en, this message translates to:
  /// **'Numbers appear here once your team starts adding leads.'**
  String get dashboardEmpty;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @profileSection.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileSection;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @roleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get roleLabel;

  /// No description provided for @companyLabel.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get companyLabel;

  /// No description provided for @displaySection.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get displaySection;

  /// No description provided for @highContrast.
  ///
  /// In en, this message translates to:
  /// **'High contrast'**
  String get highContrast;

  /// No description provided for @highContrastHint.
  ///
  /// In en, this message translates to:
  /// **'Stronger colours for bright sunlight'**
  String get highContrastHint;

  /// No description provided for @largeText.
  ///
  /// In en, this message translates to:
  /// **'Large text'**
  String get largeText;

  /// No description provided for @largeTextHint.
  ///
  /// In en, this message translates to:
  /// **'Bigger letters across the app'**
  String get largeTextHint;

  /// No description provided for @syncSection.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get syncSection;

  /// No description provided for @syncStatusOnline.
  ///
  /// In en, this message translates to:
  /// **'Connected to server'**
  String get syncStatusOnline;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @trackingTitle.
  ///
  /// In en, this message translates to:
  /// **'Track your solar project'**
  String get trackingTitle;

  /// No description provided for @trackingComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Your installer will share project updates on this page.'**
  String get trackingComingSoon;

  /// No description provided for @notFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get notFoundTitle;

  /// No description provided for @goHome.
  ///
  /// In en, this message translates to:
  /// **'Go to home'**
  String get goHome;

  /// No description provided for @configMissingTitle.
  ///
  /// In en, this message translates to:
  /// **'App not configured'**
  String get configMissingTitle;

  /// No description provided for @configMissingBody.
  ///
  /// In en, this message translates to:
  /// **'Supabase URL and key are missing. Build with --dart-define-from-file=env/dev.json (see README).'**
  String get configMissingBody;

  /// No description provided for @editLead.
  ///
  /// In en, this message translates to:
  /// **'Edit lead'**
  String get editLead;

  /// No description provided for @saveLead.
  ///
  /// In en, this message translates to:
  /// **'Save lead'**
  String get saveLead;

  /// No description provided for @leadSaved.
  ///
  /// In en, this message translates to:
  /// **'Lead saved'**
  String get leadSaved;

  /// No description provided for @leadDeleted.
  ///
  /// In en, this message translates to:
  /// **'Lead deleted'**
  String get leadDeleted;

  /// No description provided for @deleteLead.
  ///
  /// In en, this message translates to:
  /// **'Delete lead'**
  String get deleteLead;

  /// No description provided for @deleteLeadConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this lead? It will be removed from all devices.'**
  String get deleteLeadConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @customerSection.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customerSection;

  /// No description provided for @addressSection.
  ///
  /// In en, this message translates to:
  /// **'Address & location'**
  String get addressSection;

  /// No description provided for @followUpSection.
  ///
  /// In en, this message translates to:
  /// **'Follow-up'**
  String get followUpSection;

  /// No description provided for @leadNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer name'**
  String get leadNameLabel;

  /// No description provided for @leadPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get leadPhoneLabel;

  /// No description provided for @leadAltPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Alternate number (optional)'**
  String get leadAltPhoneLabel;

  /// No description provided for @leadAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'House / street / area'**
  String get leadAddressLabel;

  /// No description provided for @leadDistrictLabel.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get leadDistrictLabel;

  /// No description provided for @leadPincodeLabel.
  ///
  /// In en, this message translates to:
  /// **'PIN code'**
  String get leadPincodeLabel;

  /// No description provided for @invalidPincode.
  ///
  /// In en, this message translates to:
  /// **'Enter a 6-digit PIN code'**
  String get invalidPincode;

  /// No description provided for @leadSourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get leadSourceLabel;

  /// No description provided for @sourceWalkIn.
  ///
  /// In en, this message translates to:
  /// **'Walk-in'**
  String get sourceWalkIn;

  /// No description provided for @sourceReferral.
  ///
  /// In en, this message translates to:
  /// **'Referral'**
  String get sourceReferral;

  /// No description provided for @sourceCall.
  ///
  /// In en, this message translates to:
  /// **'Phone call'**
  String get sourceCall;

  /// No description provided for @sourceCampaign.
  ///
  /// In en, this message translates to:
  /// **'Campaign'**
  String get sourceCampaign;

  /// No description provided for @leadNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get leadNotesLabel;

  /// No description provided for @followUpLabel.
  ///
  /// In en, this message translates to:
  /// **'Next follow-up'**
  String get followUpLabel;

  /// No description provided for @followUpNone.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get followUpNone;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @assignedToLabel.
  ///
  /// In en, this message translates to:
  /// **'Assigned to'**
  String get assignedToLabel;

  /// No description provided for @captureLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my current location'**
  String get captureLocation;

  /// No description provided for @locationCaptured.
  ///
  /// In en, this message translates to:
  /// **'Location saved'**
  String get locationCaptured;

  /// No description provided for @locationFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t get location. Turn on GPS and allow location access.'**
  String get locationFailed;

  /// No description provided for @consentLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer agrees to share their electricity bill and site photos with us'**
  String get consentLabel;

  /// No description provided for @consentRequiredForPhotos.
  ///
  /// In en, this message translates to:
  /// **'Record the customer\'s consent (Edit lead) before adding photos.'**
  String get consentRequiredForPhotos;

  /// No description provided for @draftRestored.
  ///
  /// In en, this message translates to:
  /// **'Unsaved draft restored'**
  String get draftRestored;

  /// No description provided for @discardDraft.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discardDraft;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @whatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsapp;

  /// No description provided for @directions.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get directions;

  /// No description provided for @notSynced.
  ///
  /// In en, this message translates to:
  /// **'Not synced'**
  String get notSynced;

  /// No description provided for @allStatuses.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allStatuses;

  /// No description provided for @allReps.
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get allReps;

  /// No description provided for @leadNotFound.
  ///
  /// In en, this message translates to:
  /// **'This lead no longer exists.'**
  String get leadNotFound;

  /// No description provided for @changeStatus.
  ///
  /// In en, this message translates to:
  /// **'Change status'**
  String get changeStatus;

  /// No description provided for @lostReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Why was it lost?'**
  String get lostReasonLabel;

  /// No description provided for @tabOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get tabOverview;

  /// No description provided for @tabBill.
  ///
  /// In en, this message translates to:
  /// **'Bill'**
  String get tabBill;

  /// No description provided for @tabSurvey.
  ///
  /// In en, this message translates to:
  /// **'Survey'**
  String get tabSurvey;

  /// No description provided for @tabProposals.
  ///
  /// In en, this message translates to:
  /// **'Proposals'**
  String get tabProposals;

  /// No description provided for @tabProject.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get tabProject;

  /// No description provided for @photosTitle.
  ///
  /// In en, this message translates to:
  /// **'Site photos'**
  String get photosTitle;

  /// No description provided for @photosChecklist.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} checklist photos'**
  String photosChecklist(int done, int total);

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @photoKindRoof.
  ///
  /// In en, this message translates to:
  /// **'Roof'**
  String get photoKindRoof;

  /// No description provided for @photoKindMeter.
  ///
  /// In en, this message translates to:
  /// **'Meter'**
  String get photoKindMeter;

  /// No description provided for @photoKindDbBox.
  ///
  /// In en, this message translates to:
  /// **'DB box'**
  String get photoKindDbBox;

  /// No description provided for @photoKindWiring.
  ///
  /// In en, this message translates to:
  /// **'Wiring path'**
  String get photoKindWiring;

  /// No description provided for @photoKindBill.
  ///
  /// In en, this message translates to:
  /// **'Electricity bill'**
  String get photoKindBill;

  /// No description provided for @photoKindOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get photoKindOther;

  /// No description provided for @photoWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting to upload'**
  String get photoWaiting;

  /// No description provided for @deletePhoto.
  ///
  /// In en, this message translates to:
  /// **'Delete photo'**
  String get deletePhoto;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No leads match your search.'**
  String get noResults;

  /// No description provided for @addedOn.
  ///
  /// In en, this message translates to:
  /// **'Added {date}'**
  String addedOn(String date);

  /// No description provided for @followUpOn.
  ///
  /// In en, this message translates to:
  /// **'Follow up {date}'**
  String followUpOn(String date);

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @totalLeads.
  ///
  /// In en, this message translates to:
  /// **'Total leads'**
  String get totalLeads;

  /// No description provided for @openLeads.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openLeads;

  /// No description provided for @wonLeads.
  ///
  /// In en, this message translates to:
  /// **'Won'**
  String get wonLeads;

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Everything you do is saved on this phone and will sync automatically.'**
  String get offlineBanner;

  /// No description provided for @syncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get syncing;

  /// No description provided for @syncedAt.
  ///
  /// In en, this message translates to:
  /// **'Last synced {time}'**
  String syncedAt(String time);

  /// No description provided for @neverSynced.
  ///
  /// In en, this message translates to:
  /// **'Not synced yet'**
  String get neverSynced;

  /// No description provided for @syncNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Sync is not set up in this build; data stays on this device.'**
  String get syncNotConfigured;

  /// No description provided for @pendingChanges.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{All changes uploaded} =1{1 change waiting to upload} other{{count} changes waiting to upload}}'**
  String pendingChanges(int count);

  /// No description provided for @scanBill.
  ///
  /// In en, this message translates to:
  /// **'Scan bill'**
  String get scanBill;

  /// No description provided for @enterBillManually.
  ///
  /// In en, this message translates to:
  /// **'Enter manually'**
  String get enterBillManually;

  /// No description provided for @scanQueued.
  ///
  /// In en, this message translates to:
  /// **'Bill photo saved. It will be read automatically when the phone is online.'**
  String get scanQueued;

  /// No description provided for @scanReady.
  ///
  /// In en, this message translates to:
  /// **'Bill read. Tap to check and confirm.'**
  String get scanReady;

  /// No description provided for @scanFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read the bill: {error}'**
  String scanFailed(String error);

  /// No description provided for @retry2.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry2;

  /// No description provided for @reviewScan.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get reviewScan;

  /// No description provided for @discardScan.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discardScan;

  /// No description provided for @noBillsTitle.
  ///
  /// In en, this message translates to:
  /// **'No bill yet'**
  String get noBillsTitle;

  /// No description provided for @noBillsBody.
  ///
  /// In en, this message translates to:
  /// **'Scan the customer\'s electricity bill, or type the values from it.'**
  String get noBillsBody;

  /// No description provided for @billFromScan.
  ///
  /// In en, this message translates to:
  /// **'Read by AI'**
  String get billFromScan;

  /// No description provided for @billManual.
  ///
  /// In en, this message translates to:
  /// **'Typed in'**
  String get billManual;

  /// No description provided for @avgUnitsShort.
  ///
  /// In en, this message translates to:
  /// **'{units} units/month'**
  String avgUnitsShort(String units);

  /// No description provided for @sizeSystem.
  ///
  /// In en, this message translates to:
  /// **'Size the system'**
  String get sizeSystem;

  /// No description provided for @sizingCta.
  ///
  /// In en, this message translates to:
  /// **'See system size, subsidy, EMI and payback'**
  String get sizingCta;

  /// No description provided for @billFormTitle.
  ///
  /// In en, this message translates to:
  /// **'Electricity bill'**
  String get billFormTitle;

  /// No description provided for @confirmBill.
  ///
  /// In en, this message translates to:
  /// **'Confirm bill'**
  String get confirmBill;

  /// No description provided for @billSaved.
  ///
  /// In en, this message translates to:
  /// **'Bill saved'**
  String get billSaved;

  /// No description provided for @deleteBill.
  ///
  /// In en, this message translates to:
  /// **'Delete bill'**
  String get deleteBill;

  /// No description provided for @discomLabel.
  ///
  /// In en, this message translates to:
  /// **'DISCOM'**
  String get discomLabel;

  /// No description provided for @consumerNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Consumer number'**
  String get consumerNumberLabel;

  /// No description provided for @billCustomerNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name on bill'**
  String get billCustomerNameLabel;

  /// No description provided for @tariffCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Tariff category'**
  String get tariffCategoryLabel;

  /// No description provided for @sanctionedLoadLabel.
  ///
  /// In en, this message translates to:
  /// **'Sanctioned load (kW)'**
  String get sanctionedLoadLabel;

  /// No description provided for @billingPeriodLabel.
  ///
  /// In en, this message translates to:
  /// **'Billing period'**
  String get billingPeriodLabel;

  /// No description provided for @avgUnitsLabel.
  ///
  /// In en, this message translates to:
  /// **'Average monthly units (kWh)'**
  String get avgUnitsLabel;

  /// No description provided for @billAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Bill amount (₹)'**
  String get billAmountLabel;

  /// No description provided for @unitsHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly units printed on the bill'**
  String get unitsHistoryTitle;

  /// No description provided for @checkThisField.
  ///
  /// In en, this message translates to:
  /// **'Please check: the AI was not sure'**
  String get checkThisField;

  /// No description provided for @duplicateConsumer.
  ///
  /// In en, this message translates to:
  /// **'This consumer number is already on another lead. Only one central subsidy is allowed per household.'**
  String get duplicateConsumer;

  /// No description provided for @invalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get invalidNumber;

  /// No description provided for @sizingTitle.
  ///
  /// In en, this message translates to:
  /// **'System sizing'**
  String get sizingTitle;

  /// No description provided for @usageSection.
  ///
  /// In en, this message translates to:
  /// **'Customer usage'**
  String get usageSection;

  /// No description provided for @roofAreaLabel.
  ///
  /// In en, this message translates to:
  /// **'Usable roof area (m², optional)'**
  String get roofAreaLabel;

  /// No description provided for @shadingLabel.
  ///
  /// In en, this message translates to:
  /// **'Shading'**
  String get shadingLabel;

  /// No description provided for @shadingNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get shadingNone;

  /// No description provided for @shadingLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get shadingLow;

  /// No description provided for @shadingMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get shadingMedium;

  /// No description provided for @shadingHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get shadingHigh;

  /// No description provided for @dcrPanels.
  ///
  /// In en, this message translates to:
  /// **'DCR & ALMM-listed panels'**
  String get dcrPanels;

  /// No description provided for @dcrHint.
  ///
  /// In en, this message translates to:
  /// **'Required for the subsidy'**
  String get dcrHint;

  /// No description provided for @recommendedLabel.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommendedLabel;

  /// No description provided for @recommendedKw.
  ///
  /// In en, this message translates to:
  /// **'Recommended: {kw}'**
  String recommendedKw(String kw);

  /// No description provided for @requiredKwNote.
  ///
  /// In en, this message translates to:
  /// **'Covers about {units} units a month'**
  String requiredKwNote(String units);

  /// No description provided for @exceedsLoad.
  ///
  /// In en, this message translates to:
  /// **'Above the sanctioned load ({load} kW). The customer may need a load increase.'**
  String exceedsLoad(String load);

  /// No description provided for @limitedByRoof.
  ///
  /// In en, this message translates to:
  /// **'Limited by roof area (max {kw}).'**
  String limitedByRoof(String kw);

  /// No description provided for @compareTitle.
  ///
  /// In en, this message translates to:
  /// **'Compare sizes'**
  String get compareTitle;

  /// No description provided for @customSize.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get customSize;

  /// No description provided for @generationTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly generation'**
  String get generationTitle;

  /// No description provided for @generationPvgis.
  ///
  /// In en, this message translates to:
  /// **'Based on PVGIS solar data for this location'**
  String get generationPvgis;

  /// No description provided for @generationFallback.
  ///
  /// In en, this message translates to:
  /// **'Estimate ({kwh} units per kW per day). Add the site location and go online for a location-based figure.'**
  String generationFallback(String kwh);

  /// No description provided for @perYear.
  ///
  /// In en, this message translates to:
  /// **'{kwh} units a year'**
  String perYear(String kwh);

  /// No description provided for @subsidySection.
  ///
  /// In en, this message translates to:
  /// **'Subsidy'**
  String get subsidySection;

  /// No description provided for @centralSubsidy.
  ///
  /// In en, this message translates to:
  /// **'Central (PM Surya Ghar)'**
  String get centralSubsidy;

  /// No description provided for @stateSubsidy.
  ///
  /// In en, this message translates to:
  /// **'State top-up'**
  String get stateSubsidy;

  /// No description provided for @totalSubsidy.
  ///
  /// In en, this message translates to:
  /// **'Total subsidy'**
  String get totalSubsidy;

  /// No description provided for @subsidyPerKw.
  ///
  /// In en, this message translates to:
  /// **'About {amount} per kW'**
  String subsidyPerKw(String amount);

  /// No description provided for @subsidyLine.
  ///
  /// In en, this message translates to:
  /// **'{from}–{to} kW × {rate}'**
  String subsidyLine(String from, String to, String rate);

  /// No description provided for @noSubsidyNonDcr.
  ///
  /// In en, this message translates to:
  /// **'No subsidy: panels must be DCR and ALMM-listed.'**
  String get noSubsidyNonDcr;

  /// No description provided for @costSection.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get costSection;

  /// No description provided for @grossPrice.
  ///
  /// In en, this message translates to:
  /// **'System price'**
  String get grossPrice;

  /// No description provided for @pricePerKwLabel.
  ///
  /// In en, this message translates to:
  /// **'Price per kW (₹)'**
  String get pricePerKwLabel;

  /// No description provided for @netPrice.
  ///
  /// In en, this message translates to:
  /// **'Customer pays after subsidy'**
  String get netPrice;

  /// No description provided for @loanSection.
  ///
  /// In en, this message translates to:
  /// **'Loan & EMI'**
  String get loanSection;

  /// No description provided for @loanBank.
  ///
  /// In en, this message translates to:
  /// **'Loan option'**
  String get loanBank;

  /// No description provided for @interestRate.
  ///
  /// In en, this message translates to:
  /// **'Interest % a year'**
  String get interestRate;

  /// No description provided for @tenureYears.
  ///
  /// In en, this message translates to:
  /// **'Years'**
  String get tenureYears;

  /// No description provided for @loanAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Loan amount (₹)'**
  String get loanAmountLabel;

  /// No description provided for @emiLabel.
  ///
  /// In en, this message translates to:
  /// **'EMI'**
  String get emiLabel;

  /// No description provided for @currentBillLabel.
  ///
  /// In en, this message translates to:
  /// **'Current bill'**
  String get currentBillLabel;

  /// No description provided for @perMonth.
  ///
  /// In en, this message translates to:
  /// **'a month'**
  String get perMonth;

  /// No description provided for @emiVsBillGood.
  ///
  /// In en, this message translates to:
  /// **'EMI is lower than today\'s bill'**
  String get emiVsBillGood;

  /// No description provided for @savingsSection.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get savingsSection;

  /// No description provided for @monthlySaving.
  ///
  /// In en, this message translates to:
  /// **'Saving a month (year 1)'**
  String get monthlySaving;

  /// No description provided for @paybackLabel.
  ///
  /// In en, this message translates to:
  /// **'Payback'**
  String get paybackLabel;

  /// No description provided for @paybackYears.
  ///
  /// In en, this message translates to:
  /// **'{years} years'**
  String paybackYears(String years);

  /// No description provided for @noPayback.
  ///
  /// In en, this message translates to:
  /// **'More than {years} years'**
  String noPayback(String years);

  /// No description provided for @lifetimeSavings.
  ///
  /// In en, this message translates to:
  /// **'{years}-year savings'**
  String lifetimeSavings(String years);

  /// No description provided for @configMissing.
  ///
  /// In en, this message translates to:
  /// **'Pricing settings haven\'t reached this device yet. Connect to the internet and open this again.'**
  String get configMissing;

  /// No description provided for @noTariffUsingBill.
  ///
  /// In en, this message translates to:
  /// **'No tariff for this state yet; using the average rate from the bill.'**
  String get noTariffUsingBill;

  /// No description provided for @noTariff.
  ///
  /// In en, this message translates to:
  /// **'Add the bill amount (or a tariff for this state) to see savings.'**
  String get noTariff;

  /// No description provided for @needUsage.
  ///
  /// In en, this message translates to:
  /// **'Enter the average monthly units to size the system.'**
  String get needUsage;

  /// No description provided for @rowGeneration.
  ///
  /// In en, this message translates to:
  /// **'Units / month'**
  String get rowGeneration;

  /// No description provided for @rowSubsidy.
  ///
  /// In en, this message translates to:
  /// **'Subsidy'**
  String get rowSubsidy;

  /// No description provided for @rowNet.
  ///
  /// In en, this message translates to:
  /// **'Customer pays'**
  String get rowNet;

  /// No description provided for @rowEmi.
  ///
  /// In en, this message translates to:
  /// **'EMI'**
  String get rowEmi;

  /// No description provided for @rowPayback.
  ///
  /// In en, this message translates to:
  /// **'Payback'**
  String get rowPayback;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get addProduct;

  /// No description provided for @editProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit product'**
  String get editProduct;

  /// No description provided for @productType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get productType;

  /// No description provided for @typePanel.
  ///
  /// In en, this message translates to:
  /// **'Panel'**
  String get typePanel;

  /// No description provided for @typeInverter.
  ///
  /// In en, this message translates to:
  /// **'Inverter'**
  String get typeInverter;

  /// No description provided for @typeStructure.
  ///
  /// In en, this message translates to:
  /// **'Structure'**
  String get typeStructure;

  /// No description provided for @typeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get typeOther;

  /// No description provided for @brandLabel.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get brandLabel;

  /// No description provided for @modelLabel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get modelLabel;

  /// No description provided for @wattPeakLabel.
  ///
  /// In en, this message translates to:
  /// **'Watt peak (Wp)'**
  String get wattPeakLabel;

  /// No description provided for @dcrLabel.
  ///
  /// In en, this message translates to:
  /// **'DCR (made-in-India cells)'**
  String get dcrLabel;

  /// No description provided for @almmLabel.
  ///
  /// In en, this message translates to:
  /// **'ALMM listed'**
  String get almmLabel;

  /// No description provided for @approvedListLabel.
  ///
  /// In en, this message translates to:
  /// **'On the approved inverter list'**
  String get approvedListLabel;

  /// No description provided for @warrantyLabel.
  ///
  /// In en, this message translates to:
  /// **'Warranty (years)'**
  String get warrantyLabel;

  /// No description provided for @unitPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price (₹)'**
  String get unitPriceLabel;

  /// No description provided for @activeLabel.
  ///
  /// In en, this message translates to:
  /// **'Available for proposals'**
  String get activeLabel;

  /// No description provided for @noProducts.
  ///
  /// In en, this message translates to:
  /// **'No products yet'**
  String get noProducts;

  /// No description provided for @noProductsBody.
  ///
  /// In en, this message translates to:
  /// **'Add the panels and inverters you sell. Only DCR and ALMM-listed panels get the subsidy.'**
  String get noProductsBody;

  /// No description provided for @deleteProduct.
  ///
  /// In en, this message translates to:
  /// **'Delete product'**
  String get deleteProduct;

  /// No description provided for @productSaved.
  ///
  /// In en, this message translates to:
  /// **'Product saved'**
  String get productSaved;

  /// No description provided for @ownerOnly.
  ///
  /// In en, this message translates to:
  /// **'Only the owner can change products.'**
  String get ownerOnly;

  /// No description provided for @newProposal.
  ///
  /// In en, this message translates to:
  /// **'New proposal'**
  String get newProposal;

  /// No description provided for @proposalVersion.
  ///
  /// In en, this message translates to:
  /// **'Proposal v{version}'**
  String proposalVersion(String version);

  /// No description provided for @statusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get statusDraft;

  /// No description provided for @statusSent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get statusSent;

  /// No description provided for @statusSigned.
  ///
  /// In en, this message translates to:
  /// **'Signed'**
  String get statusSigned;

  /// No description provided for @statusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get statusExpired;

  /// No description provided for @noProposalsTitle.
  ///
  /// In en, this message translates to:
  /// **'No proposals yet'**
  String get noProposalsTitle;

  /// No description provided for @noProposalsBody.
  ///
  /// In en, this message translates to:
  /// **'Create a proposal, share it on WhatsApp, take the signature and the advance.'**
  String get noProposalsBody;

  /// No description provided for @systemSection.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemSection;

  /// No description provided for @systemKwLabel.
  ///
  /// In en, this message translates to:
  /// **'System size (kW)'**
  String get systemKwLabel;

  /// No description provided for @panelLabel.
  ///
  /// In en, this message translates to:
  /// **'Panels'**
  String get panelLabel;

  /// No description provided for @inverterLabel.
  ///
  /// In en, this message translates to:
  /// **'Inverter'**
  String get inverterLabel;

  /// No description provided for @selectProduct.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get selectProduct;

  /// No description provided for @panelsNeeded.
  ///
  /// In en, this message translates to:
  /// **'{count} panels × {wp} Wp = {kw}'**
  String panelsNeeded(String count, String wp, String kw);

  /// No description provided for @priceSection.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get priceSection;

  /// No description provided for @grossPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'System price (₹)'**
  String get grossPriceLabel;

  /// No description provided for @languageForProposal.
  ///
  /// In en, this message translates to:
  /// **'Proposal language'**
  String get languageForProposal;

  /// No description provided for @complianceTitle.
  ///
  /// In en, this message translates to:
  /// **'Compliance checklist'**
  String get complianceTitle;

  /// No description provided for @checkPanelsDcr.
  ///
  /// In en, this message translates to:
  /// **'Panels are DCR (made-in-India cells)'**
  String get checkPanelsDcr;

  /// No description provided for @checkPanelsAlmm.
  ///
  /// In en, this message translates to:
  /// **'Panels are ALMM-listed'**
  String get checkPanelsAlmm;

  /// No description provided for @checkInverterApproved.
  ///
  /// In en, this message translates to:
  /// **'Inverter is on the approved list'**
  String get checkInverterApproved;

  /// No description provided for @checkOwnConnection.
  ///
  /// In en, this message translates to:
  /// **'Electricity connection is in the customer\'s own name'**
  String get checkOwnConnection;

  /// No description provided for @checkConsumerNumber.
  ///
  /// In en, this message translates to:
  /// **'Consumer number entered (customer registered on the national portal)'**
  String get checkConsumerNumber;

  /// No description provided for @checkRoofPhotos.
  ///
  /// In en, this message translates to:
  /// **'At least 4 site photos ({count} taken)'**
  String checkRoofPhotos(String count);

  /// No description provided for @checkRoofType.
  ///
  /// In en, this message translates to:
  /// **'Roof type recorded'**
  String get checkRoofType;

  /// No description provided for @checkSingleSubsidy.
  ///
  /// In en, this message translates to:
  /// **'No other subsidy on this consumer number'**
  String get checkSingleSubsidy;

  /// No description provided for @ownerOverride.
  ///
  /// In en, this message translates to:
  /// **'Owner override: allow sending anyway'**
  String get ownerOverride;

  /// No description provided for @complianceBlocked.
  ///
  /// In en, this message translates to:
  /// **'Finish the checklist before sending. Only the owner can override.'**
  String get complianceBlocked;

  /// No description provided for @saveDraft.
  ///
  /// In en, this message translates to:
  /// **'Save draft'**
  String get saveDraft;

  /// No description provided for @proposalSaved.
  ///
  /// In en, this message translates to:
  /// **'Proposal saved'**
  String get proposalSaved;

  /// No description provided for @actionsSection.
  ///
  /// In en, this message translates to:
  /// **'Share, sign and collect advance'**
  String get actionsSection;

  /// No description provided for @generatePdf.
  ///
  /// In en, this message translates to:
  /// **'Create PDF'**
  String get generatePdf;

  /// No description provided for @regeneratePdf.
  ///
  /// In en, this message translates to:
  /// **'Update PDF'**
  String get regeneratePdf;

  /// No description provided for @pdfReady.
  ///
  /// In en, this message translates to:
  /// **'PDF ready'**
  String get pdfReady;

  /// No description provided for @sharePdf.
  ///
  /// In en, this message translates to:
  /// **'Share PDF file'**
  String get sharePdf;

  /// No description provided for @shareWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'Send on WhatsApp'**
  String get shareWhatsapp;

  /// No description provided for @openPdf.
  ///
  /// In en, this message translates to:
  /// **'Open PDF'**
  String get openPdf;

  /// No description provided for @needsOnline.
  ///
  /// In en, this message translates to:
  /// **'This needs the internet. Connect and try again.'**
  String get needsOnline;

  /// No description provided for @captureSignature.
  ///
  /// In en, this message translates to:
  /// **'Take customer signature'**
  String get captureSignature;

  /// No description provided for @signHereHint.
  ///
  /// In en, this message translates to:
  /// **'Ask the customer to sign inside the box'**
  String get signHereHint;

  /// No description provided for @clearSignature.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearSignature;

  /// No description provided for @saveSignature.
  ///
  /// In en, this message translates to:
  /// **'Save signature'**
  String get saveSignature;

  /// No description provided for @signedOnDate.
  ///
  /// In en, this message translates to:
  /// **'Signed on {date}'**
  String signedOnDate(String date);

  /// No description provided for @paymentSection.
  ///
  /// In en, this message translates to:
  /// **'Advance payment'**
  String get paymentSection;

  /// No description provided for @advanceAmount.
  ///
  /// In en, this message translates to:
  /// **'Advance amount (₹)'**
  String get advanceAmount;

  /// No description provided for @createPaymentLink.
  ///
  /// In en, this message translates to:
  /// **'Create UPI payment link'**
  String get createPaymentLink;

  /// No description provided for @sendPaymentLink.
  ///
  /// In en, this message translates to:
  /// **'Send link on WhatsApp'**
  String get sendPaymentLink;

  /// No description provided for @paymentPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paymentPaid;

  /// No description provided for @paymentWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for payment'**
  String get paymentWaiting;

  /// No description provided for @paymentExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get paymentExpired;

  /// No description provided for @newVersion.
  ///
  /// In en, this message translates to:
  /// **'New version'**
  String get newVersion;

  /// No description provided for @proposalLocked.
  ///
  /// In en, this message translates to:
  /// **'This proposal has been sent, so it cannot be edited. Create a new version to change it.'**
  String get proposalLocked;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get copyLink;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get linkCopied;

  /// No description provided for @waitingToSync.
  ///
  /// In en, this message translates to:
  /// **'Saved on this phone. It will upload when online; then you can create the PDF.'**
  String get waitingToSync;

  /// No description provided for @netPriceShort.
  ///
  /// In en, this message translates to:
  /// **'Customer pays'**
  String get netPriceShort;

  /// No description provided for @tagNoSubsidy.
  ///
  /// In en, this message translates to:
  /// **'No subsidy'**
  String get tagNoSubsidy;

  /// No description provided for @tagApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get tagApproved;

  /// No description provided for @createProposal.
  ///
  /// In en, this message translates to:
  /// **'Create proposal'**
  String get createProposal;

  /// No description provided for @surveyTitle.
  ///
  /// In en, this message translates to:
  /// **'Roof survey'**
  String get surveyTitle;

  /// No description provided for @startSurvey.
  ///
  /// In en, this message translates to:
  /// **'Start roof survey'**
  String get startSurvey;

  /// No description provided for @editSurvey.
  ///
  /// In en, this message translates to:
  /// **'Edit roof survey'**
  String get editSurvey;

  /// No description provided for @drawRoofHint.
  ///
  /// In en, this message translates to:
  /// **'Tap each corner of the roof on the map'**
  String get drawRoofHint;

  /// No description provided for @undoPoint.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undoPoint;

  /// No description provided for @clearRoof.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearRoof;

  /// No description provided for @myLocation.
  ///
  /// In en, this message translates to:
  /// **'My location'**
  String get myLocation;

  /// No description provided for @needThreePoints.
  ///
  /// In en, this message translates to:
  /// **'Tap at least 3 corners to draw the roof'**
  String get needThreePoints;

  /// No description provided for @roofAreaResult.
  ///
  /// In en, this message translates to:
  /// **'Roof area'**
  String get roofAreaResult;

  /// No description provided for @panelsFit.
  ///
  /// In en, this message translates to:
  /// **'Panels that fit'**
  String get panelsFit;

  /// No description provided for @fittedKwLabel.
  ///
  /// In en, this message translates to:
  /// **'Panels fit'**
  String get fittedKwLabel;

  /// No description provided for @maxKwRoof.
  ///
  /// In en, this message translates to:
  /// **'Roof allows up to {kw}'**
  String maxKwRoof(String kw);

  /// No description provided for @roofTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Roof type'**
  String get roofTypeLabel;

  /// No description provided for @roofRcc.
  ///
  /// In en, this message translates to:
  /// **'RCC (concrete)'**
  String get roofRcc;

  /// No description provided for @roofTin.
  ///
  /// In en, this message translates to:
  /// **'Tin sheet'**
  String get roofTin;

  /// No description provided for @roofOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get roofOther;

  /// No description provided for @floorsLabel.
  ///
  /// In en, this message translates to:
  /// **'Floors'**
  String get floorsLabel;

  /// No description provided for @orientationLabel.
  ///
  /// In en, this message translates to:
  /// **'Panels face'**
  String get orientationLabel;

  /// No description provided for @tiltLabel.
  ///
  /// In en, this message translates to:
  /// **'Tilt'**
  String get tiltLabel;

  /// No description provided for @degreesValue.
  ///
  /// In en, this message translates to:
  /// **'{deg}°'**
  String degreesValue(String deg);

  /// No description provided for @dirN.
  ///
  /// In en, this message translates to:
  /// **'North'**
  String get dirN;

  /// No description provided for @dirNE.
  ///
  /// In en, this message translates to:
  /// **'North-east'**
  String get dirNE;

  /// No description provided for @dirE.
  ///
  /// In en, this message translates to:
  /// **'East'**
  String get dirE;

  /// No description provided for @dirSE.
  ///
  /// In en, this message translates to:
  /// **'South-east'**
  String get dirSE;

  /// No description provided for @dirS.
  ///
  /// In en, this message translates to:
  /// **'South'**
  String get dirS;

  /// No description provided for @dirSW.
  ///
  /// In en, this message translates to:
  /// **'South-west'**
  String get dirSW;

  /// No description provided for @dirW.
  ///
  /// In en, this message translates to:
  /// **'West'**
  String get dirW;

  /// No description provided for @dirNW.
  ///
  /// In en, this message translates to:
  /// **'North-west'**
  String get dirNW;

  /// No description provided for @saveSurvey.
  ///
  /// In en, this message translates to:
  /// **'Save survey'**
  String get saveSurvey;

  /// No description provided for @surveySaved.
  ///
  /// In en, this message translates to:
  /// **'Survey saved'**
  String get surveySaved;

  /// No description provided for @noSurveyTitle.
  ///
  /// In en, this message translates to:
  /// **'No roof survey yet'**
  String get noSurveyTitle;

  /// No description provided for @noSurveyBody.
  ///
  /// In en, this message translates to:
  /// **'Draw the roof on the satellite map to see how many panels fit.'**
  String get noSurveyBody;

  /// No description provided for @roofLimitWarning.
  ///
  /// In en, this message translates to:
  /// **'More than the roof allows ({kw}).'**
  String roofLimitWarning(String kw);

  /// No description provided for @photoKindRoofLayout.
  ///
  /// In en, this message translates to:
  /// **'Roof layout'**
  String get photoKindRoofLayout;

  /// No description provided for @surveyConfigMissing.
  ///
  /// In en, this message translates to:
  /// **'Panel settings haven\'t reached this device yet. Connect to the internet and open this again.'**
  String get surveyConfigMissing;

  /// No description provided for @noLocationHint.
  ///
  /// In en, this message translates to:
  /// **'This lead has no saved location. Use \"My location\" at the site, or move the map to the house.'**
  String get noLocationHint;

  /// No description provided for @stagePortalRegistration.
  ///
  /// In en, this message translates to:
  /// **'Registration on the national portal'**
  String get stagePortalRegistration;

  /// No description provided for @stageDiscomFeasibility.
  ///
  /// In en, this message translates to:
  /// **'DISCOM feasibility approval'**
  String get stageDiscomFeasibility;

  /// No description provided for @stageVendorSelected.
  ///
  /// In en, this message translates to:
  /// **'Vendor selected'**
  String get stageVendorSelected;

  /// No description provided for @stageInstallation.
  ///
  /// In en, this message translates to:
  /// **'Installation'**
  String get stageInstallation;

  /// No description provided for @stageNetMeterApplied.
  ///
  /// In en, this message translates to:
  /// **'Net meter applied'**
  String get stageNetMeterApplied;

  /// No description provided for @stageNetMeterInstalled.
  ///
  /// In en, this message translates to:
  /// **'Net meter installed'**
  String get stageNetMeterInstalled;

  /// No description provided for @stageInspection.
  ///
  /// In en, this message translates to:
  /// **'Inspection'**
  String get stageInspection;

  /// No description provided for @stageCommissioning.
  ///
  /// In en, this message translates to:
  /// **'Commissioning certificate'**
  String get stageCommissioning;

  /// No description provided for @stageSubsidyClaimed.
  ///
  /// In en, this message translates to:
  /// **'Subsidy claimed'**
  String get stageSubsidyClaimed;

  /// No description provided for @stageSubsidyCredited.
  ///
  /// In en, this message translates to:
  /// **'Subsidy credited'**
  String get stageSubsidyCredited;

  /// No description provided for @stagePending.
  ///
  /// In en, this message translates to:
  /// **'Not started'**
  String get stagePending;

  /// No description provided for @stageInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get stageInProgress;

  /// No description provided for @stageDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get stageDone;

  /// No description provided for @stageBlocked.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get stageBlocked;

  /// No description provided for @projectTitle.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get projectTitle;

  /// No description provided for @stageProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} of 10 stages done'**
  String stageProgress(String done);

  /// No description provided for @dueOn.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String dueOn(String date);

  /// No description provided for @doneOn.
  ///
  /// In en, this message translates to:
  /// **'Done {date}'**
  String doneOn(String date);

  /// No description provided for @markDone.
  ///
  /// In en, this message translates to:
  /// **'Mark done'**
  String get markDone;

  /// No description provided for @markBlocked.
  ///
  /// In en, this message translates to:
  /// **'Mark blocked'**
  String get markBlocked;

  /// No description provided for @resumeStage.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resumeStage;

  /// No description provided for @reopenStage.
  ///
  /// In en, this message translates to:
  /// **'Reopen'**
  String get reopenStage;

  /// No description provided for @blockedReason.
  ///
  /// In en, this message translates to:
  /// **'What is blocking this stage?'**
  String get blockedReason;

  /// No description provided for @stageNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get stageNote;

  /// No description provided for @addDocument.
  ///
  /// In en, this message translates to:
  /// **'Add document'**
  String get addDocument;

  /// No description provided for @sendStageUpdate.
  ///
  /// In en, this message translates to:
  /// **'Send update on WhatsApp'**
  String get sendStageUpdate;

  /// No description provided for @stageMarkedDone.
  ///
  /// In en, this message translates to:
  /// **'Stage marked done'**
  String get stageMarkedDone;

  /// No description provided for @trackingLink.
  ///
  /// In en, this message translates to:
  /// **'Customer tracking link'**
  String get trackingLink;

  /// No description provided for @shareTrackingLink.
  ///
  /// In en, this message translates to:
  /// **'Share link on WhatsApp'**
  String get shareTrackingLink;

  /// No description provided for @revokeLink.
  ///
  /// In en, this message translates to:
  /// **'Turn off link'**
  String get revokeLink;

  /// No description provided for @linkRevoked.
  ///
  /// In en, this message translates to:
  /// **'Link turned off'**
  String get linkRevoked;

  /// No description provided for @netMeterNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Net meter number'**
  String get netMeterNumberLabel;

  /// No description provided for @commissioningDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Commissioning date'**
  String get commissioningDateLabel;

  /// No description provided for @subsidyReceivedLabel.
  ///
  /// In en, this message translates to:
  /// **'Subsidy received (₹)'**
  String get subsidyReceivedLabel;

  /// No description provided for @installersLabel.
  ///
  /// In en, this message translates to:
  /// **'Installers'**
  String get installersLabel;

  /// No description provided for @noProjectYet.
  ///
  /// In en, this message translates to:
  /// **'The project starts when the customer signs the proposal.'**
  String get noProjectYet;

  /// No description provided for @openProject.
  ///
  /// In en, this message translates to:
  /// **'Open project'**
  String get openProject;

  /// No description provided for @projectComplete.
  ///
  /// In en, this message translates to:
  /// **'Project complete'**
  String get projectComplete;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotifications;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @notifProjectCreated.
  ///
  /// In en, this message translates to:
  /// **'Proposal signed. Project started ({kw}).'**
  String notifProjectCreated(String kw);

  /// No description provided for @notifStageDone.
  ///
  /// In en, this message translates to:
  /// **'Stage done: {stage}'**
  String notifStageDone(String stage);

  /// No description provided for @kpiActiveProjects.
  ///
  /// In en, this message translates to:
  /// **'Active projects'**
  String get kpiActiveProjects;

  /// No description provided for @projectsByStage.
  ///
  /// In en, this message translates to:
  /// **'Projects by stage'**
  String get projectsByStage;

  /// No description provided for @daysInStage.
  ///
  /// In en, this message translates to:
  /// **'{days} days in this stage'**
  String daysInStage(String days);

  /// No description provided for @overdueTitle.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdueTitle;

  /// No description provided for @allOnTrack.
  ///
  /// In en, this message translates to:
  /// **'Everything is on track.'**
  String get allOnTrack;

  /// No description provided for @expectedSubsidyLabel.
  ///
  /// In en, this message translates to:
  /// **'Expected subsidy'**
  String get expectedSubsidyLabel;

  /// No description provided for @inviteMember.
  ///
  /// In en, this message translates to:
  /// **'Invite member'**
  String get inviteMember;

  /// No description provided for @inviteSent.
  ///
  /// In en, this message translates to:
  /// **'Invite saved. Ask them to log in with this number.'**
  String get inviteSent;

  /// No description provided for @pendingInvites.
  ///
  /// In en, this message translates to:
  /// **'Pending invites'**
  String get pendingInvites;

  /// No description provided for @cancelInvite.
  ///
  /// In en, this message translates to:
  /// **'Cancel invite'**
  String get cancelInvite;

  /// No description provided for @deactivate.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get deactivate;

  /// No description provided for @activate.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get activate;

  /// No description provided for @performanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get performanceTitle;

  /// No description provided for @leadsCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Leads'**
  String get leadsCountLabel;

  /// No description provided for @wonCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Won'**
  String get wonCountLabel;

  /// No description provided for @inactiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactiveLabel;

  /// No description provided for @youLabel.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get youLabel;

  /// No description provided for @ownerOnlyHint.
  ///
  /// In en, this message translates to:
  /// **'Only the owner can change this.'**
  String get ownerOnlyHint;

  /// No description provided for @appSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'App settings'**
  String get appSettingsTitle;

  /// No description provided for @loanPresetsTitle.
  ///
  /// In en, this message translates to:
  /// **'Loan options'**
  String get loanPresetsTitle;

  /// No description provided for @subsidyRulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Subsidy rules'**
  String get subsidyRulesTitle;

  /// No description provided for @tariffsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tariffs'**
  String get tariffsTitle;

  /// No description provided for @configCompanyNote.
  ///
  /// In en, this message translates to:
  /// **'Changes apply to your company only. The defaults stay as they are.'**
  String get configCompanyNote;

  /// No description provided for @validFromLabel.
  ///
  /// In en, this message translates to:
  /// **'Valid from'**
  String get validFromLabel;

  /// No description provided for @slabsLabel.
  ///
  /// In en, this message translates to:
  /// **'Slabs'**
  String get slabsLabel;

  /// No description provided for @capLabel.
  ///
  /// In en, this message translates to:
  /// **'Cap (₹)'**
  String get capLabel;

  /// No description provided for @uptoKwLabel.
  ///
  /// In en, this message translates to:
  /// **'Up to kW'**
  String get uptoKwLabel;

  /// No description provided for @perKwLabel.
  ///
  /// In en, this message translates to:
  /// **'₹ per kW'**
  String get perKwLabel;

  /// No description provided for @uptoUnitsLabel.
  ///
  /// In en, this message translates to:
  /// **'Up to units'**
  String get uptoUnitsLabel;

  /// No description provided for @rateLabel.
  ///
  /// In en, this message translates to:
  /// **'₹ per unit'**
  String get rateLabel;

  /// No description provided for @fixedChargeLabel.
  ///
  /// In en, this message translates to:
  /// **'Fixed charge (₹/month)'**
  String get fixedChargeLabel;

  /// No description provided for @bankNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Bank / lender'**
  String get bankNameLabel;

  /// No description provided for @maxYearsLabel.
  ///
  /// In en, this message translates to:
  /// **'Max years'**
  String get maxYearsLabel;

  /// No description provided for @addRow.
  ///
  /// In en, this message translates to:
  /// **'Add row'**
  String get addRow;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addItem;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @overridden.
  ///
  /// In en, this message translates to:
  /// **'Your value'**
  String get overridden;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressLabel;

  /// No description provided for @gstinLabel.
  ///
  /// In en, this message translates to:
  /// **'GSTIN'**
  String get gstinLabel;

  /// No description provided for @brandColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Brand colour'**
  String get brandColorLabel;

  /// No description provided for @mnreVendorIdLabel.
  ///
  /// In en, this message translates to:
  /// **'MNRE vendor ID'**
  String get mnreVendorIdLabel;

  /// No description provided for @companyPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Company phone'**
  String get companyPhoneLabel;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get exportCsv;

  /// No description provided for @trackHello.
  ///
  /// In en, this message translates to:
  /// **'Namaste {name}'**
  String trackHello(String name);

  /// No description provided for @trackSystem.
  ///
  /// In en, this message translates to:
  /// **'Your {kw} rooftop solar system'**
  String trackSystem(String kw);

  /// No description provided for @trackDownloadPdf.
  ///
  /// In en, this message translates to:
  /// **'Download proposal (PDF)'**
  String get trackDownloadPdf;

  /// No description provided for @trackSign.
  ///
  /// In en, this message translates to:
  /// **'Sign the proposal'**
  String get trackSign;

  /// No description provided for @trackSigned.
  ///
  /// In en, this message translates to:
  /// **'Signed. Thank you!'**
  String get trackSigned;

  /// No description provided for @trackPay.
  ///
  /// In en, this message translates to:
  /// **'Pay advance {amount}'**
  String trackPay(String amount);

  /// No description provided for @trackPaid.
  ///
  /// In en, this message translates to:
  /// **'Advance paid'**
  String get trackPaid;

  /// No description provided for @trackStagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get trackStagesTitle;

  /// No description provided for @trackNotFound.
  ///
  /// In en, this message translates to:
  /// **'This link is not valid or has been turned off.'**
  String get trackNotFound;

  /// No description provided for @trackSignHint.
  ///
  /// In en, this message translates to:
  /// **'Sign inside the box with your finger'**
  String get trackSignHint;

  /// No description provided for @trackSubmitSignature.
  ///
  /// In en, this message translates to:
  /// **'Submit signature'**
  String get trackSubmitSignature;

  /// No description provided for @trackCallCompany.
  ///
  /// In en, this message translates to:
  /// **'Call {company}'**
  String trackCallCompany(String company);

  /// No description provided for @trackSubsidyLine.
  ///
  /// In en, this message translates to:
  /// **'Subsidy {subsidy} · You pay {net}'**
  String trackSubsidyLine(String subsidy, String net);

  /// No description provided for @trackNotStarted.
  ///
  /// In en, this message translates to:
  /// **'Work starts after you sign the proposal.'**
  String get trackNotStarted;

  /// No description provided for @invalidJson.
  ///
  /// In en, this message translates to:
  /// **'Not valid. Use the same format as before, e.g. [ ... ]'**
  String get invalidJson;

  /// No description provided for @panelLengthLabel.
  ///
  /// In en, this message translates to:
  /// **'Panel length (m)'**
  String get panelLengthLabel;

  /// No description provided for @panelWidthLabel.
  ///
  /// In en, this message translates to:
  /// **'Panel width (m)'**
  String get panelWidthLabel;

  /// No description provided for @panelSizeHint.
  ///
  /// In en, this message translates to:
  /// **'From the datasheet, e.g. 2.384 × 1.303 for 710 W. Used by the roof survey.'**
  String get panelSizeHint;

  /// No description provided for @demoTitle.
  ///
  /// In en, this message translates to:
  /// **'Try the demo'**
  String get demoTitle;

  /// No description provided for @demoBody.
  ///
  /// In en, this message translates to:
  /// **'No SMS needed. Pick a role; it signs in with a test number (code 123456). Demo data resets every Monday.'**
  String get demoBody;

  /// No description provided for @demoAsOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get demoAsOwner;

  /// No description provided for @demoAsSales.
  ///
  /// In en, this message translates to:
  /// **'Sales rep'**
  String get demoAsSales;

  /// No description provided for @demoAsInstaller.
  ///
  /// In en, this message translates to:
  /// **'Installer'**
  String get demoAsInstaller;

  /// No description provided for @landingHeadline.
  ///
  /// In en, this message translates to:
  /// **'Sell rooftop solar faster, from first visit to subsidy credit.'**
  String get landingHeadline;

  /// No description provided for @landingF1.
  ///
  /// In en, this message translates to:
  /// **'Scan an electricity bill with AI and size the system in seconds'**
  String get landingF1;

  /// No description provided for @landingF2.
  ///
  /// In en, this message translates to:
  /// **'Draw the roof on satellite imagery; panels fit automatically'**
  String get landingF2;

  /// No description provided for @landingF3.
  ///
  /// In en, this message translates to:
  /// **'Hindi and English proposals as PDF, shared on WhatsApp, signed on the phone'**
  String get landingF3;

  /// No description provided for @landingF4.
  ///
  /// In en, this message translates to:
  /// **'UPI advance payment links that mark themselves paid'**
  String get landingF4;

  /// No description provided for @landingF5.
  ///
  /// In en, this message translates to:
  /// **'Track all 10 PM Surya Ghar subsidy stages; customers get a live link'**
  String get landingF5;

  /// No description provided for @landingF6.
  ///
  /// In en, this message translates to:
  /// **'Works offline at the site and syncs when back online'**
  String get landingF6;

  /// No description provided for @downloadApk.
  ///
  /// In en, this message translates to:
  /// **'Download Android app'**
  String get downloadApk;

  /// No description provided for @searchPlaceHint.
  ///
  /// In en, this message translates to:
  /// **'Search address or place'**
  String get searchPlaceHint;

  /// No description provided for @detectRoof.
  ///
  /// In en, this message translates to:
  /// **'Detect roof (Google)'**
  String get detectRoof;

  /// No description provided for @roofDetected.
  ///
  /// In en, this message translates to:
  /// **'Google found this roof. Drag the map and adjust corners if needed.'**
  String get roofDetected;

  /// No description provided for @roofNotFound.
  ///
  /// In en, this message translates to:
  /// **'Google has no roof data here. Tap the roof corners to draw it.'**
  String get roofNotFound;

  /// No description provided for @googleRoofInfo.
  ///
  /// In en, this message translates to:
  /// **'Google: {panels} panels fit · {hours} sun hours/year · photo {date}'**
  String googleRoofInfo(String panels, String hours, String date);

  /// No description provided for @addressLocated.
  ///
  /// In en, this message translates to:
  /// **'Map moved to the lead\'s address. Check it is the right house.'**
  String get addressLocated;

  /// No description provided for @addressNotFound.
  ///
  /// In en, this message translates to:
  /// **'Could not find this address on the map. Search or use My location.'**
  String get addressNotFound;
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
      <String>['en', 'hi'].contains(locale.languageCode);

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
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
