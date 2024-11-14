#import "AppDelegate.h"
#import <BackgroundTasks/BackgroundTasks.h>
#import <React/RCTBundleURLProvider.h>
#import "OrderDemo-Swift.h"
#import <UserNotifications/UserNotifications.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.moduleName = @"OrderDemo";
  // You can add your custom initial props in the dictionary below.
  // They will be passed down to the ViewController used by React Native.
  self.initialProps = @{};
  
  [UNUserNotificationCenter.currentNotificationCenter
     requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge)
     completionHandler:^(BOOL granted, NSError * _Nullable error) {
       if (granted) {
         dispatch_async(dispatch_get_main_queue(), ^{
           [application registerForRemoteNotifications];
         });
       }
   }];

  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge
{
  return [self bundleURL];
}


- (NSURL *)bundleURL
{
#if DEBUG
  return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index"];
#else
  return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
#endif
}

@end
