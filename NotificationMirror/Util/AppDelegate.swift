//
//  AppDelegate.swift
//  NotificationMirror
//
//  Created by Krishna Suryavanshi on 12/07/24.
//

import Foundation
import AppKit
import UserNotifications
import Network
import SwiftUI


class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    var server: VaporServer?
    let monitor = NWPathMonitor()
    var service: NetService?
    var clipboardManager : ClipboardManager?
    
    @AppStorage("ipAddress") var ipAddress: String = ""
    let queue = DispatchQueue(label: "NetworkMonitor")
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        UNUserNotificationCenter.current().delegate = self
        server = VaporServer()
        clipboardManager = ClipboardManager()
        startServer()
        startNetworkMonitoring()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        server?.stop()
        stopBonjour()
        monitor.cancel()
    }
    
    func startServer() {
        startBonjour()
        server?.start()
    }
    
    func stopServer() {
        server?.stop()
        stopBonjour()
    }
    
    func restartServer() {
        stopServer()
        startBonjour()
        startServer()
        
    }
    
    func startBonjour() {
        let serviceType = "_notificationmirror._tcp."
        service = NetService(domain: "local.", type: serviceType, name: "", port: 8080)
        service?.delegate = self
        service?.publish()
    }
    
    func startNetworkMonitoring() {
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                DispatchQueue.main.async {
                    self.restartServer()
                }
            }
        }
        monitor.start(queue: queue)
    }
    
    func stopBonjour() {
        service?.stop()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}

extension AppDelegate: NetServiceDelegate {
    func netServiceDidPublish(_ sender: NetService) {
        print("Bonjour service published: \(sender)")
    }
    
    func netService(_ sender: NetService, didNotPublish errorDict: [String : NSNumber]) {
        print("Failed to publish Bonjour service: \(errorDict)")
    }
}
