import AppKit
import CoreGraphics
import Foundation

// Renders a 1024x1024 macOS app icon with a continuous superellipse squircle,
// Liquid Glass obsidian backdrop, vibrant capacity ring gauge, and precision
// brushed-titanium external SSD hardware emblem.

let canvasSize: CGFloat = 1024
let iconRect = CGRect(x: 100, y: 100, width: 824, height: 824)
let iconCornerRadius: CGFloat = 185

func makeContinuousRoundedRect(_ rect: CGRect, radius: CGFloat) -> CGPath {
  let path = NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
  if #available(macOS 14.0, *) {
    return path.cgPath
  }
  return CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil)
}

func makeColorSpace() -> CGColorSpace {
  CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB()
}

func makeCGColor(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1.0) -> CGColor {
  let cs = makeColorSpace()
  return CGColor(colorSpace: cs, components: [r, g, b, a])!
}

guard
  let rep = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: Int(canvasSize),
    pixelsHigh: Int(canvasSize),
    bitsPerSample: 8,
    samplesPerPixel: 4,
    hasAlpha: true,
    isPlanar: false,
    colorSpaceName: .calibratedRGB,
    bytesPerRow: 0,
    bitsPerPixel: 0
  ),
  let nsCtx = NSGraphicsContext(bitmapImageRep: rep)
else {
  fatalError("Failed to allocate bitmap context")
}

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = nsCtx
let ctx = nsCtx.cgContext
ctx.setAllowsAntialiasing(true)
ctx.setShouldAntialias(true)
ctx.interpolationQuality = .high
ctx.clear(CGRect(x: 0, y: 0, width: canvasSize, height: canvasSize))

let squirclePath = makeContinuousRoundedRect(iconRect, radius: iconCornerRadius)

// 1. Soft macOS Dock/Finder ambient drop shadow
ctx.saveGState()
ctx.setShadow(
  offset: CGSize(width: 0, height: -16),
  blur: 36,
  color: makeCGColor(0, 0, 0, 0.42)
)
ctx.addPath(squirclePath)
ctx.setFillColor(makeCGColor(0.06, 0.08, 0.12, 1.0))
ctx.fillPath()
ctx.restoreGState()

// 2. Clipped Obsidian Liquid Glass Tile Backdrop
ctx.saveGState()
ctx.addPath(squirclePath)
ctx.clip()

let cs = makeColorSpace()
let bgColors = [
  makeCGColor(0.135, 0.175, 0.245, 1.0),
  makeCGColor(0.085, 0.115, 0.172, 1.0),
  makeCGColor(0.052, 0.072, 0.112, 1.0),
] as CFArray
if let bgGradient = CGGradient(colorsSpace: cs, colors: bgColors, locations: [0.0, 0.52, 1.0]) {
  ctx.drawLinearGradient(
    bgGradient,
    start: CGPoint(x: iconRect.minX, y: iconRect.maxY),
    end: CGPoint(x: iconRect.maxX, y: iconRect.minY),
    options: []
  )
}

// Subtle top-left cool blue-teal atmospheric sheen
let topGlowColors = [
  makeCGColor(0.18, 0.52, 0.96, 0.22),
  makeCGColor(0.12, 0.72, 0.64, 0.08),
  makeCGColor(0.0, 0.0, 0.0, 0.0),
] as CFArray
if let glow = CGGradient(colorsSpace: cs, colors: topGlowColors, locations: [0.0, 0.48, 1.0]) {
  ctx.drawRadialGradient(
    glow,
    startCenter: CGPoint(x: iconRect.minX + 210, y: iconRect.maxY - 170),
    startRadius: 0,
    endCenter: CGPoint(x: iconRect.minX + 210, y: iconRect.maxY - 170),
    endRadius: 560,
    options: []
  )
}

