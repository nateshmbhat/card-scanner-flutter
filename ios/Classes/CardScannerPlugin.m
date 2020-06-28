#import "CardScannerPlugin.h"
#if __has_include(<card_scanner/card_scanner-Swift.h>)
#import <card_scanner/card_scanner-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "card_scanner-Swift.h"
#endif

@implementation CardScannerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftCardScannerPlugin registerWithRegistrar:registrar];
}
@end
