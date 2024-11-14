//
//  PushToken.swift
//  OrderDemo
//
//  Created by YOUZONGYAN on 2024/11/8.
//

import Foundation

struct PushToken: Codable, Hashable {
  var deviceId: String
  var token: String
  var type: String
  var activityId: String
}
