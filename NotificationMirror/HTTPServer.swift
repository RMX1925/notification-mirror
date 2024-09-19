//
//  HTTPServer.swift
//  NotificationMirror
//
//  Created by Krishna Suryavanshi on 11/07/24.
//

import Foundation
import UserNotifications
import Vapor
import AppKit
import Cocoa

class VaporServer {
    
    var app: Application!
    
    func start() {

        app = try! Application(.detect())
        try! configure(app)
        app.http.server.configuration.hostname = getWiFiAddress() ?? "192.168.0.0"
        DispatchQueue.global(qos: .background).async {
            do{
                try self.app.run()
            } catch {
                print("Failed to start vapor server: \(error)")
            }
        }
    }
    
    func stop() {
        app.shutdown()
    }
    
    private func getWiFiAddress() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }
        
        for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ptr.pointee
            let addrFamily = interface.ifa_addr.pointee.sa_family
            
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                let name = String(cString: interface.ifa_name)
                if name == "en0" {
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        
        freeifaddrs(ifaddr)
        return address
    }
    
    private func configure(_ app: Application) throws {
        app.post("notifications") { request -> HTTPStatus in
            do {
                let notification = try request.content.decode(NotificationContent.self)
                if let iconFileURL = saveIconFromBase64(base64Data: notification.iconBase64) {
                    self.displayNotification(title: notification.title, text: notification.text, iconFileURL: iconFileURL)
                } else {
                    print("Data not sent")
                }
                
                return .ok
            } catch {
                print("Error: \(error)")
                return .badRequest
            }
        }
        
        app.post("clipboard") { req -> HTTPStatus in
            do {
                let data = try req.content.decode(ClipboardContent.self)
                DispatchQueue.main.async {
                    let appDelegate = NSApp.delegate as! AppDelegate
                    appDelegate.clipboardManager?.updateClipboardContent(content: data.content)
                }
                return .ok
            } catch {
                print("Error in clipboard : \(error)")
                return .badRequest
            }
        }
        
//        app.post("upload") { req -> HTTPStatus in
//            let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("uploaded_file")
//            
//            let data = try req.body.collect().get()
//            
//            do {
//                try data.write(to: filePath)
//            }
//        }
//        
//        app.on(.POST, "upload", body: .collect(maxSize: "10mb")) { req -> HTTPStatus in
//            guard let data = req.body.read else {
//                print("data is not found")
//                return .notFound
//            }
//            
//            let filename =  "uploaded_file"
//            
//            let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(filename)
//            
//            do {
//                try data.write(toFileAt: filePath)
//                return .ok
//            } catch {
//                print("Error geting file : \(error)")
//                return .internalServerError
//            }
//        }
    }
    
    private func requestNotificationAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Request authroization failed: \(error)")
            }
        }
    }
    
    private func displayNotification(title: String, text: String, iconFileURL : URL) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = text
        content.sound = UNNotificationSound.default
        
        if let attachment = try? UNNotificationAttachment(identifier: "icon", url: iconFileURL, options: nil) {
            content.attachments = [attachment]
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
        print("Notification sent")
        
    }
}