// Bottom-right emerald reflection tint
let bottomGlowColors = [
  makeCGColor(0.16, 0.84, 0.45, 0.16),
  makeCGColor(0.0, 0.0, 0.0, 0.0),
] as CFArray
if let bottomGlow = CGGradient(colorsSpace: cs, colors: bottomGlowColors, locations: [0.0, 1.0]) {
  ctx.drawRadialGradient(
    bottomGlow,
    startCenter: CGPoint(x: iconRect.maxX - 210, y: iconRect.minY + 190),
    startRadius: 0,
    endCenter: CGPoint(x: iconRect.maxX - 210, y: iconRect.minY + 190),
    endRadius: 430,
    options: []
  )
}

// Inner frosted glass card rim
ctx.saveGState()
ctx.addPath(squirclePath)
ctx.setLineWidth(4.0)
ctx.setStrokeColor(makeCGColor(1, 1, 1, 0.16))
ctx.strokePath()
ctx.restoreGState()

// Top specular glass highlight band
ctx.saveGState()
let topHighlightRect = CGRect(
  x: iconRect.minX + 24, y: iconRect.maxY - 120, width: iconRect.width - 48, height: 110)
let topHighlightColors = [
  makeCGColor(1, 1, 1, 0.12),
  makeCGColor(1, 1, 1, 0.0),
] as CFArray
if let thGrad = CGGradient(colorsSpace: cs, colors: topHighlightColors, locations: [0.0, 1.0]) {
  ctx.drawLinearGradient(
    thGrad,
    start: CGPoint(x: topHighlightRect.midX, y: iconRect.maxY),
    end: CGPoint(x: topHighlightRect.midX, y: topHighlightRect.minY),
    options: []
  )
}
ctx.restoreGState()

// 3. Outer Frosted Gauge Backplate Disc
let center = CGPoint(x: 512, y: 516)
let plateRadius: CGFloat = 294
ctx.saveGState()
ctx.setShadow(
  offset: CGSize(width: 0, height: -10),
  blur: 24,
  color: makeCGColor(0, 0, 0, 0.45)
)
ctx.addEllipse(
  in: CGRect(
    x: center.x - plateRadius, y: center.y - plateRadius,
    width: plateRadius * 2, height: plateRadius * 2
  ))
ctx.setFillColor(makeCGColor(0.11, 0.15, 0.21, 0.72))
ctx.fillPath()
ctx.restoreGState()

ctx.saveGState()
ctx.addEllipse(
  in: CGRect(
    x: center.x - plateRadius, y: center.y - plateRadius,
    width: plateRadius * 2, height: plateRadius * 2
  ))
ctx.setLineWidth(2.0)
ctx.setStrokeColor(makeCGColor(1, 1, 1, 0.10))
ctx.strokePath()
ctx.restoreGState()

// 4. Vibrant Storage Gauge Ring (Track + 72% Emerald-to-Cyan Gradient Arc)
let ringRadius: CGFloat = 240
let ringLineWidth: CGFloat = 46

// Track ring
ctx.saveGState()
ctx.addArc(
  center: center,
  radius: ringRadius,
  startAngle: 0,
  endAngle: .pi * 2,
  clockwise: false
)
ctx.setLineWidth(ringLineWidth)
ctx.setStrokeColor(makeCGColor(1, 1, 1, 0.11))
ctx.strokePath()
ctx.restoreGState()

// Glowing progress arc (~72%, clockwise from top 12 o'clock)
let startDeg: CGFloat = 90
let sweepDeg: CGFloat = 262  // ~73%
let endDeg: CGFloat = startDeg - sweepDeg
let startRad = startDeg * .pi / 180
let endRad = endDeg * .pi / 180

let arcMutable = CGMutablePath()
arcMutable.addArc(
  center: center,
  radius: ringRadius,
  startAngle: startRad,
  endAngle: endRad,
  clockwise: true
)
let strokedArc = arcMutable.copy(
  strokingWithWidth: ringLineWidth,
  lineCap: .round,
  lineJoin: .round,
  miterLimit: 10
)

