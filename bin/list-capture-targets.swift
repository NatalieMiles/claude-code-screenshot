#!/usr/bin/env swift
import Cocoa
import CoreGraphics

// Emits tab-separated lines: <ID>\t<DISPLAY_STRING>
//   ID = "s1".."sN" for screens (1-based, matches `screencapture -D`)
//        "w<windowID>" for windows (matches `screencapture -l`)
//        "HEADER" for section dividers (not selectable targets)
// The bash picker reads the ID column for lookup and shows only the
// display column to the user, so CoreGraphics IDs never leak into the UI.

// --- SCREENS ---
var displayCount: UInt32 = 0
CGGetActiveDisplayList(0, nil, &displayCount)
var displays = [CGDirectDisplayID](repeating: 0, count: Int(displayCount))
CGGetActiveDisplayList(displayCount, &displays, &displayCount)
let mainDisplay = CGMainDisplayID()

var screenByID: [CGDirectDisplayID: NSScreen] = [:]
for screen in NSScreen.screens {
    if let num = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber {
        screenByID[CGDirectDisplayID(num.uint32Value)] = screen
    }
}

print("HEADER\t─── SCREENS ───")
for (index, display) in displays.enumerated() {
    let bounds = CGDisplayBounds(display)
    let w = Int(bounds.width)
    let h = Int(bounds.height)
    let mainTag = display == mainDisplay ? " [main]" : ""
    let name = screenByID[display]?.localizedName ?? "Screen \(index + 1)"
    print("s\(index + 1)\t🖥  \(name) — \(w)×\(h)\(mainTag)")
}

// --- WINDOWS ---
let frontmostApp = NSWorkspace.shared.frontmostApplication?.localizedName ?? ""

let options: CGWindowListOption = [.optionOnScreenOnly, .excludeDesktopElements]
guard let windowList = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] else {
    print("HEADER\t─── WINDOWS ───")
    print("HEADER\t(unable to enumerate — Screen Recording permission may be required)")
    exit(0)
}

print("HEADER\t─── WINDOWS ───")
var shown = 0
for window in windowList {
    guard let layer = window[kCGWindowLayer as String] as? Int, layer == 0 else { continue }
    guard let windowID = window[kCGWindowNumber as String] as? UInt32 else { continue }
    let ownerName = window[kCGWindowOwnerName as String] as? String ?? "Unknown"
    let windowName = (window[kCGWindowName as String] as? String) ?? ""

    var boundsHint = ""
    if let bounds = window[kCGWindowBounds as String] as? [String: CGFloat] {
        let w = bounds["Width"] ?? 0
        let h = bounds["Height"] ?? 0
        let x = bounds["X"] ?? 0
        let y = bounds["Y"] ?? 0
        if w < 80 || h < 80 { continue }
        boundsHint = "\(Int(w))×\(Int(h)) @ \(Int(x)),\(Int(y))"
    }

    let marker = (ownerName == frontmostApp && shown == 0) ? "★ " : "▫️ "
    let title: String
    if windowName.isEmpty {
        title = boundsHint.isEmpty ? ownerName : "\(ownerName) — \(boundsHint)"
    } else {
        title = "\(ownerName) — \(windowName)"
    }
    print("w\(windowID)\t\(marker) \(title)")
    shown += 1
}

if shown == 0 {
    print("HEADER\t(no windows visible — try opening apps first)")
}
