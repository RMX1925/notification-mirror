//
//  NotificationMirrorApp.swift
//  NotificationMirror
//
//  Created by Krishna Suryavanshi on 11/07/24.
//

import SwiftUI
import UserNotifications
import Network

@main
struct NotificationMirrorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