// Soft emerald aura behind arc
ctx.saveGState()
ctx.setShadow(
  offset: .zero,
  blur: 26,
  color: makeCGColor(0.18, 0.88, 0.48, 0.45)
)
ctx.addPath(strokedArc)
ctx.setFillColor(makeCGColor(0.18, 0.88, 0.48, 0.25))
ctx.fillPath()
ctx.restoreGState()

// Crisp gradient fill along the stroked arc
ctx.saveGState()
ctx.addPath(strokedArc)
ctx.clip()
let arcColors = [
  makeCGColor(0.24, 0.92, 0.46, 1.0),  // luminous emerald green
  makeCGColor(0.12, 0.84, 0.68, 1.0),  // mint-teal transition
  makeCGColor(0.20, 0.66, 0.98, 1.0),  // crisp Apple sky blue
] as CFArray
if let arcGrad = CGGradient(colorsSpace: cs, colors: arcColors, locations: [0.0, 0.52, 1.0]) {
  ctx.drawLinearGradient(
    arcGrad,
    start: CGPoint(x: center.x + ringRadius * 0.4, y: center.y + ringRadius),
    end: CGPoint(x: center.x - ringRadius * 0.9, y: center.y - ringRadius * 0.6),
    options: [.drawsBeforeStartLocation, .drawsAfterEndLocation]
  )
}
ctx.restoreGState()

// 5. Centerpiece: Precision Brushed-Titanium External SSD Enclosure
let driveW: CGFloat = 246
let driveH: CGFloat = 296
let driveRect = CGRect(
  x: center.x - driveW / 2,
  y: center.y - driveH / 2,
  width: driveW,
  height: driveH
)
let drivePath = makeContinuousRoundedRect(driveRect, radius: 44)

// Drive shadow
ctx.saveGState()
ctx.setShadow(
  offset: CGSize(width: 0, height: -14),
  blur: 24,
  color: makeCGColor(0, 0, 0, 0.55)
)
ctx.addPath(drivePath)
ctx.setFillColor(makeCGColor(0.75, 0.80, 0.86, 1.0))
ctx.fillPath()
ctx.restoreGState()

// Drive brushed-aluminum gradient body
ctx.saveGState()
ctx.addPath(drivePath)
ctx.clip()

let metalColors = [
  makeCGColor(0.95, 0.97, 0.99, 1.0),
  makeCGColor(0.84, 0.87, 0.91, 1.0),
  makeCGColor(0.70, 0.74, 0.80, 1.0),
] as CFArray
if let metalGrad = CGGradient(colorsSpace: cs, colors: metalColors, locations: [0.0, 0.58, 1.0]) {
  ctx.drawLinearGradient(
    metalGrad,
    start: CGPoint(x: driveRect.minX, y: driveRect.maxY),
    end: CGPoint(x: driveRect.maxX, y: driveRect.minY),
    options: []
  )
}

// Lower darker recessed drive chin band (hardware status bezel)
let bezelHeight: CGFloat = 62
let bezelRect = CGRect(
  x: driveRect.minX, y: driveRect.minY, width: driveRect.width, height: bezelHeight)
let bezelColors = [
  makeCGColor(0.20, 0.24, 0.30, 1.0),
  makeCGColor(0.13, 0.16, 0.21, 1.0),
] as CFArray
if let bezelGrad = CGGradient(colorsSpace: cs, colors: bezelColors, locations: [0.0, 1.0]) {
  ctx.saveGState()
  ctx.clip(to: bezelRect)
  ctx.drawLinearGradient(
    bezelGrad,
    start: CGPoint(x: bezelRect.midX, y: bezelRect.maxY),
    end: CGPoint(x: bezelRect.midX, y: bezelRect.minY),
    options: []
  )
  ctx.restoreGState()
}

