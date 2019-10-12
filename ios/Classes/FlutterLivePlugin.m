#import "FlutterLivePlugin.h"
#import <flutter_live/flutter_live-Swift.h>

@implementation FlutterLivePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterLivePlugin registerWithRegistrar:registrar];
}
@end
