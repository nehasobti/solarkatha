import 'package:solar_core/solar_core.dart';
import 'package:test/test.dart';

ComplianceInput input({
  bool dcr = true,
  bool almm = true,
  bool inverter = true,
  bool own = true,
  String? consumer = '4521778309',
  int photos = 4,
  bool roofType = true,
  int duplicates = 0,
}) => ComplianceInput(
  panelsDcr: dcr,
  panelsAlmm: almm,
  inverterApproved: inverter,
  ownConnectionConfirmed: own,
  consumerNumber: consumer,
  photoCount: photos,
  roofTypeRecorded: roofType,
  duplicateConsumerLeads: duplicates,
);

void main() {
  test('everything in place → can send', () {
    final r = evaluateCompliance(input());
    expect(r.allPassed, isTrue);
    expect(r.canSend, isTrue);
    expect(r.items, hasLength(8));
    expect(r.failing, isEmpty);
  });

  test('each failure blocks sending', () {
    final cases = <ComplianceCheck, ComplianceInput>{
      ComplianceCheck.panelsDcr: input(dcr: false),
      ComplianceCheck.panelsAlmm: input(almm: false),
      ComplianceCheck.inverterApproved: input(inverter: false),
      ComplianceCheck.ownConnection: input(own: false),
      ComplianceCheck.consumerNumber: input(consumer: ' 12 '),
      ComplianceCheck.roofPhotos: input(photos: 3),
      ComplianceCheck.roofType: input(roofType: false),
      ComplianceCheck.singleSubsidy: input(duplicates: 1),
    };
    cases.forEach((check, i) {
      final r = evaluateCompliance(i);
      expect(r.canSend, isFalse, reason: '$check');
      expect(r.failing.single.check, check);
    });
    expect(evaluateCompliance(input(consumer: null)).canSend, isFalse);
  });

  test('owner override allows sending despite failures', () {
    final r = evaluateCompliance(input(dcr: false), ownerOverride: true);
    expect(r.allPassed, isFalse);
    expect(r.overridden, isTrue);
    expect(r.canSend, isTrue);
  });

  test('manual items are marked', () {
    final manual = evaluateCompliance(input()).items.where((i) => i.manual);
    expect(manual.map((i) => i.check), [
      ComplianceCheck.ownConnection,
      ComplianceCheck.roofType,
    ]);
  });

  test('panel count rounds up; installed kW', () {
    expect(panelCount(3, 540), 6); // 5.56 → 6
    expect(panelCount(3, 500), 6);
    expect(panelCount(2, 545), 4);
    expect(panelCount(0, 540), 0);
    expect(panelCount(3, 0), 0);
    expect(installedKw(6, 540), closeTo(3.24, 1e-9));
  });
}
