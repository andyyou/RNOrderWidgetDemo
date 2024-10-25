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
  
  private func parseDate(_ timestamp: Any?) -> Date? {
    if let timeInterval = timestamp as? Double {
        return Date(timeIntervalSince1970: timeInterval / 1000)
    }
    return nil
  }
  
  private func areActivitiesEnabled() -> Bool {
    return ActivityAuthorizationInfo().areActivitiesEnabled
  }
  
  @objc(startActivity:)
  func startLiveActivity(params: NSDictionary) -> Void {
    if (!areActivitiesEnabled()) {
      return
    }
    let carPlate = (params["carPlate"] as? String) ?? "無車牌"
    let last4CardNumber = (params["last4CardNumber"] as? String) ?? ""
    let paymentMethod = params["paymentMethod"] as? String
    guard let estimatedFee = params["estimatedFee"] as? Double else {
      return
    }
    
    let parkedAt = parseDate(params["parkedAt"])
    let chargedAt = parseDate(params["chargedAt"])
    
    let activityAttributes = OrderWidgetAttributes()
    let contentState = OrderWidgetAttributes.ContentState(
      parkedAt: parkedAt,
      chargedAt: chargedAt,
      estimatedFee: estimatedFee,
      last4CardNumber: last4CardNumber,
      carPlate: carPlate,
      paymentMethod: paymentMethod
    )
    let activityContent = ActivityContent(state: contentState,  staleDate: nil)
    do {
      currentActivity = try Activity.request(attributes: activityAttributes, content: activityContent)
    } catch {
      return
    }
    
  }
  
  @objc(stopActivity)
  func stopLiveActivity() -> Void {
    Task {
      for activity in Activity<OrderWidgetAttributes>.activities {
        await activity.end(nil, dismissalPolicy: .immediate)
      }
    }
  }
  
  @objc(updateState:)
  func updateState(state: NSDictionary) -> Void {
    var tmp = currentActivity?.content.state ?? OrderWidgetAttributes.ContentState()
    
    if let carPlate = state["carPlate"] as? String {
      tmp.carPlate = carPlate
    }
    
    if let last4CardNumber = state["last4CardNumber"] as? String {
      tmp.last4CardNumber = last4CardNumber
    }
    
    if let paymentMethod = state["paymentMethod"] as? String {
        tmp.paymentMethod = paymentMethod
    }
    
    if let estimatedFee = state["estimatedFee"] as? Double {
      tmp.estimatedFee = estimatedFee
    }
    
    if let parkedAt = state["parkedAt"] as? TimeInterval {
      tmp.parkedAt = parseDate(parkedAt)
    }
    
    if let chargedAt = state["chargedAt"] as? TimeInterval {
      tmp.chargedAt = parseDate(chargedAt)
    }
    
    let contentState = tmp
        
    Task {
      await currentActivity?.update(
        ActivityContent<OrderWidgetAttributes.ContentState>(
          state: contentState,
          staleDate: nil
        )
      )
    }
  }
}
