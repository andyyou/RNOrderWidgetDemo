//
//  OrderWidgetModule.swift
//  OrderDemo
//
//  Created by YOUZONGYAN on 2024/10/25.
//

import Foundation
import ActivityKit

@objc(OrderWidgetModule)
class OrderWidgetModule: NSObject {
  private var currentActivity: Activity<OrderWidgetAttributes>?
  
  private func areActivitiesEnabled() -> Bool {
    return ActivityAuthorizationInfo().areActivitiesEnabled
  }
  
  @objc
  func startLiveActivity() -> Void {
    if (!areActivitiesEnabled()) {
      return
    }
    
    let activityAttributes = OrderWidgetAttributes()
    let contentState = OrderWidgetAttributes.ContentState(
      parkedAt: Date(),
      chargedAt: nil,
      estimatedFee: 299,
      last4CardNumber: "1234",
      carPlate: "BEN-2992",
      paymentMethod: "card"
    )
    let activityContent = ActivityContent(state: contentState,  staleDate: nil)
    do {
      currentActivity = try Activity.request(attributes: activityAttributes, content: activityContent)
    } catch {
      //
    }
    
  }
  
  @objc
  func stopLiveActivity() -> Void {
    Task {
      for activity in Activity<OrderWidgetAttributes>.activities {
        await activity.end(nil, dismissalPolicy: .immediate)
      }
    }
  }
  
  @objc
  func updateState() -> Void {
    //
  }
}
