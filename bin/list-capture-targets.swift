#!/usr/bin/env swift
import Cocoa
import CoreGraphics

var displayCount: UInt32 = 0
CGGetActiveDisplayList(0, nil, &displayCount)
var displays = [CGDirectDisplayID](repeating: 0, count: Int(displayCount))
CGGetActiveDisplayList(displayCount, &displays, &displayCount)
let mainDisplay = CGMainDisplayID()

print("SCREENS")
for (index, display) in displays.enumerated() {
    let bounds = CGDisplayBounds(display)
    let mainTag = display == mainDisplay ? " [main]" : ""
    let w = Int(bounds.width)
    let h = Int(bounds.height)
    print("  [s\(index + 1)] Screen \(index + 1) — \(w)×\(h)\(mainTag)")
}

let frontmostApp = NSWorkspace.shared.frontmostApplication?.localizedName ?? ""

let options: CGWindowListOption = [.optionOnScreenOnly, .excludeDesktopElements]
guard let windowList = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] else {
    print("\nWINDOWS\n  (unable to enumerate — Screen Recording permission may be required)")
    exit(0)
}

print("\nWINDOWS")
var shown = 0
for window in windowList {
    guard let layer = window[kCGWindowLayer as String] as? Int, layer == 0 else { continue }
    guard let windowID = window[kCGWindowNumber as String] as? UInt32 else { continue }
    let ownerName = window[kCGWindowOwnerName as String] as? String ?? "Unknown"
    let windowName = (window[kCGWindowName as String] as? String) ?? ""

    if let bounds = window[kCGWindowBounds as String] as? [String: CGFloat] {
        let w = bounds["Width"] ?? 0
        let h = bounds["Height"] ?? 0
        if w < 80 || h < 80 { continue }
    }

    let frontTag = (ownerName == frontmostApp && shown == 0) ? " ★" : ""
    let title = windowName.isEmpty ? ownerName : "\(ownerName) — \(windowName)"
    print("  [w\(windowID)]\(frontTag) \(title)")
    shown += 1
}

if shown == 0 {
    print("  (no windows visible — try opening apps first)")
}
