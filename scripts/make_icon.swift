// Make "resources/hmsl.icns" from "resources/hmsl-logo.svg".
// The logo is trimmed to its visible pixels, then centered on a white
// rounded square that follows Apple's macOS icon grid, so macOS shows
// it as is instead of putting it on a gray background.
//
// Usage: swift scripts/make_icon.swift

import AppKit

let repo = URL(fileURLWithPath: CommandLine.arguments[0])
    .deletingLastPathComponent().deletingLastPathComponent()
let svgURL = repo.appendingPathComponent("resources/hmsl-logo.svg")
let icnsURL = repo.appendingPathComponent("resources/hmsl.icns")
let iconsetURL = FileManager.default.temporaryDirectory
    .appendingPathComponent("hmsl.iconset")

guard let svg = NSImage(contentsOf: svgURL) else {
    fatalError("Cannot load \(svgURL.path)")
}

// Render the SVG at high resolution on a transparent background.
func render(_ image: NSImage, size: Int) -> NSBitmapImageRep {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: size, pixelsHigh: size,
                               bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true,
                               isPlanar: false, colorSpaceName: .deviceRGB,
                               bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    NSGraphicsContext.current?.imageInterpolation = .high
    image.draw(in: NSRect(x: 0, y: 0, width: size, height: size))
    NSGraphicsContext.restoreGraphicsState()
    return rep
}

// Find the bounding box of visible pixels, in image coordinates (origin bottom left).
let work = 2048
let big = render(svg, size: work)
var minX = work, minY = work, maxX = -1, maxY = -1
for y in 0..<work {
    for x in 0..<work {
        if big.colorAt(x: x, y: y)!.alphaComponent > 0.01 {
            minX = min(minX, x); maxX = max(maxX, x)
            minY = min(minY, y); maxY = max(maxY, y)
        }
    }
}
let scale = svg.size.width / CGFloat(work)
// colorAt uses a top-left origin so flip Y for NSImage drawing.
let content = NSRect(x: CGFloat(minX) * scale,
                     y: CGFloat(work - 1 - maxY) * scale,
                     width: CGFloat(maxX - minX + 1) * scale,
                     height: CGFloat(maxY - minY + 1) * scale)

// Apple's icon grid: an 824 x 824 rounded square centered in a 1024 x 1024 canvas.
let tileFraction: CGFloat = 824.0 / 1024.0
let cornerFraction: CGFloat = 185.4 / 824.0
let logoFraction: CGFloat = 0.80 // size of the logo inside the tile

func drawIcon(size: Int) -> NSBitmapImageRep {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: size, pixelsHigh: size,
                               bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true,
                               isPlanar: false, colorSpaceName: .deviceRGB,
                               bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    NSGraphicsContext.current?.imageInterpolation = .high
    let canvas = CGFloat(size)
    let tileSize = canvas * tileFraction
    let tile = NSRect(x: (canvas - tileSize) / 2, y: (canvas - tileSize) / 2,
                      width: tileSize, height: tileSize)
    let corner = tileSize * cornerFraction
    NSColor.white.setFill()
    NSBezierPath(roundedRect: tile, xRadius: corner, yRadius: corner).fill()

    let available = tileSize * logoFraction
    let fit = available / max(content.width, content.height)
    let w = content.width * fit, h = content.height * fit
    let dest = NSRect(x: (canvas - w) / 2, y: (canvas - h) / 2, width: w, height: h)
    svg.draw(in: dest, from: content, operation: .sourceOver, fraction: 1.0)
    NSGraphicsContext.restoreGraphicsState()
    return rep
}

try? FileManager.default.removeItem(at: iconsetURL)
try! FileManager.default.createDirectory(at: iconsetURL, withIntermediateDirectories: true)
for base in [16, 32, 128, 256, 512] {
    for factor in [1, 2] {
        let rep = drawIcon(size: base * factor)
        let name = factor == 1 ? "icon_\(base)x\(base).png" : "icon_\(base)x\(base)@2x.png"
        try! rep.representation(using: .png, properties: [:])!
            .write(to: iconsetURL.appendingPathComponent(name))
    }
}

let iconutil = Process()
iconutil.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
iconutil.arguments = ["-c", "icns", "-o", icnsURL.path, iconsetURL.path]
try! iconutil.run()
iconutil.waitUntilExit()
print("Created \(icnsURL.path)")
