// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'SolarKatha';

  @override
  String get appTagline => 'छत पर सोलर, साइट विज़िट से सब्सिडी तक';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHindi => 'हिंदी';

  @override
  String get languageLabel => 'भाषा';

  @override
  String get loginTitle => 'साइन इन करें';

  @override
  String get loginSubtitle => 'हम आपके मोबाइल नंबर पर एक बार का कोड भेजेंगे।';

  @override
  String get loginEmailSubtitle =>
      'मालिक अपने ईमेल पर भेजे गए कोड से साइन इन कर सकते हैं।';

  @override
  String get phoneLabel => 'मोबाइल नंबर';

  @override
  String get phoneHint => '10 अंकों का मोबाइल नंबर';

  @override
  String get emailLabel => 'ईमेल';

  @override
  String get sendOtp => 'कोड भेजें';

  @override
  String get otpLabel => '6 अंकों का कोड';

  @override
  String get verifyOtp => 'पुष्टि करें और आगे बढ़ें';

  @override
  String otpSentTo(String destination) {
    return 'कोड $destination पर भेजा गया';
  }

  @override
  String get changeNumber => 'बदलें';

  @override
  String get resendOtp => 'कोड फिर से भेजें';

  @override
  String get useEmailInstead => 'मालिक हैं? ईमेल से साइन इन करें';

  @override
  String get usePhoneInstead => 'मोबाइल नंबर से साइन इन करें';

  @override
  String get invalidPhone => 'सही 10 अंकों का भारतीय मोबाइल नंबर डालें';

  @override
  String get invalidEmail => 'सही ईमेल पता डालें';

  @override
  String get invalidOtp => '6 अंकों का कोड डालें';

  @override
  String get otpIncorrect =>
      'कोड गलत है या उसकी समय-सीमा खत्म हो गई है। फिर से कोशिश करें या नया कोड मँगाएँ।';

  @override
  String get onboardingTitle => 'अपनी कंपनी सेट करें';

  @override
  String get onboardingSubtitle =>
      'इस खाते के लिए कोई टीम निमंत्रण नहीं मिला। मालिक के रूप में आगे बढ़ने के लिए अपनी कंपनी बनाएँ। अगर आपकी कंपनी SolarKatha इस्तेमाल करती है, तो उनसे इस नंबर को आमंत्रित करने को कहें।';

  @override
  String get yourNameLabel => 'आपका नाम';

  @override
  String get companyNameLabel => 'कंपनी का नाम';

  @override
  String get stateLabel => 'राज्य';

  @override
  String get createCompany => 'कंपनी बनाएँ';

  @override
  String get requiredField => 'ज़रूरी';

  @override
  String get deactivatedTitle => 'खाता निष्क्रिय है';

  @override
  String get deactivatedBody =>
      'आपकी कंपनी के मालिक ने यह खाता निष्क्रिय कर दिया है। फिर से पहुँच के लिए उनसे संपर्क करें।';

  @override
  String get signOut => 'साइन आउट';

  @override
  String get loading => 'लोड हो रहा है…';

  @override
  String get retry => 'फिर से कोशिश करें';

  @override
  String get errorGeneric => 'कुछ गड़बड़ हो गई। कृपया फिर से कोशिश करें।';

  @override
  String get errorNetwork =>
      'इंटरनेट कनेक्शन नहीं है। नेटवर्क जाँचें और फिर से कोशिश करें।';

  @override
  String get comingSoon => 'अगले अपडेट में उपलब्ध होगा';

  @override
  String get roleOwner => 'मालिक';

  @override
  String get roleSales => 'सेल्स';

  @override
  String get roleInstaller => 'इंस्टॉलर';

  @override
  String get navHome => 'होम';

  @override
  String get navLeads => 'लीड';

  @override
  String get navProjects => 'प्रोजेक्ट';

  @override
  String get navSettings => 'सेटिंग्स';

  @override
  String get navOverview => 'सारांश';

  @override
  String get navSubsidy => 'सब्सिडी ट्रैकर';

  @override
  String get navTeam => 'टीम';

  @override
  String get navProducts => 'प्रोडक्ट';

  @override
  String get navConfig => 'कॉन्फ़िग';

  @override
  String get navBranding => 'ब्रांडिंग';

  @override
  String greeting(String name) {
    return 'नमस्ते, $name';
  }

  @override
  String get newLead => 'नई लीड';

  @override
  String get followUpsToday => 'आज के फ़ॉलो-अप';

  @override
  String get noFollowUps => 'आज कोई फ़ॉलो-अप नहीं';

  @override
  String get leadsByStatus => 'स्थिति के अनुसार लीड';

  @override
  String get statusNew => 'नई';

  @override
  String get statusSurveyed => 'सर्वे हो गया';

  @override
  String get statusProposalSent => 'प्रस्ताव भेजा';

  @override
  String get statusWon => 'जीती';

  @override
  String get statusLost => 'हारी';

  @override
  String get online => 'ऑनलाइन';

  @override
  String get offline => 'ऑफ़लाइन';

  @override
  String get searchLeads => 'नाम या फ़ोन से खोजें';

  @override
  String get leadsEmptyTitle => 'अभी कोई लीड नहीं';

  @override
  String get leadsEmptyBody =>
      'आपकी जोड़ी गई लीड यहाँ दिखेंगी, इंटरनेट न होने पर भी।';

  @override
  String get projectsEmptyTitle => 'अभी कोई प्रोजेक्ट नहीं';

  @override
  String get projectsEmptyBody =>
      'ग्राहक के प्रस्ताव पर हस्ताक्षर करने और आपको सौंपे जाने के बाद प्रोजेक्ट यहाँ दिखेंगे।';

  @override
  String get kpiLeadsThisMonth => 'इस महीने की लीड';

  @override
  String get kpiConversion => 'कन्वर्ज़न दर';

  @override
  String get kpiKwSold => 'बेचे गए kW';

  @override
  String get kpiRevenue => 'आय';

  @override
  String get kpiSubsidiesPending => 'बाकी सब्सिडी';

  @override
  String get pipelineTitle => 'पाइपलाइन';

  @override
  String get dashboardEmpty =>
      'टीम के लीड जोड़ना शुरू करते ही आँकड़े यहाँ दिखेंगे।';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get profileSection => 'प्रोफ़ाइल';

  @override
  String get nameLabel => 'नाम';

  @override
  String get roleLabel => 'भूमिका';

  @override
  String get companyLabel => 'कंपनी';

  @override
  String get displaySection => 'डिस्प्ले';

  @override
  String get highContrast => 'हाई कॉन्ट्रास्ट';

  @override
  String get highContrastHint => 'तेज़ धूप के लिए गहरे रंग';

  @override
  String get largeText => 'बड़े अक्षर';

  @override
  String get largeTextHint => 'पूरे ऐप में बड़े अक्षर';

  @override
  String get syncSection => 'सिंक';

  @override
  String get syncStatusOnline => 'सर्वर से जुड़ा है';

  @override
  String get save => 'सेव करें';

  @override
  String get saved => 'सेव हो गया';

  @override
  String get trackingTitle => 'अपने सोलर प्रोजेक्ट को ट्रैक करें';

  @override
  String get trackingComingSoon =>
      'आपके इंस्टॉलर प्रोजेक्ट की जानकारी इस पेज पर देंगे।';

  @override
  String get notFoundTitle => 'पेज नहीं मिला';

  @override
  String get goHome => 'होम पर जाएँ';

  @override
  String get configMissingTitle => 'ऐप कॉन्फ़िगर नहीं है';

  @override
  String get configMissingBody =>
      'Supabase URL और key नहीं मिले। --dart-define-from-file=env/dev.json के साथ बिल्ड करें (README देखें)।';

  @override
  String get editLead => 'लीड बदलें';

  @override
  String get saveLead => 'लीड सेव करें';

  @override
  String get leadSaved => 'लीड सेव हो गई';

  @override
  String get leadDeleted => 'लीड हटा दी गई';

  @override
  String get deleteLead => 'लीड हटाएँ';

  @override
  String get deleteLeadConfirm => 'यह लीड हटाएँ? यह सभी डिवाइस से हट जाएगी।';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get delete => 'हटाएँ';

  @override
  String get customerSection => 'ग्राहक';

  @override
  String get addressSection => 'पता और लोकेशन';

  @override
  String get followUpSection => 'फ़ॉलो-अप';

  @override
  String get leadNameLabel => 'ग्राहक का नाम';

  @override
  String get leadPhoneLabel => 'मोबाइल नंबर';

  @override
  String get leadAltPhoneLabel => 'दूसरा नंबर (वैकल्पिक)';

  @override
  String get leadAddressLabel => 'मकान / गली / इलाका';

  @override
  String get leadDistrictLabel => 'ज़िला';

  @override
  String get leadPincodeLabel => 'पिन कोड';

  @override
  String get invalidPincode => '6 अंकों का पिन कोड डालें';

  @override
  String get leadSourceLabel => 'स्रोत';

  @override
  String get sourceWalkIn => 'खुद आए';

  @override
  String get sourceReferral => 'रेफ़रल';

  @override
  String get sourceCall => 'फ़ोन कॉल';

  @override
  String get sourceCampaign => 'कैंपेन';

  @override
  String get leadNotesLabel => 'नोट्स';

  @override
  String get followUpLabel => 'अगला फ़ॉलो-अप';

  @override
  String get followUpNone => 'तय नहीं';

  @override
  String get clear => 'हटाएँ';

  @override
  String get assignedToLabel => 'किसे सौंपी';

  @override
  String get captureLocation => 'मेरी अभी की लोकेशन लें';

  @override
  String get locationCaptured => 'लोकेशन सेव हो गई';

  @override
  String get locationFailed =>
      'लोकेशन नहीं मिली। GPS चालू करें और लोकेशन की अनुमति दें।';

  @override
  String get consentLabel =>
      'ग्राहक अपना बिजली बिल और साइट की फ़ोटो हमारे साथ साझा करने के लिए सहमत है';

  @override
  String get consentRequiredForPhotos =>
      'फ़ोटो जोड़ने से पहले ग्राहक की सहमति दर्ज करें (लीड बदलें)।';

  @override
  String get draftRestored => 'बिना सेव किया ड्राफ़्ट वापस लाया गया';

  @override
  String get discardDraft => 'हटाएँ';

  @override
  String get call => 'कॉल';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get directions => 'रास्ता';

  @override
  String get notSynced => 'सिंक नहीं हुआ';

  @override
  String get allStatuses => 'सभी';

  @override
  String get allReps => 'सभी';

  @override
  String get leadNotFound => 'यह लीड अब मौजूद नहीं है।';

  @override
  String get changeStatus => 'स्थिति बदलें';

  @override
  String get lostReasonLabel => 'लीड क्यों हारी?';

  @override
  String get tabOverview => 'सारांश';

  @override
  String get tabBill => 'बिल';

  @override
  String get tabSurvey => 'सर्वे';

  @override
  String get tabProposals => 'प्रस्ताव';

  @override
  String get tabProject => 'प्रोजेक्ट';

  @override
  String get photosTitle => 'साइट की फ़ोटो';

  @override
  String photosChecklist(int done, int total) {
    return 'चेकलिस्ट की $total में से $done फ़ोटो';
  }

  @override
  String get takePhoto => 'फ़ोटो खींचें';

  @override
  String get chooseFromGallery => 'गैलरी से चुनें';

  @override
  String get photoKindRoof => 'छत';

  @override
  String get photoKindMeter => 'मीटर';

  @override
  String get photoKindDbBox => 'DB बॉक्स';

  @override
  String get photoKindWiring => 'वायरिंग का रास्ता';

  @override
  String get photoKindBill => 'बिजली बिल';

  @override
  String get photoKindOther => 'अन्य';

  @override
  String get photoWaiting => 'अपलोड बाकी';

  @override
  String get deletePhoto => 'फ़ोटो हटाएँ';

  @override
  String get noResults => 'आपकी खोज से कोई लीड नहीं मिली।';

  @override
  String addedOn(String date) {
    return '$date को जोड़ी';
  }

  @override
  String followUpOn(String date) {
    return 'फ़ॉलो-अप $date';
  }

  @override
  String get overdue => 'देर हो गई';

  @override
  String get totalLeads => 'कुल लीड';

  @override
  String get openLeads => 'चालू';

  @override
  String get wonLeads => 'जीती';

  @override
  String get offlineBanner =>
      'आप ऑफ़लाइन हैं। आपका सारा काम इस फ़ोन पर सेव है और अपने-आप सिंक हो जाएगा।';

  @override
  String get syncing => 'सिंक हो रहा है…';

  @override
  String syncedAt(String time) {
    return 'आख़िरी सिंक $time';
  }

  @override
  String get neverSynced => 'अभी सिंक नहीं हुआ';

  @override
  String get syncNotConfigured =>
      'इस बिल्ड में सिंक सेट नहीं है; डेटा इसी डिवाइस पर रहेगा।';

  @override
  String pendingChanges(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count बदलाव अपलोड होने बाकी',
      one: '1 बदलाव अपलोड होना बाकी',
      zero: 'सारे बदलाव अपलोड हो गए',
    );
    return '$_temp0';
  }

  @override
  String get scanBill => 'बिल स्कैन करें';

  @override
  String get enterBillManually => 'खुद भरें';

  @override
  String get scanQueued =>
      'बिल की फ़ोटो सेव हो गई। फ़ोन ऑनलाइन होते ही यह अपने-आप पढ़ा जाएगा।';

  @override
  String get scanReady =>
      'बिल पढ़ लिया गया। जाँचने और पुष्टि करने के लिए टैप करें।';

  @override
  String scanFailed(String error) {
    return 'बिल नहीं पढ़ा जा सका: $error';
  }

  @override
  String get retry2 => 'फिर से कोशिश करें';

  @override
  String get reviewScan => 'जाँचें';

  @override
  String get discardScan => 'हटाएँ';

  @override
  String get noBillsTitle => 'अभी कोई बिल नहीं';

  @override
  String get noBillsBody =>
      'ग्राहक का बिजली बिल स्कैन करें, या उसमें से आँकड़े भरें।';

  @override
  String get billFromScan => 'AI ने पढ़ा';

  @override
  String get billManual => 'खुद भरा';

  @override
  String avgUnitsShort(String units) {
    return '$units यूनिट/महीना';
  }

  @override
  String get sizeSystem => 'सिस्टम का साइज़ तय करें';

  @override
  String get sizingCta => 'सिस्टम साइज़, सब्सिडी, EMI और पेबैक देखें';

  @override
  String get billFormTitle => 'बिजली बिल';

  @override
  String get confirmBill => 'बिल की पुष्टि करें';

  @override
  String get billSaved => 'बिल सेव हो गया';

  @override
  String get deleteBill => 'बिल हटाएँ';

  @override
  String get discomLabel => 'DISCOM';

  @override
  String get consumerNumberLabel => 'उपभोक्ता संख्या';

  @override
  String get billCustomerNameLabel => 'बिल पर नाम';

  @override
  String get tariffCategoryLabel => 'टैरिफ़ श्रेणी';

  @override
  String get sanctionedLoadLabel => 'स्वीकृत लोड (kW)';

  @override
  String get billingPeriodLabel => 'बिलिंग अवधि';

  @override
  String get avgUnitsLabel => 'औसत मासिक यूनिट (kWh)';

  @override
  String get billAmountLabel => 'बिल राशि (₹)';

  @override
  String get unitsHistoryTitle => 'बिल पर छपी मासिक यूनिट';

  @override
  String get checkThisField => 'कृपया जाँचें: AI को पक्का नहीं था';

  @override
  String get duplicateConsumer =>
      'यह उपभोक्ता संख्या किसी दूसरी लीड पर पहले से है। एक घर को केवल एक केंद्रीय सब्सिडी मिलती है।';

  @override
  String get invalidNumber => 'सही संख्या डालें';

  @override
  String get sizingTitle => 'सिस्टम साइज़';

  @override
  String get usageSection => 'ग्राहक की खपत';

  @override
  String get roofAreaLabel => 'छत का उपयोगी क्षेत्र (m², वैकल्पिक)';

  @override
  String get shadingLabel => 'छाया';

  @override
  String get shadingNone => 'कोई नहीं';

  @override
  String get shadingLow => 'कम';

  @override
  String get shadingMedium => 'मध्यम';

  @override
  String get shadingHigh => 'ज़्यादा';

  @override
  String get dcrPanels => 'DCR और ALMM सूची वाले पैनल';

  @override
  String get dcrHint => 'सब्सिडी के लिए ज़रूरी';

  @override
  String get recommendedLabel => 'सुझाया गया';

  @override
  String recommendedKw(String kw) {
    return 'सुझाव: $kw';
  }

  @override
  String requiredKwNote(String units) {
    return 'लगभग $units यूनिट महीने की खपत पूरी करता है';
  }

  @override
  String exceedsLoad(String load) {
    return 'स्वीकृत लोड ($load kW) से ज़्यादा। ग्राहक को लोड बढ़वाना पड़ सकता है।';
  }

  @override
  String limitedByRoof(String kw) {
    return 'छत के क्षेत्र के कारण सीमित (अधिकतम $kw)।';
  }

  @override
  String get compareTitle => 'साइज़ की तुलना';

  @override
  String get customSize => 'अपना साइज़';

  @override
  String get generationTitle => 'मासिक उत्पादन';

  @override
  String get generationPvgis => 'इस जगह के PVGIS सोलर डेटा पर आधारित';

  @override
  String generationFallback(String kwh) {
    return 'अनुमान ($kwh यूनिट प्रति kW प्रति दिन)। जगह के हिसाब से आँकड़े के लिए साइट की लोकेशन जोड़ें और ऑनलाइन रहें।';
  }

  @override
  String perYear(String kwh) {
    return 'साल में $kwh यूनिट';
  }

  @override
  String get subsidySection => 'सब्सिडी';

  @override
  String get centralSubsidy => 'केंद्रीय (पीएम सूर्य घर)';

  @override
  String get stateSubsidy => 'राज्य की अतिरिक्त सब्सिडी';

  @override
  String get totalSubsidy => 'कुल सब्सिडी';

  @override
  String subsidyPerKw(String amount) {
    return 'लगभग $amount प्रति kW';
  }

  @override
  String subsidyLine(String from, String to, String rate) {
    return '$from–$to kW × $rate';
  }

  @override
  String get noSubsidyNonDcr =>
      'सब्सिडी नहीं: पैनल DCR और ALMM सूची वाले होने चाहिए।';

  @override
  String get costSection => 'लागत';

  @override
  String get grossPrice => 'सिस्टम की कीमत';

  @override
  String get pricePerKwLabel => 'प्रति kW कीमत (₹)';

  @override
  String get netPrice => 'सब्सिडी के बाद ग्राहक देगा';

  @override
  String get loanSection => 'लोन और EMI';

  @override
  String get loanBank => 'लोन विकल्प';

  @override
  String get interestRate => 'ब्याज % सालाना';

  @override
  String get tenureYears => 'साल';

  @override
  String get loanAmountLabel => 'लोन राशि (₹)';

  @override
  String get emiLabel => 'EMI';

  @override
  String get currentBillLabel => 'अभी का बिल';

  @override
  String get perMonth => 'महीना';

  @override
  String get emiVsBillGood => 'EMI आज के बिल से कम है';

  @override
  String get savingsSection => 'बचत';

  @override
  String get monthlySaving => 'महीने की बचत (पहला साल)';

  @override
  String get paybackLabel => 'पेबैक';

  @override
  String paybackYears(String years) {
    return '$years साल';
  }

  @override
  String noPayback(String years) {
    return '$years साल से ज़्यादा';
  }

  @override
  String lifetimeSavings(String years) {
    return '$years साल की बचत';
  }

  @override
  String get configMissing =>
      'कीमतों की सेटिंग अभी इस डिवाइस पर नहीं आई है। इंटरनेट से जुड़ें और फिर से खोलें।';

  @override
  String get noTariffUsingBill =>
      'इस राज्य का टैरिफ़ अभी नहीं है; बिल की औसत दर ली जा रही है।';

  @override
  String get noTariff =>
      'बचत देखने के लिए बिल राशि (या इस राज्य का टैरिफ़) डालें।';

  @override
  String get needUsage =>
      'सिस्टम का साइज़ तय करने के लिए औसत मासिक यूनिट डालें।';

  @override
  String get rowGeneration => 'यूनिट / महीना';

  @override
  String get rowSubsidy => 'सब्सिडी';

  @override
  String get rowNet => 'ग्राहक देगा';

  @override
  String get rowEmi => 'EMI';

  @override
  String get rowPayback => 'पेबैक';

  @override
  String get addProduct => 'प्रोडक्ट जोड़ें';

  @override
  String get editProduct => 'प्रोडक्ट बदलें';

  @override
  String get productType => 'प्रकार';

  @override
  String get typePanel => 'पैनल';

  @override
  String get typeInverter => 'इन्वर्टर';

  @override
  String get typeStructure => 'स्ट्रक्चर';

  @override
  String get typeOther => 'अन्य';

  @override
  String get brandLabel => 'ब्रांड';

  @override
  String get modelLabel => 'मॉडल';

  @override
  String get wattPeakLabel => 'वॉट पीक (Wp)';

  @override
  String get dcrLabel => 'DCR (भारत में बने सेल)';

  @override
  String get almmLabel => 'ALMM सूची में';

  @override
  String get approvedListLabel => 'मंज़ूर इन्वर्टर सूची में';

  @override
  String get warrantyLabel => 'वारंटी (साल)';

  @override
  String get unitPriceLabel => 'कीमत (₹)';

  @override
  String get activeLabel => 'प्रस्तावों के लिए उपलब्ध';

  @override
  String get noProducts => 'अभी कोई प्रोडक्ट नहीं';

  @override
  String get noProductsBody =>
      'आप जो पैनल और इन्वर्टर बेचते हैं, उन्हें जोड़ें। सब्सिडी केवल DCR और ALMM सूची वाले पैनल पर मिलती है।';

  @override
  String get deleteProduct => 'प्रोडक्ट हटाएँ';

  @override
  String get productSaved => 'प्रोडक्ट सेव हो गया';

  @override
  String get ownerOnly => 'केवल मालिक प्रोडक्ट बदल सकते हैं।';

  @override
  String get newProposal => 'नया प्रस्ताव';

  @override
  String proposalVersion(String version) {
    return 'प्रस्ताव v$version';
  }

  @override
  String get statusDraft => 'ड्राफ़्ट';

  @override
  String get statusSent => 'भेजा';

  @override
  String get statusSigned => 'हस्ताक्षरित';

  @override
  String get statusExpired => 'समय-सीमा खत्म';

  @override
  String get noProposalsTitle => 'अभी कोई प्रस्ताव नहीं';

  @override
  String get noProposalsBody =>
      'प्रस्ताव बनाएँ, WhatsApp पर भेजें, हस्ताक्षर और एडवांस लें।';

  @override
  String get systemSection => 'सिस्टम';

  @override
  String get systemKwLabel => 'सिस्टम साइज़ (kW)';

  @override
  String get panelLabel => 'पैनल';

  @override
  String get inverterLabel => 'इन्वर्टर';

  @override
  String get selectProduct => 'चुनें';

  @override
  String panelsNeeded(String count, String wp, String kw) {
    return '$count पैनल × $wp Wp = $kw';
  }

  @override
  String get priceSection => 'कीमत';

  @override
  String get grossPriceLabel => 'सिस्टम की कीमत (₹)';

  @override
  String get languageForProposal => 'प्रस्ताव की भाषा';

  @override
  String get complianceTitle => 'अनुपालन चेकलिस्ट';

  @override
  String get checkPanelsDcr => 'पैनल DCR हैं (भारत में बने सेल)';

  @override
  String get checkPanelsAlmm => 'पैनल ALMM सूची में हैं';

  @override
  String get checkInverterApproved => 'इन्वर्टर मंज़ूर सूची में है';

  @override
  String get checkOwnConnection => 'बिजली कनेक्शन ग्राहक के अपने नाम पर है';

  @override
  String get checkConsumerNumber =>
      'उपभोक्ता संख्या दर्ज है (ग्राहक राष्ट्रीय पोर्टल पर पंजीकृत)';

  @override
  String checkRoofPhotos(String count) {
    return 'कम से कम 4 साइट फ़ोटो ($count ली गईं)';
  }

  @override
  String get checkRoofType => 'छत का प्रकार दर्ज है';

  @override
  String get checkSingleSubsidy =>
      'इस उपभोक्ता संख्या पर कोई दूसरी सब्सिडी नहीं';

  @override
  String get ownerOverride => 'मालिक की अनुमति: फिर भी भेजें';

  @override
  String get complianceBlocked =>
      'भेजने से पहले चेकलिस्ट पूरी करें। केवल मालिक अनुमति दे सकते हैं।';

  @override
  String get saveDraft => 'ड्राफ़्ट सेव करें';

  @override
  String get proposalSaved => 'प्रस्ताव सेव हो गया';

  @override
  String get actionsSection => 'भेजें, हस्ताक्षर लें और एडवांस लें';

  @override
  String get generatePdf => 'PDF बनाएँ';

  @override
  String get regeneratePdf => 'PDF अपडेट करें';

  @override
  String get pdfReady => 'PDF तैयार';

  @override
  String get sharePdf => 'PDF फ़ाइल भेजें';

  @override
  String get shareWhatsapp => 'WhatsApp पर भेजें';

  @override
  String get openPdf => 'PDF खोलें';

  @override
  String get needsOnline =>
      'इसके लिए इंटरनेट चाहिए। जुड़ें और फिर से कोशिश करें।';

  @override
  String get captureSignature => 'ग्राहक के हस्ताक्षर लें';

  @override
  String get signHereHint => 'ग्राहक से बॉक्स के अंदर हस्ताक्षर करवाएँ';

  @override
  String get clearSignature => 'मिटाएँ';

  @override
  String get saveSignature => 'हस्ताक्षर सेव करें';

  @override
  String signedOnDate(String date) {
    return '$date को हस्ताक्षर किए';
  }

  @override
  String get paymentSection => 'एडवांस भुगतान';

  @override
  String get advanceAmount => 'एडवांस राशि (₹)';

  @override
  String get createPaymentLink => 'UPI भुगतान लिंक बनाएँ';

  @override
  String get sendPaymentLink => 'लिंक WhatsApp पर भेजें';

  @override
  String get paymentPaid => 'भुगतान हो गया';

  @override
  String get paymentWaiting => 'भुगतान बाकी';

  @override
  String get paymentExpired => 'समय-सीमा खत्म';

  @override
  String get newVersion => 'नया वर्ज़न';

  @override
  String get proposalLocked =>
      'यह प्रस्ताव भेजा जा चुका है, इसलिए बदला नहीं जा सकता। बदलने के लिए नया वर्ज़न बनाएँ।';

  @override
  String get copyLink => 'लिंक कॉपी करें';

  @override
  String get linkCopied => 'लिंक कॉपी हो गया';

  @override
  String get waitingToSync =>
      'इस फ़ोन पर सेव है। ऑनलाइन होने पर अपलोड होगा; फिर PDF बना सकेंगे।';

  @override
  String get netPriceShort => 'ग्राहक देगा';

  @override
  String get tagNoSubsidy => 'सब्सिडी नहीं';

  @override
  String get tagApproved => 'मंज़ूर';

  @override
  String get createProposal => 'प्रस्ताव बनाएँ';

  @override
  String get surveyTitle => 'छत का सर्वे';

  @override
  String get startSurvey => 'छत का सर्वे शुरू करें';

  @override
  String get editSurvey => 'छत का सर्वे बदलें';

  @override
  String get drawRoofHint => 'मैप पर छत के हर कोने पर टैप करें';

  @override
  String get undoPoint => 'पीछे';

  @override
  String get clearRoof => 'मिटाएँ';

  @override
  String get myLocation => 'मेरी लोकेशन';

  @override
  String get needThreePoints => 'छत बनाने के लिए कम से कम 3 कोनों पर टैप करें';

  @override
  String get roofAreaResult => 'छत का क्षेत्र';

  @override
  String get panelsFit => 'कितने पैनल आएँगे';

  @override
  String get fittedKwLabel => 'पैनल आएँगे';

  @override
  String maxKwRoof(String kw) {
    return 'छत पर अधिकतम $kw';
  }

  @override
  String get roofTypeLabel => 'छत का प्रकार';

  @override
  String get roofRcc => 'RCC (कंक्रीट)';

  @override
  String get roofTin => 'टिन शेड';

  @override
  String get roofOther => 'अन्य';

  @override
  String get floorsLabel => 'मंज़िलें';

  @override
  String get orientationLabel => 'पैनल की दिशा';

  @override
  String get tiltLabel => 'झुकाव';

  @override
  String degreesValue(String deg) {
    return '$deg°';
  }

  @override
  String get dirN => 'उत्तर';

  @override
  String get dirNE => 'उत्तर-पूर्व';

  @override
  String get dirE => 'पूर्व';

  @override
  String get dirSE => 'दक्षिण-पूर्व';

  @override
  String get dirS => 'दक्षिण';

  @override
  String get dirSW => 'दक्षिण-पश्चिम';

  @override
  String get dirW => 'पश्चिम';

  @override
  String get dirNW => 'उत्तर-पश्चिम';

  @override
  String get saveSurvey => 'सर्वे सेव करें';

  @override
  String get surveySaved => 'सर्वे सेव हो गया';

  @override
  String get noSurveyTitle => 'अभी छत का सर्वे नहीं हुआ';

  @override
  String get noSurveyBody =>
      'कितने पैनल आएँगे, यह देखने के लिए सैटेलाइट मैप पर छत बनाएँ।';

  @override
  String roofLimitWarning(String kw) {
    return 'छत की सीमा ($kw) से ज़्यादा।';
  }

  @override
  String get photoKindRoofLayout => 'छत का लेआउट';

  @override
  String get surveyConfigMissing =>
      'पैनल की सेटिंग अभी इस डिवाइस पर नहीं आई है। इंटरनेट से जुड़ें और फिर से खोलें।';

  @override
  String get noLocationHint =>
      'इस लीड की लोकेशन सेव नहीं है। साइट पर \"मेरी लोकेशन\" दबाएँ, या मैप को घर तक ले जाएँ।';

  @override
  String get stagePortalRegistration => 'राष्ट्रीय पोर्टल पर पंजीकरण';

  @override
  String get stageDiscomFeasibility => 'DISCOM से व्यवहार्यता मंज़ूरी';

  @override
  String get stageVendorSelected => 'वेंडर चुना गया';

  @override
  String get stageInstallation => 'इंस्टॉलेशन';

  @override
  String get stageNetMeterApplied => 'नेट मीटर के लिए आवेदन';

  @override
  String get stageNetMeterInstalled => 'नेट मीटर लगा';

  @override
  String get stageInspection => 'जाँच';

  @override
  String get stageCommissioning => 'कमीशनिंग प्रमाणपत्र';

  @override
  String get stageSubsidyClaimed => 'सब्सिडी का दावा किया';

  @override
  String get stageSubsidyCredited => 'सब्सिडी खाते में जमा';

  @override
  String get stagePending => 'शुरू नहीं';

  @override
  String get stageInProgress => 'चल रहा है';

  @override
  String get stageDone => 'पूरा';

  @override
  String get stageBlocked => 'रुका हुआ';

  @override
  String get projectTitle => 'प्रोजेक्ट';

  @override
  String stageProgress(String done) {
    return '10 में से $done चरण पूरे';
  }

  @override
  String dueOn(String date) {
    return 'अंतिम तारीख $date';
  }

  @override
  String doneOn(String date) {
    return '$date को पूरा';
  }

  @override
  String get markDone => 'पूरा करें';

  @override
  String get markBlocked => 'रुका हुआ बताएँ';

  @override
  String get resumeStage => 'फिर शुरू करें';

  @override
  String get reopenStage => 'फिर खोलें';

  @override
  String get blockedReason => 'यह चरण क्यों रुका है?';

  @override
  String get stageNote => 'नोट';

  @override
  String get addDocument => 'दस्तावेज़ जोड़ें';

  @override
  String get sendStageUpdate => 'WhatsApp पर अपडेट भेजें';

  @override
  String get stageMarkedDone => 'चरण पूरा हुआ';

  @override
  String get trackingLink => 'ग्राहक का ट्रैकिंग लिंक';

  @override
  String get shareTrackingLink => 'लिंक WhatsApp पर भेजें';

  @override
  String get revokeLink => 'लिंक बंद करें';

  @override
  String get linkRevoked => 'लिंक बंद कर दिया गया';

  @override
  String get netMeterNumberLabel => 'नेट मीटर नंबर';

  @override
  String get commissioningDateLabel => 'कमीशनिंग की तारीख';

  @override
  String get subsidyReceivedLabel => 'मिली सब्सिडी (₹)';

  @override
  String get installersLabel => 'इंस्टॉलर';

  @override
  String get noProjectYet =>
      'ग्राहक के प्रस्ताव पर हस्ताक्षर करते ही प्रोजेक्ट शुरू होगा।';

  @override
  String get openProject => 'प्रोजेक्ट खोलें';

  @override
  String get projectComplete => 'प्रोजेक्ट पूरा';

  @override
  String get notificationsTitle => 'सूचनाएँ';

  @override
  String get noNotifications => 'अभी कोई सूचना नहीं';

  @override
  String get markAllRead => 'सब पढ़ा हुआ करें';

  @override
  String notifProjectCreated(String kw) {
    return 'प्रस्ताव पर हस्ताक्षर हुए। प्रोजेक्ट शुरू ($kw)।';
  }

  @override
  String notifStageDone(String stage) {
    return 'चरण पूरा: $stage';
  }

  @override
  String get kpiActiveProjects => 'चालू प्रोजेक्ट';

  @override
  String get projectsByStage => 'चरण के अनुसार प्रोजेक्ट';

  @override
  String daysInStage(String days) {
    return 'इस चरण में $days दिन';
  }

  @override
  String get overdueTitle => 'देर से चल रहे';

  @override
  String get allOnTrack => 'सब समय पर है।';

  @override
  String get expectedSubsidyLabel => 'अपेक्षित सब्सिडी';

  @override
  String get inviteMember => 'सदस्य जोड़ें';

  @override
  String get inviteSent =>
      'निमंत्रण सेव हुआ। उन्हें इसी नंबर से लॉग इन करने को कहें।';

  @override
  String get pendingInvites => 'बाकी निमंत्रण';

  @override
  String get cancelInvite => 'निमंत्रण रद्द करें';

  @override
  String get deactivate => 'निष्क्रिय करें';

  @override
  String get activate => 'सक्रिय करें';

  @override
  String get performanceTitle => 'प्रदर्शन';

  @override
  String get leadsCountLabel => 'लीड';

  @override
  String get wonCountLabel => 'जीती';

  @override
  String get inactiveLabel => 'निष्क्रिय';

  @override
  String get youLabel => 'आप';

  @override
  String get ownerOnlyHint => 'केवल मालिक इसे बदल सकते हैं।';

  @override
  String get appSettingsTitle => 'ऐप सेटिंग्स';

  @override
  String get loanPresetsTitle => 'लोन विकल्प';

  @override
  String get subsidyRulesTitle => 'सब्सिडी नियम';

  @override
  String get tariffsTitle => 'टैरिफ़';

  @override
  String get configCompanyNote =>
      'बदलाव केवल आपकी कंपनी पर लागू होंगे। डिफ़ॉल्ट वैसे ही रहेंगे।';

  @override
  String get validFromLabel => 'से लागू';

  @override
  String get slabsLabel => 'स्लैब';

  @override
  String get capLabel => 'अधिकतम (₹)';

  @override
  String get uptoKwLabel => 'kW तक';

  @override
  String get perKwLabel => '₹ प्रति kW';

  @override
  String get uptoUnitsLabel => 'यूनिट तक';

  @override
  String get rateLabel => '₹ प्रति यूनिट';

  @override
  String get fixedChargeLabel => 'फ़िक्स्ड चार्ज (₹/महीना)';

  @override
  String get bankNameLabel => 'बैंक / लोन देने वाला';

  @override
  String get maxYearsLabel => 'अधिकतम साल';

  @override
  String get addRow => 'पंक्ति जोड़ें';

  @override
  String get addItem => 'जोड़ें';

  @override
  String get remove => 'हटाएँ';

  @override
  String get overridden => 'आपका मान';

  @override
  String get addressLabel => 'पता';

  @override
  String get gstinLabel => 'GSTIN';

  @override
  String get brandColorLabel => 'ब्रांड रंग';

  @override
  String get mnreVendorIdLabel => 'MNRE वेंडर ID';

  @override
  String get companyPhoneLabel => 'कंपनी का फ़ोन';

  @override
  String get exportCsv => 'CSV डाउनलोड करें';

  @override
  String trackHello(String name) {
    return 'नमस्ते $name';
  }

  @override
  String trackSystem(String kw) {
    return 'आपका $kw रूफ़टॉप सोलर सिस्टम';
  }

  @override
  String get trackDownloadPdf => 'प्रस्ताव डाउनलोड करें (PDF)';

  @override
  String get trackSign => 'प्रस्ताव पर हस्ताक्षर करें';

  @override
  String get trackSigned => 'हस्ताक्षर हो गए। धन्यवाद!';

  @override
  String trackPay(String amount) {
    return '$amount एडवांस भरें';
  }

  @override
  String get trackPaid => 'एडवांस भर दिया गया';

  @override
  String get trackStagesTitle => 'प्रगति';

  @override
  String get trackNotFound => 'यह लिंक सही नहीं है या बंद कर दिया गया है।';

  @override
  String get trackSignHint => 'बॉक्स के अंदर उंगली से हस्ताक्षर करें';

  @override
  String get trackSubmitSignature => 'हस्ताक्षर भेजें';

  @override
  String trackCallCompany(String company) {
    return '$company को कॉल करें';
  }

  @override
  String trackSubsidyLine(String subsidy, String net) {
    return 'सब्सिडी $subsidy · आप देंगे $net';
  }

  @override
  String get trackNotStarted => 'प्रस्ताव पर हस्ताक्षर के बाद काम शुरू होगा।';

  @override
  String get invalidJson =>
      'सही नहीं है। पहले जैसा ही फ़ॉर्मैट रखें, जैसे [ ... ]';

  @override
  String get panelLengthLabel => 'पैनल की लंबाई (मीटर)';

  @override
  String get panelWidthLabel => 'पैनल की चौड़ाई (मीटर)';

  @override
  String get panelSizeHint =>
      'डेटाशीट से, जैसे 710 W के लिए 2.384 × 1.303। छत सर्वे में काम आता है।';

  @override
  String get landingHeadline =>
      'रूफटॉप सोलर तेज़ी से बेचें, पहली मुलाक़ात से सब्सिडी मिलने तक।';

  @override
  String get landingF1 =>
      'AI से बिजली बिल स्कैन करें और सेकंडों में सिस्टम साइज़ तय करें';

  @override
  String get landingF2 =>
      'सैटेलाइट तस्वीर पर छत बनाएँ; पैनल अपने आप फ़िट होते हैं';

  @override
  String get landingF3 =>
      'हिंदी और अंग्रेज़ी प्रस्ताव PDF, WhatsApp पर भेजें, फ़ोन पर साइन';

  @override
  String get landingF4 => 'UPI एडवांस पेमेंट लिंक, भुगतान अपने आप दर्ज';

  @override
  String get landingF5 =>
      'PM सूर्य घर सब्सिडी के सभी 10 चरण ट्रैक करें; ग्राहक को लाइव लिंक';

  @override
  String get landingF6 => 'साइट पर ऑफ़लाइन काम करता है, नेटवर्क आने पर सिंक';

  @override
  String get downloadApk => 'Android ऐप डाउनलोड करें';

  @override
  String get searchPlaceHint => 'पता या जगह खोजें';

  @override
  String get detectRoof => 'छत पहचानें (Google)';

  @override
  String get roofDetected =>
      'Google ने यह छत ढूँढी। ज़रूरत हो तो कोने ठीक करें।';

  @override
  String get roofNotFound =>
      'यहाँ Google के पास छत का डेटा नहीं है। छत के कोनों पर टैप करके बनाएँ।';

  @override
  String googleRoofInfo(String panels, String hours, String date) {
    return 'Google: $panels पैनल आएँगे · $hours धूप घंटे/साल · फ़ोटो $date';
  }

  @override
  String get addressLocated =>
      'नक्शा लीड के पते पर ले जाया गया। जाँच लें कि घर सही है।';

  @override
  String get addressNotFound =>
      'यह पता नक्शे पर नहीं मिला। खोजें या मेरी लोकेशन इस्तेमाल करें।';

  @override
  String get loginPasswordSubtitle =>
      'आपको दिया गया मोबाइल नंबर और पासवर्ड डालें।';

  @override
  String get passwordLabel => 'पासवर्ड';

  @override
  String get showPassword => 'पासवर्ड दिखाएँ';

  @override
  String get signInButton => 'साइन इन करें';

  @override
  String get wrongCredentials => 'मोबाइल नंबर या पासवर्ड गलत है।';
}
