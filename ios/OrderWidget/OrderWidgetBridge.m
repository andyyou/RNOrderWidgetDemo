//
//  OrderWidgetBridge.m
//  OrderDemo
//
//  Created by YOUZONGYAN on 2024/10/25.
//

#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(OrderWidgetModule, NSObject)
+ (bool)requiresMainQueueSetup {
  return NO;
}

RCT_EXTERN_METHOD(startLiveActivity)
RCT_EXTERN_METHOD(stopLiveActivity)
RCT_EXTERN_METHOD(updateState)

@end
