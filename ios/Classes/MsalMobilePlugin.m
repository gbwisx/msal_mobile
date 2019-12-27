#import "MsalMobilePlugin.h"
#if __has_include(<msal_mobile/msal_mobile-Swift.h>)
#import <msal_mobile/msal_mobile-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "msal_mobile-Swift.h"
#endif

@implementation MsalMobilePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftMsalMobilePlugin registerWithRegistrar:registrar];
}
@end
