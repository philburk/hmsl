// Make "resources/dmg-background.png" and "resources/dmg-background@2x.png",
// the background of the DMG window. dmgbuild combines them for Retina displays.
// It has an arrow from the HMSL icon to the Applications folder icon.
// The positions must match scripts/dmg_settings.py.
//
// Usage: swift scripts/make_dmg_background.swift

import AppKit

let repo = URL(fileURLWithPath: CommandLine.arguments[0])
    .deletingLastPathComponent().deletingLastPathComponent()

let width: CGFloat = 640, height: CGFloat = 400
let iconY: CGFloat = 165          // icon centers, measured from the top
let appX: CGFloat = 170, applicationsX: CGFloat = 470
let ink = NSColor(srgbRed: 0x20 / 255.0, green: 0x20 / 255.0, blue: 0x40 / 255.0, alpha: 1)

func drawBackground(scale: CGFloat) -> NSBitmapImageRep {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil,
                               pixelsWide: Int(width * scale), pixelsHigh: Int(height * scale),
                               bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true,
                               isPlanar: false, colorSpaceName: .deviceRGB,
                               bytesPerRow: 0, bitsPerPixel: 0)!
    rep.size = NSSize(width: width, height: height) // draw in points, scaled to pixels
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    let flip = { (y: CGFloat) in height - y } // AppKit's origin is at the bottom

    // Soft vertical gradient.
    NSGradient(starting: NSColor(white: 1.0, alpha: 1),
               ending: NSColor(srgbRed: 0.92, green: 0.93, blue: 0.96, alpha: 1))!
        .draw(in: NSRect(x: 0, y: 0, width: width, height: height), angle: -90)

    // Arrow between the icons.
    let y = flip(iconY)
    let start = appX + 80, end = applicationsX - 80
    let shaft = NSBezierPath()
    shaft.move(to: NSPoint(x: start, y: y))
    shaft.line(to: NSPoint(x: end - 26, y: y))
    shaft.lineWidth = 6
    shaft.lineCapStyle = .butt
    let arrowColor = ink.blended(withFraction: 0.45, of: .white)!
    arrowColor.setStroke()
    shaft.stroke()
    let head = NSBezierPath()
    head.move(to: NSPoint(x: end, y: y))
    head.line(to: NSPoint(x: end - 26, y: y + 17))
    head.line(to: NSPoint(x: end - 26, y: y - 17))
    head.close()
    arrowColor.setFill()
    head.fill()

    // Instructions.
    func drawCentered(_ text: String, y: CGFloat, size: CGFloat, weight: NSFont.Weight,
                      color: NSColor) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: size, weight: weight),
            .foregroundColor: color,
        ]
        let string = NSAttributedString(string: text, attributes: attributes)
        let bounds = string.size()
        string.draw(at: NSPoint(x: (width - bounds.width) / 2, y: flip(y) - bounds.height / 2))
    }
    drawCentered("Drag HMSL to Applications to install", y: 305, size: 16,
                 weight: .medium, color: ink)
    drawCentered("Hierarchical Music Specification Language", y: 332, size: 12,
                 weight: .regular, color: ink.withAlphaComponent(0.6))

    NSGraphicsContext.restoreGraphicsState()
    return rep
}

// Finder may ignore a background image with an alpha channel.
// AppKit cannot draw into an RGB bitmap without alpha, so copy it into one.
func removeAlpha(_ rep: NSBitmapImageRep) -> NSBitmapImageRep {
    let context = CGContext(data: nil, width: rep.pixelsWide, height: rep.pixelsHigh,
                            bitsPerComponent: 8, bytesPerRow: 0,
                            space: CGColorSpaceCreateDeviceRGB(),
                            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
    context.draw(rep.cgImage!, in: CGRect(x: 0, y: 0, width: rep.pixelsWide, height: rep.pixelsHigh))
    return NSBitmapImageRep(cgImage: context.makeImage()!)
}

for (scale, name) in [(CGFloat(1), "dmg-background.png"), (CGFloat(2), "dmg-background@2x.png")] {
    let url = repo.appendingPathComponent("resources/" + name)
    try! removeAlpha(drawBackground(scale: scale)).representation(using: .png, properties: [:])!
        .write(to: url)
    print("Created \(url.path)")
}
