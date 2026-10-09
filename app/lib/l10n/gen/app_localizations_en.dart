// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SolarKatha';

  @override
  String get appTagline => 'Rooftop solar, from site visit to subsidy';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHindi => 'हिंदी';

  @override
  String get languageLabel => 'Language';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginSubtitle =>
      'We will send a one-time code to your mobile number.';

  @override
  String get loginEmailSubtitle =>
      'Owners can sign in with a code sent to their email.';

  @override
  String get phoneLabel => 'Mobile number';

  @override
  String get phoneHint => '10-digit mobile number';

  @override
  String get emailLabel => 'Email';

  @override
  String get sendOtp => 'Send code';

  @override
  String get otpLabel => '6-digit code';

  @override
  String get verifyOtp => 'Verify and continue';

  @override
  String otpSentTo(String destination) {
    return 'Code sent to $destination';
  }

  @override
  String get changeNumber => 'Change';

  @override
  String get resendOtp => 'Resend code';

  @override
  String get useEmailInstead => 'Owner? Sign in with email';

  @override
  String get usePhoneInstead => 'Sign in with mobile number';

  @override
  String get invalidPhone => 'Enter a valid 10-digit Indian mobile number';

  @override
  String get invalidEmail => 'Enter a valid email address';

  @override
  String get invalidOtp => 'Enter the 6-digit code';

  @override
  String get otpIncorrect =>
      'The code is wrong or has expired. Try again or resend.';

  @override
  String get onboardingTitle => 'Set up your company';

  @override
  String get onboardingSubtitle =>
      'No team invite was found for this account. Create your company to continue as its owner. If your employer uses SolarKatha, ask them to invite this number.';

  @override
  String get yourNameLabel => 'Your name';

  @override
  String get companyNameLabel => 'Company name';

  @override
  String get stateLabel => 'State';

  @override
  String get createCompany => 'Create company';

  @override
  String get requiredField => 'Required';

  @override
  String get deactivatedTitle => 'Account deactivated';

  @override
  String get deactivatedBody =>
      'Your company owner has deactivated this account. Contact them to get access again.';

  @override
  String get signOut => 'Sign out';

  @override
  String get loading => 'Loading…';

  @override
  String get retry => 'Retry';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorNetwork =>
      'No internet connection. Check your network and try again.';

  @override
  String get comingSoon => 'Coming in a later update';

  @override
  String get roleOwner => 'Owner';

  @override
  String get roleSales => 'Sales';

  @override
  String get roleInstaller => 'Installer';

  @override
  String get navHome => 'Home';

  @override
  String get navLeads => 'Leads';

  @override
  String get navProjects => 'Projects';

  @override
  String get navSettings => 'Settings';

  @override
  String get navOverview => 'Overview';

  @override
  String get navSubsidy => 'Subsidy tracker';

  @override
  String get navTeam => 'Team';

  @override
  String get navProducts => 'Products';

  @override
  String get navConfig => 'Config';

  @override
  String get navBranding => 'Branding';

  @override
  String greeting(String name) {
    return 'Namaste, $name';
  }

  @override
  String get newLead => 'New lead';

  @override
  String get followUpsToday => 'Today\'s follow-ups';

  @override
  String get noFollowUps => 'No follow-ups today';

  @override
  String get leadsByStatus => 'Leads by status';

  @override
  String get statusNew => 'New';

  @override
  String get statusSurveyed => 'Surveyed';

  @override
  String get statusProposalSent => 'Proposal sent';

  @override
  String get statusWon => 'Won';

  @override
  String get statusLost => 'Lost';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String get searchLeads => 'Search by name or phone';

  @override
  String get leadsEmptyTitle => 'No leads yet';

  @override
  String get leadsEmptyBody =>
      'Leads you add will appear here, even when you are offline.';

  @override
  String get projectsEmptyTitle => 'No projects yet';

  @override
  String get projectsEmptyBody =>
      'Projects appear here once a customer signs a proposal and you are assigned to it.';

  @override
  String get kpiLeadsThisMonth => 'Leads this month';

  @override
  String get kpiConversion => 'Conversion rate';

  @override
  String get kpiKwSold => 'kW sold';

  @override
  String get kpiRevenue => 'Revenue';

  @override
  String get kpiSubsidiesPending => 'Subsidies pending';

  @override
  String get pipelineTitle => 'Pipeline';

  @override
  String get dashboardEmpty =>
      'Numbers appear here once your team starts adding leads.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get profileSection => 'Profile';

  @override
  String get nameLabel => 'Name';

  @override
  String get roleLabel => 'Role';

  @override
  String get companyLabel => 'Company';

  @override
  String get displaySection => 'Display';

  @override
  String get highContrast => 'High contrast';

  @override
  String get highContrastHint => 'Stronger colours for bright sunlight';

  @override
  String get largeText => 'Large text';

  @override
  String get largeTextHint => 'Bigger letters across the app';

  @override
  String get syncSection => 'Sync';

  @override
  String get syncStatusOnline => 'Connected to server';

  @override
  String get save => 'Save';

  @override
  String get saved => 'Saved';

  @override
  String get trackingTitle => 'Track your solar project';

  @override
  String get trackingComingSoon =>
      'Your installer will share project updates on this page.';

  @override
  String get notFoundTitle => 'Page not found';

  @override
  String get goHome => 'Go to home';

  @override
  String get configMissingTitle => 'App not configured';

  @override
  String get configMissingBody =>
      'Supabase URL and key are missing. Build with --dart-define-from-file=env/dev.json (see README).';

  @override
  String get editLead => 'Edit lead';

  @override
  String get saveLead => 'Save lead';

  @override
  String get leadSaved => 'Lead saved';

  @override
  String get leadDeleted => 'Lead deleted';

  @override
  String get deleteLead => 'Delete lead';

  @override
  String get deleteLeadConfirm =>
      'Delete this lead? It will be removed from all devices.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get customerSection => 'Customer';

  @override
  String get addressSection => 'Address & location';

  @override
  String get followUpSection => 'Follow-up';

  @override
  String get leadNameLabel => 'Customer name';

  @override
  String get leadPhoneLabel => 'Mobile number';

  @override
  String get leadAltPhoneLabel => 'Alternate number (optional)';

  @override
  String get leadAddressLabel => 'House / street / area';

  @override
  String get leadDistrictLabel => 'District';

  @override
  String get leadPincodeLabel => 'PIN code';

  @override
  String get invalidPincode => 'Enter a 6-digit PIN code';

  @override
  String get leadSourceLabel => 'Source';

  @override
  String get sourceWalkIn => 'Walk-in';

  @override
  String get sourceReferral => 'Referral';

  @override
  String get sourceCall => 'Phone call';

  @override
  String get sourceCampaign => 'Campaign';

  @override
  String get leadNotesLabel => 'Notes';

  @override
  String get followUpLabel => 'Next follow-up';

  @override
  String get followUpNone => 'Not set';

  @override
  String get clear => 'Clear';

  @override
  String get assignedToLabel => 'Assigned to';

  @override
  String get captureLocation => 'Use my current location';

  @override
  String get locationCaptured => 'Location saved';

  @override
  String get locationFailed =>
      'Couldn\'t get location. Turn on GPS and allow location access.';

  @override
  String get consentLabel =>
      'Customer agrees to share their electricity bill and site photos with us';

  @override
  String get consentRequiredForPhotos =>
      'Record the customer\'s consent (Edit lead) before adding photos.';

  @override
  String get draftRestored => 'Unsaved draft restored';

  @override
  String get discardDraft => 'Discard';

  @override
  String get call => 'Call';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get directions => 'Directions';

  @override
  String get notSynced => 'Not synced';

  @override
  String get allStatuses => 'All';

  @override
  String get allReps => 'Everyone';

  @override
  String get leadNotFound => 'This lead no longer exists.';

  @override
  String get changeStatus => 'Change status';

  @override
  String get lostReasonLabel => 'Why was it lost?';

  @override
  String get tabOverview => 'Overview';

  @override
  String get tabBill => 'Bill';

  @override
  String get tabSurvey => 'Survey';

  @override
  String get tabProposals => 'Proposals';

  @override
  String get tabProject => 'Project';

  @override
  String get photosTitle => 'Site photos';

  @override
  String photosChecklist(int done, int total) {
    return '$done of $total checklist photos';
  }

  @override
  String get takePhoto => 'Take photo';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get photoKindRoof => 'Roof';

  @override
  String get photoKindMeter => 'Meter';

  @override
  String get photoKindDbBox => 'DB box';

  @override
  String get photoKindWiring => 'Wiring path';

  @override
  String get photoKindBill => 'Electricity bill';

  @override
  String get photoKindOther => 'Other';

  @override
  String get photoWaiting => 'Waiting to upload';

  @override
  String get deletePhoto => 'Delete photo';

  @override
  String get noResults => 'No leads match your search.';

  @override
  String addedOn(String date) {
    return 'Added $date';
  }

  @override
  String followUpOn(String date) {
    return 'Follow up $date';
  }

  @override
  String get overdue => 'Overdue';

  @override
  String get totalLeads => 'Total leads';

  @override
  String get openLeads => 'Open';

  @override
  String get wonLeads => 'Won';

  @override
  String get offlineBanner =>
      'You\'re offline. Everything you do is saved on this phone and will sync automatically.';

  @override
  String get syncing => 'Syncing…';

  @override
  String syncedAt(String time) {
    return 'Last synced $time';
  }

  @override
  String get neverSynced => 'Not synced yet';

  @override
  String get syncNotConfigured =>
      'Sync is not set up in this build; data stays on this device.';

  @override
  String pendingChanges(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes waiting to upload',
      one: '1 change waiting to upload',
      zero: 'All changes uploaded',
    );
    return '$_temp0';
  }

  @override
  String get scanBill => 'Scan bill';

  @override
  String get enterBillManually => 'Enter manually';

  @override
  String get scanQueued =>
      'Bill photo saved. It will be read automatically when the phone is online.';

  @override
  String get scanReady => 'Bill read. Tap to check and confirm.';

  @override
  String scanFailed(String error) {
    return 'Couldn\'t read the bill: $error';
  }

  @override
  String get retry2 => 'Try again';

  @override
  String get reviewScan => 'Review';

  @override
  String get discardScan => 'Discard';

  @override
  String get noBillsTitle => 'No bill yet';

  @override
  String get noBillsBody =>
      'Scan the customer\'s electricity bill, or type the values from it.';

  @override
  String get billFromScan => 'Read by AI';

  @override
  String get billManual => 'Typed in';

  @override
  String avgUnitsShort(String units) {
    return '$units units/month';
  }

  @override
  String get sizeSystem => 'Size the system';

  @override
  String get sizingCta => 'See system size, subsidy, EMI and payback';

  @override
  String get billFormTitle => 'Electricity bill';

  @override
  String get confirmBill => 'Confirm bill';

  @override
  String get billSaved => 'Bill saved';

  @override
  String get deleteBill => 'Delete bill';

  @override
  String get discomLabel => 'DISCOM';

  @override
  String get consumerNumberLabel => 'Consumer number';

  @override
  String get billCustomerNameLabel => 'Name on bill';

  @override
  String get tariffCategoryLabel => 'Tariff category';

  @override
  String get sanctionedLoadLabel => 'Sanctioned load (kW)';

  @override
  String get billingPeriodLabel => 'Billing period';

  @override
  String get avgUnitsLabel => 'Average monthly units (kWh)';

  @override
  String get billAmountLabel => 'Bill amount (₹)';

  @override
  String get unitsHistoryTitle => 'Monthly units printed on the bill';

  @override
  String get checkThisField => 'Please check: the AI was not sure';

  @override
  String get duplicateConsumer =>
      'This consumer number is already on another lead. Only one central subsidy is allowed per household.';

  @override
  String get invalidNumber => 'Enter a valid number';

  @override
  String get sizingTitle => 'System sizing';

  @override
  String get usageSection => 'Customer usage';

  @override
  String get roofAreaLabel => 'Usable roof area (m², optional)';

  @override
  String get shadingLabel => 'Shading';

  @override
  String get shadingNone => 'None';

  @override
  String get shadingLow => 'Low';

  @override
  String get shadingMedium => 'Medium';

  @override
  String get shadingHigh => 'High';

  @override
  String get dcrPanels => 'DCR & ALMM-listed panels';

  @override
  String get dcrHint => 'Required for the subsidy';

  @override
  String get recommendedLabel => 'Recommended';

  @override
  String recommendedKw(String kw) {
    return 'Recommended: $kw';
  }

  @override
  String requiredKwNote(String units) {
    return 'Covers about $units units a month';
  }

  @override
  String exceedsLoad(String load) {
    return 'Above the sanctioned load ($load kW). The customer may need a load increase.';
  }

  @override
  String limitedByRoof(String kw) {
    return 'Limited by roof area (max $kw).';
  }

  @override
  String get compareTitle => 'Compare sizes';

  @override
  String get customSize => 'Custom';

  @override
  String get generationTitle => 'Monthly generation';

  @override
  String get generationPvgis => 'Based on PVGIS solar data for this location';

  @override
  String generationFallback(String kwh) {
    return 'Estimate ($kwh units per kW per day). Add the site location and go online for a location-based figure.';
  }

  @override
  String perYear(String kwh) {
    return '$kwh units a year';
  }

  @override
  String get subsidySection => 'Subsidy';

  @override
  String get centralSubsidy => 'Central (PM Surya Ghar)';

  @override
  String get stateSubsidy => 'State top-up';

  @override
  String get totalSubsidy => 'Total subsidy';

  @override
  String subsidyPerKw(String amount) {
    return 'About $amount per kW';
  }

  @override
  String subsidyLine(String from, String to, String rate) {
    return '$from–$to kW × $rate';
  }

  @override
  String get noSubsidyNonDcr =>
      'No subsidy: panels must be DCR and ALMM-listed.';

  @override
  String get costSection => 'Cost';

  @override
  String get grossPrice => 'System price';

  @override
  String get pricePerKwLabel => 'Price per kW (₹)';

  @override
  String get netPrice => 'Customer pays after subsidy';

  @override
  String get loanSection => 'Loan & EMI';

  @override
  String get loanBank => 'Loan option';

  @override
  String get interestRate => 'Interest % a year';

  @override
  String get tenureYears => 'Years';

  @override
  String get loanAmountLabel => 'Loan amount (₹)';

  @override
  String get emiLabel => 'EMI';

  @override
  String get currentBillLabel => 'Current bill';

  @override
  String get perMonth => 'a month';

  @override
  String get emiVsBillGood => 'EMI is lower than today\'s bill';

  @override
  String get savingsSection => 'Savings';

  @override
  String get monthlySaving => 'Saving a month (year 1)';

  @override
  String get paybackLabel => 'Payback';

  @override
  String paybackYears(String years) {
    return '$years years';
  }

  @override
  String noPayback(String years) {
    return 'More than $years years';
  }

  @override
  String lifetimeSavings(String years) {
    return '$years-year savings';
  }

  @override
  String get configMissing =>
      'Pricing settings haven\'t reached this device yet. Connect to the internet and open this again.';

  @override
  String get noTariffUsingBill =>
      'No tariff for this state yet; using the average rate from the bill.';

  @override
  String get noTariff =>
      'Add the bill amount (or a tariff for this state) to see savings.';

  @override
  String get needUsage => 'Enter the average monthly units to size the system.';

  @override
  String get rowGeneration => 'Units / month';

  @override
  String get rowSubsidy => 'Subsidy';

  @override
  String get rowNet => 'Customer pays';

  @override
  String get rowEmi => 'EMI';

  @override
  String get rowPayback => 'Payback';

  @override
  String get addProduct => 'Add product';

  @override
  String get editProduct => 'Edit product';

  @override
  String get productType => 'Type';

  @override
  String get typePanel => 'Panel';

  @override
  String get typeInverter => 'Inverter';

  @override
  String get typeStructure => 'Structure';

  @override
  String get typeOther => 'Other';

  @override
  String get brandLabel => 'Brand';

  @override
  String get modelLabel => 'Model';

  @override
  String get wattPeakLabel => 'Watt peak (Wp)';

  @override
  String get dcrLabel => 'DCR (made-in-India cells)';

  @override
  String get almmLabel => 'ALMM listed';

  @override
  String get approvedListLabel => 'On the approved inverter list';

  @override
  String get warrantyLabel => 'Warranty (years)';

  @override
  String get unitPriceLabel => 'Price (₹)';

  @override
  String get activeLabel => 'Available for proposals';

  @override
  String get noProducts => 'No products yet';

  @override
  String get noProductsBody =>
      'Add the panels and inverters you sell. Only DCR and ALMM-listed panels get the subsidy.';

  @override
  String get deleteProduct => 'Delete product';

  @override
  String get productSaved => 'Product saved';

  @override
  String get ownerOnly => 'Only the owner can change products.';

  @override
  String get newProposal => 'New proposal';

  @override
  String proposalVersion(String version) {
    return 'Proposal v$version';
  }

  @override
  String get statusDraft => 'Draft';

  @override
  String get statusSent => 'Sent';

  @override
  String get statusSigned => 'Signed';

  @override
  String get statusExpired => 'Expired';

  @override
  String get noProposalsTitle => 'No proposals yet';

  @override
  String get noProposalsBody =>
      'Create a proposal, share it on WhatsApp, take the signature and the advance.';

  @override
  String get systemSection => 'System';

  @override
  String get systemKwLabel => 'System size (kW)';

  @override
  String get panelLabel => 'Panels';

  @override
  String get inverterLabel => 'Inverter';

  @override
  String get selectProduct => 'Select';

  @override
  String panelsNeeded(String count, String wp, String kw) {
    return '$count panels × $wp Wp = $kw';
  }

  @override
  String get priceSection => 'Price';

  @override
  String get grossPriceLabel => 'System price (₹)';

  @override
  String get languageForProposal => 'Proposal language';

  @override
  String get complianceTitle => 'Compliance checklist';

  @override
  String get checkPanelsDcr => 'Panels are DCR (made-in-India cells)';

  @override
  String get checkPanelsAlmm => 'Panels are ALMM-listed';

  @override
  String get checkInverterApproved => 'Inverter is on the approved list';

  @override
  String get checkOwnConnection =>
      'Electricity connection is in the customer\'s own name';

  @override
  String get checkConsumerNumber =>
      'Consumer number entered (customer registered on the national portal)';

  @override
  String checkRoofPhotos(String count) {
    return 'At least 4 site photos ($count taken)';
  }

  @override
  String get checkRoofType => 'Roof type recorded';

  @override
  String get checkSingleSubsidy => 'No other subsidy on this consumer number';

  @override
  String get ownerOverride => 'Owner override: allow sending anyway';

  @override
  String get complianceBlocked =>
      'Finish the checklist before sending. Only the owner can override.';

  @override
  String get saveDraft => 'Save draft';

  @override
  String get proposalSaved => 'Proposal saved';

  @override
  String get actionsSection => 'Share, sign and collect advance';

  @override
  String get generatePdf => 'Create PDF';

  @override
  String get regeneratePdf => 'Update PDF';

  @override
  String get pdfReady => 'PDF ready';

  @override
  String get sharePdf => 'Share PDF file';

  @override
  String get shareWhatsapp => 'Send on WhatsApp';

  @override
  String get openPdf => 'Open PDF';

  @override
  String get needsOnline => 'This needs the internet. Connect and try again.';

  @override
  String get captureSignature => 'Take customer signature';

  @override
  String get signHereHint => 'Ask the customer to sign inside the box';

  @override
  String get clearSignature => 'Clear';

  @override
  String get saveSignature => 'Save signature';

  @override
  String signedOnDate(String date) {
    return 'Signed on $date';
  }

  @override
  String get paymentSection => 'Advance payment';

  @override
  String get advanceAmount => 'Advance amount (₹)';

  @override
  String get createPaymentLink => 'Create UPI payment link';

  @override
  String get sendPaymentLink => 'Send link on WhatsApp';

  @override
  String get paymentPaid => 'Paid';

  @override
  String get paymentWaiting => 'Waiting for payment';

  @override
  String get paymentExpired => 'Expired';

  @override
  String get newVersion => 'New version';

  @override
  String get proposalLocked =>
      'This proposal has been sent, so it cannot be edited. Create a new version to change it.';

  @override
  String get copyLink => 'Copy link';

  @override
  String get linkCopied => 'Link copied';

  @override
  String get waitingToSync =>
      'Saved on this phone. It will upload when online; then you can create the PDF.';

  @override
  String get netPriceShort => 'Customer pays';

  @override
  String get tagNoSubsidy => 'No subsidy';

  @override
  String get tagApproved => 'Approved';

  @override
  String get createProposal => 'Create proposal';

  @override
  String get surveyTitle => 'Roof survey';

  @override
  String get startSurvey => 'Start roof survey';

  @override
  String get editSurvey => 'Edit roof survey';

  @override
  String get drawRoofHint => 'Tap each corner of the roof on the map';

  @override
  String get undoPoint => 'Undo';

  @override
  String get clearRoof => 'Clear';

  @override
  String get myLocation => 'My location';

  @override
  String get needThreePoints => 'Tap at least 3 corners to draw the roof';

  @override
  String get roofAreaResult => 'Roof area';

  @override
  String get panelsFit => 'Panels that fit';

  @override
  String get fittedKwLabel => 'Panels fit';

  @override
  String maxKwRoof(String kw) {
    return 'Roof allows up to $kw';
  }

  @override
  String get roofTypeLabel => 'Roof type';

  @override
  String get roofRcc => 'RCC (concrete)';

  @override
  String get roofTin => 'Tin sheet';

  @override
  String get roofOther => 'Other';

  @override
  String get floorsLabel => 'Floors';

  @override
  String get orientationLabel => 'Panels face';

  @override
  String get tiltLabel => 'Tilt';

  @override
  String degreesValue(String deg) {
    return '$deg°';
  }

  @override
  String get dirN => 'North';

  @override
  String get dirNE => 'North-east';

  @override
  String get dirE => 'East';

  @override
  String get dirSE => 'South-east';

  @override
  String get dirS => 'South';

  @override
  String get dirSW => 'South-west';

  @override
  String get dirW => 'West';

  @override
  String get dirNW => 'North-west';

  @override
  String get saveSurvey => 'Save survey';

  @override
  String get surveySaved => 'Survey saved';

  @override
  String get noSurveyTitle => 'No roof survey yet';

  @override
  String get noSurveyBody =>
      'Draw the roof on the satellite map to see how many panels fit.';

  @override
  String roofLimitWarning(String kw) {
    return 'More than the roof allows ($kw).';
  }

  @override
  String get photoKindRoofLayout => 'Roof layout';

  @override
  String get surveyConfigMissing =>
      'Panel settings haven\'t reached this device yet. Connect to the internet and open this again.';

  @override
  String get noLocationHint =>
      'This lead has no saved location. Use \"My location\" at the site, or move the map to the house.';

  @override
  String get stagePortalRegistration => 'Registration on the national portal';

  @override
  String get stageDiscomFeasibility => 'DISCOM feasibility approval';

  @override
  String get stageVendorSelected => 'Vendor selected';

  @override
  String get stageInstallation => 'Installation';

  @override
  String get stageNetMeterApplied => 'Net meter applied';

  @override
  String get stageNetMeterInstalled => 'Net meter installed';

  @override
  String get stageInspection => 'Inspection';

  @override
  String get stageCommissioning => 'Commissioning certificate';

  @override
  String get stageSubsidyClaimed => 'Subsidy claimed';

  @override
  String get stageSubsidyCredited => 'Subsidy credited';

  @override
  String get stagePending => 'Not started';

  @override
  String get stageInProgress => 'In progress';

  @override
  String get stageDone => 'Done';

  @override
  String get stageBlocked => 'Blocked';

  @override
  String get projectTitle => 'Project';

  @override
  String stageProgress(String done) {
    return '$done of 10 stages done';
  }

  @override
  String dueOn(String date) {
    return 'Due $date';
  }

  @override
  String doneOn(String date) {
    return 'Done $date';
  }

  @override
  String get markDone => 'Mark done';

  @override
  String get markBlocked => 'Mark blocked';

  @override
  String get resumeStage => 'Resume';

  @override
  String get reopenStage => 'Reopen';

  @override
  String get blockedReason => 'What is blocking this stage?';

  @override
  String get stageNote => 'Note';

  @override
  String get addDocument => 'Add document';

  @override
  String get sendStageUpdate => 'Send update on WhatsApp';

  @override
  String get stageMarkedDone => 'Stage marked done';

  @override
  String get trackingLink => 'Customer tracking link';

  @override
  String get shareTrackingLink => 'Share link on WhatsApp';

  @override
  String get revokeLink => 'Turn off link';

  @override
  String get linkRevoked => 'Link turned off';

  @override
  String get netMeterNumberLabel => 'Net meter number';

  @override
  String get commissioningDateLabel => 'Commissioning date';

  @override
  String get subsidyReceivedLabel => 'Subsidy received (₹)';

  @override
  String get installersLabel => 'Installers';

  @override
  String get noProjectYet =>
      'The project starts when the customer signs the proposal.';

  @override
  String get openProject => 'Open project';

  @override
  String get projectComplete => 'Project complete';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get noNotifications => 'No notifications yet';

  @override
  String get markAllRead => 'Mark all read';

  @override
  String notifProjectCreated(String kw) {
    return 'Proposal signed. Project started ($kw).';
  }

  @override
  String notifStageDone(String stage) {
    return 'Stage done: $stage';
  }

  @override
  String get kpiActiveProjects => 'Active projects';

  @override
  String get projectsByStage => 'Projects by stage';

  @override
  String daysInStage(String days) {
    return '$days days in this stage';
  }

  @override
  String get overdueTitle => 'Overdue';

  @override
  String get allOnTrack => 'Everything is on track.';

  @override
  String get expectedSubsidyLabel => 'Expected subsidy';

  @override
  String get inviteMember => 'Invite member';

  @override
  String get inviteSent => 'Invite saved. Ask them to log in with this number.';

  @override
  String get pendingInvites => 'Pending invites';

  @override
  String get cancelInvite => 'Cancel invite';

  @override
  String get deactivate => 'Deactivate';

  @override
  String get activate => 'Activate';

  @override
  String get performanceTitle => 'Performance';

  @override
  String get leadsCountLabel => 'Leads';

  @override
  String get wonCountLabel => 'Won';

  @override
  String get inactiveLabel => 'Inactive';

  @override
  String get youLabel => 'You';

  @override
  String get ownerOnlyHint => 'Only the owner can change this.';

  @override
  String get appSettingsTitle => 'App settings';

  @override
  String get loanPresetsTitle => 'Loan options';

  @override
  String get subsidyRulesTitle => 'Subsidy rules';

  @override
  String get tariffsTitle => 'Tariffs';

  @override
  String get configCompanyNote =>
      'Changes apply to your company only. The defaults stay as they are.';

  @override
  String get validFromLabel => 'Valid from';

  @override
  String get slabsLabel => 'Slabs';

  @override
  String get capLabel => 'Cap (₹)';

  @override
  String get uptoKwLabel => 'Up to kW';

  @override
  String get perKwLabel => '₹ per kW';

  @override
  String get uptoUnitsLabel => 'Up to units';

  @override
  String get rateLabel => '₹ per unit';

  @override
  String get fixedChargeLabel => 'Fixed charge (₹/month)';

  @override
  String get bankNameLabel => 'Bank / lender';

  @override
  String get maxYearsLabel => 'Max years';

  @override
  String get addRow => 'Add row';

  @override
  String get addItem => 'Add';

  @override
  String get remove => 'Remove';

  @override
  String get overridden => 'Your value';

  @override
  String get addressLabel => 'Address';

  @override
  String get gstinLabel => 'GSTIN';

  @override
  String get brandColorLabel => 'Brand colour';

  @override
  String get mnreVendorIdLabel => 'MNRE vendor ID';

  @override
  String get companyPhoneLabel => 'Company phone';

  @override
  String get exportCsv => 'Export CSV';

  @override
  String trackHello(String name) {
    return 'Namaste $name';
  }

  @override
  String trackSystem(String kw) {
    return 'Your $kw rooftop solar system';
  }

  @override
  String get trackDownloadPdf => 'Download proposal (PDF)';

  @override
  String get trackSign => 'Sign the proposal';

  @override
  String get trackSigned => 'Signed. Thank you!';

  @override
  String trackPay(String amount) {
    return 'Pay advance $amount';
  }

  @override
  String get trackPaid => 'Advance paid';

  @override
  String get trackStagesTitle => 'Progress';

  @override
  String get trackNotFound => 'This link is not valid or has been turned off.';

  @override
  String get trackSignHint => 'Sign inside the box with your finger';

  @override
  String get trackSubmitSignature => 'Submit signature';

  @override
  String trackCallCompany(String company) {
    return 'Call $company';
  }

  @override
  String trackSubsidyLine(String subsidy, String net) {
    return 'Subsidy $subsidy · You pay $net';
  }

  @override
  String get trackNotStarted => 'Work starts after you sign the proposal.';

  @override
  String get invalidJson =>
      'Not valid. Use the same format as before, e.g. [ ... ]';

  @override
  String get panelLengthLabel => 'Panel length (m)';

  @override
  String get panelWidthLabel => 'Panel width (m)';

  @override
  String get panelSizeHint =>
      'From the datasheet, e.g. 2.384 × 1.303 for 710 W. Used by the roof survey.';
}
