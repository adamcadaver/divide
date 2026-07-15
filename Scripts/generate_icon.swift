#!/usr/bin/env swift
import Cocoa

// Renders the Divide app icon (black rounded square, white division sign) at every
// size macOS expects in an .iconset, then packages it into Resources/AppIcon.icns.
// Run this again (`swift Scripts/generate_icon.swift`) if the design ever changes.

struct IconSpec {
    let filename: String
    let pixelSize: Int
}

let specs: [IconSpec] = [
    IconSpec(filename: "icon_16x16.png", pixelSize: 16),
    IconSpec(filename: "icon_16x16@2x.png", pixelSize: 32),
    IconSpec(filename: "icon_32x32.png", pixelSize: 32),
    IconSpec(filename: "icon_32x32@2x.png", pixelSize: 64),
    IconSpec(filename: "icon_128x128.png", pixelSize: 128),
    IconSpec(filename: "icon_128x128@2x.png", pixelSize: 256),
    IconSpec(filename: "icon_256x256.png", pixelSize: 256),
    IconSpec(filename: "icon_256x256@2x.png", pixelSize: 512),
    IconSpec(filename: "icon_512x512.png", pixelSize: 512),
    IconSpec(filename: "icon_512x512@2x.png", pixelSize: 1024),
]

func renderIcon(pixelSize: Int) -> NSBitmapImageRep {
    let size = CGFloat(pixelSize)
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: pixelSize,
        pixelsHigh: pixelSize,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    )!
    rep.size = NSSize(width: size, height: size)

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

    // Black rounded-square background, matching macOS's app icon proportions
    // (content inset ~1.5%, corner radius ~22% of the square's side).
    let inset = size * 0.015
    let squareRect = NSRect(x: inset, y: inset, width: size - inset * 2, height: size - inset * 2)
    let radius = squareRect.width * 0.2237
    let background = NSBezierPath(roundedRect: squareRect, xRadius: radius, yRadius: radius)
    NSColor.black.setFill()
    background.fill()

    // White division sign, centered.
    let symbolConfig = NSImage.SymbolConfiguration(pointSize: size * 0.5, weight: .semibold)
    if let symbol = NSImage(systemSymbolName: "divide", accessibilityDescription: nil)?
        .withSymbolConfiguration(symbolConfig) {
        let tinted = NSImage(size: symbol.size)
        tinted.lockFocus()
        NSColor.white.set()
        let imageRect = NSRect(origin: .zero, size: symbol.size)
        symbol.draw(in: imageRect)
        imageRect.fill(using: .sourceAtop)
        tinted.unlockFocus()

        let drawRect = NSRect(
            x: (size - tinted.size.width) / 2,
            y: (size - tinted.size.height) / 2,
            width: tinted.size.width,
            height: tinted.size.height
        )
        tinted.draw(in: drawRect)
    }

    NSGraphicsContext.restoreGraphicsState()
    return rep
}

let scriptURL = URL(fileURLWithPath: CommandLine.arguments[0]).resolvingSymlinksInPath()
let scriptsDir = scriptURL.deletingLastPathComponent()
let projectDir = scriptsDir.deletingLastPathComponent()
let resourcesDir = projectDir.appendingPathComponent("Resources")
let iconsetDir = resourcesDir.appendingPathComponent("AppIcon.iconset")

try? FileManager.default.removeItem(at: iconsetDir)
try FileManager.default.createDirectory(at: iconsetDir, withIntermediateDirectories: true)

for spec in specs {
    let rep = renderIcon(pixelSize: spec.pixelSize)
    guard let data = rep.representation(using: .png, properties: [:]) else {
        fatalError("Failed to encode \(spec.filename)")
    }
    let fileURL = iconsetDir.appendingPathComponent(spec.filename)
    try data.write(to: fileURL)
    print("Wrote \(spec.filename)")
}

let icnsURL = resourcesDir.appendingPathComponent("AppIcon.icns")
let process = Process()
process.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
process.arguments = ["-c", "icns", iconsetDir.path, "-o", icnsURL.path]
try process.run()
process.waitUntilExit()

guard process.terminationStatus == 0 else {
    fatalError("iconutil failed with status \(process.terminationStatus)")
}

try? FileManager.default.removeItem(at: iconsetDir)
print("Wrote \(icnsURL.path)")
