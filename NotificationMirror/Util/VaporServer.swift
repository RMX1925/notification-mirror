//
//  VaporServer.swift
//  NotificationMirror
//
//  Created by Krishna Suryavanshi on 11/07/24.
//

import Foundation

class ServiceBrowserDelegate: NSObject, NetServiceBrowserDelegate {
    private var services: [NetService] = []
    private let onUpdate: ([NetService]) -> Void
    
    init(onUpdate: @escaping ([NetService]) -> Void) {
        self.onUpdate = onUpdate
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        services.append(service)
        if !moreComing {
            onUpdate(services)
        }
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        if let index = services.firstIndex(of: service) {
            services.remove(at: index)
        }
        if !moreComing {
            onUpdate(services)
        }
    }
}
