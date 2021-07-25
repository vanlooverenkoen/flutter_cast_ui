#import "CastUiPlugin.h"
#if __has_include(<cast_ui/cast_ui-Swift.h>)
#import <cast_ui/cast_ui-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "cast_ui-Swift.h"
#endif

@implementation CastUiPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftCastUiPlugin registerWithRegistrar:registrar];
}
@end
