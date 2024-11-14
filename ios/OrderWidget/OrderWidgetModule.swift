//
//  OrderWidgetModule.swift
//  OrderDemo
//
//  Created by YOUZONGYAN on 2024/10/25.
//

import Foundation
import ActivityKit
import SwiftUI

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
  
  @objc(syncPushToStartToken:)
  func syncPushToStartToken(params: NSDictionary) -> Void {
    print("Go")
    if #available(iOS 17.2, *) {
      let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
      var memberId = (params["memberId"] as? String) ?? ""
      let memberAccessToken = (params["accessToken"] as? String) ?? ""
      
      Task {
        for try await token in Activity<OrderWidgetAttributes>.pushToStartTokenUpdates {
          let tokenParts = token.map { data in
            String(format: "%02.2hhx", data)
          }
          let token = tokenParts.joined()
          print("Live activity push to start token updated \(token)")

          // 後端紀錄 pushToken
          let body: [String: Any] = [
            "token": token,
            "type": "push_to_start",
            "device_id": deviceId,
          ]
          guard let url = URL(string: "http://localhost:8000/api/live_activity_push_tokens") else {
            print("Invalid request URL")
            return
          }
          var request = URLRequest(url: url)
          request.httpMethod = "POST"
          request.setValue("application/json", forHTTPHeaderField: "Content-Type")
          request.setValue("Bearer \(memberAccessToken)", forHTTPHeaderField: "Authorization")
          
          do {
            let json = try JSONSerialization.data(withJSONObject: body)
            request.httpBody = json
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
              print("Invalid response")
              return
            }
            
            switch httpResponse.statusCode {
            case 200:
              print("Updated push to start token")
            case 401:
              print("Unauthorized bearer token")
            default:
              print("Failed to update push to start token.")
            }
          } catch {
            print("Failed to update push to start token: \(error.localizedDescription)")
          }
        }
      }
    }
  }
  
  @objc(startLiveActivity:)
  func startLiveActivity(params: NSDictionary) -> Void {
    print("Starting live activity")
    
    if (!areActivitiesEnabled()) {
      print("Live activitity not enabled")
      return
    }
    
    let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
    let memberId = (params["memberId"] as? String) ?? ""
    let memberAccessToken = (params["accessToken"] as? String) ?? ""
    let carPlate = (params["carPlate"] as? String) ?? "無車牌"
    let last4CardNumber = (params["last4CardNumber"] as? String) ?? ""
    let paymentMethod = params["paymentMethod"] as? String
    guard let estimatedFee = params["estimatedFee"] as? Double else {
      return
    }
    let parkedAt = parseDate(params["parkedAt"])
    let chargedAt = parseDate(params["chargedAt"])

    if let currentActivity = Activity<OrderWidgetAttributes>.activities.first {
      self.currentActivity = currentActivity
    } else {
      // 若沒有現有的 activity，則建立新的 activity
      do {
        let activityAttributes = OrderWidgetAttributes()
        let contentState = OrderWidgetAttributes.ContentState(
          memberId: memberId,
          memberAccessToken: memberAccessToken,
          parkedAt: parkedAt,
          chargedAt: chargedAt,
          estimatedFee: estimatedFee,
          last4CardNumber: last4CardNumber,
          carPlate: carPlate,
          paymentMethod: paymentMethod
        )
        let activityContent = ActivityContent(state: contentState,  staleDate: nil)
        currentActivity = try Activity.request(attributes: activityAttributes, content: activityContent, pushType: .token)
        print("Live activitity started \(String(describing: currentActivity?.id))")
      } catch {
        print("Error requesting live activity \(error.localizedDescription)")
        return
      }
    }
    
    Task {
      guard let currentActivity else { return }
      
      for try await token in currentActivity.pushTokenUpdates {
        let tokenParts = token.map { data in
          String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        print("Live activity token updated \(token)")
        
        // 後端紀錄 pushToken
        let body: [String: Any] = [
          "token": token,
          "type": "push",
          "device_id": deviceId,
          "activity_id": currentActivity.id,
        ]
        guard let url = URL(string: "http://localhost:8000/api/live_activity_push_tokens") else {
          print("Invalid request URL")
          return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(memberAccessToken)", forHTTPHeaderField: "Authorization")
        
        do {
          let json = try JSONSerialization.data(withJSONObject: body)
          request.httpBody = json
          let (data, response) = try await URLSession.shared.data(for: request)
          
          guard let httpResponse = response as? HTTPURLResponse else {
            print("Invalid response")
            return
          }
          
          switch httpResponse.statusCode {
          case 200:
            print("Updated push token")
          case 401:
            print("Unauthorized bearer token")
          default:
            print("Failed to update push token.")
          }
        } catch {
          print("Failed to update token: \(error.localizedDescription)")
        }
      }
    }
    
  }
  
  @objc(stopLiveActivity)
  func stopLiveActivity() -> Void {
    print("Stop live activity called")
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
