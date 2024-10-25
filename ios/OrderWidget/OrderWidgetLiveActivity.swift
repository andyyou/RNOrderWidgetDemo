//
//  OrderWidgetLiveActivity.swift
//  OrderWidget
//
//  Created by YOUZONGYAN on 2024/10/24.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct OrderWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var parkedAt: Date?
        var chargedAt: Date?
        var estimatedFee: Double?
        var last4CardNumber: String = "****"
        var carPlate: String = "無車牌"
        var paymentMethod: String? = "card"
        
        func isCharging() -> Bool {
            return chargedAt != nil
        }
        
        func isParking() -> Bool {
            return parkedAt != nil
        }
        
        func isBindedPaymentMethod() -> Bool {
            return paymentMethod != nil
        }
        
        func getParkingTimeSinceNow() -> TimeInterval {
            guard let startTime = self.parkedAt else {
                return 0;
            }
            return startTime.timeIntervalSince1970 - Date().timeIntervalSince1970
        }
        
        func getFormattedParkingTime() -> (hours: String, minutes: String, seconds: String) {
            let interval = abs(getParkingTimeSinceNow())
            let hours = Int(interval / 3600)
            let minutes = Int((interval.truncatingRemainder(dividingBy: 3600)) / 60)
            let seconds = Int(interval.truncatingRemainder(dividingBy: 60))
            
            return (String(format: "%02d", hours), String(format: "%02d", minutes), String(format: "%02d", seconds))
        }
        
        func getChargingTimeSinceNow() -> TimeInterval {
            guard let startTime = self.chargedAt else {
                return 0
            }
            return startTime.timeIntervalSince1970 - Date().timeIntervalSince1970
        }
        
        func getFormattedChargingTime() -> (hours: String, minutes: String, seconds: String) {
            let interval = abs(getChargingTimeSinceNow())
            let hours = Int(interval / 3600)
            let minutes = Int((interval.truncatingRemainder(dividingBy: 3600)) / 60)
            let seconds = Int(interval.truncatingRemainder(dividingBy: 60))
            
            return (String(format: "%02d", hours), String(format: "%02d", minutes), String(format: "%02d", seconds))
        }
    }
}

struct OrderWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: OrderWidgetAttributes.self) { context in
            // Lock screen/banner UI
            // 上部區塊
            VStack(spacing: 0) {
                HStack {
                    HStack(alignment: .bottom) {
                        Text("\(context.state.carPlate)")
                                        .font(.system(size: 18, weight: .bold))
                    }
                    
                    Spacer()
                    
                    // 時間區塊
                    if (context.state.isCharging()) {
                        Text(
                          Date(
                            timeIntervalSinceNow: context.state.getChargingTimeSinceNow()
                          ),
                          style: .timer
                        )
                        .font(.system(size: 24, weight: .bold))
                        .multilineTextAlignment(.trailing)
                        .monospacedDigit()
                    } else if (context.state.isParking()) {
                        Text(
                          Date(
                            timeIntervalSinceNow: context.state.getParkingTimeSinceNow()
                          ),
                          style: .timer
                        )
                        .font(.system(size: 24, weight: .bold))
                        .multilineTextAlignment(.trailing)
                        .monospacedDigit()
                    }
                    
                }
                .padding(.top, 16)
                .padding(.horizontal, 16)
            }
            
            Divider().background(Color(.white))
            // 第二個區塊
            VStack {
                HStack {
                    Text("預估費用 \(String(format: "%.0f", context.state.estimatedFee ?? 0))")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Text("********")
                            .foregroundColor(.secondary)
                        Text("\(context.state.last4CardNumber)")
                        if (context.state.isBindedPaymentMethod()) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .font(.system(size: 16))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack(alignment: .center) {
                        if (context.state.isCharging()) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 12, height: 12)
                                .padding(.leading, 8)
                            Text("充電中")
                                .foregroundColor(.green)
                        } else {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 12, height: 12)
                                .padding(.leading, 8)
                            Text("停車中")
                                .foregroundColor(.blue)
                        }
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    // 上部區塊
                    VStack(spacing: 0) {
                        HStack {
                            HStack(alignment: .bottom) {
                                Text("\(context.state.carPlate)")
                                                .font(.system(size: 18, weight: .bold))
                            }
                            
                            Spacer()
                            
                            // 時間區塊
                            if (context.state.isCharging()) {
                                Text(
                                  Date(
                                    timeIntervalSinceNow: context.state.getChargingTimeSinceNow()
                                  ),
                                  style: .timer
                                )
                                .font(.system(size: 24, weight: .bold))
                                .multilineTextAlignment(.trailing)
                                .monospacedDigit()
                            } else if (context.state.isParking()) {
                                Text(
                                  Date(
                                    timeIntervalSinceNow: context.state.getParkingTimeSinceNow()
                                  ),
                                  style: .timer
                                )
                                .font(.system(size: 24, weight: .bold))
                                .multilineTextAlignment(.trailing)
                                .monospacedDigit()
                            }
                            
                        }
                        .padding(.top, 16)
                        .padding(.horizontal, 16)
                    }
                    
                    Divider().background(Color(.white))
                    // 第二個區塊
                    VStack {
                        HStack {
                            Text("預估費用 \(String(format: "%.0f", context.state.estimatedFee ?? 0))")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Text("********")
                                    .foregroundColor(.secondary)
                                Text("\(context.state.last4CardNumber)")
                                if (context.state.isBindedPaymentMethod()) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                            .font(.system(size: 16))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                }
            } compactLeading: {
                if (context.state.isCharging()) {
                    Image(systemName: "bolt.fill")
                      .imageScale(.medium)
                      .foregroundColor(.green)
                      .symbolEffect(.pulse)
                } else if (context.state.isParking()) {
                    Image(systemName: "parkingsign")
                      .imageScale(.medium)
                      .foregroundColor(.blue)
                      .symbolEffect(.pulse)
                }
            } compactTrailing: {
                if (context.state.isCharging()) {
                    Text(
                      Date(
                        timeIntervalSinceNow: context.state.getChargingTimeSinceNow()
                      ),
                      style: .timer
                    ).frame(maxWidth: 32)
                } else if (context.state.isParking()) {
                    Text(
                      Date(
                        timeIntervalSinceNow: context.state.getParkingTimeSinceNow()
                      ),
                      style: .timer
                    ).frame(maxWidth: 32)
                }
            } minimal: {
                if (context.state.isCharging()) {
                    Image(systemName: "bolt.fill")
                      .imageScale(.medium)
                      .foregroundColor(.green)
                      .symbolEffect(.pulse)
                } else {
                    Image(systemName: "parkingsign")
                      .imageScale(.medium)
                      .foregroundColor(.blue)
                      .symbolEffect(.pulse)
                }
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}


extension OrderWidgetAttributes {
    fileprivate static var preview: OrderWidgetAttributes {
        OrderWidgetAttributes()
    }
}

extension OrderWidgetAttributes.ContentState {
    fileprivate static var initState: OrderWidgetAttributes.ContentState {
        OrderWidgetAttributes.ContentState(
            parkedAt: Date(),
            chargedAt: Date(),
            estimatedFee: 223.0,
            last4CardNumber: "9191",
            carPlate: "BEN-9939"
        )
     }
}

#Preview("Notification", as: .content, using: OrderWidgetAttributes.preview) {
   OrderWidgetLiveActivity()
} contentStates: {
    OrderWidgetAttributes.ContentState.initState
}
