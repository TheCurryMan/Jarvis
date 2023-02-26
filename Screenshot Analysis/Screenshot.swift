//
//  Screenshot.swift
//  Screenshot Analysis
//
//  Created by Avinash Jain on 2/25/23.
//

import Foundation
import AppKit
import UIImageColors
import Vision

enum ScreenshotType: String {
    case color = "color"
}

enum ScreenshotAnalysisType: String {
    case color = "color"
    case words = "words"
    case numbers = "numbers"
}

struct Screenshot: Hashable {
    var name: String
    var type: ScreenshotType
    var image: NSImage?
}

var screenshots: [Screenshot] = []

func screenshotWindowAndSuccess() -> Bool {
    NSPasteboard.general.clearContents()
    let task = Process()
    task.launchPath = "/usr/sbin/screencapture"
    task.arguments = ["-icx"]
    task.launch()
    task.waitUntilExit()
    let status = task.terminationStatus
    print(status)
    
    return status == 0
}

func getImageFromCopy() -> NSImage? {
    let pasteboard = NSPasteboard.general
    guard pasteboard.canReadItem(withDataConformingToTypes:
                                    NSImage.imageTypes) else { return nil }
    guard let image = NSImage(pasteboard: pasteboard) else { return
        nil }
    return image
}

func addScreenshot(screenshots: inout [Screenshot], selectedScreenshot: inout Screenshot?) {
    if screenshotWindowAndSuccess() {
        let image = getImageFromCopy()
        if (image == nil) {
            return
        }
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = " HH:mm:ss yyyy-MM-dd"
        let recentScreenshot = Screenshot(name: formatter.string(from: date), type: .color, image: image)
        selectedScreenshot = recentScreenshot
        screenshots.append(recentScreenshot)
    } else {
        print("No screenshot")
    }
}

func setColor(image: NSImage, color: inout UIColor?) {
    color = NSBitmapImageRep(data: image.tiffRepresentation!)?.colorAt(x: 1, y: 1)
}

func setText(image: NSImage, completionHandler: @escaping (_ request: VNRequest, _ error: Error?) -> Void) {
    guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return }
    let requestHandler = VNImageRequestHandler(cgImage: cgImage)
    let request = VNRecognizeTextRequest(completionHandler: completionHandler)

    do {
        // Perform the text-recognition request.
        try requestHandler.perform([request])
    } catch {
        print("Unable to perform the requests: \(error).")
    }
}
extension [String] {
    func wordAnalysis() -> (characterCount: NSInteger, wordCount: NSInteger) {
        let fullString = self.joined(separator: " ")
        return (fullString.count, fullString.split(separator: " ").count)
    }
    
    func numberAnalysis() -> (sum: Float, average: Float, numbersFound: String) {
        let fullString = self.joined(separator: " ")
        let numbers = fullString.components(separatedBy:CharacterSet.decimalDigits.inverted)
        let floatNumbers = numbers.compactMap { Float($0) }
        return (floatNumbers.reduce(0, +), floatNumbers.reduce(0, +) / Float(floatNumbers.count), numbers.joined(separator: ", "))
        
    }
}

extension NSColor {
    
    var hexString: String {
        guard let rgbColor = usingColorSpaceName(NSColorSpaceName.calibratedRGB) else {
            return "NO COLOR FOUND"
        }
        let red = Int(round(rgbColor.redComponent * 0xFF))
        let green = Int(round(rgbColor.greenComponent * 0xFF))
        let blue = Int(round(rgbColor.blueComponent * 0xFF))
        let hexString = NSString(format: "#%02X%02X%02X", red, green, blue)
        return hexString as String
    }
    
    func components() -> ((alpha: String, red: String, green: String, blue: String, css: String), (alpha: CGFloat, red: CGFloat, green: CGFloat, blue: CGFloat), (alpha: CGFloat, red: CGFloat, green: CGFloat, blue: CGFloat))? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        if var color = self.usingColorSpaceName(NSColorSpaceName.calibratedRGB) {
            color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            let nsTuple = (alpha: alpha, red: red, green: green, blue: blue)
            red = round(red * 255.0)
            green = round(green * 255.0)
            blue = round(blue * 255.0)
            alpha = round(alpha * 255.0)
            let xalpha = String(Int(alpha), radix: 16, uppercase: true)
            let xred = String(Int(red), radix: 16, uppercase: true)
            let xgreen = String(Int(green), radix: 16, uppercase: true)
            let xblue = String(Int(blue), radix: 16, uppercase: true)
            let css = "#\(xred)\(xgreen)\(xblue)"
            let hexTuple = (alpha: xalpha, red: xred, green: xgreen, blue: xblue, css: css)
            let rgbTuple = (alpha: alpha, red: red, green: green, blue: blue)
            return (hexTuple, rgbTuple, nsTuple)
        }
        return nil
    }
    
}
