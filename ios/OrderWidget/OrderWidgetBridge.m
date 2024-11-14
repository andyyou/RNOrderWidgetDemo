//
//  OrderWidgetBridge.m
//  OrderDemo
//
//  Created by YOUZONGYAN on 2024/10/25.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import "React/RCTBridgeModule.h"

@interface RCT_EXTERN_MODULE(OrderWidgetModule, NSObject)
+ (bool)requiresMainQueueSetup {
  return NO;
}

RCT_EXTERN_METHOD(startLiveActivity:(NSDictionary *)params)
RCT_EXTERN_METHOD(stopLiveActivity)
RCT_EXTERN_METHOD(updateState:(NSDictionary *)state)
RCT_EXTERN_METHOD(syncPushToStartToken:(NSDictionary *)params)
RCT_EXTERN_METHOD(syncPushToken:(NSDictionary *)params)

@end
