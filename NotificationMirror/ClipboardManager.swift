//
//  ClipboardManager.swift
//  NotificationMirror
//
//  Created by Krishna Suryavanshi on 12/07/24.
//

import Foundation
import AppKit

class ClipboardManager : ObservableObject {
    
    private var changeCount: Int
    private var timer: Timer?
    
    init() {
        self.changeCount = NSPasteboard.general.changeCount
        startMonitoring()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    private func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.checkForChanges()
        }
    }
    
    private func checkForChanges() {
        let pasteboard = NSPasteboard.general
        if pasteboard.changeCount != changeCount {
            changeCount = pasteboard.changeCount
        }
    }
    
    func updateClipboardContent(content: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(content, forType: .string)
    }
}
