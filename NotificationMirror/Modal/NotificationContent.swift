//
//  NotificationContent.swift
//  NotificationMirror
//
//  Created by Krishna Suryavanshi on 12/07/24.
//

import Foundation
import Vapor

struct NotificationContent: Content {
    var title: String
    var text : String
    var iconBase64: String
}