// Crisp seam line between silver enclosure and dark lower bezel
ctx.setFillColor(makeCGColor(0, 0, 0, 0.28))
ctx.fill(CGRect(x: driveRect.minX, y: bezelRect.maxY, width: driveRect.width, height: 2.5))
ctx.setFillColor(makeCGColor(1, 1, 1, 0.55))
ctx.fill(CGRect(x: driveRect.minX, y: bezelRect.maxY + 2.5, width: driveRect.width, height: 1.5))

ctx.restoreGState()

// Metallic outer chamfer highlight around SSD body
ctx.saveGState()
ctx.addPath(drivePath)
ctx.setLineWidth(2.0)
ctx.setStrokeColor(makeCGColor(1, 1, 1, 0.72))
ctx.strokePath()
ctx.restoreGState()

// Subtle etched Eject emblem centered on the aluminum face
let faceMidX = driveRect.midX
let faceMidY = bezelRect.maxY + (driveRect.maxY - bezelRect.maxY) * 0.50
let triSize: CGFloat = 46
let triBaseY = faceMidY - 8
let triPath = CGMutablePath()
triPath.move(to: CGPoint(x: faceMidX, y: triBaseY + triSize * 0.92))
triPath.addLine(to: CGPoint(x: faceMidX - triSize, y: triBaseY))
triPath.addLine(to: CGPoint(x: faceMidX + triSize, y: triBaseY))
triPath.closeSubpath()

let barRect = CGRect(x: faceMidX - triSize, y: triBaseY - 22, width: triSize * 2, height: 13)
let barPath = makeContinuousRoundedRect(barRect, radius: 6.5)

ctx.saveGState()
ctx.addPath(triPath)
ctx.addPath(barPath)
ctx.setFillColor(makeCGColor(0.24, 0.29, 0.37, 0.85))
ctx.fillPath()
ctx.restoreGState()

// Precision USB-C port slot + glowing emerald LED dot inside dark lower bezel
let portW: CGFloat = 58
let portH: CGFloat = 15
let portRect = CGRect(
  x: driveRect.midX - portW / 2,
  y: bezelRect.midY - portH / 2,
  width: portW,
  height: portH
)
ctx.saveGState()
ctx.addPath(makeContinuousRoundedRect(portRect, radius: portH / 2))
ctx.setFillColor(makeCGColor(0.05, 0.07, 0.10, 1.0))
ctx.fillPath()
ctx.addPath(makeContinuousRoundedRect(portRect, radius: portH / 2))
ctx.setLineWidth(1.5)
ctx.setStrokeColor(makeCGColor(1, 1, 1, 0.18))
ctx.strokePath()
ctx.restoreGState()

// Glowing emerald activity LED dot on the bezel
let ledCenter = CGPoint(x: driveRect.minX + 46, y: bezelRect.midY)
let ledR: CGFloat = 7.5
ctx.saveGState()
ctx.setShadow(
  offset: .zero,
  blur: 14,
  color: makeCGColor(0.20, 0.95, 0.45, 0.95)
)
ctx.addEllipse(in: CGRect(x: ledCenter.x - ledR, y: ledCenter.y - ledR, width: ledR * 2, height: ledR * 2))
ctx.setFillColor(makeCGColor(0.26, 0.96, 0.50, 1.0))
ctx.fillPath()
ctx.restoreGState()

ctx.restoreGState()  // end icon squircle clip
NSGraphicsContext.restoreGraphicsState()

let outputURL = URL(fileURLWithPath: CommandLine.arguments.dropFirst().first ?? "Assets/AppIcon.png")
try FileManager.default.createDirectory(
  at: outputURL.deletingLastPathComponent(), withIntermediateDirectories: true)
guard let pngData = rep.representation(using: .png, properties: [:]) else {
  fatalError("Failed to encode PNG")
}
try pngData.write(to: outputURL, options: .atomic)
print("Generated icon PNG at \(outputURL.path)")
