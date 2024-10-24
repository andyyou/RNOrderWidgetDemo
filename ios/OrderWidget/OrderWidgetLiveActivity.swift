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
            VStack {
                Text("\(context.state.carPlate)")
            }
            .activityBackgroundTint(Color.black)
            .activitySystemActionForegroundColor(Color.white)

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
                    VStack(spacing: 0) {
                        HStack {
                            HStack(alignment: .bottom) {
                                Text("\(context.state.carPlate)")
                                                .font(.system(size: 18, weight: .bold))
                            }
                            
                            Spacer()
                            
                            // 時間區塊
                            if (context.state.isCharging()) {
                                HStack(alignment: .bottom) {
                                    let date = Date(timeIntervalSinceNow: context.state.getChargingTimeSinceNow())
                                    let hours = Calendar.current.component(.hour, from: date)
                                    
                                    if abs(hours) > 0 {
                                        Text(date, style: .timer)
                                            .font(.system(size: 24, weight: .bold))
                                            .monospacedDigit()
                                            .formatStyle(Date.FormatStyle().hour())
                                        Text("hr")
                                            .font(.system(size: 16))
                                            .foregroundColor(.secondary)
                                        Text(date, style: .timer)
                                            .font(.system(size: 24, weight: .bold))
                                            .monospacedDigit()
                                            .formatStyle(Date.FormatStyle().minute())
                                        Text("min")
                                            .font(.system(size: 16))
                                            .foregroundColor(.secondary)
                                    } else {
                                        Text(date, style: .timer)
                                            .font(.system(size: 24, weight: .bold))
                                            .monospacedDigit()
                                            .formatStyle(Date.FormatStyle().minute())
                                        Text("min")
                                            .font(.system(size: 16))
                                            .foregroundColor(.secondary)
                                        Text(date, style: .timer)
                                            .font(.system(size: 24, weight: .bold))
                                            .monospacedDigit()
                                            .formatStyle(Date.FormatStyle().second())
                                        Text("sec")
                                            .font(.system(size: 16))
                                            .foregroundColor(.secondary)
                                    }
                                }
                            } else if (context.state.isParking()) {
                                HStack(alignment: .bottom) {
                                    let time = context.state.getFormattedParkingTime()
                                    let isShowHour = Int(time.hours) ?? 0 > 0
                                    
                                    if isShowHour {
                                        Text(time.hours)
                                            .font(.system(size: 24, weight: .bold))
                                        Text("hr")
                                            .font(.system(size: 16))
                                            .foregroundColor(.secondary)
                                        Text(time.minutes)
                                            .font(.system(size: 24, weight: .bold))
                                        Text("min")
                                            .font(.system(size: 16))
                                            .foregroundColor(.secondary)
                                    } else {
                                        Text(time.minutes)
                                            .font(.system(size: 24, weight: .bold))
                                        Text("min")
                                            .font(.system(size: 16))
                                            .foregroundColor(.secondary)
                                        Text(time.seconds)
                                            .font(.system(size: 24, weight: .bold))
                                        Text("sec")
                                            .font(.system(size: 16))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                            }
                            
                        }
                        .padding(.top, 16)
                        .padding(.horizontal, 16)
                    }
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
                    .frame(maxWidth: .infinity)
                    .background(
                        Color(.systemGray5)
                        .edgesIgnoringSafeArea(.bottom)
                    )
                }
            } compactLeading: {
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
            } compactTrailing: {
                Text("12:00")
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
