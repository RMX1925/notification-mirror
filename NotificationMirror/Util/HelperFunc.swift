//
//  HelperFunc.swift
//  NotificationMirror
//
//  Created by Krishna Suryavanshi on 12/07/24.
//

import Foundation
import AppKit


func saveIconFromBase64(base64Data: String) -> URL? {
    if base64Data.count <= 1 {
        return nil
    }
    
    let base64String = base64Data.replacingOccurrences(of: "\n", with: "")
    print(base64String)
    
    guard let data = Data(base64Encoded: base64String) else {
        print("Error: Unable to decode Base64 string")
        return nil
    }
    
    guard let image = NSImage(data: data) else {
        print("Error: Unable to create image from data")
        return nil
    }
    
    let fileManager = FileManager.default
    let tempDirectory = fileManager.temporaryDirectory
    let fileURL = tempDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("png")
    
    guard let tiffData = image.tiffRepresentation,
          let bitmapImage = NSBitmapImageRep(data: tiffData),
          let pngData = bitmapImage.representation(using: .png, properties: [:]) else {
        print("Error: Unable to convert image to PNG data")
        return nil
    }
    
    do {
        try pngData.write(to: fileURL)
        return fileURL
    } catch {
        print("Error saving icon file: \(error)")
        return nil
    }
}
