#import "FlutterCastUiPlugin.h"
#if __has_include(<flutter_cast_ui/flutter_cast_ui-Swift.h>)
#import <flutter_cast_ui/flutter_cast_ui-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_cast_ui-Swift.h"
#endif

@implementation FlutterCastUiPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterCastUiPlugin registerWithRegistrar:registrar];
}
@end
