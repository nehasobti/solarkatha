/// Indian states and union territories with their two-letter codes, as used
/// for `state_code` columns (subsidy rules, tariffs, companies, leads).
class IndianState {
  const IndianState(this.code, this.nameEn, this.nameHi);

  final String code;
  final String nameEn;
  final String nameHi;

  String name(String languageCode) => languageCode == 'hi' ? nameHi : nameEn;
}

const indianStates = <IndianState>[
  IndianState(
    'AN',
    'Andaman and Nicobar Islands',
    'अंडमान और निकोबार द्वीपसमूह',
  ),
  IndianState('AP', 'Andhra Pradesh', 'आंध्र प्रदेश'),
  IndianState('AR', 'Arunachal Pradesh', 'अरुणाचल प्रदेश'),
  IndianState('AS', 'Assam', 'असम'),
  IndianState('BR', 'Bihar', 'बिहार'),
  IndianState('CH', 'Chandigarh', 'चंडीगढ़'),
  IndianState('CG', 'Chhattisgarh', 'छत्तीसगढ़'),
  IndianState(
    'DH',
    'Dadra and Nagar Haveli and Daman and Diu',
    'दादरा और नगर हवेली और दमन और दीव',
  ),
  IndianState('DL', 'Delhi', 'दिल्ली'),
  IndianState('GA', 'Goa', 'गोवा'),
  IndianState('GJ', 'Gujarat', 'गुजरात'),
  IndianState('HR', 'Haryana', 'हरियाणा'),
  IndianState('HP', 'Himachal Pradesh', 'हिमाचल प्रदेश'),
  IndianState('JK', 'Jammu and Kashmir', 'जम्मू और कश्मीर'),
  IndianState('JH', 'Jharkhand', 'झारखंड'),
  IndianState('KA', 'Karnataka', 'कर्नाटक'),
  IndianState('KL', 'Kerala', 'केरल'),
  IndianState('LA', 'Ladakh', 'लद्दाख'),
  IndianState('LD', 'Lakshadweep', 'लक्षद्वीप'),
  IndianState('MP', 'Madhya Pradesh', 'मध्य प्रदेश'),
  IndianState('MH', 'Maharashtra', 'महाराष्ट्र'),
  IndianState('MN', 'Manipur', 'मणिपुर'),
  IndianState('ML', 'Meghalaya', 'मेघालय'),
  IndianState('MZ', 'Mizoram', 'मिज़ोरम'),
  IndianState('NL', 'Nagaland', 'नागालैंड'),
  IndianState('OD', 'Odisha', 'ओडिशा'),
  IndianState('PY', 'Puducherry', 'पुदुचेरी'),
  IndianState('PB', 'Punjab', 'पंजाब'),
  IndianState('RJ', 'Rajasthan', 'राजस्थान'),
  IndianState('SK', 'Sikkim', 'सिक्किम'),
  IndianState('TN', 'Tamil Nadu', 'तमिलनाडु'),
  IndianState('TS', 'Telangana', 'तेलंगाना'),
  IndianState('TR', 'Tripura', 'त्रिपुरा'),
  IndianState('UP', 'Uttar Pradesh', 'उत्तर प्रदेश'),
  IndianState('UK', 'Uttarakhand', 'उत्तराखंड'),
  IndianState('WB', 'West Bengal', 'पश्चिम बंगाल'),
];
