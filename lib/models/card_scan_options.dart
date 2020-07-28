// @author nateshmbhat created on 30,June,2020

/// [portrait] corresponds to the home button at the bottom and the phone held upright.
///
/// [landscape] corresponds to the home button on the right and the phone held across.
enum CameraOrientation { portrait, landscape }

class CardScanOptions {
  final bool scanExpiryDate;
  final bool scanCardHolderName;
  final String prompt;
  final CameraOrientation cameraOrientation;

  const CardScanOptions({
    this.scanExpiryDate = true,
    this.scanCardHolderName = false,
    this.prompt = 'Scan your card to proceed',
    this.cameraOrientation = CameraOrientation.portrait,
  });

  Map<String, String> get map => {
        'scanExpiryDate': scanExpiryDate.toString(),
        'scanCardHolderName': scanCardHolderName.toString(),
        'promptText': prompt,
        'cameraOrientation': cameraOrientation.toString().split('.').last ?? 'portrait',
      };
}
