//
//  ContentView.swift
//  NotificationMirror
//
//  Created by Krishna Suryavanshi on 11/07/24.
//

import SwiftUI

struct ContentView: View {
    @State private var discoveredServices: [NetService] = []
    @AppStorage("ipAddress") private var ipAddress: String = ""
    
    var body: some View {
        VStack {
            Text("Discovered Services")
                .font(.headline)
            List(discoveredServices, id: \.self) { service in
                Text("\(service.name) - \(service.hostName ?? "Unknown Host")")
            }
            Spacer()
            TextField("IP Address", text: $ipAddress)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
        }
        .onAppear {
            discoverServices()
        }
    }
    
    func discoverServices() {
        let browser = NetServiceBrowser()
        browser.delegate = ServiceBrowserDelegate { services in
            discoveredServices = services
            for service in services {
                print("Discovered service : \(service)")
            }
        }
        browser.searchForServices(ofType: "_notificationmirror._tcp.", inDomain: "local.")
    }
}
