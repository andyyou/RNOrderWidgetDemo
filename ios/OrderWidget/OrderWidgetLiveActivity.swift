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
    var paymentMethod: String?
    
    func isCharging() -> Bool {
      return chargedAt != nil
    }
    
    func isParking() -> Bool {
      return parkedAt != nil
    }
    
    func isBindedPaymentMethod() -> Bool {
      guard let method = paymentMethod else { return false }
      return !method.isEmpty
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
      VStack(spacing: 8) {
        HStack(alignment: .top) {
          HStack {
            if (context.state.isCharging()) {
              Circle().fill(
                Color(red: 21/255, green: 221/255, blue: 115/255, opacity: 1)
              ).frame(width: 10, height: 10)
              Text("充電中")
                .fontWeight(.bold)
                .foregroundColor(.white)
            } else if (context.state.isParking()) {
              Circle().fill(
                Color(red: 10/255, green: 132/255, blue: 255/255, opacity: 1)
              ).frame(width: 10, height: 10)
              Text("停車中")
                .fontWeight(.bold)
                .foregroundColor(.white)
            }
          }.frame(maxWidth: .infinity, alignment: .leading)
          
          Spacer()
          
          Image("Logo")
            .resizable()
            .scaledToFit()
            .frame(width: 80)
          
        }.frame(
          maxWidth: .infinity,
          alignment: .leading
        )
        
        Spacer().frame(height: 4)
        
        // 車牌 + Timer
        HStack() {
          Circle().fill(.black).frame(width: 10, height: 10)
          Text("\(context.state.carPlate)")
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(.white)
          if (context.state.isCharging()) {
             Text(
               Date(
                 timeIntervalSinceNow: context.state.getChargingTimeSinceNow()
               ),
               style: .timer
             )
             .foregroundColor(.white)
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
             .foregroundColor(.white)
             .font(.system(size: 24, weight: .bold))
             .multilineTextAlignment(.trailing)
             .monospacedDigit()
           }
        }.frame(
          maxWidth: .infinity,
          alignment: .leading
        )
        
        Divider().background(.white)
        
        // 費用 + 支付方式
        HStack {
          Circle().fill(.black).frame(width: 10, height: 10)
          Text("預估費用 \(String(format: "%.0f", context.state.estimatedFee ?? 0))")
            .font(.system(size: 16))
            .foregroundColor(.white)
            .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
          
          Spacer()
          
          let paymentMethods: [String: String] = [
            // 可以在這裡加入更多支付方法，但是不能加入信用卡
            "linepay": "Line Pay",
            "jkopay":"街口",
            "tappay_creditcard":"AMEX \(context.state.last4CardNumber)",
            "gmo_creditcard":"••••\(context.state.last4CardNumber)",
            "gmo_amazon_pay":"Amazon Pay",
            "gmo_au_pay":"au Pay",
          ]
          let paymentMethodText = paymentMethods[context.state.paymentMethod ?? "card"] ?? "••••\(context.state.last4CardNumber)"
          Text(paymentMethodText)
            .foregroundColor(.white)
            
          if (context.state.isBindedPaymentMethod()) {
            Image(systemName: "checkmark.circle.fill")
              .foregroundColor(.green)
          } else {
            Text("已失效")
              .font(.system(size: 12))
              .foregroundColor(.white)
              .padding(.horizontal, 6)
              .padding(.vertical, 2)
              .background(
                Color(red: 209/255, green: 46/255, blue: 37/255, opacity: 0.8)
              ).cornerRadius(2)
          }
          
        }.frame(maxWidth: .infinity, alignment: .leading)
        
      }.padding(.horizontal, 24)
      .frame(
        width: 367,
        height: 136,
        alignment: .leading
      )
      .background(.black)
      .cornerRadius(12)
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
                .foregroundColor(.white)
            } else {
              Circle()
                .fill(Color.blue)
                .frame(width: 12, height: 12)
                .padding(.leading, 8)
              Text("停車中")
                .foregroundColor(.white)
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
                let paymentMethods: [String: String] = [
                  // 可以在這裡添加更多支付方法，但是不能加入信用卡
                  "linepay": "Line Pay",
                  "jkopay":"街口",
                  "tappay_creditcard":"AMEX \(context.state.last4CardNumber)",
                  "gmo_creditcard":"****\(context.state.last4CardNumber)",
                  "gmo_amazon_pay":"Amazon Pay",
                  "gmo_au_pay":"au Pay",
                ]
                let paymentMethodText = paymentMethods[context.state.paymentMethod ?? "card"] ?? "****\(context.state.last4CardNumber)"
                
                Text(paymentMethodText)
                  .foregroundColor(.secondary)
                
                if (context.state.isBindedPaymentMethod()) {
                  Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                } else {
                  Text("已失效")
                    .font(.system(size: 12))
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                      Capsule()
                        .fill(Color.red)
                    )
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
            .padding(.leading, 4)
        } else if (context.state.isParking()) {
          Image(systemName: "parkingsign")
            .imageScale(.medium)
            .foregroundColor(.blue)
            .symbolEffect(.pulse)
            .padding(.leading, 4)
        }
      } compactTrailing: {
        if (context.state.isCharging()) {
          Text(
            Date(
              timeIntervalSinceNow: context.state.getChargingTimeSinceNow()
            ),
            style: .timer
          ).frame(maxWidth: 40, alignment: .trailing)
            .monospacedDigit()
        } else if (context.state.isParking()) {
          Text(
            Date(
              timeIntervalSinceNow: context.state.getParkingTimeSinceNow()
            ),
            style: .timer
          ).frame(maxWidth: 40, alignment: .trailing)
            .monospacedDigit()
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
