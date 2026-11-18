import AppKit
import CoreServices
import QuartzCore
import ServiceManagement
import WidgetKit

// MARK: - Layout

struct WidgetLayout {
  var width: CGFloat = 236
  var height: CGFloat = 90
  var iconX: CGFloat = 16
  var iconY: CGFloat = 8
  var iconSize: CGFloat = 30
  var nameX: CGFloat = 56
  var nameY: CGFloat = 11
  var statusX: CGFloat = 56
  var statusBottom: CGFloat = 15
  var ringX: CGFloat = 12
  var ringY: CGFloat = 7
  var ringSize: CGFloat = 44
  var ejectX: CGFloat = 64
  var ejectY: CGFloat = 7
  var ejectSize: CGFloat = 22
  var cornerRadius: CGFloat = 18
  var nameFontSize: CGFloat = 13
  var statusFontSize: CGFloat = 10
  var ringTextFontSize: CGFloat = 9
  var opacity: CGFloat = 0.70
  var stackSpacing: CGFloat = 12
  var accentRed: CGFloat = 0.0
  var accentGreen: CGFloat = 0.478
  var accentBlue: CGFloat = 1.0
  var showDiskImagesInWidget: Bool = true
  var showMenuBarItem: Bool = true
  var showDesktopCards: Bool = true
  var dimWhenDesktopInactive: Bool = false
  var desktopActiveStyle: Int = 0
  var ringShowsAvailablePercentage: Bool = false

  init(defaults: UserDefaults = .standard, loadSavedValues: Bool = true) {
    guard loadSavedValues else { return }

    func value(_ key: String, _ fallback: CGFloat) -> CGFloat {
      defaults.object(forKey: key) == nil ? fallback : CGFloat(defaults.double(forKey: key))
    }

    width = value("disk-widget-layout-width", width)
    height = value("disk-widget-layout-height", height)
    iconX = value("disk-widget-layout-icon-x", iconX)
    iconY = value("disk-widget-layout-icon-y", iconY)
    iconSize = value("disk-widget-layout-icon-size", iconSize)
    nameX = value("disk-widget-layout-name-x", nameX)
    nameY = value("disk-widget-layout-name-y", nameY)
    statusX = value("disk-widget-layout-status-x", statusX)
    statusBottom = value("disk-widget-layout-status-bottom", statusBottom)
    ringX = value("disk-widget-layout-ring-x", ringX)
    ringY = value("disk-widget-layout-ring-y", ringY)
    ringSize = value("disk-widget-layout-ring-size", ringSize)
    ejectX = value("disk-widget-layout-eject-x", ejectX)
    ejectY = value("disk-widget-layout-eject-y", ejectY)
    ejectSize = value("disk-widget-layout-eject-size", ejectSize)
    cornerRadius = value("disk-widget-layout-corner-radius", cornerRadius)
    nameFontSize = value("disk-widget-layout-name-font", nameFontSize)
    statusFontSize = value("disk-widget-layout-status-font", statusFontSize)
    ringTextFontSize = value("disk-widget-layout-ring-text-font", ringTextFontSize)
    opacity = value("disk-widget-background-opacity", opacity)
    stackSpacing = value("disk-widget-layout-stack-spacing", stackSpacing)
    accentRed = value("disk-widget-accent-red", accentRed)
    accentGreen = value("disk-widget-accent-green", accentGreen)
    accentBlue = value("disk-widget-accent-blue", accentBlue)
    if defaults.object(forKey: "disk-widget-show-disk-images") != nil {
      showDiskImagesInWidget = defaults.bool(forKey: "disk-widget-show-disk-images")
    }
    if defaults.object(forKey: "disk-widget-show-menu-bar-item") != nil {
      showMenuBarItem = defaults.bool(forKey: "disk-widget-show-menu-bar-item")
    }
    if defaults.object(forKey: "disk-widget-show-desktop-cards") != nil {
      showDesktopCards = defaults.bool(forKey: "disk-widget-show-desktop-cards")
    }
    if defaults.object(forKey: "disk-widget-dim-when-inactive") != nil {
      dimWhenDesktopInactive = defaults.bool(forKey: "disk-widget-dim-when-inactive")
    }
    if defaults.object(forKey: "disk-widget-desktop-active-style") != nil {
      desktopActiveStyle = defaults.integer(forKey: "disk-widget-desktop-active-style")
    }
    if defaults.object(forKey: "disk-widget-ring-shows-free") != nil {
      ringShowsAvailablePercentage = defaults.bool(forKey: "disk-widget-ring-shows-free")
    }
    normalize()
  }

  static var factoryDefaults: WidgetLayout {
    WidgetLayout(loadSavedValues: false)
  }

  static var nativeWidgetPreset: WidgetLayout {
    var preset = WidgetLayout(loadSavedValues: false)
    preset.width = 360
    preset.height = 84
    preset.cornerRadius = 22
    preset.opacity = 0.35
    preset.stackSpacing = 10
    preset.iconX = 18
    preset.iconY = 0
    preset.iconSize = 22
    preset.nameX = 62
    preset.nameY = -16
    preset.nameFontSize = 14
    preset.statusX = 62
    preset.statusBottom = 12
    preset.statusFontSize = 10.5
    preset.ringX = 16
    preset.ringY = 0
    preset.ringSize = 46
    preset.ringTextFontSize = 10
    preset.ejectX = 72
    preset.ejectY = 0
    preset.ejectSize = 26
    preset.accentRed = 1.0
    preset.accentGreen = 1.0
    preset.accentBlue = 1.0
    preset.dimWhenDesktopInactive = true
    preset.desktopActiveStyle = 0
    preset.showMenuBarItem = true
    preset.showDesktopCards = true
    preset.normalize()
    return preset
  }

  var accentColor: NSColor {
    NSColor(srgbRed: accentRed, green: accentGreen, blue: accentBlue, alpha: 1)
  }

  mutating func setAccentColor(_ color: NSColor) {
    guard let rgb = color.usingColorSpace(.sRGB) else { return }
    accentRed = rgb.redComponent
    accentGreen = rgb.greenComponent
    accentBlue = rgb.blueComponent
    normalize()
  }

  mutating func normalize() {
    width = min(max(width.rounded(), 180), 360)
    height = min(max(height.rounded(), 64), 120)
    iconSize = min(max(iconSize.rounded(), 16), 48)
    ringSize = min(max(ringSize.rounded(), 34), 60)
    ejectSize = min(max(ejectSize.rounded(), 16), 36)
    cornerRadius = min(max(cornerRadius.rounded(), 8), min(28, (height / 2).rounded()))
    nameFontSize = min(max(nameFontSize.rounded(), 10), 18)
    statusFontSize = min(max(statusFontSize.rounded(), 8), 13)
    ringTextFontSize = min(max(ringTextFontSize.rounded(), 7), 16)
    opacity = min(max(opacity, 0), 1)
    stackSpacing = min(max(stackSpacing.rounded(), 4), 40)
    desktopActiveStyle = min(max(desktopActiveStyle, 0), 2)
    accentRed = min(max(accentRed, 0), 1)
    accentGreen = min(max(accentGreen, 0), 1)
    accentBlue = min(max(accentBlue, 0), 1)

    iconX = min(max(iconX.rounded(), 0), max(0, width - iconSize))
    nameX = min(max(nameX.rounded(), 0), max(0, width - 24))
    statusX = min(max(statusX.rounded(), 0), max(0, width - 24))
    ringX = min(max(ringX.rounded(), 0), max(0, width - ringSize))
    ejectX = min(max(ejectX.rounded(), 0), max(0, width - ejectSize))

    let iconYLimit = max(0, ((height - iconSize) / 2).rounded())
    let ringYLimit = max(0, ((height - ringSize) / 2).rounded())
    let ejectYLimit = max(0, ((height - ejectSize) / 2).rounded())
    iconY = min(max(iconY.rounded(), -iconYLimit), iconYLimit)
    ringY = min(max(ringY.rounded(), -ringYLimit), ringYLimit)
    ejectY = min(max(ejectY.rounded(), -ejectYLimit), ejectYLimit)
    let halfHeight = (height / 2).rounded()
    nameY = min(max(nameY.rounded(), -halfHeight), halfHeight)
    statusBottom = min(max(statusBottom.rounded(), 2), max(2, height - statusFontSize - 2))
  }

  func normalized() -> WidgetLayout {
    var copy = self
    copy.normalize()
    return copy
  }

  func save(to defaults: UserDefaults = .standard) {
    let layout = normalized()
    defaults.set(Double(layout.width), forKey: "disk-widget-layout-width")
    defaults.set(Double(layout.height), forKey: "disk-widget-layout-height")
    defaults.set(Double(layout.iconX), forKey: "disk-widget-layout-icon-x")
    defaults.set(Double(layout.iconY), forKey: "disk-widget-layout-icon-y")
    defaults.set(Double(layout.iconSize), forKey: "disk-widget-layout-icon-size")
    defaults.set(Double(layout.nameX), forKey: "disk-widget-layout-name-x")
    defaults.set(Double(layout.nameY), forKey: "disk-widget-layout-name-y")
    defaults.set(Double(layout.statusX), forKey: "disk-widget-layout-status-x")
    defaults.set(Double(layout.statusBottom), forKey: "disk-widget-layout-status-bottom")
    defaults.set(Double(layout.ringX), forKey: "disk-widget-layout-ring-x")
    defaults.set(Double(layout.ringY), forKey: "disk-widget-layout-ring-y")
    defaults.set(Double(layout.ringSize), forKey: "disk-widget-layout-ring-size")
    defaults.set(Double(layout.ejectX), forKey: "disk-widget-layout-eject-x")
    defaults.set(Double(layout.ejectY), forKey: "disk-widget-layout-eject-y")
    defaults.set(Double(layout.ejectSize), forKey: "disk-widget-layout-eject-size")
    defaults.set(Double(layout.cornerRadius), forKey: "disk-widget-layout-corner-radius")
    defaults.set(Double(layout.nameFontSize), forKey: "disk-widget-layout-name-font")
    defaults.set(Double(layout.statusFontSize), forKey: "disk-widget-layout-status-font")
    defaults.set(Double(layout.ringTextFontSize), forKey: "disk-widget-layout-ring-text-font")
    defaults.set(Double(layout.opacity), forKey: "disk-widget-background-opacity")
    defaults.set(Double(layout.stackSpacing), forKey: "disk-widget-layout-stack-spacing")
    defaults.set(Double(layout.accentRed), forKey: "disk-widget-accent-red")
    defaults.set(Double(layout.accentGreen), forKey: "disk-widget-accent-green")
    defaults.set(Double(layout.accentBlue), forKey: "disk-widget-accent-blue")
    defaults.set(layout.showDiskImagesInWidget, forKey: "disk-widget-show-disk-images")
    defaults.set(layout.showMenuBarItem, forKey: "disk-widget-show-menu-bar-item")
    defaults.set(layout.showDesktopCards, forKey: "disk-widget-show-desktop-cards")
    defaults.set(layout.dimWhenDesktopInactive, forKey: "disk-widget-dim-when-inactive")
    defaults.set(layout.desktopActiveStyle, forKey: "disk-widget-desktop-active-style")
    defaults.set(layout.ringShowsAvailablePercentage, forKey: "disk-widget-ring-shows-free")
  }
}

// MARK: - Card interaction

final class DiskCardView: NSView {
  var acceptsFiles: (() -> Bool)?
  var rejectedFileDropReason: (() -> String?)?
  var RejectedDropHoverChanged: ((String?) -> Void)?
  var receivesFiles: (([URL]) -> Bool)?
  var highlightsDrop: ((Bool) -> Void)?
  var opensDisk: (() -> Void)?
  var singleClickedCard: (() -> Bool)?
  var hoverChanged: ((Bool) -> Void)?
  var pressChanged: ((Bool) -> Void)?
  var appearanceChanged: (() -> Void)?
  var layoutChanged: (() -> Void)?
  var showsSettingsMenu: ((NSEvent) -> Void)?
  var groupDragBegan: (() -> Void)?
  var groupDragChanged: ((NSPoint) -> Void)?
  var groupDragEnded: (() -> Void)?
  var reorderDragBegan: (() -> Void)?
  var reorderDragChanged: ((NSPoint) -> Void)?
  var reorderDragEnded: (() -> Void)?

  private enum DragMode { case none, group, reorder }
  private var dragMode: DragMode = .none
  private var dragStart: NSPoint?
  private var windowStart: NSPoint?
  private var didDragWindow = false

  func cancelActiveDrag() {
    dragStart = nil
    windowStart = nil
    didDragWindow = false
    dragMode = .none
    pressChanged?(false)
  }

  override func viewDidChangeEffectiveAppearance() {
    super.viewDidChangeEffectiveAppearance()
    appearanceChanged?()
  }

  override func layout() {
    super.layout()
    layoutChanged?()
  }

  override func updateTrackingAreas() {
    super.updateTrackingAreas()
    trackingAreas.forEach(removeTrackingArea)
    addTrackingArea(
      NSTrackingArea(
        rect: .zero,
        options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
        owner: self
      ))
  }

  override func mouseEntered(with event: NSEvent) { hoverChanged?(true) }
  override func mouseExited(with event: NSEvent) { hoverChanged?(false) }

  override func hitTest(_ point: NSPoint) -> NSView? {
    let hit = super.hitTest(point)
    return hit is NSButton || hit is UsageRingView ? hit : self
  }

  override func mouseDown(with event: NSEvent) {
    guard let window else { return }
    dragStart = NSEvent.mouseLocation
    windowStart = window.frame.origin
    didDragWindow = false
    dragMode = .none
    pressChanged?(true)
  }

  override func mouseDragged(with event: NSEvent) {
    guard let dragStart, let windowStart, let window else { return }
    let current = NSEvent.mouseLocation
    let dx = (current.x - dragStart.x).rounded()
    let dy = (current.y - dragStart.y).rounded()
    guard abs(dx) > 4 || abs(dy) > 4 else { return }

    if !didDragWindow {
      didDragWindow = true
      pressChanged?(false)
      dragMode = event.modifierFlags.contains(.option) ? .reorder : .group
      switch dragMode {
      case .reorder:
        NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .default)
        reorderDragBegan?()
      case .group:
        groupDragBegan?()
      case .none:
        break
      }
    }

    let delta = NSPoint(x: dx, y: dy)
    switch dragMode {
    case .reorder:
      reorderDragChanged?(delta)
    case .group:
      if let groupDragChanged {
        groupDragChanged(delta)
      } else {
        window.setFrameOrigin(NSPoint(x: windowStart.x + dx, y: windowStart.y + dy))
      }
    case .none:
      break
    }
  }

  override func mouseUp(with event: NSEvent) {
    pressChanged?(false)
    if didDragWindow {
      switch dragMode {
      case .reorder: reorderDragEnded?()
      case .group: groupDragEnded?()
      case .none: break
      }
    } else if event.clickCount == 2 {
      opensDisk?()
    } else if event.clickCount == 1 {
      _ = singleClickedCard?()
    }
    cancelActiveDrag()
  }

  override func rightMouseDown(with event: NSEvent) {
    pressChanged?(false)
    showsSettingsMenu?(event)
  }

  override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
    guard sender.draggingPasteboard.canReadObject(forClasses: [NSURL.self], options: nil) else {
      return []
    }
    guard acceptsFiles?() == true else {
      if let reason = rejectedFileDropReason?() {
        RejectedDropHoverChanged?(reason)
      }
      return []
    }
    NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .default)
    highlightsDrop?(true)
    return .copy
  }

  override func draggingExited(_ sender: NSDraggingInfo?) {
    RejectedDropHoverChanged?(nil)
    highlightsDrop?(false)
  }

  override func draggingEnded(_ sender: NSDraggingInfo) {
    RejectedDropHoverChanged?(nil)
    highlightsDrop?(false)
  }

  override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
    acceptsFiles?() == true
  }

  override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
    defer {
      RejectedDropHoverChanged?(nil)
      highlightsDrop?(false)
    }
    guard
      let urls = sender.draggingPasteboard.readObjects(forClasses: [NSURL.self], options: nil)
        as? [URL],
      !urls.isEmpty
    else { return false }
    let accepted = receivesFiles?(urls) ?? false
    if accepted {
      NSHapticFeedbackManager.defaultPerformer.perform(.levelChange, performanceTime: .default)
    }
    return accepted
  }
}

final class ContextForwardingButton: NSButton {
  var hoverChanged: ((Bool) -> Void)?

  private var isHovered = false {
    didSet { if isHovered != oldValue { needsDisplay = true } }
  }

  override func updateTrackingAreas() {
    super.updateTrackingAreas()
    trackingAreas.forEach(removeTrackingArea)
    addTrackingArea(
      NSTrackingArea(
        rect: .zero,
        options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
        owner: self
      ))
  }

  override func mouseEntered(with event: NSEvent) {
    isHovered = true
    hoverChanged?(true)
    superview?.mouseEntered(with: event)
  }

  override func mouseExited(with event: NSEvent) {
    isHovered = false
    hoverChanged?(false)
  }

  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
  }

  override func rightMouseDown(with event: NSEvent) {
    superview?.rightMouseDown(with: event)
  }
}

final class UsageRingView: NSView {
  var fraction: CGFloat = 0 {
    didSet {
      if abs(fraction - oldValue) > 0.0005 { needsDisplay = true }
    }
  }
  var centerText = "—" {
    didSet {
      if centerText != oldValue { needsDisplay = true }
    }
  }
  var textFontSize: CGFloat = 9 {
    didSet {
      if abs(textFontSize - oldValue) > 0.01 { needsDisplay = true }
    }
  }
  var accentColor: NSColor = .systemBlue {
    didSet {
      if accentColor != oldValue { needsDisplay = true }
    }
  }
  var isBusy: Bool = false {
    didSet {
      guard isBusy != oldValue else { return }
      updateSpinTimer()
      needsDisplay = true
    }
  }
  var isTransferring: Bool = false {
    didSet {
      if isTransferring != oldValue { needsDisplay = true }
    }
  }
  var isMonochromeDimmed: Bool = false {
    didSet {
      if isMonochromeDimmed != oldValue { needsDisplay = true }
    }
  }
  var ringClicked: (() -> Void)?
  private var spinPhase: CGFloat = 0
  private var spinTimer: Timer?
  private var mouseDownLocation: NSPoint?
  private var forwardedDrag = false
  var hoverChanged: ((Bool) -> Void)?
  override var isOpaque: Bool { false }

  deinit {
    spinTimer?.invalidate()
  }

  private func updateSpinTimer() {
    spinTimer?.invalidate()
    spinTimer = nil
    guard isBusy else { return }
    let timer = Timer(timeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
      guard let self else { return }
      self.spinPhase = (self.spinPhase - 12).truncatingRemainder(dividingBy: 360)
      self.needsDisplay = true
    }
    spinTimer = timer
    RunLoop.main.add(timer, forMode: .common)
  }

  override func updateTrackingAreas() {
    super.updateTrackingAreas()
    trackingAreas.forEach(removeTrackingArea)
    addTrackingArea(
      NSTrackingArea(
        rect: .zero,
        options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
        owner: self
      ))
  }

  override func mouseEntered(with event: NSEvent) { hoverChanged?(true) }
  override func mouseExited(with event: NSEvent) { hoverChanged?(false) }

  override func mouseDown(with event: NSEvent) {
    mouseDownLocation = NSEvent.mouseLocation
    forwardedDrag = false
    superview?.mouseDown(with: event)
  }

  override func mouseDragged(with event: NSEvent) {
    if let start = mouseDownLocation {
      let current = NSEvent.mouseLocation
      if abs(current.x - start.x) > 4 || abs(current.y - start.y) > 4 {
        forwardedDrag = true
      }
    }
    superview?.mouseDragged(with: event)
  }

  override func mouseUp(with event: NSEvent) {
    if !forwardedDrag && event.clickCount == 1 {
      ringClicked?()
      mouseDownLocation = nil
      superview?.mouseUp(with: event)
      return
    }
    mouseDownLocation = nil
    forwardedDrag = false
    superview?.mouseUp(with: event)
  }

  override func rightMouseDown(with event: NSEvent) { superview?.rightMouseDown(with: event) }

  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    let lineWidth: CGFloat = max(4.2, (min(bounds.width, bounds.height) * 0.11).rounded())
    let radius = max(1, min(bounds.width, bounds.height) / 2 - lineWidth)
    let center = NSPoint(x: bounds.midX, y: bounds.midY)

    let track = NSBezierPath()
    track.lineWidth = lineWidth
    track.lineCapStyle = .round
    track.appendArc(withCenter: center, radius: radius, startAngle: 90, endAngle: 450)
    NSColor.white.withAlphaComponent(isMonochromeDimmed ? 0.15 : 0.20).setStroke()
    track.stroke()

    if isBusy {
      let spinner = NSBezierPath()
      spinner.lineWidth = lineWidth
      spinner.lineCapStyle = .round
      spinner.appendArc(
        withCenter: center,
        radius: radius,
        startAngle: 90 + spinPhase,
        endAngle: 90 + spinPhase - 95,
        clockwise: true
      )
      (isMonochromeDimmed
        ? NSColor.white.withAlphaComponent(0.78)
        : accentColor.withAlphaComponent(0.90)
      ).setStroke()
      spinner.stroke()
    } else {
      let clamped = min(max(fraction, 0), 1)
      if clamped > 0 {
        let usage = NSBezierPath()
        usage.lineWidth = lineWidth
        usage.lineCapStyle = .round
        usage.appendArc(
          withCenter: center,
          radius: radius,
          startAngle: 90,
          endAngle: 90 - 360 * clamped,
          clockwise: true
        )
        let ringColor: NSColor
        if isMonochromeDimmed {
          ringColor = NSColor.white.withAlphaComponent(0.78)
        } else if isTransferring {
          ringColor = .systemGreen
        } else if clamped >= 0.9 {
          ringColor = .systemOrange
        } else {
          ringColor = accentColor.withAlphaComponent(0.95)
        }
        ringColor.setStroke()
        usage.stroke()
      }
    }

    let attributes: [NSAttributedString.Key: Any] = [
      .font: NSFont.monospacedDigitSystemFont(ofSize: textFontSize, weight: .semibold),
      .foregroundColor: NSColor.white.withAlphaComponent(isMonochromeDimmed ? 0.84 : 0.96),
    ]
    let text = centerText as NSString
    let size = text.size(withAttributes: attributes)
    text.draw(
      at: NSPoint(x: bounds.midX - size.width / 2, y: bounds.midY - size.height / 2),
      withAttributes: attributes
    )
  }
}

// MARK: - Disk panel

final class DiskPanel: NSPanel, NSWindowDelegate {
  private enum PanelState {
    case connected
    case unmounting
    case unmounted
    case reconnecting
    case fullyEjecting
    case disconnected
  }

  private struct DiskTarget {
    let volumeIdentifier: String
    let wholeDiskIdentifier: String?
    let volumeUUID: String?
  }

  let diskName: String
  let isPreviewPlaceholder: Bool
  private(set) var isDiskImage: Bool

  private let nameLabel = NSTextField(labelWithString: "")
  private let statusLabel = NSTextField(labelWithString: "")
  private let diskIcon = NSImageView()
  private let iconBadgeView = NSView()
  private let formatBadgeBox = NSView()
  private let formatBadgeLabel = NSTextField(labelWithString: "")
  private let inlineBarTrack = NSView()
  private let inlineBarFill = NSView()
  private let ejectPillView = NSView()
  private let usageRing = UsageRingView()
  private let ejectButton = ContextForwardingButton()
  private let materialView = NSVisualEffectView()
  private var glassBackgroundView: NSView?
  private let surfaceBaseLayer = CALayer()
  private let ambientGradientLayer = CAGradientLayer()
  private var surface: DiskCardView!

  private var volumeURL: URL?
  private var isReadOnlyVolume = false
  private var isRemovableMedia = false
  private var volumeFormatDescription: String?
  private var lastUsedBytes: Int = 0
  private var lastAvailableBytes: Int = 0
  private var lastTotalBytes: Int = 0
  private var ringShowsAvailablePercentage = false
  private var currentDisplayName: String = ""
  private var lastVolumeUUID: String?
  private var reconnectVolumeIdentifier: String?
  private var reconnectWholeDiskIdentifier: String?
  private var state: PanelState = .disconnected
  private var disconnectedMessage = "未连接"
  private var operationGeneration = 0
  private var hasOrderedOnDesktop = false
  private var isVerifyingBackingDevice = false
  private var currentEjectSymbol = ""
  private var currentDiskSymbol = ""
  private var statusOverrideUntil: Date?
  private var lastUnmountFailed = false
  private var maskCornerRadius: CGFloat = -1
  private var maskSize: NSSize = .zero

  private var isCopyingFiles = false
  private var cancelCopyRequested = false
  private let copyCancelLock = NSLock()
  private var lastCopiedURLs: [URL] = []
  private var revealCopiedItemsUntil: Date?

  private var hoverDetails = ""
  private var hoverTimer: Timer?
  private var isDropTarget = false {
    didSet { if isDropTarget != oldValue { updateAppearance() } }
  }
  private var isCardHovered = false {
    didSet { if isCardHovered != oldValue { updateAppearance() } }
  }
  private var isEjectHovered = false {
    didSet { if isEjectHovered != oldValue { updateAppearance() } }
  }
  private var isCardPressed = false {
    didSet { if isCardPressed != oldValue { updateAppearance() } }
  }
  private var isReorderActive = false {
    didSet { if isReorderActive != oldValue { updateAppearance() } }
  }
  private var isDesktopActive = true {
    didSet { if isDesktopActive != oldValue { updateAppearance() } }
  }
  private var dimWhenDesktopInactive = false {
    didSet { if dimWhenDesktopInactive != oldValue { updateAppearance() } }
  }
  private var desktopActiveStyle = 0 {
    didSet { if desktopActiveStyle != oldValue { updateAppearance() } }
  }
  var cardIndex = 0 {
    didSet { if cardIndex != oldValue { updateAppearance() } }
  }
  private var backgroundOpacity: CGFloat = 0.70
  private var isHiddenForDesktopPresentation = false
  private var hideDesktopCardWindow = false
  private var accentColor: NSColor = .systemBlue
  private var currentBarFraction: CGFloat = 0
  private var currentCardHeight: CGFloat = 90
  private var inlineBarFillWidthConstraint: NSLayoutConstraint!

  private let copyQueue = DispatchQueue(label: "DiskWidget.CopyQueue", qos: .utility)

  private var iconXConstraint: NSLayoutConstraint!
  private var iconYConstraint: NSLayoutConstraint!
  private var iconWidthConstraint: NSLayoutConstraint!
  private var iconHeightConstraint: NSLayoutConstraint!
  private var nameXConstraint: NSLayoutConstraint!
  private var nameYConstraint: NSLayoutConstraint!
  private var statusXConstraint: NSLayoutConstraint!
  private var ejectCenterConstraint: NSLayoutConstraint!
  private var ejectXConstraint: NSLayoutConstraint!
  private var ejectWidthConstraint: NSLayoutConstraint!
  private var ejectHeightConstraint: NSLayoutConstraint!
  private var ringCenterConstraint: NSLayoutConstraint!
  private var ringXConstraint: NSLayoutConstraint!
  private var statusBottomConstraint: NSLayoutConstraint!
  private var ringWidthConstraint: NSLayoutConstraint!
  private var ringHeightConstraint: NSLayoutConstraint!

  var removalRequested: ((DiskPanel) -> Void)?
  var layoutEditorRequested: (() -> Void)?
  var ringModeToggleRequested: (() -> Void)?
  var ejectAllRequested: (() -> Void)?
  var groupDragBegan: ((DiskPanel) -> Void)?
  var groupDragChanged: ((DiskPanel, NSPoint) -> Void)?
  var groupDragEnded: ((DiskPanel) -> Void)?
  var reorderDragBegan: ((DiskPanel) -> Void)?
  var reorderDragChanged: ((DiskPanel, NSPoint) -> Void)?
  var reorderDragEnded: ((DiskPanel) -> Void)?
  var stateChanged: (() -> Void)?

  deinit {
    hoverTimer?.invalidate()
  }

  override var canBecomeKey: Bool { false }
  override var canBecomeMain: Bool { false }

  /// DesktopPlacement already manages multi-monitor clamping across all connected
  /// screens. Prevent AppKit from constraining secondary-display coordinates back
  /// to `NSScreen.main` or shifting cards below the menu bar of another screen.
  override func constrainFrameRect(_ frameRect: NSRect, to screen: NSScreen?) -> NSRect {
    frameRect
  }

  override func orderOut(_ sender: Any?) {
    hasOrderedOnDesktop = false
    surface?.cancelActiveDrag()
    super.orderOut(sender)
  }

  init(
    diskName: String,
    initialVolumeUUID: String? = nil,
    isDiskImage: Bool = false,
    isPreviewPlaceholder: Bool = false,
    initialLayout: WidgetLayout
  ) {
    self.diskName = diskName
    self.isDiskImage = isDiskImage
    self.isPreviewPlaceholder = isPreviewPlaceholder
    self.currentDisplayName = diskName

    let layout = initialLayout.normalized()
    super.init(
      contentRect: NSRect(x: 0, y: 0, width: layout.width, height: layout.height),
      styleMask: [.borderless, .nonactivatingPanel],
      backing: .buffered,
      defer: false
    )

    lastVolumeUUID =
      initialVolumeUUID
      ?? UserDefaults.standard.string(forKey: "disk-widget-volume-uuid-\(diskName)")

    isOpaque = false
    backgroundColor = .clear
    appearance = NSAppearance(named: .darkAqua)
    hasShadow = true
    level = Self.desktopWidgetLevel
    setForceMainAppearance(true)
    // Keep desktop cards pinned on desktop spaces (`.stationary` prevents Show Desktop
    // hiding on wallpaper click, `.fullScreenNone` excludes cards from Fullscreen
    // App Spaces so WindowServer slides cards natively with the Desktop Space).
    collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle, .fullScreenNone]
    hidesOnDeactivate = false
    ignoresMouseEvents = false
    acceptsMouseMovedEvents = true
    animationBehavior = .none
    delegate = self
    becomesKeyOnlyIfNeeded = true

    let card = DiskCardView(frame: contentView?.bounds ?? .zero)
    card.acceptsFiles = { [weak self] in
      guard let self, !self.isPreviewPlaceholder else { return false }
      return self.state == .connected && self.volumeURL != nil && !self.isReadOnlyVolume
        && !self.isCopyingFiles
    }
    card.rejectedFileDropReason = { [weak self] in
      guard let self else { return nil }
      if self.isPreviewPlaceholder { return "预览卡片不支持拖放复制" }
      if self.isReadOnlyVolume {
        if let fmt = self.volumeFormatDescription, !fmt.isEmpty {
          return "只读格式 (\(fmt)) · 无法写入"
        }
        return "当前卷为只读格式 · 无法写入"
      }
      if self.isCopyingFiles { return "当前正在复制文件…" }
      return nil
    }
    card.RejectedDropHoverChanged = { [weak self] message in
      guard let self else { return }
      if let message {
        self.statusOverrideUntil = Date().addingTimeInterval(3.0)
        self.statusLabel.stringValue = message
      } else {
        self.statusOverrideUntil = nil
        if !self.isReorderActive && !self.isCopyingFiles {
          self.statusLabel.stringValue = self.hoverDetails
        }
      }
    }
    card.receivesFiles = { [weak self] urls in self?.copyDroppedFiles(urls) ?? false }
    card.highlightsDrop = { [weak self] highlighted in self?.isDropTarget = highlighted }
    card.opensDisk = { [weak self] in self?.openDisk() }
    card.singleClickedCard = { [weak self] in
      guard let self else { return false }
      if let until = self.revealCopiedItemsUntil, Date() < until, !self.lastCopiedURLs.isEmpty {
        self.revealLastCopiedItemsInFinder()
        return true
      }
      return false
    }
    card.hoverChanged = { [weak self] hovering in self?.isCardHovered = hovering }
    card.pressChanged = { [weak self] pressed in self?.isCardPressed = pressed }
    card.appearanceChanged = { [weak self] in self?.updateAppearance() }
    card.showsSettingsMenu = { [weak self] event in self?.showSettingsMenu(for: event) }
    card.groupDragBegan = { [weak self] in
      guard let self else { return }
      self.groupDragBegan?(self)
    }
    card.groupDragChanged = { [weak self] delta in
      guard let self else { return }
      self.groupDragChanged?(self, delta)
    }
    card.groupDragEnded = { [weak self] in
      guard let self else { return }
      self.groupDragEnded?(self)
    }
    card.reorderDragBegan = { [weak self] in
      guard let self else { return }
      self.reorderDragBegan?(self)
    }
    card.reorderDragChanged = { [weak self] delta in
      guard let self else { return }
      self.reorderDragChanged?(self, delta)
    }
    card.reorderDragEnded = { [weak self] in
      guard let self else { return }
      self.reorderDragEnded?(self)
    }
    card.layoutChanged = { [weak self] in
      self?.updateInlineBarFillWidth()
    }
    card.registerForDraggedTypes([.fileURL])
    surface = card
    surface.toolTip = "拖动移动整组 · 按住 ⌥ 拖动调整顺序 · 单击圆环切换已用/剩余比例"
    surface.autoresizingMask = [.width, .height]
    surface.wantsLayer = true
    surface.layer?.cornerRadius = layout.cornerRadius
    surface.layer?.cornerCurve = .continuous
    surface.layer?.masksToBounds = true
    contentView = surface

    materialView.material = .popover
    materialView.blendingMode = .behindWindow
    materialView.state = .active
    materialView.translatesAutoresizingMaskIntoConstraints = false
    materialView.wantsLayer = true
    materialView.layer?.cornerRadius = layout.cornerRadius
    materialView.layer?.cornerCurve = .continuous
    materialView.layer?.masksToBounds = true
    surfaceBaseLayer.cornerRadius = layout.cornerRadius
    surfaceBaseLayer.cornerCurve = .continuous
    surfaceBaseLayer.frame = NSRect(x: 0, y: 0, width: layout.width, height: layout.height)
    ambientGradientLayer.startPoint = CGPoint(x: 0, y: 1)
    ambientGradientLayer.endPoint = CGPoint(x: 1, y: 0)
    ambientGradientLayer.locations = [0, 0.52, 1]
    ambientGradientLayer.cornerRadius = layout.cornerRadius
    ambientGradientLayer.cornerCurve = .continuous
    ambientGradientLayer.frame = NSRect(x: 0, y: 0, width: layout.width, height: layout.height)
    surface.addSubview(materialView)
    NSLayoutConstraint.activate([
      materialView.leadingAnchor.constraint(equalTo: surface.leadingAnchor),
      materialView.trailingAnchor.constraint(equalTo: surface.trailingAnchor),
      materialView.topAnchor.constraint(equalTo: surface.topAnchor),
      materialView.bottomAnchor.constraint(equalTo: surface.bottomAnchor),
    ])

    if #available(macOS 26.0, *) {
      let glass = NSGlassEffectView(frame: .zero)
      glass.style = .clear
      glass.cornerRadius = layout.cornerRadius + 1.5
      glass.appearance = NSAppearance(named: .darkAqua)
      glass.tintColor = NSColor(srgbRed: 0, green: 0, blue: 0, alpha: 0.35)
      glass.translatesAutoresizingMaskIntoConstraints = false
      surface.addSubview(glass)
      NSLayoutConstraint.activate([
        glass.leadingAnchor.constraint(equalTo: surface.leadingAnchor, constant: -1.5),
        glass.trailingAnchor.constraint(equalTo: surface.trailingAnchor, constant: 1.5),
        glass.topAnchor.constraint(equalTo: surface.topAnchor, constant: -1.5),
        glass.bottomAnchor.constraint(equalTo: surface.bottomAnchor, constant: 1.5),
      ])
      glassBackgroundView = glass
      materialView.isHidden = true
      surfaceBaseLayer.isHidden = true
      surface.layer?.insertSublayer(surfaceBaseLayer, above: glass.layer ?? materialView.layer)
      surface.layer?.insertSublayer(ambientGradientLayer, above: surfaceBaseLayer)
    } else {
      surface.layer?.insertSublayer(surfaceBaseLayer, above: materialView.layer)
      surface.layer?.insertSublayer(ambientGradientLayer, above: surfaceBaseLayer)
    }

    iconBadgeView.wantsLayer = true
    iconBadgeView.layer?.cornerRadius = 10
    iconBadgeView.layer?.cornerCurve = .continuous

    setDiskIconSymbol(isDiskImage ? "opticaldiscdrive.fill" : "externaldrive.fill")
    diskIcon.contentTintColor = .secondaryLabelColor
    diskIcon.symbolConfiguration = NSImage.SymbolConfiguration(pointSize: 22, weight: .regular)
    diskIcon.imageScaling = .scaleProportionallyUpOrDown

    nameLabel.stringValue = effectiveTitleText
    nameLabel.font = .systemFont(ofSize: layout.nameFontSize, weight: .semibold)
    nameLabel.textColor = .labelColor
    nameLabel.lineBreakMode = .byTruncatingTail
    nameLabel.usesSingleLineMode = true
    nameLabel.maximumNumberOfLines = 1
    // Card width is globally managed. Text must yield to that width instead of
    // contributing a different fitting width for each disk name/capacity string.
    nameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
    nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

    formatBadgeBox.wantsLayer = true
    formatBadgeBox.layer?.cornerRadius = 7
    formatBadgeBox.layer?.cornerCurve = .continuous
    formatBadgeBox.isHidden = true
    formatBadgeBox.setContentHuggingPriority(.required, for: .horizontal)
    formatBadgeBox.setContentCompressionResistancePriority(
      NSLayoutConstraint.Priority(400), for: .horizontal)

    formatBadgeLabel.font = .systemFont(ofSize: 8.5, weight: .semibold)
    formatBadgeLabel.textColor = .secondaryLabelColor
    formatBadgeLabel.lineBreakMode = .byTruncatingTail
    formatBadgeLabel.usesSingleLineMode = true
    formatBadgeLabel.maximumNumberOfLines = 1
    formatBadgeLabel.setContentHuggingPriority(.required, for: .horizontal)
    formatBadgeLabel.setContentCompressionResistancePriority(
      NSLayoutConstraint.Priority(400), for: .horizontal)
    formatBadgeLabel.translatesAutoresizingMaskIntoConstraints = false
    formatBadgeBox.addSubview(formatBadgeLabel)
    NSLayoutConstraint.activate([
      formatBadgeLabel.leadingAnchor.constraint(equalTo: formatBadgeBox.leadingAnchor, constant: 5.5),
      formatBadgeLabel.trailingAnchor.constraint(equalTo: formatBadgeBox.trailingAnchor, constant: -5.5),
      formatBadgeLabel.topAnchor.constraint(equalTo: formatBadgeBox.topAnchor, constant: 1.5),
      formatBadgeLabel.bottomAnchor.constraint(equalTo: formatBadgeBox.bottomAnchor, constant: -1.5),
    ])

    inlineBarTrack.wantsLayer = true
    inlineBarTrack.layer?.cornerRadius = 2.25
    inlineBarTrack.layer?.cornerCurve = .continuous
    inlineBarTrack.layer?.masksToBounds = true
    inlineBarFill.wantsLayer = true
    inlineBarFill.layer?.cornerRadius = 2.25
    inlineBarFill.layer?.cornerCurve = .continuous
    inlineBarFill.translatesAutoresizingMaskIntoConstraints = false
    inlineBarTrack.addSubview(inlineBarFill)
    inlineBarFillWidthConstraint = inlineBarFill.widthAnchor.constraint(equalToConstant: 0)
    NSLayoutConstraint.activate([
      inlineBarFill.leadingAnchor.constraint(equalTo: inlineBarTrack.leadingAnchor),
      inlineBarFill.topAnchor.constraint(equalTo: inlineBarTrack.topAnchor),
      inlineBarFill.bottomAnchor.constraint(equalTo: inlineBarTrack.bottomAnchor),
      inlineBarFillWidthConstraint,
    ])

    statusLabel.font = .systemFont(ofSize: layout.statusFontSize, weight: .medium)
    statusLabel.textColor = .secondaryLabelColor
    statusLabel.lineBreakMode = .byTruncatingTail
    statusLabel.alignment = .left
    statusLabel.usesSingleLineMode = true
    statusLabel.maximumNumberOfLines = 1
    statusLabel.cell?.wraps = false
    statusLabel.cell?.truncatesLastVisibleLine = true
    statusLabel.setContentHuggingPriority(NSLayoutConstraint.Priority(448), for: .horizontal)
    statusLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

    ejectPillView.wantsLayer = true
    ejectPillView.layer?.cornerRadius = layout.ejectSize / 2
    ejectPillView.layer?.cornerCurve = .continuous

    ejectButton.imagePosition = .imageOnly
    ejectButton.isBordered = false
    ejectButton.imageScaling = .scaleProportionallyDown
    ejectButton.symbolConfiguration = NSImage.SymbolConfiguration(
      pointSize: max(10, (layout.ejectSize * 0.46).rounded()),
      weight: .semibold
    )
    ejectButton.contentTintColor = .secondaryLabelColor
    ejectButton.target = self
    ejectButton.action = #selector(diskAction)
    ejectButton.focusRingType = .none
    ejectButton.hoverChanged = { [weak self] hovering in self?.isEjectHovered = hovering }

    usageRing.hoverChanged = { [weak self] hovering in self?.showHoverDetails(hovering) }
    usageRing.ringClicked = { [weak self] in
      NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .default)
      self?.ringModeToggleRequested?()
    }

    [
      iconBadgeView,
      diskIcon,
      nameLabel,
      formatBadgeBox,
      inlineBarTrack,
      statusLabel,
      usageRing,
      ejectPillView,
      ejectButton,
    ].forEach {
      $0.translatesAutoresizingMaskIntoConstraints = false
      surface.addSubview($0)
    }

    let barSpaceGuide = NSLayoutGuide()
    surface.addLayoutGuide(barSpaceGuide)

    iconXConstraint = diskIcon.leadingAnchor.constraint(
      equalTo: surface.leadingAnchor, constant: layout.iconX)
    iconYConstraint = diskIcon.centerYAnchor.constraint(
      equalTo: surface.centerYAnchor, constant: layout.iconY)
    iconWidthConstraint = diskIcon.widthAnchor.constraint(equalToConstant: layout.iconSize)
    iconHeightConstraint = diskIcon.heightAnchor.constraint(equalToConstant: layout.iconSize)
    nameXConstraint = nameLabel.leadingAnchor.constraint(
      equalTo: surface.leadingAnchor, constant: layout.nameX)
    nameYConstraint = nameLabel.centerYAnchor.constraint(
      equalTo: surface.centerYAnchor, constant: layout.nameY)
    statusXConstraint = statusLabel.leadingAnchor.constraint(
      equalTo: surface.leadingAnchor, constant: layout.statusX)
    statusBottomConstraint = statusLabel.bottomAnchor.constraint(
      equalTo: surface.bottomAnchor, constant: -layout.statusBottom)
    ejectCenterConstraint = ejectButton.centerYAnchor.constraint(
      equalTo: surface.centerYAnchor, constant: layout.ejectY)
    ejectXConstraint = ejectButton.trailingAnchor.constraint(
      equalTo: surface.trailingAnchor, constant: -layout.ejectX)
    ejectWidthConstraint = ejectButton.widthAnchor.constraint(equalToConstant: layout.ejectSize)
    ejectHeightConstraint = ejectButton.heightAnchor.constraint(equalToConstant: layout.ejectSize)
    ringCenterConstraint = usageRing.centerYAnchor.constraint(
      equalTo: surface.centerYAnchor, constant: layout.ringY)
    ringXConstraint = usageRing.trailingAnchor.constraint(
      equalTo: surface.trailingAnchor, constant: -layout.ringX)
    ringWidthConstraint = usageRing.widthAnchor.constraint(equalToConstant: layout.ringSize)
    ringHeightConstraint = usageRing.heightAnchor.constraint(equalToConstant: layout.ringSize)

    let nameTrailing = nameLabel.trailingAnchor.constraint(
      lessThanOrEqualTo: ejectButton.leadingAnchor, constant: -10)
    nameTrailing.priority = NSLayoutConstraint.Priority(450)
    let badgeLeading = formatBadgeBox.leadingAnchor.constraint(
      equalTo: nameLabel.trailingAnchor, constant: 5)
    badgeLeading.priority = NSLayoutConstraint.Priority(440)
    let badgeTrailing = formatBadgeBox.trailingAnchor.constraint(
      lessThanOrEqualTo: ejectButton.leadingAnchor, constant: -10)
    badgeTrailing.priority = NSLayoutConstraint.Priority(450)
    let badgeMaxWidth = formatBadgeBox.widthAnchor.constraint(lessThanOrEqualToConstant: 58)
    badgeMaxWidth.priority = NSLayoutConstraint.Priority(460)
    let statusTrailing = statusLabel.trailingAnchor.constraint(
      lessThanOrEqualTo: ejectButton.leadingAnchor, constant: -10)
    statusTrailing.priority = NSLayoutConstraint.Priority(450)
    let barGuideTop = barSpaceGuide.topAnchor.constraint(equalTo: nameLabel.bottomAnchor)
    barGuideTop.priority = NSLayoutConstraint.Priority(450)
    let barGuideBottom = barSpaceGuide.bottomAnchor.constraint(equalTo: statusLabel.topAnchor)
    barGuideBottom.priority = NSLayoutConstraint.Priority(449)
    let barGuideTrailing = barSpaceGuide.trailingAnchor.constraint(
      lessThanOrEqualTo: ejectButton.leadingAnchor, constant: -10)
    barGuideTrailing.priority = NSLayoutConstraint.Priority(450)
    let barMatchStatusTrailing = inlineBarTrack.trailingAnchor.constraint(
      equalTo: statusLabel.trailingAnchor)
    barMatchStatusTrailing.priority = NSLayoutConstraint.Priority(445)
    let barTrailing = inlineBarTrack.trailingAnchor.constraint(
      lessThanOrEqualTo: ejectButton.leadingAnchor, constant: -10)
    barTrailing.priority = NSLayoutConstraint.Priority(450)
    let barMinWidth = inlineBarTrack.widthAnchor.constraint(greaterThanOrEqualToConstant: 64)
    barMinWidth.priority = NSLayoutConstraint.Priority(440)

    NSLayoutConstraint.activate([
      iconXConstraint,
      iconYConstraint,
      iconWidthConstraint,
      iconHeightConstraint,
      iconBadgeView.centerXAnchor.constraint(equalTo: diskIcon.centerXAnchor),
      iconBadgeView.centerYAnchor.constraint(equalTo: diskIcon.centerYAnchor),
      iconBadgeView.widthAnchor.constraint(equalTo: diskIcon.widthAnchor, constant: 14),
      iconBadgeView.heightAnchor.constraint(equalTo: diskIcon.heightAnchor, constant: 14),
      nameXConstraint,
      nameYConstraint,
      nameTrailing,
      badgeLeading,
      formatBadgeBox.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
      badgeTrailing,
      badgeMaxWidth,
      barSpaceGuide.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
      barGuideTrailing,
      barGuideTop,
      barGuideBottom,
      inlineBarTrack.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
      barMatchStatusTrailing,
      barTrailing,
      barMinWidth,
      inlineBarTrack.centerYAnchor.constraint(equalTo: barSpaceGuide.centerYAnchor),
      inlineBarTrack.heightAnchor.constraint(equalToConstant: 4.5),
      statusXConstraint,
      statusBottomConstraint,
      statusTrailing,
      ejectXConstraint,
      ejectCenterConstraint,
      ejectWidthConstraint,
      ejectHeightConstraint,
      ejectPillView.centerXAnchor.constraint(equalTo: ejectButton.centerXAnchor),
      ejectPillView.centerYAnchor.constraint(equalTo: ejectButton.centerYAnchor),
      ejectPillView.widthAnchor.constraint(equalTo: ejectButton.widthAnchor),
      ejectPillView.heightAnchor.constraint(equalTo: ejectButton.heightAnchor),
      ringXConstraint,
      ringCenterConstraint,
      ringWidthConstraint,
      ringHeightConstraint,
    ])

    applyLayout(layout)
    if isPreviewPlaceholder {
      configureAsPreviewPlaceholder()
    } else {
      showDisconnectedState(message: "未连接")
    }
  }

  private func configureAsPreviewPlaceholder() {
    state = .connected
    volumeFormatDescription = "APFS"
    lastTotalBytes = 1_000_000_000_000
    lastAvailableBytes = 320_000_000_000
    lastUsedBytes = 680_000_000_000
    nameLabel.stringValue = "示例外置硬盘 (预览)"
    hoverDetails = "拖动此卡可调整桌面位置"
    statusLabel.stringValue = hoverDetails
    updateRingDisplayFromCachedCapacity()
    updateFormatBadge()
    usageRing.toolTip = "未接入外置盘时的桌面位置预览卡 · 关闭设置或插入硬盘后自动收起"
    setEjectButtonSymbol("slider.horizontal.3", accessibilityDescription: "设置预览")
    ejectButton.toolTip = "桌面预览占位卡"
    ejectButton.isEnabled = false
    updateAppearance()
  }

  private static var desktopWidgetLevel: NSWindow.Level {
    NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopIconWindow)) + 2)
  }

  /// Places the panel onto the desktop once when first added. Subsequent calls
  /// only verify the window level and never call `orderFrontRegardless()`, so
  /// WindowServer remains in full control of hiding/restoring the panel during
  /// Mission Control and Space transitions.
  func reassertDesktopLevel() {
    if hideDesktopCardWindow {
      if isVisible { orderOut(nil) }
      return
    }
    if level != Self.desktopWidgetLevel { level = Self.desktopWidgetLevel }
    guard !hasOrderedOnDesktop else { return }
    hasOrderedOnDesktop = true
    orderFrontRegardless()
  }

  func ensureDesktopLevelWithoutOrdering() {
    if hideDesktopCardWindow {
      if isVisible { orderOut(nil) }
      return
    }
    if level != Self.desktopWidgetLevel { level = Self.desktopWidgetLevel }
  }

  func setDesktopActive(_ active: Bool) {
    isDesktopActive = active
  }

  func setHiddenForDesktopPresentation(_ hidden: Bool) {
    guard isHiddenForDesktopPresentation != hidden else { return }
    isHiddenForDesktopPresentation = hidden
    ignoresMouseEvents = hidden
    alphaValue = hidden ? 0.0 : 1.0
  }

  func representsVolume(name: String, uuid: String?) -> Bool {
    if isPreviewPlaceholder { return false }
    if let uuid, !uuid.isEmpty, let lastVolumeUUID, !lastVolumeUUID.isEmpty {
      return uuid == lastVolumeUUID
    }
    return name == currentDisplayName || name == diskName
  }

  var orderingKey: String {
    if let lastVolumeUUID, !lastVolumeUUID.isEmpty { return "uuid:\(lastVolumeUUID)" }
    return "name:\(diskName)"
  }

  var isConnectedVolume: Bool {
    !isPreviewPlaceholder && state == .connected && volumeURL != nil
  }

  var isUnmountedReconnectable: Bool {
    !isPreviewPlaceholder && state == .unmounted
  }

  var menuSummaryTitle: String {
    let title = effectiveTitleText
    if state == .connected {
      return "\(title) — \(hoverDetails)"
    } else if state == .unmounted {
      return "\(title)（已安全推出 · 可重连）"
    }
    return "\(title)（\(statusLabel.stringValue)）"
  }

  func makeSnapshotItem() -> DiskSnapshotItem {
    let snapshotState: DiskSnapshotState
    if isCopyingFiles {
      snapshotState = .copying
    } else {
      switch state {
      case .connected: snapshotState = .connected
      case .unmounting: snapshotState = .unmounting
      case .unmounted: snapshotState = .unmounted
      case .reconnecting: snapshotState = .reconnecting
      case .fullyEjecting: snapshotState = .fullyEjecting
      case .disconnected: snapshotState = .disconnected
      }
    }

    let resolvedStatus: String
    if snapshotState == .connected {
      resolvedStatus = hoverDetails
    } else if snapshotState == .unmounted {
      resolvedStatus = "已安全推出 · 可重连"
    } else {
      resolvedStatus = statusLabel.stringValue.isEmpty ? hoverDetails : statusLabel.stringValue
    }

    let symbol = currentDiskSymbol.isEmpty ? "externaldrive.fill" : currentDiskSymbol
    return DiskSnapshotItem(
      id: orderingKey,
      name: diskName,
      displayName: effectiveTitleText,
      volumePath: volumeURL?.standardizedFileURL.path,
      volumeUUID: lastVolumeUUID,
      iconSymbol: symbol,
      state: snapshotState,
      statusText: resolvedStatus,
      formatDescription: volumeFormatDescription,
      isReadOnly: isReadOnlyVolume,
      isDiskImage: isDiskImage,
      usedBytes: Int64(max(0, lastUsedBytes)),
      availableBytes: Int64(max(0, lastAvailableBytes)),
      totalBytes: Int64(max(0, lastTotalBytes))
    )
  }

  private var customAlias: String? {
    let dict = UserDefaults.standard.dictionary(forKey: "disk-widget-custom-aliases") as? [String: String]
    guard let alias = dict?[orderingKey]?.trimmingCharacters(in: .whitespacesAndNewlines),
      !alias.isEmpty
    else { return nil }
    return alias
  }

  private func setCustomAlias(_ alias: String?) {
    var dict =
      (UserDefaults.standard.dictionary(forKey: "disk-widget-custom-aliases") as? [String: String])
      ?? [:]
    let trimmed = alias?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    if trimmed.isEmpty {
      dict.removeValue(forKey: orderingKey)
    } else {
      dict[orderingKey] = trimmed
    }
    UserDefaults.standard.set(dict, forKey: "disk-widget-custom-aliases")
    nameLabel.stringValue = effectiveTitleText
    stateChanged?()
  }

  private var customIconSymbol: String? {
    let dict = UserDefaults.standard.dictionary(forKey: "disk-widget-custom-icons") as? [String: String]
    guard let symbol = dict?[orderingKey], !symbol.isEmpty else { return nil }
    return symbol
  }

  private func setCustomIconSymbol(_ symbol: String?) {
    var dict =
      (UserDefaults.standard.dictionary(forKey: "disk-widget-custom-icons") as? [String: String])
      ?? [:]
    if let symbol, !symbol.isEmpty {
      dict[orderingKey] = symbol
    } else {
      dict.removeValue(forKey: orderingKey)
    }
    UserDefaults.standard.set(dict, forKey: "disk-widget-custom-icons")
    updateDiskIconForCurrentVolume()
    stateChanged?()
  }

  var effectiveTitleText: String {
    if let alias = customAlias { return alias }
    return currentDisplayName.isEmpty ? diskName : currentDisplayName
  }

  var mountedPath: String? {
    volumeURL?.standardizedFileURL.path
  }

  func setDiskImageClassification(_ value: Bool) {
    guard isDiskImage != value else { return }
    isDiskImage = value
    updateDiskIconForCurrentVolume()
  }

  func setReorderActive(_ active: Bool) {
    guard isReorderActive != active else { return }
    isReorderActive = active

    if active {
      statusLabel.stringValue = "拖动调整顺序"
      statusLabel.textColor = accentColor
      NSCursor.openHand.set()
    } else {
      statusLabel.textColor = .secondaryLabelColor
      NSCursor.arrow.set()
      // Re-read the current disk state so the temporary sorting cue never
      // becomes part of the card's persistent status text.
      if isPreviewPlaceholder {
        configureAsPreviewPlaceholder()
      } else {
        refresh()
      }
    }
  }

  /// A normal disconnected card should not remain on the desktop. The only
  /// intentional no-mount state we keep is `.unmounted`, because the device is
  /// still attached and can be software-mounted again.
  var shouldAutoRemoveWhenUnavailable: Bool {
    !isPreviewPlaceholder && state == .disconnected && volumeURL == nil && !lastUnmountFailed
  }

  /// When a disk was deliberately software-unmounted, FileManager can no longer
  /// see its volume. Verify that the underlying /dev device still exists so a
  /// physically removed USB drive does not leave behind a stale reconnect card.
  func verifyBackingDevicePresence(_ completion: @escaping (Bool) -> Void) {
    guard !isPreviewPlaceholder, state == .unmounted else {
      completion(true)
      return
    }

    guard let identifier = reconnectWholeDiskIdentifier ?? reconnectVolumeIdentifier else {
      completion(false)
      return
    }

    guard !isVerifyingBackingDevice else { return }
    isVerifyingBackingDevice = true

    DispatchQueue.global(qos: .utility).async {
      let exists = (try? Self.runDiskutil(["info", "-plist", identifier], timeout: 5)) != nil
      DispatchQueue.main.async { [weak self] in
        guard let self else { return }
        self.isVerifyingBackingDevice = false
        guard self.state == .unmounted else { return }
        completion(exists)
      }
    }
  }

  private func setForceMainAppearance(_ force: Bool) {
    let sel = Selector(("_setForceMainAppearance:"))
    guard responds(to: sel), let m = method(for: sel) else { return }
    typealias SetBoolIMP = @convention(c) (AnyObject, Selector, Bool) -> Void
    let imp = unsafeBitCast(m, to: SetBoolIMP.self)
    imp(self, sel, force)
  }

  func setBackgroundOpacity(_ opacity: CGFloat) {
    let clamped = max(0, min(opacity, 1))
    backgroundOpacity = clamped
    let shouldHide = clamped <= 0.001
    if #available(macOS 26.0, *), glassBackgroundView is NSGlassEffectView {
      materialView.isHidden = true
      if surface != nil {
        updateAppearance()
      }
      return
    }
    if abs(materialView.alphaValue - clamped) > 0.001 {
      materialView.alphaValue = clamped
    }
    if materialView.isHidden != shouldHide {
      materialView.isHidden = shouldHide
    }
  }

  /// Updates the rounded mask image on `NSVisualEffectView` so behind-window
  /// blur and window shadow follow the exact continuous corner radius without
  /// rectangular corner bleeding.
  private func updateMaterialMaskIfNeeded(size: NSSize, cornerRadius: CGFloat) {
    guard size.width > 0, size.height > 0 else { return }
    guard size != maskSize || abs(cornerRadius - maskCornerRadius) > 0.1 else { return }
    maskSize = size
    maskCornerRadius = cornerRadius

    let image = NSImage(size: size, flipped: false) { rect in
      NSColor.black.setFill()
      NSBezierPath(
        roundedRect: rect,
        xRadius: cornerRadius,
        yRadius: cornerRadius
      ).fill()
      return true
    }
    materialView.maskImage = image
    if isVisible {
      invalidateShadow()
    }
  }

  func applyLayout(_ newLayout: WidgetLayout) {
    let layout = newLayout.normalized()
    currentCardHeight = layout.height
    hideDesktopCardWindow = !layout.showDesktopCards
    if hideDesktopCardWindow && isVisible {
      orderOut(nil)
    }
    setBackgroundOpacity(layout.opacity)
    dimWhenDesktopInactive = layout.dimWhenDesktopInactive
    desktopActiveStyle = layout.desktopActiveStyle
    let ringModeChanged = (ringShowsAvailablePercentage != layout.ringShowsAvailablePercentage)
    ringShowsAvailablePercentage = layout.ringShowsAvailablePercentage
    accentColor = layout.accentColor
    usageRing.accentColor = accentColor
    usageRing.textFontSize = layout.ringTextFontSize
    iconXConstraint.constant = layout.iconX
    iconYConstraint.constant = layout.iconY
    iconWidthConstraint.constant = layout.iconSize
    iconHeightConstraint.constant = layout.iconSize
    nameXConstraint.constant = layout.nameX
    nameYConstraint.constant = layout.nameY
    statusXConstraint.constant = layout.statusX
    statusBottomConstraint.constant = -layout.statusBottom
    ringXConstraint.constant = -layout.ringX
    ringCenterConstraint.constant = layout.ringY
    ringWidthConstraint.constant = layout.ringSize
    ringHeightConstraint.constant = layout.ringSize
    ejectCenterConstraint.constant = layout.ejectY
    ejectXConstraint.constant = -layout.ejectX
    ejectWidthConstraint.constant = layout.ejectSize
    ejectHeightConstraint.constant = layout.ejectSize
    ejectPillView.layer?.cornerRadius = layout.ejectSize / 2
    ejectButton.symbolConfiguration = NSImage.SymbolConfiguration(
      pointSize: max(10, (layout.ejectSize * 0.46).rounded()),
      weight: .semibold
    )
    iconBadgeView.layer?.cornerRadius = max(7, ((layout.iconSize + 14) * 0.28).rounded())
    nameLabel.font = .systemFont(ofSize: layout.nameFontSize, weight: .semibold)
    statusLabel.font = .systemFont(ofSize: layout.statusFontSize, weight: .medium)
    surface.layer?.cornerRadius = layout.cornerRadius
    surface.layer?.cornerCurve = .continuous
    materialView.layer?.cornerRadius = layout.cornerRadius
    materialView.layer?.cornerCurve = .continuous
    if #available(macOS 26.0, *), let glass = glassBackgroundView as? NSGlassEffectView {
      glass.cornerRadius = layout.cornerRadius + 1.5
    }
    let targetSize = NSSize(width: layout.width, height: layout.height)
    surfaceBaseLayer.cornerRadius = layout.cornerRadius
    surfaceBaseLayer.cornerCurve = .continuous
    surfaceBaseLayer.frame = NSRect(origin: .zero, size: targetSize)
    ambientGradientLayer.cornerRadius = layout.cornerRadius
    ambientGradientLayer.frame = NSRect(origin: .zero, size: targetSize)
    enforceManagedSize(targetSize)
    updateMaterialMaskIfNeeded(size: targetSize, cornerRadius: layout.cornerRadius)
    if ringModeChanged && state == .connected && !isCopyingFiles {
      updateRingDisplayFromCachedCapacity()
    }
    updateInlineProgressBar(
      fraction: currentBarFraction,
      visible: state == .connected && (lastTotalBytes > 0 || isCopyingFiles)
    )
    surface.needsLayout = true
    surface.layoutSubtreeIfNeeded()
    updateInlineBarFillWidth()
    updateAppearance()
  }

  private func updateFormatBadge() {
    guard state == .connected,
      let raw = volumeFormatDescription?.trimmingCharacters(in: .whitespacesAndNewlines),
      !raw.isEmpty
    else {
      formatBadgeBox.isHidden = true
      return
    }
    let shortFormat: String
    if raw.localizedCaseInsensitiveContains("NTFS") {
      shortFormat = "NTFS"
    } else if raw.localizedCaseInsensitiveContains("FAT32") {
      shortFormat = "FAT32"
    } else if raw.localizedCaseInsensitiveContains("ExFAT") {
      shortFormat = "ExFAT"
    } else if raw.localizedCaseInsensitiveContains("APFS") {
      shortFormat = "APFS"
    } else if raw.localizedCaseInsensitiveContains("Mac OS") {
      shortFormat = "HFS+"
    } else {
      shortFormat = raw
    }
    formatBadgeLabel.stringValue = isReadOnlyVolume ? "\(shortFormat)·只读" : shortFormat
    formatBadgeBox.isHidden = false
  }

  private func updateInlineProgressBar(fraction: CGFloat, visible: Bool) {
    currentBarFraction = min(max(fraction, 0), 1)
    let shouldShow = visible && currentCardHeight >= 74
    if inlineBarTrack.isHidden == shouldShow {
      inlineBarTrack.isHidden = !shouldShow
    }
    updateInlineBarFillWidth()
  }

  private func updateInlineBarFillWidth() {
    guard inlineBarFillWidthConstraint != nil else { return }
    let trackWidth = inlineBarTrack.bounds.width
    guard trackWidth > 0, !inlineBarTrack.isHidden else {
      inlineBarFillWidthConstraint.constant = 0
      return
    }
    let clamped = min(max(currentBarFraction, 0), 1)
    let fillWidth = clamped > 0 ? max(4.5, (trackWidth * clamped).rounded()) : 0
    inlineBarFillWidthConstraint.constant = min(trackWidth, fillWidth)
  }

  private func updateRingDisplayFromCachedCapacity() {
    guard lastTotalBytes > 0 else {
      usageRing.fraction = 0
      usageRing.centerText = "—"
      updateInlineProgressBar(fraction: 0, visible: false)
      return
    }
    let usedFraction = min(max(CGFloat(lastUsedBytes) / CGFloat(lastTotalBytes), 0), 1)
    let freeFraction = min(max(CGFloat(lastAvailableBytes) / CGFloat(lastTotalBytes), 0), 1)
    usageRing.fraction = usedFraction
    if ringShowsAvailablePercentage {
      usageRing.centerText = "剩\(Int((freeFraction * 100).rounded()))%"
      updateInlineProgressBar(fraction: freeFraction, visible: true)
    } else {
      usageRing.centerText = "\(Int((usedFraction * 100).rounded()))%"
      updateInlineProgressBar(fraction: usedFraction, visible: true)
    }
  }

  /// Hard-lock the NSPanel itself to the globally managed card size.
  ///
  /// Merely calling setFrame()/setContentSize() is not sufficient here: AppKit can
  /// later re-evaluate a window's content fitting size after labels change. Capacity
  /// strings have different intrinsic widths, so that can make otherwise identical
  /// cards drift apart once the card becomes wide enough. By locking both the frame
  /// and content min/max sizes, text is forced to truncate/compress instead of ever
  /// resizing an individual panel.
  func enforceManagedSize(_ size: NSSize) {
    let target = NSSize(
      width: max(1, size.width.rounded()),
      height: max(1, size.height.rounded())
    )
    let topLeft = NSPoint(x: frame.minX, y: frame.maxY)
    let targetFrame = NSRect(
      x: topLeft.x,
      y: topLeft.y - target.height,
      width: target.width,
      height: target.height
    )
    setManagedFrame(targetFrame)
  }

  /// Atomically sets both the window frame and exact min/max size locks in a
  /// single pass, avoiding intermediate redraws at stale coordinates.
  func setManagedFrame(_ targetFrame: NSRect, animated: Bool = false) {
    let targetSize = NSSize(
      width: max(1, targetFrame.width.rounded()),
      height: max(1, targetFrame.height.rounded())
    )
    let normalizedFrame = NSRect(
      x: targetFrame.origin.x,
      y: targetFrame.origin.y,
      width: targetSize.width,
      height: targetSize.height
    )

    let sizeChanged = frame.size != targetSize
    let locksNeedUpdate =
      minSize != targetSize || maxSize != targetSize
      || contentMinSize != targetSize || contentMaxSize != targetSize

    if sizeChanged || locksNeedUpdate {
      let generousMax = NSSize(width: 10_000, height: 10_000)
      minSize = NSSize(width: 1, height: 1)
      maxSize = generousMax
      contentMinSize = NSSize(width: 1, height: 1)
      contentMaxSize = generousMax
    }

    if frame != normalizedFrame {
      if animated && isVisible && !sizeChanged {
        NSAnimationContext.runAnimationGroup { context in
          context.duration = 0.16
          context.timingFunction = CAMediaTimingFunction(name: .easeOut)
          self.animator().setFrame(normalizedFrame, display: true)
        }
      } else {
        setFrame(normalizedFrame, display: isVisible)
      }
    }

    if sizeChanged || locksNeedUpdate {
      minSize = targetSize
      maxSize = targetSize
      contentMinSize = targetSize
      contentMaxSize = targetSize
    }

    if let contentView, contentView.frame.size != targetSize {
      contentView.frame = NSRect(origin: .zero, size: targetSize)
      contentView.needsLayout = true
      contentView.layoutSubtreeIfNeeded()
    }
    if sizeChanged, maskCornerRadius > 0 {
      updateMaterialMaskIfNeeded(size: targetSize, cornerRadius: maskCornerRadius)
    }
  }

  private func setEjectButtonSymbol(_ symbol: String, accessibilityDescription: String) {
    guard currentEjectSymbol != symbol else { return }
    currentEjectSymbol = symbol
    ejectButton.image = NSImage(
      systemSymbolName: symbol, accessibilityDescription: accessibilityDescription)
  }

  private func setDiskIconSymbol(_ symbol: String) {
    guard currentDiskSymbol != symbol else { return }
    currentDiskSymbol = symbol
    if let img = NSImage(systemSymbolName: symbol, accessibilityDescription: "外置硬盘")
      ?? NSImage(systemSymbolName: "externaldrive.fill", accessibilityDescription: "外置硬盘")
    {
      diskIcon.image = img
    }
  }

  private func updateDiskIconForCurrentVolume() {
    if let custom = customIconSymbol {
      setDiskIconSymbol(custom)
      return
    }
    if isDiskImage {
      setDiskIconSymbol("opticaldiscdrive.fill")
      return
    }
    if let url = volumeURL {
      let tmManifest = url.appendingPathComponent("backup_manifest.plist")
      let tmFolder = url.appendingPathComponent("Backups.backupdb")
      if FileManager.default.fileExists(atPath: tmManifest.path)
        || FileManager.default.fileExists(atPath: tmFolder.path)
      {
        setDiskIconSymbol("externaldrive.badge.timemachine")
        return
      }
    }
    if isRemovableMedia {
      setDiskIconSymbol("sdcard.fill")
      return
    }
    setDiskIconSymbol("externaldrive.fill")
  }

  static let iconChoices: [(title: String, symbol: String?)] = [
    ("自动识别", nil),
    ("外置硬盘", "externaldrive.fill"),
    ("存储卡 / SD 卡", "sdcard.fill"),
    ("相机 / 素材盘", "camera.fill"),
    ("光盘 / 安装镜像", "opticaldiscdrive.fill"),
    ("Time Machine 备份盘", "externaldrive.badge.timemachine"),
  ]

  private func showSettingsMenu(for event: NSEvent) {
    let menu = NSMenu(title: effectiveTitleText)

    if !isPreviewPlaceholder && state == .connected {
      let openItem = NSMenuItem(
        title: "在 Finder 中打开", action: #selector(requestOpenDisk), keyEquivalent: "")
      openItem.target = self
      openItem.image = NSImage(systemSymbolName: "folder", accessibilityDescription: nil)
      menu.addItem(openItem)

      if !lastCopiedURLs.isEmpty {
        let revealItem = NSMenuItem(
          title: "在 Finder 中定位上次复制的项目",
          action: #selector(requestRevealCopiedItems),
          keyEquivalent: ""
        )
        revealItem.target = self
        revealItem.image = NSImage(
          systemSymbolName: "doc.viewfinder", accessibilityDescription: nil)
        menu.addItem(revealItem)
      }

      let infoItem = NSMenuItem(
        title: "显示简介", action: #selector(requestShowVolumeInfo), keyEquivalent: "")
      infoItem.target = self
      infoItem.image = NSImage(systemSymbolName: "info.circle", accessibilityDescription: "显示简介")
      menu.addItem(infoItem)
      menu.addItem(.separator())
    }

    if !isPreviewPlaceholder {
      switch state {
      case .connected:
        if isCopyingFiles {
          let cancelCopyItem = NSMenuItem(
            title: "取消正在进行的文件复制",
            action: #selector(requestCancelCopy),
            keyEquivalent: ""
          )
          cancelCopyItem.target = self
          cancelCopyItem.image = NSImage(
            systemSymbolName: "stop.circle", accessibilityDescription: nil)
          menu.addItem(cancelCopyItem)
          menu.addItem(.separator())
        }

        let fullEjectItem = NSMenuItem(
          title: "完全推出（断电移除）", action: #selector(requestFullEject), keyEquivalent: "")
        fullEjectItem.target = self
        fullEjectItem.image = NSImage(
          systemSymbolName: "eject.fill", accessibilityDescription: "完全推出（断电移除）")
        menu.addItem(fullEjectItem)

        let forceItem = NSMenuItem(
          title: lastUnmountFailed ? "强制推出（解决占用）…" : "强制推出…",
          action: #selector(requestForceUnmount),
          keyEquivalent: ""
        )
        forceItem.target = self
        forceItem.image = NSImage(
          systemSymbolName: "exclamationmark.triangle", accessibilityDescription: "强制推出")
        menu.addItem(forceItem)

      case .unmounted:
        let reconnectItem = NSMenuItem(
          title: "重新连接", action: #selector(requestReconnect), keyEquivalent: "")
        reconnectItem.target = self
        reconnectItem.image = NSImage(
          systemSymbolName: "arrow.clockwise", accessibilityDescription: nil)
        menu.addItem(reconnectItem)

        if reconnectWholeDiskIdentifier != nil {
          let fullEjectItem = NSMenuItem(
            title: "完全推出（断电移除）", action: #selector(requestFullEject), keyEquivalent: "")
          fullEjectItem.target = self
          fullEjectItem.image = NSImage(
            systemSymbolName: "eject.fill", accessibilityDescription: "完全推出（断电移除）")
          menu.addItem(fullEjectItem)
        }

      case .unmounting, .reconnecting, .fullyEjecting:
        let busyItem = NSMenuItem(title: statusLabel.stringValue, action: nil, keyEquivalent: "")
        busyItem.isEnabled = false
        menu.addItem(busyItem)

      case .disconnected:
        break
      }

      menu.addItem(.separator())

      let aliasTitle = customAlias == nil ? "设置卡片别名…" : "修改卡片别名（\(customAlias!)）…"
      let aliasItem = NSMenuItem(
        title: aliasTitle, action: #selector(requestEditAlias), keyEquivalent: "")
      aliasItem.target = self
      aliasItem.image = NSImage(systemSymbolName: "pencil", accessibilityDescription: nil)
      menu.addItem(aliasItem)

      let ejectAllItem = NSMenuItem(
        title: "安全推出所有外置磁盘", action: #selector(requestEjectAll), keyEquivalent: "")
      ejectAllItem.target = self
      ejectAllItem.image = NSImage(
        systemSymbolName: "eject.circle", accessibilityDescription: nil)
      menu.addItem(ejectAllItem)

      menu.addItem(.separator())
    }

    let editorItem = NSMenuItem(
      title: "统一组件设置…", action: #selector(requestLayoutEditor), keyEquivalent: "")
    editorItem.target = self
    editorItem.image = NSImage(
      systemSymbolName: "slider.horizontal.3", accessibilityDescription: nil)
    menu.addItem(editorItem)

    if !isPreviewPlaceholder && state != .connected {
      menu.addItem(.separator())
      let removeItem = NSMenuItem(
        title: "移除这张卡片", action: #selector(requestRemoval), keyEquivalent: "")
      removeItem.target = self
      menu.addItem(removeItem)
    }

    NSMenu.popUpContextMenu(menu, with: event, for: surface)
    let mouseInWindow = convertPoint(fromScreen: NSEvent.mouseLocation)
    let mouseInSurface = surface.convert(mouseInWindow, from: nil)
    isCardHovered = surface.bounds.contains(mouseInSurface)
  }

  @objc func requestOpenDisk() { openDisk() }
  @objc private func requestRevealCopiedItems() { revealLastCopiedItemsInFinder() }
  @objc private func requestCancelCopy() { cancelActiveFileCopy() }
  @objc private func requestShowVolumeInfo() { showVolumeInfo() }
  @objc private func requestLayoutEditor() { layoutEditorRequested?() }
  @objc private func requestToggleRingMode() { ringModeToggleRequested?() }
  @objc private func requestEjectAll() { ejectAllRequested?() }
  @objc private func requestRemoval() { removalRequested?(self) }
  @objc func requestReconnect() { reconnectDisk() }
  @objc func requestSafeUnmount() { safeUnmountForReconnect() }
  @objc private func requestFullEject() { fullyEjectDisk() }
  @objc private func requestForceUnmount() { confirmAndForceUnmount() }

  @objc private func requestEditAlias() {
    let alert = NSAlert()
    alert.messageText = "设置卡片本地别名"
    alert.informativeText = "仅修改桌面卡片上显示的名称，不会改动磁盘分区本身的名称。留空可恢复默认卷名。"
    alert.addButton(withTitle: "保存")
    alert.addButton(withTitle: "恢复默认")
    alert.addButton(withTitle: "取消")

    let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 260, height: 24))
    input.placeholderString = currentDisplayName.isEmpty ? diskName : currentDisplayName
    input.stringValue = customAlias ?? ""
    alert.accessoryView = input
    NSApp.activate(ignoringOtherApps: true)
    let response = alert.runModal()
    if response == .alertFirstButtonReturn {
      setCustomAlias(input.stringValue)
    } else if response == .alertSecondButtonReturn {
      setCustomAlias(nil)
    }
  }

  @objc private func requestSelectCustomIcon(_ sender: NSMenuItem) {
    guard Self.iconChoices.indices.contains(sender.tag) else { return }
    setCustomIconSymbol(Self.iconChoices[sender.tag].symbol)
  }

  var customIconChoiceIndex: Int {
    Self.iconChoices.firstIndex { $0.symbol == customIconSymbol } ?? 0
  }

  func setCustomIconChoice(index: Int) {
    guard Self.iconChoices.indices.contains(index) else { return }
    setCustomIconSymbol(Self.iconChoices[index].symbol)
  }

  private func revealLastCopiedItemsInFinder() {
    let existing = lastCopiedURLs.filter { FileManager.default.fileExists(atPath: $0.path) }
    guard !existing.isEmpty else {
      openDisk()
      return
    }
    NSWorkspace.shared.activateFileViewerSelecting(existing)
  }

  private func cancelActiveFileCopy() {
    copyCancelLock.lock()
    cancelCopyRequested = true
    copyCancelLock.unlock()
  }

  func refresh(using mountedVolumes: [URL]? = nil) {
    guard !isPreviewPlaceholder else { return }
    guard state != .unmounting,
      state != .reconnecting,
      state != .fullyEjecting
    else {
      return
    }

    let keys: Set<URLResourceKey> = [
      .volumeNameKey,
      .volumeUUIDStringKey,
      .volumeAvailableCapacityKey,
      .volumeTotalCapacityKey,
      .volumeIsReadOnlyKey,
      .volumeIsRemovableKey,
      .volumeLocalizedFormatDescriptionKey,
    ]
    let volumes =
      mountedVolumes
      ?? FileManager.default.mountedVolumeURLs(
        includingResourceValuesForKeys: Array(keys), options: []
      )
      ?? []

    var match: (URL, URLResourceValues)?
    var fallback: (URL, URLResourceValues)?
    let hasKnownUUID = (lastVolumeUUID?.isEmpty == false)

    for url in volumes {
      guard let values = try? url.resourceValues(forKeys: keys) else { continue }
      guard Self.isDisplayableMount(url: url, values: values) else { continue }
      let candidateUUID = values.volumeUUIDString
      if let uuid = lastVolumeUUID,
        !uuid.isEmpty,
        candidateUUID == uuid
      {
        match = (url, values)
        break
      }
      let candidateHasUUID = (candidateUUID?.isEmpty == false)
      if (!hasKnownUUID || !candidateHasUUID),
        values.volumeName == currentDisplayName || values.volumeName == diskName,
        fallback == nil
      {
        fallback = (url, values)
      }
    }

    if match == nil { match = fallback }

    guard let (url, values) = match else {
      volumeURL = nil
      isReadOnlyVolume = false
      if state == .unmounted {
        showUnmountedState()
      } else {
        state = .disconnected
        showDisconnectedState(message: disconnectedMessage)
      }
      updateAppearance()
      return
    }

    volumeURL = url
    isReadOnlyVolume = (values.volumeIsReadOnly == true)
    isRemovableMedia = (values.volumeIsRemovable == true)
    volumeFormatDescription = values.volumeLocalizedFormatDescription
    state = .connected
    if !isCopyingFiles {
      usageRing.isBusy = false
      usageRing.isTransferring = false
    }
    disconnectedMessage = "未连接"
    currentDisplayName = values.volumeName ?? diskName
    let displayTitle = effectiveTitleText
    if nameLabel.stringValue != displayTitle {
      nameLabel.stringValue = displayTitle
    }
    updateDiskIconForCurrentVolume()

    if let uuid = values.volumeUUIDString, !uuid.isEmpty, uuid != lastVolumeUUID {
      lastVolumeUUID = uuid
      UserDefaults.standard.set(uuid, forKey: "disk-widget-volume-uuid-\(diskName)")
    }
    updateFormatBadge()

    let formatPrefix: String
    if let fmt = volumeFormatDescription, !fmt.isEmpty {
      formatPrefix = "\(fmt) · "
    } else {
      formatPrefix = ""
    }

    if let total = values.volumeTotalCapacity,
      let available = values.volumeAvailableCapacity,
      total > 0
    {
      let used = max(0, total - available)
      lastTotalBytes = total
      lastAvailableBytes = available
      lastUsedBytes = used
      if !isCopyingFiles {
        updateRingDisplayFromCachedCapacity()
      }
      let compactAvailable = Self.size(available).replacingOccurrences(of: " ", with: "")
      let compactTotal = Self.size(total).replacingOccurrences(of: " ", with: "")
      if isReadOnlyVolume {
        if let fmt = volumeFormatDescription, !fmt.isEmpty {
          hoverDetails = "只读 (\(fmt)) · 共 \(compactTotal)"
        } else {
          hoverDetails = "只读 · 共 \(compactTotal)"
        }
      } else {
        hoverDetails = "\(compactAvailable) 可用 · 共 \(compactTotal)"
      }
      let readOnlySuffix = isReadOnlyVolume ? " · 只读" : ""
      let newToolTip =
        "\(formatPrefix)已用 \(Self.size(used)) · 可用 \(Self.size(available)) · 总容量 \(Self.size(total))\(readOnlySuffix)（单击切换已用/剩余）"
      if usageRing.toolTip != newToolTip {
        usageRing.toolTip = newToolTip
      }
    } else {
      lastTotalBytes = 0
      lastAvailableBytes = 0
      lastUsedBytes = 0
      if !isCopyingFiles {
        usageRing.fraction = 0
        usageRing.centerText = "—"
        updateInlineProgressBar(fraction: 0, visible: false)
      }
      hoverDetails = isReadOnlyVolume ? "只读卷" : "容量信息不可用"
      if usageRing.toolTip != hoverDetails {
        usageRing.toolTip = hoverDetails
      }
    }

    let hasActiveStatusOverride =
      statusOverrideUntil.map { Date() < $0 } ?? false
    if !isReorderActive && !isCopyingFiles && !hasActiveStatusOverride
      && statusLabel.stringValue != hoverDetails
    {
      statusLabel.stringValue = hoverDetails
    }

    if !isCopyingFiles {
      setEjectButtonSymbol("eject.fill", accessibilityDescription: "安全推出")
      let ejectTip = "安全推出 \(effectiveTitleText)（可重新连接）"
      if ejectButton.toolTip != ejectTip {
        ejectButton.toolTip = ejectTip
      }
      if !ejectButton.isEnabled { ejectButton.isEnabled = true }
      if ejectButton.isHidden { ejectButton.isHidden = false }
    }
    updateAppearance()
  }

  private func showUnmountedState() {
    volumeURL = nil
    isReadOnlyVolume = false
    statusOverrideUntil = nil
    usageRing.isBusy = false
    usageRing.isTransferring = false
    usageRing.fraction = 0
    usageRing.centerText = "—"
    updateFormatBadge()
    updateInlineProgressBar(fraction: 0, visible: false)
    hoverDetails = "硬盘已安全卸载"
    usageRing.toolTip = "已安全卸载，可重新连接"
    if !isReorderActive {
      statusLabel.stringValue = "已安全推出 · 可重连"
    }
    diskIcon.contentTintColor = .secondaryLabelColor
    setEjectButtonSymbol("arrow.clockwise.circle.fill", accessibilityDescription: "重新连接")
    ejectButton.toolTip = "重新连接 \(effectiveTitleText)"
    ejectButton.isEnabled = true
    ejectButton.isHidden = false
  }

  private func showDisconnectedState(message: String) {
    volumeURL = nil
    isReadOnlyVolume = false
    statusOverrideUntil = nil
    usageRing.isBusy = false
    usageRing.isTransferring = false
    usageRing.fraction = 0
    usageRing.centerText = "—"
    updateFormatBadge()
    updateInlineProgressBar(fraction: 0, visible: false)
    hoverDetails = message
    usageRing.toolTip = message
    if !isReorderActive {
      statusLabel.stringValue = message
    }
    diskIcon.contentTintColor = .tertiaryLabelColor
    setEjectButtonSymbol("xmark.circle.fill", accessibilityDescription: "移除卡片")
    ejectButton.toolTip = "移除 \(effectiveTitleText) 卡片"
    ejectButton.isEnabled = true
    ejectButton.isHidden = false
  }

  private func showBusyState(_ message: String, symbol: String) {
    volumeURL = nil
    statusOverrideUntil = nil
    usageRing.isBusy = true
    usageRing.isTransferring = false
    usageRing.fraction = 0
    usageRing.centerText = "…"
    updateFormatBadge()
    updateInlineProgressBar(fraction: 0, visible: false)
    hoverDetails = message
    usageRing.toolTip = message
    statusLabel.stringValue = message
    diskIcon.contentTintColor = .secondaryLabelColor
    setEjectButtonSymbol(symbol, accessibilityDescription: message)
    ejectButton.toolTip = message
    ejectButton.isEnabled = false
    ejectButton.isHidden = false
  }

  private func showHoverDetails(_ hovering: Bool) {
    // Product behavior: keep the useful capacity summary stable instead of
    // turning the secondary label into a marquee on hover. Full detail remains
    // available in the capacity ring tooltip.
    hoverTimer?.invalidate()
    hoverTimer = nil
  }

  private func copyDroppedFiles(_ urls: [URL]) -> Bool {
    guard state == .connected, !isReadOnlyVolume, !isCopyingFiles,
      let destinationRoot = volumeURL, !urls.isEmpty
    else {
      return false
    }

    isCopyingFiles = true
    copyCancelLock.lock()
    cancelCopyRequested = false
    copyCancelLock.unlock()

    statusOverrideUntil = Date().addingTimeInterval(3600)
    statusLabel.stringValue = "正在计算文件大小…"
    usageRing.isTransferring = true
    usageRing.fraction = 0.01
    usageRing.centerText = "0%"
    updateInlineProgressBar(fraction: 0.01, visible: true)
    setEjectButtonSymbol("stop.circle.fill", accessibilityDescription: "取消复制")
    ejectButton.toolTip = "点击取消正在进行的文件复制"
    ejectButton.isEnabled = true
    let displayName = effectiveTitleText
    let availableCapacity = lastAvailableBytes

    copyQueue.async { [weak self] in
      guard let self else { return }
      let totalBytes = Self.calculateTotalBytes(for: urls)

      if availableCapacity > 0 && totalBytes > Int64(availableCapacity) {
        let deficit = totalBytes - Int64(availableCapacity)
        DispatchQueue.main.async { [weak self] in
          guard let self else { return }
          self.isCopyingFiles = false
          self.usageRing.isTransferring = false
          self.isDropTarget = false
          NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .default)
          self.statusOverrideUntil = Date().addingTimeInterval(3.5)
          self.statusLabel.stringValue = "空间不足（还差 \(Self.size(Int(deficit)))）"
          self.refresh()
        }
        return
      }

      var copiedCount = 0
      var copiedBytes: Int64 = 0
      var createdDestinations: [URL] = []
      var lastUIUpdate = Date.distantPast

      let reportProgress: (Int64) -> Bool = { [weak self] chunkBytes in
        guard let self else { return false }
        self.copyCancelLock.lock()
        let cancelled = self.cancelCopyRequested
        self.copyCancelLock.unlock()
        if cancelled { return false }

        copiedBytes += chunkBytes
        let now = Date()
        if now.timeIntervalSince(lastUIUpdate) >= 0.06 || copiedBytes >= totalBytes {
          lastUIUpdate = now
          let fraction =
            totalBytes > 0 ? min(max(CGFloat(copiedBytes) / CGFloat(totalBytes), 0.01), 1.0) : 1.0
          let percentText = "\(Int((fraction * 100).rounded()))%"
          let statusText =
            totalBytes > 0
            ? "复制中 \(Self.size(Int(copiedBytes))) / \(Self.size(Int(totalBytes)))"
            : "正在复制 \(urls.count) 项…"
          DispatchQueue.main.async { [weak self] in
            guard let self, self.isCopyingFiles else { return }
            self.usageRing.fraction = fraction
            self.usageRing.centerText = percentText
            self.statusLabel.stringValue = statusText
            self.updateInlineProgressBar(fraction: fraction, visible: true)
          }
        }
        return true
      }

      for source in urls {
        self.copyCancelLock.lock()
        let cancelled = self.cancelCopyRequested
        self.copyCancelLock.unlock()
        if cancelled { break }

        let destination = Self.uniqueDestination(for: source, in: destinationRoot)
        do {
          try Self.copyItemWithProgress(
            from: source,
            to: destination,
            progress: reportProgress
          )
          copiedCount += 1
          createdDestinations.append(destination)
        } catch let err as NSError where err.domain == "DiskWidget.CopyCancelled" {
          try? FileManager.default.removeItem(at: destination)
          break
        } catch {
          try? FileManager.default.removeItem(at: destination)
          NSLog(
            "Could not copy \(source.lastPathComponent) to \(displayName): \(error.localizedDescription)"
          )
        }
      }

      self.copyCancelLock.lock()
      let wasCancelled = self.cancelCopyRequested
      self.copyCancelLock.unlock()

      DispatchQueue.main.async { [weak self] in
        guard let self else { return }
        self.isCopyingFiles = false
        self.usageRing.isTransferring = false
        self.isDropTarget = false
        if self.state == .connected {
          if wasCancelled {
            self.statusOverrideUntil = Date().addingTimeInterval(2.5)
            self.statusLabel.stringValue = "已取消复制"
          } else if copiedCount > 0 {
            self.lastCopiedURLs = createdDestinations
            self.revealCopiedItemsUntil = Date().addingTimeInterval(4.0)
            self.statusOverrideUntil = Date().addingTimeInterval(4.0)
            self.statusLabel.stringValue = "已复制 \(copiedCount) 项 · 单击定位"
          } else {
            self.statusOverrideUntil = Date().addingTimeInterval(3.0)
            self.statusLabel.stringValue = "复制失败"
          }
          self.refresh()
          let delay: TimeInterval = (!wasCancelled && copiedCount > 0) ? 4.1 : 2.6
          DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self else { return }
            self.statusOverrideUntil = nil
            self.refresh()
          }
        } else {
          self.statusOverrideUntil = nil
        }
      }
    }
    return true
  }

  private static func calculateTotalBytes(for urls: [URL]) -> Int64 {
    var total: Int64 = 0
    let fm = FileManager.default
    let keys: [URLResourceKey] = [.isDirectoryKey, .fileSizeKey, .totalFileSizeKey]
    for url in urls {
      guard let values = try? url.resourceValues(forKeys: Set(keys)) else { continue }
      if values.isDirectory == true {
        if let enumerator = fm.enumerator(
          at: url, includingPropertiesForKeys: keys, options: [])
        {
          for case let fileURL as URL in enumerator {
            if let fileValues = try? fileURL.resourceValues(forKeys: Set(keys)),
              fileValues.isDirectory != true
            {
              total += Int64(fileValues.totalFileSize ?? fileValues.fileSize ?? 0)
            }
          }
        }
      } else {
        total += Int64(values.totalFileSize ?? values.fileSize ?? 0)
      }
    }
    return total
  }

  private static func copyItemWithProgress(
    from source: URL,
    to destination: URL,
    progress: (Int64) -> Bool
  ) throws {
    let fm = FileManager.default
    let values = try source.resourceValues(forKeys: [.isDirectoryKey, .isSymbolicLinkKey])
    if values.isSymbolicLink == true {
      let destPath = try fm.destinationOfSymbolicLink(atPath: source.path)
      try fm.createSymbolicLink(atPath: destination.path, withDestinationPath: destPath)
      return
    }
    if values.isDirectory == true {
      try fm.createDirectory(at: destination, withIntermediateDirectories: true)
      let children = try fm.contentsOfDirectory(
        at: source, includingPropertiesForKeys: [.isDirectoryKey, .isSymbolicLinkKey], options: [])
      for child in children {
        let childDest = destination.appendingPathComponent(child.lastPathComponent)
        try copyItemWithProgress(from: child, to: childDest, progress: progress)
      }
      if let attrs = try? fm.attributesOfItem(atPath: source.path) {
        try? fm.setAttributes(attrs, ofItemAtPath: destination.path)
      }
      return
    }

    guard fm.createFile(atPath: destination.path, contents: nil) else {
      throw NSError(
        domain: "DiskWidget.Copy",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "无法创建目标文件"]
      )
    }
    let reader = try FileHandle(forReadingFrom: source)
    defer { try? reader.close() }
    let writer = try FileHandle(forWritingTo: destination)
    defer { try? writer.close() }

    let chunkSize = 4 * 1024 * 1024
    while true {
      let data = try reader.read(upToCount: chunkSize) ?? Data()
      if data.isEmpty { break }
      try writer.write(contentsOf: data)
      if !progress(Int64(data.count)) {
        throw NSError(domain: "DiskWidget.CopyCancelled", code: 1)
      }
    }
    if let attrs = try? fm.attributesOfItem(atPath: source.path) {
      try? fm.setAttributes(attrs, ofItemAtPath: destination.path)
    }
  }

  private func showVolumeInfo() {
    guard state == .connected, let url = volumeURL else { return }

    // Open Finder's real “Get Info” window instead of reproducing it ourselves.
    // This keeps the content, actions, permissions, icon and layout exactly in
    // sync with the macOS version the user is running.
    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
      do {
        try Self.openFinderGetInfo(path: url.path)
      } catch {
        DispatchQueue.main.async { [weak self] in
          self?.presentOperationError(
            title: "无法显示简介",
            message: Self.finderOperationMessage(for: error)
          )
        }
      }
    }
  }

  private static func openFinderGetInfo(path: String) throws {
    // Finder's real information window is the same window opened by ⌘I.
    // This does not attempt to reproduce Finder's metadata UI inside DiskWidget.
    let script = """
      on run argv
        set targetPath to item 1 of argv
        set targetAlias to (POSIX file targetPath) as alias
        tell application "Finder"
          activate
          open information window of targetAlias
        end tell
      end run
      """
    _ = try runOSAScript(script, arguments: [path], timeout: 12)
  }

  private static func runOSAScript(
    _ source: String,
    arguments: [String],
    timeout: TimeInterval
  ) throws -> String {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
    process.arguments = ["-e", source] + arguments

    let stdout = Pipe()
    let stderr = Pipe()
    process.standardOutput = stdout
    process.standardError = stderr

    let finished = DispatchSemaphore(value: 0)
    process.terminationHandler = { _ in finished.signal() }
    try process.run()

    if finished.wait(timeout: .now() + timeout) == .timedOut {
      process.terminate()
      throw NSError(
        domain: "DiskWidget.Finder",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Finder 操作超时"]
      )
    }

    let outputData = stdout.fileHandleForReading.readDataToEndOfFile()
    let errorData = stderr.fileHandleForReading.readDataToEndOfFile()
    guard process.terminationStatus == 0 else {
      let data = errorData.isEmpty ? outputData : errorData
      let message =
        String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
        ?? "Finder 操作失败"
      throw NSError(
        domain: "DiskWidget.Finder",
        code: Int(process.terminationStatus),
        userInfo: [NSLocalizedDescriptionKey: message]
      )
    }

    return String(data: outputData, encoding: .utf8)?
      .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
  }

  private static func finderOperationMessage(for error: Error) -> String {
    let message = error.localizedDescription
    if message.contains("-1743") || message.localizedCaseInsensitiveContains("not authorized") {
      return "需要允许 DiskWidget 控制 Finder。请在系统设置 → 隐私与安全性 → 自动化中允许相关权限后重试。"
    }
    if message.contains("-5000") {
      return "Finder 无法读取该项目的信息窗口。请确认当前卷仍处于挂载状态，并检查 Finder 是否可以手动对它执行“显示简介”。"
    }
    return message
  }

  private func presentOperationError(title: String, message: String) {
    let alert = NSAlert()
    alert.messageText = title
    alert.informativeText = message
    alert.alertStyle = .warning
    alert.addButton(withTitle: "好")
    alert.runModal()
  }

  private func openDisk() {
    guard state == .connected, let volumeURL else { return }
    NSWorkspace.shared.open(volumeURL)
  }

  @objc private func diskAction() {
    if isCopyingFiles {
      cancelActiveFileCopy()
      return
    }
    switch state {
    case .connected:
      safeUnmountForReconnect()
    case .unmounted:
      reconnectDisk()
    case .disconnected:
      requestRemoval()
    case .unmounting, .reconnecting, .fullyEjecting:
      break
    }
  }

  // Primary action: unmount the whole physical disk without ejecting the device
  // from the I/O stack. The file systems are cleanly unmounted, so the disk can
  // be physically removed, but it also remains software-remountable.
  private func safeUnmountForReconnect() {
    guard state == .connected, !isCopyingFiles, let url = volumeURL else { return }

    operationGeneration += 1
    let generation = operationGeneration
    state = .unmounting
    showBusyState("正在安全推出…", symbol: "eject")
    updateAppearance()
    stateChanged?()

    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
      do {
        let target = try Self.diskTarget(for: url)
        if let wholeDisk = target.wholeDiskIdentifier {
          _ = try Self.runDiskutil(["unmountDisk", wholeDisk])
        } else {
          _ = try Self.runDiskutil(["unmount", target.volumeIdentifier])
        }

        DispatchQueue.main.async { [weak self] in
          guard let self, self.operationGeneration == generation else { return }
          self.lastUnmountFailed = false
          self.reconnectVolumeIdentifier = target.volumeIdentifier
          self.reconnectWholeDiskIdentifier = target.wholeDiskIdentifier
          if let uuid = target.volumeUUID {
            self.lastVolumeUUID = uuid
            UserDefaults.standard.set(uuid, forKey: "disk-widget-volume-uuid-\(self.diskName)")
          }
          self.state = .unmounted
          self.showUnmountedState()
          self.updateAppearance()
          self.stateChanged?()
        }
      } catch {
        let blocker = Self.detectBlockingProcessName(forVolumePath: url.path, error: error)
        NSLog("Could not safely unmount \(self?.diskName ?? "disk"): \(error.localizedDescription)")
        DispatchQueue.main.async { [weak self] in
          guard let self, self.operationGeneration == generation else { return }
          self.lastUnmountFailed = true
          self.state = .disconnected
          self.refresh()
          let failureText =
            blocker.map { "被 \($0) 占用 · 右键可强制推出" } ?? "推出失败 · 右键可强制推出"
          if self.state == .connected {
            self.statusOverrideUntil = Date().addingTimeInterval(4.5)
            self.statusLabel.stringValue = failureText
          } else {
            self.disconnectedMessage = failureText
            self.showDisconnectedState(message: failureText)
          }
          self.stateChanged?()
        }
      }
    }
  }

  private func confirmAndForceUnmount() {
    guard state == .connected, let url = volumeURL else { return }
    let alert = NSAlert()
    alert.messageText = "强制推出“\(effectiveTitleText)”？"
    alert.informativeText = "如果该磁盘上有尚未保存的文件或正在进行的读写操作，强制推出可能会导致数据丢失。"
    alert.alertStyle = .critical
    alert.addButton(withTitle: "强制推出")
    alert.addButton(withTitle: "取消")
    NSApp.activate(ignoringOtherApps: true)
    guard alert.runModal() == .alertFirstButtonReturn else { return }

    operationGeneration += 1
    let generation = operationGeneration
    state = .unmounting
    showBusyState("正在强制推出…", symbol: "exclamationmark.triangle")
    updateAppearance()
    stateChanged?()

    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
      do {
        let target = try Self.diskTarget(for: url)
        if let wholeDisk = target.wholeDiskIdentifier {
          _ = try Self.runDiskutil(["unmountDisk", "force", wholeDisk])
        } else {
          _ = try Self.runDiskutil(["unmount", "force", target.volumeIdentifier])
        }
        DispatchQueue.main.async { [weak self] in
          guard let self, self.operationGeneration == generation else { return }
          self.lastUnmountFailed = false
          self.reconnectVolumeIdentifier = target.volumeIdentifier
          self.reconnectWholeDiskIdentifier = target.wholeDiskIdentifier
          self.state = .unmounted
          self.showUnmountedState()
          self.updateAppearance()
          self.stateChanged?()
        }
      } catch {
        DispatchQueue.main.async { [weak self] in
          guard let self, self.operationGeneration == generation else { return }
          self.state = .disconnected
          self.refresh()
          self.statusOverrideUntil = Date().addingTimeInterval(3.5)
          self.statusLabel.stringValue = "强制推出失败"
          self.stateChanged?()
        }
      }
    }
  }

  private static func detectBlockingProcessName(forVolumePath path: String, error: Error) -> String?
  {
    let msg = error.localizedDescription
    if let range = msg.range(of: "dissented by PID ") {
      let after = msg[range.upperBound...]
      let pidStr = after.prefix { $0.isNumber }
      if let pid = Int32(pidStr),
        let app = NSRunningApplication(processIdentifier: pid),
        let name = app.localizedName, !name.isEmpty
      {
        return name
      }
    }

    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/sbin/lsof")
    process.arguments = ["-Fc", "-n", "-P", "--", path]
    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = Pipe()

    let finished = DispatchSemaphore(value: 0)
    process.terminationHandler = { _ in finished.signal() }
    do {
      try process.run()
    } catch {
      return nil
    }
    guard finished.wait(timeout: .now() + 2.5) == .success else {
      process.terminate()
      return nil
    }
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    guard let output = String(data: data, encoding: .utf8) else { return nil }
    for line in output.split(separator: "\n") {
      guard line.first == "c" else { continue }
      let rawName = String(line.dropFirst()).trimmingCharacters(in: .whitespacesAndNewlines)
      guard !rawName.isEmpty, rawName != "lsof" else { continue }
      if rawName.hasPrefix("mds") || rawName.hasPrefix("mdworker") {
        return "Spotlight 索引"
      }
      if rawName == "fseventsd" { continue }
      return rawName
    }
    return nil
  }

  private func reconnectDisk() {
    guard state == .unmounted else { return }
    guard reconnectWholeDiskIdentifier != nil || reconnectVolumeIdentifier != nil else {
      state = .disconnected
      disconnectedMessage = "请重新插入硬盘"
      showDisconnectedState(message: disconnectedMessage)
      return
    }

    operationGeneration += 1
    let generation = operationGeneration
    let wholeDisk = reconnectWholeDiskIdentifier
    let volumeIdentifier = reconnectVolumeIdentifier
    state = .reconnecting
    showBusyState("正在重新连接…", symbol: "arrow.triangle.2.circlepath")
    updateAppearance()
    stateChanged?()

    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
      do {
        if let wholeDisk {
          _ = try Self.runDiskutil(["mountDisk", wholeDisk])
        } else if let volumeIdentifier {
          _ = try Self.runDiskutil(["mount", volumeIdentifier])
        }

        DispatchQueue.main.async { [weak self] in
          guard let self, self.operationGeneration == generation else { return }
          self.state = .disconnected
          self.disconnectedMessage = "未连接"
          self.refresh()
          self.stateChanged?()
          if self.state != .connected {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
              self?.refresh()
              self?.stateChanged?()
            }
          }
        }
      } catch {
        NSLog("Could not reconnect \(self?.diskName ?? "disk"): \(error.localizedDescription)")
        DispatchQueue.main.async { [weak self] in
          guard let self, self.operationGeneration == generation else { return }
          self.state = .disconnected
          self.disconnectedMessage = "请重新插入硬盘"
          self.showDisconnectedState(message: self.disconnectedMessage)
          self.updateAppearance()
          self.stateChanged?()
        }
      }
    }
  }

  // Finder-style full eject. Once the device disappears from the I/O stack,
  // software remounting may no longer be possible; reinsertion is then required.
  private func fullyEjectDisk() {
    guard state == .connected || state == .unmounted else { return }

    operationGeneration += 1
    let generation = operationGeneration
    let url = volumeURL
    let wholeDisk = reconnectWholeDiskIdentifier
    state = .fullyEjecting
    showBusyState("正在完全推出…", symbol: "eject.fill")
    updateAppearance()
    stateChanged?()

    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
      do {
        let identifier: String
        if let url {
          let target = try Self.diskTarget(for: url)
          identifier = target.wholeDiskIdentifier ?? target.volumeIdentifier
        } else if let wholeDisk {
          identifier = wholeDisk
        } else {
          throw NSError(
            domain: "DiskWidget",
            code: 3,
            userInfo: [NSLocalizedDescriptionKey: "找不到可推出的设备标识"]
          )
        }
        _ = try Self.runDiskutil(["eject", identifier])

        DispatchQueue.main.async { [weak self] in
          guard let self, self.operationGeneration == generation else { return }
          self.lastUnmountFailed = false
          self.reconnectVolumeIdentifier = nil
          self.reconnectWholeDiskIdentifier = nil
          self.state = .disconnected
          // A fully ejected device no longer exists from the user's point of view,
          // so remove its card instead of leaving a disconnected placeholder.
          self.removalRequested?(self)
        }
      } catch {
        let blocker = url.flatMap { Self.detectBlockingProcessName(forVolumePath: $0.path, error: error) }
        NSLog("Could not fully eject \(self?.diskName ?? "disk"): \(error.localizedDescription)")
        DispatchQueue.main.async { [weak self] in
          guard let self, self.operationGeneration == generation else { return }
          self.lastUnmountFailed = true
          self.state = .disconnected
          self.refresh()
          let failureText =
            blocker.map { "被 \($0) 占用 · 右键可强制推出" } ?? "完全推出失败 · 右键可强制推出"
          if self.state == .connected {
            self.statusOverrideUntil = Date().addingTimeInterval(4.5)
            self.statusLabel.stringValue = failureText
          } else {
            self.disconnectedMessage = failureText
            self.showDisconnectedState(message: self.disconnectedMessage)
          }
          self.stateChanged?()
        }
      }
    }
  }

  private static func diskTarget(for volumeURL: URL) throws -> DiskTarget {
    let data = try runDiskutil(["info", "-plist", volumeURL.path])
    guard
      let dictionary = try PropertyListSerialization.propertyList(from: data, format: nil)
        as? [String: Any],
      let deviceIdentifier = dictionary["DeviceIdentifier"] as? String,
      !deviceIdentifier.isEmpty
    else {
      throw NSError(
        domain: "DiskWidget",
        code: 2,
        userInfo: [NSLocalizedDescriptionKey: "无法读取磁盘设备标识"]
      )
    }

    let isWholeDisk = (dictionary["WholeDisk"] as? Bool) == true
    let parentWholeDisk = dictionary["ParentWholeDisk"] as? String
    let wholeDiskIdentifier = parentWholeDisk ?? (isWholeDisk ? deviceIdentifier : nil)
    let volumeUUID = dictionary["VolumeUUID"] as? String

    return DiskTarget(
      volumeIdentifier: deviceIdentifier,
      wholeDiskIdentifier: wholeDiskIdentifier,
      volumeUUID: volumeUUID
    )
  }

  private static func runDiskutil(_ arguments: [String], timeout: TimeInterval = 20) throws -> Data
  {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/sbin/diskutil")
    process.arguments = arguments

    let stdout = Pipe()
    let stderr = Pipe()
    process.standardOutput = stdout
    process.standardError = stderr

    let finished = DispatchSemaphore(value: 0)
    process.terminationHandler = { _ in finished.signal() }
    try process.run()

    if finished.wait(timeout: .now() + timeout) == .timedOut {
      process.terminate()
      throw NSError(
        domain: "DiskWidget",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "diskutil 操作超时"]
      )
    }

    let outputData = stdout.fileHandleForReading.readDataToEndOfFile()
    let errorData = stderr.fileHandleForReading.readDataToEndOfFile()

    guard process.terminationStatus == 0 else {
      let data = errorData.isEmpty ? outputData : errorData
      let message =
        String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
        ?? "diskutil 失败"
      throw NSError(
        domain: "DiskWidget",
        code: Int(process.terminationStatus),
        userInfo: [NSLocalizedDescriptionKey: message]
      )
    }
    return outputData
  }

  func setManagedPosition(_ origin: NSPoint) {
    if frame.origin != origin {
      setFrameOrigin(origin)
    }
  }

  private static func uniqueDestination(for source: URL, in directory: URL) -> URL {
    let base = source.deletingPathExtension().lastPathComponent
    let ext = source.pathExtension
    var candidate = directory.appendingPathComponent(source.lastPathComponent)
    var index = 2
    while FileManager.default.fileExists(atPath: candidate.path) {
      let name = "\(base) \(index)"
      candidate = directory.appendingPathComponent(ext.isEmpty ? name : "\(name).\(ext)")
      index += 1
    }
    return candidate
  }

  fileprivate static func isDisplayableMount(url: URL, values: URLResourceValues) -> Bool {
    let path = url.standardizedFileURL.path
    guard path.hasPrefix("/Volumes/"), path != "/Volumes/Recovery" else { return false }
    let formatDesc = (
      values.volumeLocalizedFormatDescription
        ?? (try? url.resourceValues(forKeys: [.volumeLocalizedFormatDescriptionKey]))?
          .volumeLocalizedFormatDescription
        ?? ""
    ).lowercased()
    return !formatDesc.contains("autofs") && !formatDesc.contains("devicefs")
  }

  private static func isSystemDarkMode(view: NSView? = nil) -> Bool {
    if let appearance = NSApp?.effectiveAppearance ?? view?.effectiveAppearance {
      return appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
    }
    return UserDefaults.standard.string(forKey: "AppleInterfaceStyle") == "Dark"
  }

  func refreshAppearanceForSystemThemeChange() {
    updateAppearance()
  }

  private func updateAppearance() {
    guard surface != nil else { return }

    enum DesktopActiveMode { case nativeFrosted, darkSlate, sheerGlass }
    let activeMode: DesktopActiveMode
    switch desktopActiveStyle {
    case 1: activeMode = .darkSlate
    case 2: activeMode = .sheerGlass
    default: activeMode = .nativeFrosted
    }

    let isGlassActive = (glassBackgroundView != nil)
    let systemIsDark = Self.isSystemDarkMode(view: surface)
    let isDark = isGlassActive || systemIsDark
    let isActiveOnDesktop =
      !dimWhenDesktopInactive || isDesktopActive || isCardHovered || isEjectHovered
      || isDropTarget || isReorderActive
    let shouldDimIdle = !isActiveOnDesktop
    let isBackgroundVisible =
      isGlassActive ? (backgroundOpacity > 0.001) : !materialView.isHidden

    if isGlassActive {
      if #available(macOS 26.0, *), let glass = glassBackgroundView as? NSGlassEffectView {
        if glass.style != .clear {
          glass.style = .clear
        }
        if glass.appearance?.name != .darkAqua {
          glass.appearance = NSAppearance(named: .darkAqua)
        }
        let showGlass: Bool
        if !isBackgroundVisible {
          showGlass = false
        } else if isActiveOnDesktop && activeMode == .darkSlate {
          showGlass = backgroundOpacity < 0.92
        } else {
          showGlass = true
        }
        if glass.isHidden != !showGlass {
          glass.isHidden = !showGlass
        }
        if showGlass {
          if shouldDimIdle {
            if systemIsDark {
              glass.tintColor = NSColor(
                srgbRed: 0.03, green: 0.035, blue: 0.05,
                alpha: min(0.88, 0.44 + backgroundOpacity * 0.44))
            } else {
              glass.tintColor = NSColor(
                srgbRed: 0, green: 0, blue: 0, alpha: max(0.04, min(0.80, backgroundOpacity)))
            }
          } else if activeMode == .sheerGlass {
            if systemIsDark {
              glass.tintColor = NSColor(
                srgbRed: 0.02, green: 0.025, blue: 0.04,
                alpha: min(0.76, 0.24 + backgroundOpacity * 0.50))
            } else {
              glass.tintColor = NSColor(
                srgbRed: 0, green: 0, blue: 0, alpha: max(0.04, min(0.80, backgroundOpacity)))
            }
          } else if activeMode == .darkSlate {
            glass.tintColor = NSColor(
              srgbRed: 0, green: 0, blue: 0,
              alpha: systemIsDark ? max(0.22, backgroundOpacity * 0.55) : max(0.08, backgroundOpacity * 0.5))
          } else {
            if systemIsDark {
              glass.tintColor = NSColor(
                srgbRed: 0.035, green: 0.04, blue: 0.06,
                alpha: min(0.88, 0.42 + backgroundOpacity * 0.46))
            } else {
              glass.tintColor = NSColor(
                srgbRed: 0.08, green: 0.07, blue: 0.09,
                alpha: max(0.04, min(0.78, backgroundOpacity)))
            }
          }
        } else {
          glass.tintColor = nil
        }
      }
      setForceMainAppearance(true)
    } else {
      let desiredMaterial: NSVisualEffectView.Material = isDark ? .hudWindow : .menu
      if materialView.material != desiredMaterial {
        materialView.material = desiredMaterial
      }
      if materialView.state != .active {
        materialView.state = .active
      }
    }

    let nativeGreen = NSColor(srgbRed: 0.20, green: 0.84, blue: 0.36, alpha: 1.0)
    let tokenBlue = NSColor(srgbRed: 0.35, green: 0.67, blue: 0.96, alpha: 1.0)

    let effectiveAccent: NSColor
    if isGlassActive {
      if shouldDimIdle {
        effectiveAccent = NSColor.white.withAlphaComponent(0.84)
      } else {
        switch activeMode {
        case .nativeFrosted: effectiveAccent = nativeGreen
        case .darkSlate: effectiveAccent = tokenBlue
        case .sheerGlass: effectiveAccent = accentColor
        }
      }
    } else {
      effectiveAccent = shouldDimIdle ? .secondaryLabelColor : accentColor
    }

    if state == .connected {
      let iconTint: NSColor
      if isGlassActive {
        if shouldDimIdle {
          iconTint = NSColor.white.withAlphaComponent(0.78)
        } else {
          switch activeMode {
          case .nativeFrosted: iconTint = NSColor.white.withAlphaComponent(0.96)
          case .darkSlate: iconTint = tokenBlue
          case .sheerGlass: iconTint = accentColor.withAlphaComponent(0.95)
          }
        }
      } else {
        iconTint = shouldDimIdle ? .secondaryLabelColor : accentColor
      }
      if diskIcon.contentTintColor != iconTint {
        diskIcon.contentTintColor = iconTint
      }
    }
    usageRing.accentColor = effectiveAccent
    usageRing.isMonochromeDimmed = shouldDimIdle

    if isGlassActive {
      if shouldDimIdle {
        nameLabel.textColor = NSColor.white.withAlphaComponent(0.86)
        if !isReorderActive {
          statusLabel.textColor = NSColor.white.withAlphaComponent(0.58)
        }
        formatBadgeLabel.textColor = NSColor.white.withAlphaComponent(0.68)
      } else {
        switch activeMode {
        case .nativeFrosted:
          nameLabel.textColor = NSColor.white.withAlphaComponent(0.98)
          if !isReorderActive {
            statusLabel.textColor = NSColor.white.withAlphaComponent(0.76)
          }
          formatBadgeLabel.textColor = NSColor.white.withAlphaComponent(0.86)
        case .darkSlate:
          nameLabel.textColor = NSColor.white.withAlphaComponent(0.98)
          if !isReorderActive {
            statusLabel.textColor = NSColor(srgbRed: 0.68, green: 0.74, blue: 0.82, alpha: 0.92)
          }
          formatBadgeLabel.textColor = tokenBlue.withAlphaComponent(0.95)
        case .sheerGlass:
          nameLabel.textColor = NSColor.white.withAlphaComponent(0.98)
          if !isReorderActive {
            statusLabel.textColor = NSColor.white.withAlphaComponent(0.72)
          }
          formatBadgeLabel.textColor = NSColor.white.withAlphaComponent(0.84)
        }
      }
    } else {
      nameLabel.textColor = shouldDimIdle ? .secondaryLabelColor : .labelColor
      if !isReorderActive {
        statusLabel.textColor = shouldDimIdle ? .tertiaryLabelColor : .secondaryLabelColor
      }
      formatBadgeLabel.textColor = shouldDimIdle ? .tertiaryLabelColor : .secondaryLabelColor
    }

    surface.effectiveAppearance.performAsCurrentDrawingAppearance {
      let borderColor: NSColor
      let borderWidth: CGFloat
      let fillColor: NSColor

      if isDropTarget {
        borderColor = accentColor
        borderWidth = 2
        fillColor = accentColor.withAlphaComponent(0.12)
      } else if isReorderActive {
        borderColor = accentColor
        borderWidth = 2
        fillColor = accentColor.withAlphaComponent(0.08)
      } else if isGlassActive {
        if isActiveOnDesktop && isBackgroundVisible {
          switch activeMode {
          case .nativeFrosted:
            borderColor = NSColor.white.withAlphaComponent(systemIsDark ? 0.16 : 0.22)
          case .darkSlate: borderColor = NSColor.white.withAlphaComponent(0.11)
          case .sheerGlass:
            borderColor = NSColor.white.withAlphaComponent(systemIsDark ? 0.14 : 0.18)
          }
          borderWidth = 0.8
        } else if systemIsDark && isBackgroundVisible {
          borderColor = NSColor.white.withAlphaComponent(0.13)
          borderWidth = 0.75
        } else {
          borderColor = .clear
          borderWidth = 0
        }
        if isCardPressed {
          fillColor = NSColor.white.withAlphaComponent(0.06)
        } else if isCardHovered {
          fillColor = NSColor.white.withAlphaComponent(0.025)
        } else {
          fillColor = .clear
        }
      } else if isCardPressed {
        let rimAlpha: CGFloat = isDark ? 0.24 : 0.16
        borderColor = (isDark ? NSColor.white : NSColor.black).withAlphaComponent(rimAlpha)
        borderWidth = 1
        fillColor = NSColor.labelColor.withAlphaComponent(0.06)
      } else if isCardHovered {
        let rimAlpha: CGFloat = isDark ? 0.22 : 0.14
        borderColor = (isDark ? NSColor.white : NSColor.black).withAlphaComponent(rimAlpha)
        borderWidth = 1
        fillColor = NSColor.labelColor.withAlphaComponent(0.03)
      } else {
        let baseAlpha: CGFloat = isDark ? 0.14 : 0.085
        borderColor =
          (isDark ? NSColor.white : NSColor.black).withAlphaComponent(
            isBackgroundVisible ? baseAlpha : 0)
        borderWidth = isBackgroundVisible ? 0.75 : 0
        fillColor = .clear
      }

      surface.layer?.borderColor = borderColor.cgColor
      surface.layer?.borderWidth = borderWidth
      surface.layer?.backgroundColor = fillColor.cgColor

      if isGlassActive {
        if !isBackgroundVisible {
          surfaceBaseLayer.isHidden = true
        } else if shouldDimIdle {
          surfaceBaseLayer.isHidden = false
          surfaceBaseLayer.backgroundColor =
            (systemIsDark
              ? NSColor(
                srgbRed: 0.045, green: 0.05, blue: 0.07,
                alpha: min(0.76, 0.36 + backgroundOpacity * 0.40))
              : NSColor(
                srgbRed: 0.06, green: 0.07, blue: 0.09, alpha: backgroundOpacity * 0.38)
            ).cgColor
        } else if activeMode == .sheerGlass {
          surfaceBaseLayer.isHidden = false
          surfaceBaseLayer.backgroundColor =
            (systemIsDark
              ? NSColor(
                srgbRed: 0.035, green: 0.04, blue: 0.06,
                alpha: min(0.62, 0.16 + backgroundOpacity * 0.44))
              : NSColor(
                srgbRed: 0.06, green: 0.07, blue: 0.09, alpha: backgroundOpacity * 0.38)
            ).cgColor
        } else if activeMode == .darkSlate {
          surfaceBaseLayer.isHidden = false
          let slateAlpha =
            systemIsDark
            ? max(0.42, min(0.97, 0.42 + backgroundOpacity * 0.54))
            : max(0.15, min(0.96, 0.25 + backgroundOpacity * 0.72))
          surfaceBaseLayer.backgroundColor =
            NSColor(
              srgbRed: 36.0 / 255.0, green: 42.0 / 255.0, blue: 49.0 / 255.0, alpha: slateAlpha
            ).cgColor
        } else {
          surfaceBaseLayer.isHidden = false
          surfaceBaseLayer.backgroundColor =
            (systemIsDark
              ? NSColor(
                srgbRed: 0.05, green: 0.055, blue: 0.075,
                alpha: min(0.78, 0.38 + backgroundOpacity * 0.42))
              : NSColor(
                srgbRed: 0.14, green: 0.13, blue: 0.16, alpha: backgroundOpacity * 0.52)
            ).cgColor
        }
      } else if !isBackgroundVisible {
        surfaceBaseLayer.isHidden = true
      } else {
        surfaceBaseLayer.isHidden = false
        surfaceBaseLayer.backgroundColor =
          (isDark
            ? NSColor(srgbRed: 0.10, green: 0.11, blue: 0.14, alpha: 0.52)
            : NSColor(srgbRed: 0.97, green: 0.98, blue: 0.99, alpha: 0.46)
          ).cgColor
      }

      if !isBackgroundVisible || (!isGlassActive && shouldDimIdle) {
        ambientGradientLayer.isHidden = true
      } else if isGlassActive {
        ambientGradientLayer.isHidden = false
        if shouldDimIdle {
          let topSheen =
            NSColor.white.withAlphaComponent(
              systemIsDark ? 0.02 + 0.02 * backgroundOpacity : 0.01 + 0.02 * backgroundOpacity
            ).cgColor
          let midSheen =
            (systemIsDark ? NSColor.black.withAlphaComponent(0.06) : NSColor.clear).cgColor
          let bottomShade =
            NSColor.black.withAlphaComponent(
              systemIsDark ? 0.16 + 0.18 * backgroundOpacity : 0.04 + 0.10 * backgroundOpacity
            ).cgColor
          ambientGradientLayer.colors = [topSheen, midSheen, bottomShade]
        } else {
          switch activeMode {
          case .nativeFrosted:
            if systemIsDark {
              ambientGradientLayer.colors = [
                NSColor.white.withAlphaComponent(0.03 + 0.04 * backgroundOpacity).cgColor,
                NSColor.black.withAlphaComponent(0.06).cgColor,
                NSColor.black.withAlphaComponent(0.18 + 0.20 * backgroundOpacity).cgColor,
              ]
            } else {
              ambientGradientLayer.colors = [
                NSColor.white.withAlphaComponent(0.03 + 0.12 * backgroundOpacity).cgColor,
                NSColor.white.withAlphaComponent(0.01 + 0.04 * backgroundOpacity).cgColor,
                NSColor.black.withAlphaComponent(0.02 + 0.14 * backgroundOpacity).cgColor,
              ]
            }
          case .darkSlate:
            let slateAlpha =
              systemIsDark
              ? max(0.42, min(0.97, 0.42 + backgroundOpacity * 0.54))
              : max(0.15, min(0.96, 0.25 + backgroundOpacity * 0.72))
            ambientGradientLayer.colors = [
              NSColor(
                srgbRed: 43.0 / 255.0, green: 49.0 / 255.0, blue: 56.0 / 255.0,
                alpha: min(0.97, slateAlpha + 0.01)
              ).cgColor,
              NSColor(
                srgbRed: 36.0 / 255.0, green: 42.0 / 255.0, blue: 49.0 / 255.0,
                alpha: min(0.97, slateAlpha + 0.01)
              ).cgColor,
              NSColor(
                srgbRed: 31.0 / 255.0, green: 37.0 / 255.0, blue: 44.0 / 255.0,
                alpha: min(0.98, slateAlpha + 0.02)
              ).cgColor,
            ]
          case .sheerGlass:
            ambientGradientLayer.colors = [
              NSColor.white.withAlphaComponent(
                systemIsDark ? 0.02 + 0.03 * backgroundOpacity : 0.02 + 0.04 * backgroundOpacity
              ).cgColor,
              NSColor.clear.cgColor,
              NSColor.black.withAlphaComponent(
                systemIsDark ? 0.12 + 0.18 * backgroundOpacity : 0.04 + 0.14 * backgroundOpacity
              ).cgColor,
            ]
          }
        }
      } else {
        ambientGradientLayer.isHidden = false
        let topSheen = accentColor.withAlphaComponent(isDark ? 0.14 : 0.065).cgColor
        let midSheen =
          (isDark ? NSColor.white.withAlphaComponent(0.02) : NSColor.white.withAlphaComponent(0.18))
          .cgColor
        let bottomShade =
          (isDark ? NSColor.black.withAlphaComponent(0.16) : NSColor.black.withAlphaComponent(0.025))
          .cgColor
        ambientGradientLayer.colors = [topSheen, midSheen, bottomShade]
      }

      if isGlassActive {
        if shouldDimIdle {
          iconBadgeView.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.09).cgColor
          iconBadgeView.layer?.borderWidth = 0
          formatBadgeBox.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.09).cgColor
          inlineBarTrack.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.14).cgColor
          inlineBarFill.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.76).cgColor
          ejectPillView.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.10).cgColor
          ejectPillView.layer?.borderColor = NSColor.white.withAlphaComponent(0.14).cgColor
          ejectPillView.layer?.borderWidth = 0.5
        } else {
          switch activeMode {
          case .nativeFrosted:
            if state == .connected {
              iconBadgeView.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.15).cgColor
              iconBadgeView.layer?.borderColor = NSColor.white.withAlphaComponent(0.22).cgColor
              iconBadgeView.layer?.borderWidth = 0.5
            } else {
              iconBadgeView.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.09).cgColor
              iconBadgeView.layer?.borderWidth = 0
            }
            formatBadgeBox.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.14).cgColor
            inlineBarTrack.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.18).cgColor
            inlineBarFill.layer?.backgroundColor =
              (isCopyingFiles ? NSColor.systemGreen : nativeGreen).cgColor
            ejectPillView.layer?.backgroundColor =
              NSColor.white.withAlphaComponent(isEjectHovered ? 0.24 : 0.15).cgColor
            ejectPillView.layer?.borderColor = NSColor.white.withAlphaComponent(0.22).cgColor
            ejectPillView.layer?.borderWidth = 0.5
          case .darkSlate:
            if state == .connected {
              iconBadgeView.layer?.backgroundColor = tokenBlue.withAlphaComponent(0.16).cgColor
              iconBadgeView.layer?.borderColor = tokenBlue.withAlphaComponent(0.30).cgColor
              iconBadgeView.layer?.borderWidth = 0.6
            } else {
              iconBadgeView.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.09).cgColor
              iconBadgeView.layer?.borderWidth = 0
            }
            formatBadgeBox.layer?.backgroundColor = tokenBlue.withAlphaComponent(0.15).cgColor
            inlineBarTrack.layer?.backgroundColor = tokenBlue.withAlphaComponent(0.18).cgColor
            inlineBarFill.layer?.backgroundColor =
              (isCopyingFiles ? NSColor.systemGreen : tokenBlue).cgColor
            ejectPillView.layer?.backgroundColor =
              NSColor.white.withAlphaComponent(isEjectHovered ? 0.18 : 0.09).cgColor
            ejectPillView.layer?.borderColor = NSColor.white.withAlphaComponent(0.14).cgColor
            ejectPillView.layer?.borderWidth = 0.5
          case .sheerGlass:
            if state == .connected {
              iconBadgeView.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.14).cgColor
              iconBadgeView.layer?.borderColor = NSColor.white.withAlphaComponent(0.20).cgColor
              iconBadgeView.layer?.borderWidth = 0.5
            } else {
              iconBadgeView.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.09).cgColor
              iconBadgeView.layer?.borderWidth = 0
            }
            formatBadgeBox.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.14).cgColor
            inlineBarTrack.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.16).cgColor
            inlineBarFill.layer?.backgroundColor =
              (isCopyingFiles ? NSColor.systemGreen : accentColor.withAlphaComponent(0.92)).cgColor
            ejectPillView.layer?.backgroundColor =
              NSColor.white.withAlphaComponent(isEjectHovered ? 0.22 : 0.13).cgColor
            ejectPillView.layer?.borderColor = NSColor.white.withAlphaComponent(0.18).cgColor
            ejectPillView.layer?.borderWidth = 0.5
          }
        }
      } else {
        if shouldDimIdle || state != .connected {
          iconBadgeView.layer?.backgroundColor =
            NSColor.labelColor.withAlphaComponent(0.07).cgColor
          iconBadgeView.layer?.borderWidth = 0
        } else {
          iconBadgeView.layer?.backgroundColor =
            accentColor.withAlphaComponent(isDark ? 0.18 : 0.14).cgColor
          iconBadgeView.layer?.borderColor = accentColor.withAlphaComponent(0.28).cgColor
          iconBadgeView.layer?.borderWidth = 0.6
        }

        formatBadgeBox.layer?.backgroundColor =
          NSColor.labelColor.withAlphaComponent(0.07).cgColor
        inlineBarTrack.layer?.backgroundColor =
          NSColor.labelColor.withAlphaComponent(0.09).cgColor
        if shouldDimIdle {
          inlineBarFill.layer?.backgroundColor =
            NSColor.secondaryLabelColor.withAlphaComponent(0.55).cgColor
        } else {
          inlineBarFill.layer?.backgroundColor =
            (isCopyingFiles ? NSColor.systemGreen : accentColor).cgColor
        }
        ejectPillView.layer?.backgroundColor =
          NSColor.labelColor.withAlphaComponent(isCardHovered || isEjectHovered ? 0.12 : 0.06).cgColor
        ejectPillView.layer?.borderWidth = 0
      }
      ejectPillView.isHidden = ejectButton.isHidden
    }

    if isGlassActive {
      let tintAlpha: CGFloat
      if isEjectHovered {
        tintAlpha = 0.98
      } else if shouldDimIdle {
        tintAlpha = 0.78
      } else {
        tintAlpha = activeMode == .darkSlate ? 0.92 : 0.94
      }
      let tint = NSColor.white.withAlphaComponent(tintAlpha)
      if ejectButton.contentTintColor != tint {
        ejectButton.contentTintColor = tint
      }
    } else if ejectButton.contentTintColor != nil {
      ejectButton.contentTintColor = nil
    }

    let targetWindowAlpha: CGFloat = isHiddenForDesktopPresentation ? 0.0 : 1.0
    if abs(alphaValue - targetWindowAlpha) > 0.001 {
      alphaValue = targetWindowAlpha
    }

    let targetAlpha: CGFloat
    if state == .connected || state == .unmounted {
      targetAlpha = isEjectHovered ? 1.0 : (isGlassActive ? 0.96 : 0.85)
    } else {
      targetAlpha = 0.85
    }
    if abs(ejectButton.alphaValue - targetAlpha) > 0.001 {
      ejectButton.alphaValue = targetAlpha
    }
  }

  private static func size(_ bytes: Int) -> String {
    ByteCountFormatter.string(fromByteCount: Int64(bytes), countStyle: .file)
  }
}

// MARK: - Layout editor

final class LayoutSliderView: NSView {
  private let titleLabel = NSTextField(labelWithString: "")
  private let slider: NSSlider
  private let valueLabel = NSTextField(labelWithString: "")
  private let formatter: (Double) -> String
  var onChange: ((CGFloat) -> Void)?

  init(
    title: String,
    value: CGFloat,
    min: CGFloat,
    max: CGFloat,
    width: CGFloat = 370,
    height: CGFloat = 38,
    formatter: @escaping (Double) -> String = { "\(Int($0.rounded()))" }
  ) {
    slider = NSSlider(
      value: Double(value),
      minValue: Double(min),
      maxValue: Double(max),
      target: nil,
      action: nil
    )
    self.formatter = formatter
    super.init(frame: NSRect(x: 0, y: 0, width: width, height: height))

    titleLabel.stringValue = title
    titleLabel.font = .systemFont(ofSize: 12)
    titleLabel.textColor = .labelColor
    valueLabel.font = .monospacedDigitSystemFont(ofSize: 11, weight: .regular)
    valueLabel.textColor = .secondaryLabelColor
    valueLabel.alignment = .right
    slider.isContinuous = true
    slider.target = self
    slider.action = #selector(changed(_:))

    [titleLabel, slider, valueLabel].forEach {
      $0.translatesAutoresizingMaskIntoConstraints = false
      addSubview($0)
    }

    NSLayoutConstraint.activate([
      widthAnchor.constraint(equalToConstant: width),
      heightAnchor.constraint(equalToConstant: height),
      titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
      titleLabel.centerYAnchor.constraint(equalTo: slider.centerYAnchor),
      titleLabel.widthAnchor.constraint(equalToConstant: 96),
      slider.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 10),
      slider.centerYAnchor.constraint(equalTo: centerYAnchor),
      valueLabel.leadingAnchor.constraint(equalTo: slider.trailingAnchor, constant: 8),
      valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
      valueLabel.centerYAnchor.constraint(equalTo: slider.centerYAnchor),
      valueLabel.widthAnchor.constraint(equalToConstant: 54),
    ])
    updateValue()
  }

  required init?(coder: NSCoder) { nil }

  @objc private func changed(_ sender: NSSlider) {
    updateValue()
    onChange?(CGFloat(sender.doubleValue))
  }

  private func updateValue() {
    valueLabel.stringValue = formatter(slider.doubleValue)
  }
}

final class SimpleSettingRow: NSView {
  private let titleLabel = NSTextField(labelWithString: "")
  let contentView = NSView()

  init(title: String, control: NSView, width: CGFloat = 370, titleWidth: CGFloat = 112, height: CGFloat = 34) {
    super.init(frame: .zero)
    titleLabel.stringValue = title
    titleLabel.font = .systemFont(ofSize: 12)
    titleLabel.textColor = .labelColor
    titleLabel.lineBreakMode = .byTruncatingTail
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    control.translatesAutoresizingMaskIntoConstraints = false
    addSubview(titleLabel)
    addSubview(control)
    NSLayoutConstraint.activate([
      heightAnchor.constraint(equalToConstant: height),
      widthAnchor.constraint(equalToConstant: width),
      titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
      titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
      titleLabel.widthAnchor.constraint(equalToConstant: titleWidth),
      control.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 10),
      control.trailingAnchor.constraint(equalTo: trailingAnchor),
      control.centerYAnchor.constraint(equalTo: centerYAnchor),
    ])
  }

  required init?(coder: NSCoder) { nil }
}

final class SettingsGroupView: NSView {
  private let card = NSView()
  private let cardBackground = NSBox()
  let stack = NSStackView()

  init(title: String, rows: [NSView], spacing: CGFloat = 4) {
    super.init(frame: .zero)

    let header = NSTextField(labelWithString: title)
    header.font = .systemFont(ofSize: 11.5, weight: .semibold)
    header.textColor = .secondaryLabelColor
    header.translatesAutoresizingMaskIntoConstraints = false
    header.setContentHuggingPriority(.required, for: .vertical)
    header.setContentCompressionResistancePriority(.required, for: .vertical)

    card.translatesAutoresizingMaskIntoConstraints = false
    card.setContentHuggingPriority(.required, for: .vertical)
    card.setContentCompressionResistancePriority(.required, for: .vertical)

    cardBackground.boxType = .custom
    cardBackground.cornerRadius = 10
    cardBackground.borderWidth = 0.75
    cardBackground.borderColor = NSColor.separatorColor.withAlphaComponent(0.45)
    cardBackground.fillColor = NSColor.controlBackgroundColor.withAlphaComponent(0.65)
    cardBackground.translatesAutoresizingMaskIntoConstraints = false

    stack.orientation = .vertical
    stack.alignment = .leading
    stack.spacing = spacing
    stack.translatesAutoresizingMaskIntoConstraints = false
    for row in rows {
      stack.addArrangedSubview(row)
    }

    card.addSubview(cardBackground)
    card.addSubview(stack)
    NSLayoutConstraint.activate([
      cardBackground.topAnchor.constraint(equalTo: card.topAnchor),
      cardBackground.bottomAnchor.constraint(equalTo: card.bottomAnchor),
      cardBackground.leadingAnchor.constraint(equalTo: card.leadingAnchor),
      cardBackground.trailingAnchor.constraint(equalTo: card.trailingAnchor),

      stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 10),
      stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -10),
      stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
      stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
    ])

    addSubview(header)
    addSubview(card)
    NSLayoutConstraint.activate([
      header.topAnchor.constraint(equalTo: topAnchor),
      header.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
      card.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 6),
      card.leadingAnchor.constraint(equalTo: leadingAnchor),
      card.trailingAnchor.constraint(equalTo: trailingAnchor),
      card.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])
  }

  required init?(coder: NSCoder) { nil }
}

final class LayoutPreviewView: NSView {
  var layout = WidgetLayout() { didSet { needsDisplay = true } }
  override var isOpaque: Bool { false }

  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    let layout = layout.normalized()
    let systemIsDark =
      (NSApp?.effectiveAppearance ?? effectiveAppearance)
      .bestMatch(from: [.darkAqua, .aqua]) == .darkAqua

    let stageRect = bounds.insetBy(dx: 8, dy: 2)
    let stagePath = NSBezierPath(roundedRect: stageRect, xRadius: 12, yRadius: 12)
    let stageColors =
      systemIsDark
      ? [
        NSColor(srgbRed: 0.24, green: 0.22, blue: 0.29, alpha: 1.0),
        NSColor(srgbRed: 0.42, green: 0.29, blue: 0.21, alpha: 1.0),
      ]
      : [
        NSColor(srgbRed: 0.44, green: 0.39, blue: 0.48, alpha: 1.0),
        NSColor(srgbRed: 0.70, green: 0.50, blue: 0.35, alpha: 1.0),
      ]
    if let stageGradient = NSGradient(colors: stageColors) {
      stageGradient.draw(in: stagePath, angle: -24)
    }

    let available = bounds.insetBy(dx: 16, dy: 10)
    let scale = min(available.width / layout.width, available.height / layout.height, 1.25)
    let cardSize = NSSize(width: layout.width * scale, height: layout.height * scale)
    let card = NSRect(
      x: bounds.midX - cardSize.width / 2,
      y: bounds.midY - cardSize.height / 2,
      width: cardSize.width,
      height: cardSize.height
    )

    let hasBackground = layout.opacity > 0.001
    let nativeGreen = NSColor(srgbRed: 0.20, green: 0.84, blue: 0.36, alpha: 1.0)
    let tokenBlue = NSColor(srgbRed: 0.35, green: 0.67, blue: 0.96, alpha: 1.0)

    let cardFill: NSColor
    let rimColor: NSColor
    let accent: NSColor
    let iconTint: NSColor
    let iconBadgeFill: NSColor
    let primaryText: NSColor
    let secondaryText: NSColor
    let pillFill: NSColor
    let barTrackColor: NSColor

    switch layout.desktopActiveStyle {
    case 1:
      let slateAlpha: CGFloat
      if !hasBackground {
        slateAlpha = 0.0
      } else if systemIsDark {
        slateAlpha = max(0.42, min(0.97, 0.42 + layout.opacity * 0.54))
      } else {
        slateAlpha = max(0.15, min(0.96, 0.25 + layout.opacity * 0.72))
      }
      cardFill = NSColor(
        srgbRed: 36.0 / 255.0, green: 42.0 / 255.0, blue: 49.0 / 255.0, alpha: slateAlpha)
      rimColor = NSColor.white.withAlphaComponent(hasBackground ? 0.22 : 0.12)
      accent = tokenBlue
      iconTint = tokenBlue
      iconBadgeFill = tokenBlue.withAlphaComponent(0.18)
      primaryText = NSColor.white.withAlphaComponent(0.98)
      secondaryText = NSColor(srgbRed: 0.68, green: 0.74, blue: 0.82, alpha: 0.92)
      pillFill = NSColor.white.withAlphaComponent(0.10)
      barTrackColor = tokenBlue.withAlphaComponent(0.20)
    case 2:
      let glassAlpha: CGFloat
      if !hasBackground {
        glassAlpha = 0.0
      } else if systemIsDark {
        glassAlpha = min(0.84, 0.24 + layout.opacity * 0.60)
      } else {
        glassAlpha = min(0.88, 0.08 + layout.opacity * 0.80)
      }
      cardFill = NSColor(srgbRed: 0.04, green: 0.045, blue: 0.065, alpha: glassAlpha)
      rimColor = NSColor.white.withAlphaComponent(hasBackground ? (systemIsDark ? 0.20 : 0.32) : 0.14)
      accent = layout.accentColor
      iconTint = layout.accentColor.withAlphaComponent(0.95)
      iconBadgeFill = NSColor.white.withAlphaComponent(0.14)
      primaryText = NSColor.white.withAlphaComponent(0.96)
      secondaryText = NSColor.white.withAlphaComponent(0.74)
      pillFill = NSColor.white.withAlphaComponent(0.14)
      barTrackColor = NSColor.white.withAlphaComponent(0.16)
    default:
      let frostedAlpha: CGFloat
      if !hasBackground {
        frostedAlpha = 0.0
      } else if systemIsDark {
        frostedAlpha = min(0.92, 0.42 + layout.opacity * 0.48)
      } else {
        frostedAlpha = min(0.90, 0.08 + layout.opacity * 0.82)
      }
      cardFill =
        systemIsDark
        ? NSColor(srgbRed: 0.045, green: 0.05, blue: 0.07, alpha: frostedAlpha)
        : NSColor(srgbRed: 0.14, green: 0.13, blue: 0.16, alpha: frostedAlpha)
      rimColor = NSColor.white.withAlphaComponent(hasBackground ? (systemIsDark ? 0.22 : 0.36) : 0.14)
      accent = nativeGreen
      iconTint = NSColor.white.withAlphaComponent(0.96)
      iconBadgeFill = NSColor.white.withAlphaComponent(0.16)
      primaryText = NSColor.white.withAlphaComponent(0.98)
      secondaryText = NSColor.white.withAlphaComponent(0.76)
      pillFill = NSColor.white.withAlphaComponent(0.15)
      barTrackColor = NSColor.white.withAlphaComponent(0.18)
    }

    let path = NSBezierPath(
      roundedRect: card,
      xRadius: layout.cornerRadius * scale,
      yRadius: layout.cornerRadius * scale
    )
    cardFill.setFill()
    path.fill()
    rimColor.setStroke()
    path.lineWidth = 1
    path.stroke()

    func sx(_ value: CGFloat) -> CGFloat { value * scale }

    let centerY = card.midY - sx(layout.iconY)
    let badgeSize = sx(layout.iconSize + 14)
    let badgeRect = NSRect(
      x: card.minX + sx(layout.iconX) - sx(7),
      y: centerY - badgeSize / 2,
      width: badgeSize,
      height: badgeSize
    )
    iconBadgeFill.setFill()
    NSBezierPath(roundedRect: badgeRect, xRadius: sx(10), yRadius: sx(10)).fill()

    let iconRect = NSRect(
      x: card.minX + sx(layout.iconX),
      y: centerY - sx(layout.iconSize) / 2,
      width: sx(layout.iconSize),
      height: sx(layout.iconSize)
    )
    if let driveImg = NSImage(systemSymbolName: "externaldrive.fill", accessibilityDescription: nil) {
      let tinted = driveImg.copy() as? NSImage ?? driveImg
      tinted.lockFocus()
      iconTint.set()
      NSRect(origin: .zero, size: tinted.size).fill(using: .sourceAtop)
      tinted.unlockFocus()
      tinted.draw(in: iconRect)
    } else {
      iconTint.setFill()
      NSBezierPath(roundedRect: iconRect, xRadius: sx(5), yRadius: sx(5)).fill()
    }

    let name = "外置硬盘" as NSString
    let nameAttrs: [NSAttributedString.Key: Any] = [
      .font: NSFont.systemFont(ofSize: max(8, sx(layout.nameFontSize)), weight: .semibold),
      .foregroundColor: primaryText,
    ]
    let nameSize = name.size(withAttributes: nameAttrs)
    let nameOrigin = NSPoint(
      x: card.minX + sx(layout.nameX),
      y: card.midY - sx(layout.nameY) - nameSize.height / 2
    )
    name.draw(at: nameOrigin, withAttributes: nameAttrs)

    let badgeText = "APFS" as NSString
    let badgeAttrs: [NSAttributedString.Key: Any] = [
      .font: NSFont.systemFont(ofSize: max(6.5, sx(8.5)), weight: .semibold),
      .foregroundColor: layout.desktopActiveStyle == 1 ? accent : secondaryText,
    ]
    let badgeTextSize = badgeText.size(withAttributes: badgeAttrs)
    let formatPillRect = NSRect(
      x: nameOrigin.x + nameSize.width + sx(5),
      y: card.midY - sx(layout.nameY) - (badgeTextSize.height + sx(3)) / 2,
      width: badgeTextSize.width + sx(10),
      height: badgeTextSize.height + sx(3)
    )
    let ringRect = NSRect(
      x: card.maxX - sx(layout.ringX + layout.ringSize),
      y: card.midY - sx(layout.ringY) - sx(layout.ringSize) / 2,
      width: sx(layout.ringSize),
      height: sx(layout.ringSize)
    )
    let ejectCenterY = card.midY - sx(layout.ejectY)
    let ejectRect = NSRect(
      x: card.maxX - sx(layout.ejectX + layout.ejectSize),
      y: ejectCenterY - sx(layout.ejectSize) / 2,
      width: sx(layout.ejectSize),
      height: sx(layout.ejectSize)
    )
    if formatPillRect.maxX < ejectRect.minX - sx(8) {
      (layout.desktopActiveStyle == 1 ? iconBadgeFill : pillFill).setFill()
      NSBezierPath(roundedRect: formatPillRect, xRadius: sx(6), yRadius: sx(6)).fill()
      badgeText.draw(
        at: NSPoint(x: formatPillRect.minX + sx(5), y: formatPillRect.minY + sx(1.5)),
        withAttributes: badgeAttrs
      )
    }

    pillFill.setFill()
    NSBezierPath(ovalIn: ejectRect).fill()
    if let ejectImg = NSImage(systemSymbolName: "eject.fill", accessibilityDescription: nil) {
      let tintedEject = ejectImg.copy() as? NSImage ?? ejectImg
      tintedEject.lockFocus()
      primaryText.set()
      NSRect(origin: .zero, size: tintedEject.size).fill(using: .sourceAtop)
      tintedEject.unlockFocus()
      let iconSize = sx(max(8, layout.ejectSize * 0.44))
      let symbolRect = NSRect(
        x: ejectRect.midX - iconSize / 2,
        y: ejectRect.midY - iconSize / 2,
        width: iconSize,
        height: iconSize
      )
      tintedEject.draw(in: symbolRect)
    }

    let ringTrack = NSBezierPath(ovalIn: ringRect)
    ringTrack.lineWidth = max(2, sx(4.2))
    NSColor.white.withAlphaComponent(0.18).setStroke()
    ringTrack.stroke()

    let ringArc = NSBezierPath()
    ringArc.lineWidth = max(2, sx(4.2))
    ringArc.lineCapStyle = .round
    let ringCenter = NSPoint(x: ringRect.midX, y: ringRect.midY)
    let ringRadius = ringRect.width / 2
    let ringRatio: CGFloat = layout.ringShowsAvailablePercentage ? 0.32 : 0.68
    ringArc.appendArc(
      withCenter: ringCenter,
      radius: ringRadius,
      startAngle: 90,
      endAngle: 90 - 360 * ringRatio,
      clockwise: true
    )
    accent.setStroke()
    ringArc.stroke()

    let percent = (layout.ringShowsAvailablePercentage ? "剩32%" : "68%") as NSString
    let percentAttrs: [NSAttributedString.Key: Any] = [
      .font: NSFont.monospacedDigitSystemFont(
        ofSize: max(7, sx(layout.ringTextFontSize)), weight: .semibold),
      .foregroundColor: primaryText,
    ]
    let percentSize = percent.size(withAttributes: percentAttrs)
    percent.draw(
      at: NSPoint(
        x: ringRect.midX - percentSize.width / 2, y: ringRect.midY - percentSize.height / 2),
      withAttributes: percentAttrs
    )

    let status = "120GB可用 · 共1TB" as NSString
    let statusAttrs: [NSAttributedString.Key: Any] = [
      .font: NSFont.systemFont(ofSize: max(7, sx(layout.statusFontSize)), weight: .medium),
      .foregroundColor: secondaryText,
    ]
    let statusSize = status.size(withAttributes: statusAttrs)
    let statusOrigin = NSPoint(x: card.minX + sx(layout.statusX), y: card.minY + sx(layout.statusBottom))
    status.draw(at: statusOrigin, withAttributes: statusAttrs)

    if layout.height >= 74 {
      let barTop = nameOrigin.y
      let barBottom = statusOrigin.y + statusSize.height
      let maxBarWidth = max(16, ejectRect.minX - sx(10) - (card.minX + sx(layout.nameX)))
      let barWidth = min(max(sx(64), statusSize.width), maxBarWidth)
      let barHeight = max(2.5, sx(4.5))
      let barRect = NSRect(
        x: card.minX + sx(layout.nameX),
        y: (barTop + barBottom) / 2 - barHeight / 2,
        width: barWidth,
        height: barHeight
      )
      barTrackColor.setFill()
      NSBezierPath(roundedRect: barRect, xRadius: barHeight / 2, yRadius: barHeight / 2).fill()
      let fillRect = NSRect(
        x: barRect.minX,
        y: barRect.minY,
        width: barRect.width * ringRatio,
        height: barRect.height
      )
      accent.setFill()
      NSBezierPath(roundedRect: fillRect, xRadius: barHeight / 2, yRadius: barHeight / 2).fill()
    }
  }
}

final class FlippedStackView: NSStackView {
  override var isFlipped: Bool { true }
}

/// Second-level editor for users who want pixel/point-level placement control.
/// The primary settings window intentionally exposes only common personalization.
final class AdvancedLayoutWindowController: NSWindowController {
  private var layout: WidgetLayout
  private let onChange: (WidgetLayout) -> Void
  private let preview = LayoutPreviewView()
  var onDismiss: (() -> Void)?

  init(layout: WidgetLayout, onChange: @escaping (WidgetLayout) -> Void) {
    self.layout = layout.normalized()
    self.onChange = onChange
    let window = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 454, height: 650),
      styleMask: [.titled],
      backing: .buffered,
      defer: false
    )
    window.title = "高级设置"
    window.collectionBehavior = [.moveToActiveSpace, .fullScreenAuxiliary]
    window.isReleasedWhenClosed = false
    super.init(window: window)
    buildInterface()
  }

  required init?(coder: NSCoder) { nil }

  private func buildInterface() {
    guard let content = window?.contentView else { return }
    content.subviews.forEach { $0.removeFromSuperview() }

    let title = NSTextField(labelWithString: "精细布局")
    title.font = .systemFont(ofSize: 17, weight: .semibold)

    let hint = NSTextField(labelWithString: "调整图标、文字、容量环与操作按钮的位置和大小。修改会同步到所有磁盘卡片。")
    hint.font = .systemFont(ofSize: 11)
    hint.textColor = .secondaryLabelColor
    hint.lineBreakMode = .byWordWrapping

    preview.layout = layout
    preview.translatesAutoresizingMaskIntoConstraints = false

    let stack = FlippedStackView()
    stack.orientation = .vertical
    stack.alignment = .leading
    stack.spacing = 3
    stack.translatesAutoresizingMaskIntoConstraints = true

    typealias AdvancedRow = (
      section: String,
      title: String,
      min: CGFloat,
      max: CGFloat,
      value: CGFloat,
      formatter: (Double) -> String,
      apply: (inout WidgetLayout, CGFloat) -> Void
    )

    let rows: [AdvancedRow] = [
      ("图标", "左侧位置", 0, 344, layout.iconX, { "\(Int($0)) pt" }, { $0.iconX = $1 }),
      ("图标", "纵向偏移", -60, 60, layout.iconY, { "\(Int($0)) pt" }, { $0.iconY = $1 }),
      ("图标", "大小", 16, 48, layout.iconSize, { "\(Int($0)) pt" }, { $0.iconSize = $1 }),

      ("名称", "左侧位置", 0, 336, layout.nameX, { "\(Int($0)) pt" }, { $0.nameX = $1 }),
      ("名称", "纵向偏移", -60, 60, layout.nameY, { "\(Int($0)) pt" }, { $0.nameY = $1 }),

      ("容量信息", "左侧位置", 0, 336, layout.statusX, { "\(Int($0)) pt" }, { $0.statusX = $1 }),
      ("容量信息", "底部间距", 2, 110, layout.statusBottom, { "\(Int($0)) pt" }, { $0.statusBottom = $1 }),

      ("容量圆环", "右侧间距", 0, 326, layout.ringX, { "\(Int($0)) pt" }, { $0.ringX = $1 }),
      ("容量圆环", "纵向偏移", -60, 60, layout.ringY, { "\(Int($0)) pt" }, { $0.ringY = $1 }),
      ("容量圆环", "大小", 34, 60, layout.ringSize, { "\(Int($0)) pt" }, { $0.ringSize = $1 }),

      ("操作按钮", "右侧间距", 0, 344, layout.ejectX, { "\(Int($0)) pt" }, { $0.ejectX = $1 }),
      ("操作按钮", "纵向偏移", -60, 60, layout.ejectY, { "\(Int($0)) pt" }, { $0.ejectY = $1 }),
      ("操作按钮", "大小", 16, 36, layout.ejectSize, { "\(Int($0)) pt" }, { $0.ejectSize = $1 }),
    ]

    var currentSection = ""
    for row in rows {
      if row.section != currentSection {
        currentSection = row.section
        let sectionLabel = NSTextField(labelWithString: row.section)
        sectionLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        sectionLabel.textColor = .secondaryLabelColor
        sectionLabel.translatesAutoresizingMaskIntoConstraints = false
        sectionLabel.heightAnchor.constraint(equalToConstant: 27).isActive = true
        stack.addArrangedSubview(sectionLabel)
        if stack.arrangedSubviews.count > 1 { stack.setCustomSpacing(7, after: sectionLabel) }
      }

      let control = LayoutSliderView(
        title: row.title,
        value: row.value,
        min: row.min,
        max: row.max,
        formatter: row.formatter
      )
      control.onChange = { [weak self] value in
        guard let self else { return }
        row.apply(&self.layout, value)
        self.commitLayout()
      }
      stack.addArrangedSubview(control)
    }

    let scroll = NSScrollView()
    scroll.hasVerticalScroller = true
    scroll.autohidesScrollers = true
    scroll.drawsBackground = false
    scroll.borderType = .noBorder
    scroll.translatesAutoresizingMaskIntoConstraints = false
    scroll.documentView = stack

    let reset = NSButton(title: "恢复布局默认", target: self, action: #selector(resetAdvancedLayout))
    reset.bezelStyle = .rounded
    let done = NSButton(title: "完成", target: self, action: #selector(closeEditor))
    done.bezelStyle = .rounded
    done.keyEquivalent = "\r"

    [title, hint, preview, scroll, reset, done].forEach {
      $0.translatesAutoresizingMaskIntoConstraints = false
      content.addSubview($0)
    }

    NSLayoutConstraint.activate([
      title.topAnchor.constraint(equalTo: content.topAnchor, constant: 18),
      title.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 24),
      hint.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 4),
      hint.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 24),
      hint.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -24),

      preview.topAnchor.constraint(equalTo: hint.bottomAnchor, constant: 8),
      preview.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 20),
      preview.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -20),
      preview.heightAnchor.constraint(equalToConstant: 96),

      scroll.topAnchor.constraint(equalTo: preview.bottomAnchor, constant: 6),
      scroll.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 24),
      scroll.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -24),
      scroll.bottomAnchor.constraint(equalTo: done.topAnchor, constant: -12),

      reset.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 24),
      reset.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -16),
      done.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -24),
      done.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -16),
    ])

    content.layoutSubtreeIfNeeded()
    let width = max(370, scroll.contentSize.width - 16)
    stack.frame = NSRect(
      x: 6, y: 0, width: width, height: max(stack.fittingSize.height, scroll.contentSize.height))
  }

  private func commitLayout() {
    layout.normalize()
    layout.save()
    preview.layout = layout
    onChange(layout)
  }

  @objc private func resetAdvancedLayout() {
    let defaults = WidgetLayout.factoryDefaults
    layout.iconX = defaults.iconX
    layout.iconY = defaults.iconY
    layout.iconSize = defaults.iconSize
    layout.nameX = defaults.nameX
    layout.nameY = defaults.nameY
    layout.statusX = defaults.statusX
    layout.statusBottom = defaults.statusBottom
    layout.ringX = defaults.ringX
    layout.ringY = defaults.ringY
    layout.ringSize = defaults.ringSize
    layout.ejectX = defaults.ejectX
    layout.ejectY = defaults.ejectY
    layout.ejectSize = defaults.ejectSize
    commitLayout()
    buildInterface()
  }

  @objc private func closeEditor() {
    guard let window else { return }
    if let parent = window.sheetParent {
      parent.endSheet(window)
    } else {
      window.orderOut(nil)
    }
    onDismiss?()
  }

  func present(asSheetFor parent: NSWindow) {
    guard let window else { return }
    parent.beginSheet(window)
  }
}

final class LayoutEditorWindowController: NSWindowController, NSWindowDelegate {
  private var layout: WidgetLayout
  private let onChange: (WidgetLayout) -> Void
  private var cardPanels: [DiskPanel]
  var onVisibilityChanged: ((Bool) -> Void)?
  private let preview = LayoutPreviewView()
  private var advancedEditor: AdvancedLayoutWindowController?
  private weak var accentPresetControl: NSPopUpButton?
  private weak var customAccentWell: NSColorWell?
  private weak var tabView: NSTabView?
  private weak var tabControl: NSSegmentedControl?
  private var selectedTabIndex = 0
  private var previousRegularAppBeforeOpen: NSRunningApplication?
  private var openedFromOrdinaryDesktopSpace = false

  init(
    layout: WidgetLayout,
    cardPanels: [DiskPanel] = [],
    onChange: @escaping (WidgetLayout) -> Void
  ) {
    self.layout = layout.normalized()
    self.cardPanels = cardPanels.filter { !$0.isPreviewPlaceholder }
    self.onChange = onChange
    let window = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 464, height: 590),
      styleMask: [.titled, .closable],
      backing: .buffered,
      defer: false
    )
    window.title = "DiskWidget 设置"
    window.collectionBehavior = [.moveToActiveSpace, .fullScreenAuxiliary]
    window.isReleasedWhenClosed = false
    super.init(window: window)
    window.delegate = self
    buildInterface()
  }

  required init?(coder: NSCoder) { nil }

  func syncLayout(_ newLayout: WidgetLayout) {
    layout = newLayout.normalized()
    preview.layout = layout
  }

  func refreshPreviewForSystemAppearance() {
    preview.needsDisplay = true
  }

  func updateCardPanels(_ newPanels: [DiskPanel]) {
    let filtered = newPanels.filter { !$0.isPreviewPlaceholder }
    let currentIDs = cardPanels.map(ObjectIdentifier.init)
    let newIDs = filtered.map(ObjectIdentifier.init)
    guard currentIDs != newIDs || cardPanels.isEmpty != filtered.isEmpty else { return }
    cardPanels = filtered
    if window?.isVisible != true {
      buildInterface()
    }
  }

  func windowWillClose(_ notification: Notification) {
    onVisibilityChanged?(false)
    let restoreApp = previousRegularAppBeforeOpen
    let stayOnDesktop = openedFromOrdinaryDesktopSpace
    previousRegularAppBeforeOpen = nil
    openedFromOrdinaryDesktopSpace = false

    // When Settings was opened on a Desktop Space while the user's previous app
    // lives in another Fullscreen Space, closing this LSUIElement window would
    // otherwise make AppKit reactivate that app and jump to its Fullscreen Space.
    if stayOnDesktop,
      !Self.isScreenShowingFullscreenSpace(window?.screen),
      let restoreApp,
      restoreApp.bundleIdentifier != "com.apple.finder",
      !Self.applicationHasVisibleWindowOnActiveSpace(pid: restoreApp.processIdentifier)
    {
      DispatchQueue.main.async {
        NSWorkspace.shared.runningApplications
          .first { $0.bundleIdentifier == "com.apple.finder" }?
          .activate(options: [])
      }
    }
  }

  private func buildInterface() {
    guard let content = window?.contentView else { return }
    content.subviews.forEach { $0.removeFromSuperview() }

    let rowWidth: CGFloat = 388

    let title = NSTextField(labelWithString: "个性化设置")
    title.font = .systemFont(ofSize: 16, weight: .semibold)
    let hint = NSTextField(labelWithString: "所有磁盘共用一套外观与系统配置")
    hint.font = .systemFont(ofSize: 11)
    hint.textColor = .secondaryLabelColor

    let tabs = NSSegmentedControl(
      labels: ["外观风格", "尺寸与行为", "小组件与系统"],
      trackingMode: .selectOne,
      target: self,
      action: #selector(tabChanged(_:))
    )
    tabs.selectedSegment = selectedTabIndex
    tabs.segmentStyle = .texturedRounded
    tabControl = tabs

    let tabContainer = NSTabView()
    tabContainer.tabViewType = .noTabsNoBorder
    tabContainer.drawsBackground = false
    tabContainer.translatesAutoresizingMaskIntoConstraints = false
    tabView = tabContainer

    // MARK: Tab 0 - 外观风格
    preview.layout = layout
    preview.translatesAutoresizingMaskIntoConstraints = false
    preview.heightAnchor.constraint(equalToConstant: 92).isActive = true

    let presetControl = NSPopUpButton(frame: .zero, pullsDown: false)
    presetControl.target = self
    presetControl.action = #selector(accentPresetChanged(_:))
    presetControl.toolTip = "选择一套经典配色；自定义可使用右侧色块"
    for preset in accentPresets {
      presetControl.addItem(withTitle: preset.name)
      presetControl.lastItem?.image = colorSwatchImage(preset.color)
    }
    presetControl.addItem(withTitle: "自定义")
    presetControl.lastItem?.image = NSImage(
      systemSymbolName: "paintpalette", accessibilityDescription: nil)
    let selectedPreset = selectedAccentPresetIndex()
    presetControl.selectItem(at: selectedPreset >= 0 ? selectedPreset : accentPresets.count)
    presetControl.translatesAutoresizingMaskIntoConstraints = false
    presetControl.widthAnchor.constraint(equalToConstant: 158).isActive = true
    accentPresetControl = presetControl

    let colorWell = NSColorWell()
    colorWell.color = layout.accentColor
    colorWell.target = self
    colorWell.action = #selector(accentChanged(_:))
    colorWell.toolTip = "自定义主题色"
    colorWell.translatesAutoresizingMaskIntoConstraints = false
    colorWell.widthAnchor.constraint(equalToConstant: 38).isActive = true
    customAccentWell = colorWell

    let colorControls = NSStackView(views: [presetControl, colorWell])
    colorControls.orientation = .horizontal
    colorControls.alignment = .centerY
    colorControls.spacing = 8

    let ringMetricControl = NSSegmentedControl(
      labels: ["已用比例", "剩余比例"],
      trackingMode: .selectOne,
      target: self,
      action: #selector(ringMetricChanged(_:))
    )
    ringMetricControl.selectedSegment = layout.ringShowsAvailablePercentage ? 1 : 0
    ringMetricControl.toolTip = "也可直接单击桌面卡片右侧的容量圆环快速切换。"

    let desktopStyleControl = NSSegmentedControl(
      labels: ["原生毛玻璃", "深色面板", "通透玻璃"],
      trackingMode: .selectOne,
      target: self,
      action: #selector(desktopActiveStyleChanged(_:))
    )
    desktopStyleControl.selectedSegment = min(max(layout.desktopActiveStyle, 0), 2)
    desktopStyleControl.toolTip = "单击桌面时所有硬盘卡片统一的视觉效果：原生毛玻璃（翡翠绿点缀）、深色面板（深青灰实色底）或通透玻璃（高透玻璃+主题色）。"

    let styleGroup = SettingsGroupView(
      title: "配色与材质",
      rows: [
        SimpleSettingRow(title: "主题色", control: colorControls, width: rowWidth, height: 30),
        SimpleSettingRow(title: "单击桌面效果", control: desktopStyleControl, width: rowWidth, height: 30),
        SimpleSettingRow(title: "圆环数值", control: ringMetricControl, width: rowWidth, height: 30),
        makeSliderRow("玻璃背景", 0, 1, layout.opacity, width: rowWidth, formatter: { "\(Int($0 * 100))%" }) {
          $0.opacity = $1
        },
        makeSliderRow("卡片圆角", 8, 28, layout.cornerRadius, width: rowWidth, formatter: { "\(Int($0)) pt" }) {
          $0.cornerRadius = $1
        },
      ]
    )

    let fontGroup = SettingsGroupView(
      title: "文字与数字字号",
      rows: [
        makeSliderRow("名称字号", 10, 18, layout.nameFontSize, width: rowWidth, formatter: { "\(Int($0)) pt" }) {
          $0.nameFontSize = $1
        },
        makeSliderRow("容量字号", 8, 13, layout.statusFontSize, width: rowWidth, formatter: { "\(Int($0)) pt" }) {
          $0.statusFontSize = $1
        },
        makeSliderRow("圆环数字", 7, 16, layout.ringTextFontSize, width: rowWidth, formatter: { "\(Int($0)) pt" }) {
          $0.ringTextFontSize = $1
        },
      ]
    )

    let appearancePage = makeTabPage(views: [preview, styleGroup, fontGroup], spacing: 10)

    // MARK: Tab 1 - 尺寸与行为
    let advancedButton = NSButton(
      title: "高级布局微调…", target: self, action: #selector(openAdvancedSettings))
    advancedButton.bezelStyle = .rounded
    advancedButton.image = NSImage(
      systemSymbolName: "slider.horizontal.3", accessibilityDescription: nil)
    advancedButton.imagePosition = .imageLeading
    advancedButton.toolTip = "精细调整图标、文字、容量环和操作按钮的位置与大小"

    let geometryGroup = SettingsGroupView(
      title: "卡片尺寸与排布",
      rows: [
        makeSliderRow("卡片宽度", 180, 360, layout.width, width: rowWidth, formatter: { "\(Int($0)) pt" }) {
          $0.width = $1
        },
        makeSliderRow("卡片高度", 64, 120, layout.height, width: rowWidth, formatter: { "\(Int($0)) pt" }) {
          $0.height = $1
        },
        makeSliderRow("卡片间距", 4, 40, layout.stackSpacing, width: rowWidth, formatter: { "\(Int($0)) pt" }) {
          $0.stackSpacing = $1
        },
        SimpleSettingRow(title: "元素坐标", control: advancedButton, width: rowWidth, height: 30),
      ]
    )

    let installerMode = NSSegmentedControl(
      labels: ["小组件", "Finder 桌面"],
      trackingMode: .selectOne,
      target: self,
      action: #selector(installerModeChanged(_:))
    )
    installerMode.selectedSegment = layout.showDiskImagesInWidget ? 0 : 1
    installerMode.toolTip = "DMG/ISO 等安装镜像。Finder 桌面模式不会修改 Finder 自身的桌面显示偏好。"

    let dimToggle = NSButton(
      checkboxWithTitle: "使用其他应用时自动柔和淡化",
      target: self,
      action: #selector(desktopDimmingChanged(_:))
    )
    dimToggle.state = layout.dimWhenDesktopInactive ? .on : .off
    dimToggle.toolTip = "类似 macOS 原生桌面小组件：专注使用其他窗口时柔和降噪，鼠标悬停或回到桌面时恢复鲜艳。"

    let behaviorGroup = SettingsGroupView(
      title: "显示与交互",
      rows: [
        SimpleSettingRow(title: "安装镜像", control: installerMode, width: rowWidth, height: 30),
        SimpleSettingRow(title: "桌面融合", control: dimToggle, width: rowWidth, height: 28),
      ]
    )

    let shortcutIcon = NSImageView()
    shortcutIcon.image = NSImage(
      systemSymbolName: "arrow.up.arrow.down", accessibilityDescription: nil)
    shortcutIcon.contentTintColor = .secondaryLabelColor
    shortcutIcon.symbolConfiguration = NSImage.SymbolConfiguration(pointSize: 11, weight: .medium)
    shortcutIcon.translatesAutoresizingMaskIntoConstraints = false
    shortcutIcon.widthAnchor.constraint(equalToConstant: 14).isActive = true
    shortcutIcon.heightAnchor.constraint(equalToConstant: 14).isActive = true

    let shortcutLabel = NSTextField(labelWithString: "提示：按住 ⌥ 拖动卡片调整顺序 · 单击圆环切换已用/剩余")
    shortcutLabel.font = .systemFont(ofSize: 11)
    shortcutLabel.textColor = .secondaryLabelColor

    let shortcutHint = NSStackView(views: [shortcutIcon, shortcutLabel])
    shortcutHint.orientation = .horizontal
    shortcutHint.alignment = .centerY
    shortcutHint.spacing = 6

    let layoutPage = makeTabPage(views: [geometryGroup, behaviorGroup, shortcutHint], spacing: 12)

    // MARK: Tab 2 - 小组件与系统
    let desktopCardsToggle = NSButton(
      checkboxWithTitle: "显示桌面悬浮卡（支持拖放文件）",
      target: self,
      action: #selector(desktopCardsVisibilityChanged(_:))
    )
    desktopCardsToggle.state = layout.showDesktopCards ? .on : .off
    desktopCardsToggle.toolTip = "仅使用 macOS 系统小组件时可关闭悬浮卡，避免桌面上出现两套卡片。"

    let reloadWidgetButton = NSButton(
      title: "立即同步系统小组件", target: self, action: #selector(reloadSystemWidgets))
    reloadWidgetButton.bezelStyle = .rounded
    reloadWidgetButton.image = NSImage(
      systemSymbolName: "square.grid.2x2", accessibilityDescription: nil)
    reloadWidgetButton.imagePosition = .imageLeading
    reloadWidgetButton.toolTip = "在桌面右键点击 →「编辑小组件」即可添加原生 DiskWidget 系统小组件（支持 macOS 14+）。"

    let widgetTip = NSTextField(wrappingLabelWithString: "桌面右键 →「编辑小组件」→ 搜索“磁盘小组件”即可添加原生桌面卡片")
    widgetTip.font = .systemFont(ofSize: 10.5)
    widgetTip.textColor = .secondaryLabelColor
    widgetTip.translatesAutoresizingMaskIntoConstraints = false
    widgetTip.preferredMaxLayoutWidth = rowWidth
    widgetTip.widthAnchor.constraint(equalToConstant: rowWidth).isActive = true
    widgetTip.setContentHuggingPriority(.required, for: .vertical)
    widgetTip.setContentCompressionResistancePriority(.required, for: .vertical)

    let widgetGroup = SettingsGroupView(
      title: "桌面组件模式",
      rows: [
        SimpleSettingRow(title: "悬浮卡片", control: desktopCardsToggle, width: rowWidth, height: 28),
        SimpleSettingRow(title: "系统小组件", control: reloadWidgetButton, width: rowWidth, height: 30),
        widgetTip,
      ],
      spacing: 6
    )

    let menuBarToggle = NSButton(
      checkboxWithTitle: "显示菜单栏图标",
      target: self,
      action: #selector(menuBarVisibilityChanged(_:))
    )
    menuBarToggle.state = layout.showMenuBarItem ? .on : .off
    menuBarToggle.toolTip = "关闭后仍可通过磁盘卡片右键进入设置；再次启动 DiskWidget 也可重新打开设置。"

    let launchAtLoginToggle = NSButton(
      checkboxWithTitle: "开机自动启动",
      target: self,
      action: #selector(launchAtLoginChanged(_:))
    )
    launchAtLoginToggle.state = (SMAppService.mainApp.status == .enabled) ? .on : .off
    launchAtLoginToggle.toolTip = "通过 macOS 原生登录项服务注册开机自启。"

    let systemOptions = NSStackView(views: [menuBarToggle, launchAtLoginToggle])
    systemOptions.orientation = .horizontal
    systemOptions.alignment = .centerY
    systemOptions.spacing = 14

    let systemGroup = SettingsGroupView(
      title: "系统集成",
      rows: [
        SimpleSettingRow(title: "常驻与启动", control: systemOptions, width: rowWidth, height: 28),
      ]
    )

    let iconGroup: SettingsGroupView
    if cardPanels.isEmpty {
      let emptyIcons = NSTextField(wrappingLabelWithString: "当前未连接外置磁盘，接入后可在此为每张盘指定专属图标。")
      emptyIcons.font = .systemFont(ofSize: 11)
      emptyIcons.textColor = .secondaryLabelColor
      emptyIcons.translatesAutoresizingMaskIntoConstraints = false
      emptyIcons.preferredMaxLayoutWidth = rowWidth
      emptyIcons.widthAnchor.constraint(equalToConstant: rowWidth).isActive = true
      emptyIcons.setContentHuggingPriority(.required, for: .vertical)
      emptyIcons.setContentCompressionResistancePriority(.required, for: .vertical)
      iconGroup = SettingsGroupView(title: "磁盘专属图标", rows: [emptyIcons])
    } else {
      let iconListStack = FlippedStackView()
      iconListStack.orientation = .vertical
      iconListStack.alignment = .leading
      iconListStack.spacing = 4
      iconListStack.translatesAutoresizingMaskIntoConstraints = false

      for (panelIndex, panel) in cardPanels.enumerated() {
        let iconControl = NSPopUpButton(frame: .zero, pullsDown: false)
        for choice in DiskPanel.iconChoices {
          iconControl.addItem(withTitle: choice.title)
          if let symbol = choice.symbol {
            iconControl.lastItem?.image = NSImage(
              systemSymbolName: symbol, accessibilityDescription: nil)
          }
        }
        iconControl.selectItem(at: panel.customIconChoiceIndex)
        iconControl.target = self
        iconControl.action = #selector(cardIconChanged(_:))
        iconControl.tag = panelIndex
        iconControl.translatesAutoresizingMaskIntoConstraints = false
        iconControl.widthAnchor.constraint(equalToConstant: 190).isActive = true
        iconListStack.addArrangedSubview(
          SimpleSettingRow(title: panel.effectiveTitleText, control: iconControl, width: rowWidth - 10, height: 28))
      }

      if cardPanels.count <= 4 {
        iconGroup = SettingsGroupView(title: "磁盘专属图标", rows: iconListStack.arrangedSubviews)
      } else {
        let iconScroll = NSScrollView()
        iconScroll.drawsBackground = false
        iconScroll.hasVerticalScroller = true
        iconScroll.borderType = .noBorder
        iconScroll.documentView = iconListStack
        iconScroll.translatesAutoresizingMaskIntoConstraints = false
        iconScroll.widthAnchor.constraint(equalToConstant: rowWidth).isActive = true
        iconScroll.heightAnchor.constraint(equalToConstant: 122).isActive = true
        iconGroup = SettingsGroupView(title: "磁盘专属图标（\(cardPanels.count)）", rows: [iconScroll])
      }
    }

    let systemPage = makeTabPage(views: [widgetGroup, systemGroup, iconGroup], spacing: 12)

    for (index, page) in [appearancePage, layoutPage, systemPage].enumerated() {
      let item = NSTabViewItem(identifier: index)
      item.view = page
      tabContainer.addTabViewItem(item)
    }
    tabContainer.selectTabViewItem(at: min(max(selectedTabIndex, 0), 2))

    let reset = NSButton(title: "恢复默认", target: self, action: #selector(resetLayout))
    reset.bezelStyle = .rounded
    let nativePresetButton = NSButton(
      title: "一键设为原生效果", target: self, action: #selector(applyNativePreset))
    nativePresetButton.bezelStyle = .rounded
    let done = NSButton(title: "完成", target: self, action: #selector(closeEditor))
    done.bezelStyle = .rounded
    done.keyEquivalent = "\r"

    [title, hint, tabs, tabContainer, reset, nativePresetButton, done].forEach {
      $0.translatesAutoresizingMaskIntoConstraints = false
      content.addSubview($0)
    }

    NSLayoutConstraint.activate([
      title.topAnchor.constraint(equalTo: content.topAnchor, constant: 16),
      title.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 24),
      hint.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 2),
      hint.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 24),

      tabs.topAnchor.constraint(equalTo: hint.bottomAnchor, constant: 12),
      tabs.centerXAnchor.constraint(equalTo: content.centerXAnchor),
      tabs.widthAnchor.constraint(equalToConstant: 416),

      tabContainer.topAnchor.constraint(equalTo: tabs.bottomAnchor, constant: 12),
      tabContainer.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 24),
      tabContainer.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -24),
      tabContainer.bottomAnchor.constraint(equalTo: reset.topAnchor, constant: -14),

      reset.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 24),
      reset.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -16),
      nativePresetButton.leadingAnchor.constraint(equalTo: reset.trailingAnchor, constant: 8),
      nativePresetButton.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -16),
      done.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -24),
      done.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -16),
    ])
  }

  private func makeSliderRow(
    _ title: String,
    _ min: CGFloat,
    _ max: CGFloat,
    _ value: CGFloat,
    width: CGFloat,
    formatter: @escaping (Double) -> String,
    apply: @escaping (inout WidgetLayout, CGFloat) -> Void
  ) -> LayoutSliderView {
    let control = LayoutSliderView(
      title: title,
      value: value,
      min: min,
      max: max,
      width: width,
      height: 28,
      formatter: formatter
    )
    control.onChange = { [weak self] newValue in
      guard let self else { return }
      apply(&self.layout, newValue)
      self.commitLayout()
    }
    return control
  }

  private func makeTabPage(views: [NSView], spacing: CGFloat) -> NSView {
    let container = NSView()
    let stack = NSStackView(views: views)
    stack.orientation = .vertical
    stack.alignment = .leading
    stack.spacing = spacing
    stack.translatesAutoresizingMaskIntoConstraints = false
    container.addSubview(stack)
    NSLayoutConstraint.activate([
      stack.topAnchor.constraint(equalTo: container.topAnchor),
      stack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
      stack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
      stack.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor),
    ])
    for view in views {
      view.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true
    }
    return container
  }

  @objc private func tabChanged(_ sender: NSSegmentedControl) {
    selectedTabIndex = sender.selectedSegment
    tabView?.selectTabViewItem(at: selectedTabIndex)
    tabView?.selectedTabViewItem?.view?.layoutSubtreeIfNeeded()
  }

  private struct AccentPreset {
    let name: String
    let color: NSColor
  }

  /// Restrained, familiar colors chosen to stay readable on macOS materials
  /// instead of using a bright system-color rainbow.
  private var accentPresets: [AccentPreset] {
    [
      AccentPreset(name: "液态玻璃白", color: Self.rgb(0xFFFFFF)),
      AccentPreset(name: "Apple 蓝", color: Self.rgb(0x0A84FF)),
      AccentPreset(name: "石墨灰", color: Self.rgb(0x5E5E63)),
      AccentPreset(name: "海军蓝", color: Self.rgb(0x1F3A5F)),
      AccentPreset(name: "英伦绿", color: Self.rgb(0x1B4D3E)),
      AccentPreset(name: "勃艮第红", color: Self.rgb(0x722F37)),
      AccentPreset(name: "古典金", color: Self.rgb(0xB08D57)),
    ]
  }

  private static func rgb(_ hex: Int) -> NSColor {
    NSColor(
      srgbRed: CGFloat((hex >> 16) & 0xFF) / 255.0,
      green: CGFloat((hex >> 8) & 0xFF) / 255.0,
      blue: CGFloat(hex & 0xFF) / 255.0,
      alpha: 1
    )
  }

  private func colorSwatchImage(_ color: NSColor) -> NSImage {
    let image = NSImage(size: NSSize(width: 14, height: 14))
    image.lockFocus()
    let circle = NSBezierPath(ovalIn: NSRect(x: 1.5, y: 1.5, width: 11, height: 11))
    color.setFill()
    circle.fill()
    NSColor.separatorColor.withAlphaComponent(0.55).setStroke()
    circle.lineWidth = 0.7
    circle.stroke()
    image.unlockFocus()
    image.isTemplate = false
    return image
  }

  private func selectedAccentPresetIndex() -> Int {
    guard let current = layout.accentColor.usingColorSpace(.sRGB) else { return -1 }
    for (index, preset) in accentPresets.enumerated() {
      guard let candidate = preset.color.usingColorSpace(.sRGB) else { continue }
      let distance =
        abs(current.redComponent - candidate.redComponent)
        + abs(current.greenComponent - candidate.greenComponent)
        + abs(current.blueComponent - candidate.blueComponent)
      if distance < 0.035 { return index }
    }
    return -1
  }

  private func commitLayout() {
    layout.normalize()
    layout.save()
    preview.layout = layout
    onChange(layout)
  }

  @objc private func accentPresetChanged(_ sender: NSPopUpButton) {
    let index = sender.indexOfSelectedItem
    guard accentPresets.indices.contains(index) else { return }
    let color = accentPresets[index].color
    layout.setAccentColor(color)
    customAccentWell?.color = color
    commitLayout()
  }

  @objc private func accentChanged(_ sender: NSColorWell) {
    layout.setAccentColor(sender.color)
    let index = selectedAccentPresetIndex()
    accentPresetControl?.selectItem(at: index >= 0 ? index : accentPresets.count)
    commitLayout()
  }

  @objc private func ringMetricChanged(_ sender: NSSegmentedControl) {
    layout.ringShowsAvailablePercentage = (sender.selectedSegment == 1)
    commitLayout()
  }

  @objc private func desktopActiveStyleChanged(_ sender: NSSegmentedControl) {
    layout.desktopActiveStyle = min(max(sender.selectedSegment, 0), 2)
    commitLayout()
  }

  @objc private func cardIconChanged(_ sender: NSPopUpButton) {
    guard cardPanels.indices.contains(sender.tag) else { return }
    let panel = cardPanels[sender.tag]
    panel.setCustomIconChoice(index: sender.indexOfSelectedItem)
  }

  @objc private func desktopCardsVisibilityChanged(_ sender: NSButton) {
    layout.showDesktopCards = sender.state == .on
    commitLayout()
  }

  @objc private func desktopDimmingChanged(_ sender: NSButton) {
    layout.dimWhenDesktopInactive = sender.state == .on
    commitLayout()
  }

  @objc private func reloadSystemWidgets() {
    WidgetCenter.shared.reloadAllTimelines()
  }

  @objc private func menuBarVisibilityChanged(_ sender: NSButton) {
    layout.showMenuBarItem = sender.state == .on
    commitLayout()
  }

  @objc private func launchAtLoginChanged(_ sender: NSButton) {
    do {
      if sender.state == .on {
        try SMAppService.mainApp.register()
      } else {
        try SMAppService.mainApp.unregister()
      }
    } catch {
      sender.state = (SMAppService.mainApp.status == .enabled) ? .on : .off
      let alert = NSAlert()
      alert.messageText = "无法更新开机自启设置"
      alert.informativeText =
        "请确认已将 DiskWidget.app 放入“应用程序”文件夹后再开启开机自动启动（\(error.localizedDescription)）。"
      alert.alertStyle = .informational
      alert.addButton(withTitle: "好")
      alert.runModal()
    }
  }

  @objc private func installerModeChanged(_ sender: NSSegmentedControl) {
    layout.showDiskImagesInWidget = sender.selectedSegment == 0
    commitLayout()
  }

  @objc private func openAdvancedSettings() {
    guard let parent = window, advancedEditor == nil else { return }
    let editor = AdvancedLayoutWindowController(layout: layout) { [weak self] newLayout in
      guard let self else { return }
      self.layout = newLayout.normalized()
      self.layout.save()
      self.preview.layout = self.layout
      self.onChange(self.layout)
    }
    editor.onDismiss = { [weak self] in
      self?.advancedEditor = nil
    }
    advancedEditor = editor
    editor.present(asSheetFor: parent)
  }

  @objc private func closeEditor() {
    window?.performClose(nil)
  }

  @objc private func resetLayout() {
    layout = .factoryDefaults
    layout.save()
    onChange(layout)
    buildInterface()
  }

  @objc private func applyNativePreset() {
    layout = .nativeWidgetPreset
    layout.save()
    onChange(layout)
    buildInterface()
  }

  func present() {
    guard let window else { return }
    window.collectionBehavior = [.moveToActiveSpace, .fullScreenAuxiliary]
    let targetScreen =
      NSScreen.screens.first { NSMouseInRect(NSEvent.mouseLocation, $0.frame, false) }
      ?? NSScreen.main
      ?? NSScreen.screens.first

    if !window.isVisible {
      let frontApp = NSWorkspace.shared.frontmostApplication
      if frontApp?.bundleIdentifier != Bundle.main.bundleIdentifier {
        previousRegularAppBeforeOpen = frontApp
      }
      openedFromOrdinaryDesktopSpace = !Self.isScreenShowingFullscreenSpace(targetScreen)
      if let targetScreen {
        let visible = targetScreen.visibleFrame
        let origin = NSPoint(
          x: visible.midX - window.frame.width / 2,
          y: visible.midY - window.frame.height / 2
        )
        window.setFrameOrigin(origin)
      } else {
        window.center()
      }
    }

    window.makeKeyAndOrderFront(nil)
    showWindow(nil)
    NSApp.activate(ignoringOtherApps: true)
    onVisibilityChanged?(true)
  }

  private static func isScreenShowingFullscreenSpace(_ screen: NSScreen?) -> Bool {
    guard let screen,
      let primaryHeight = NSScreen.screens.first?.frame.height,
      primaryHeight > 0,
      let list = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID)
        as? [[String: Any]]
    else { return false }

    let displayRect = CGRect(
      x: screen.frame.minX,
      y: primaryHeight - screen.frame.maxY,
      width: screen.frame.width,
      height: screen.frame.height
    )
    for info in list {
      let owner = info[kCGWindowOwnerName as String] as? String ?? ""
      let layer = info[kCGWindowLayer as String] as? Int ?? 0
      guard owner == "WindowManager", layer == -2147483622,
        let boundsDict = info[kCGWindowBounds as String] as? NSDictionary,
        let bounds = CGRect(dictionaryRepresentation: boundsDict),
        bounds.width >= displayRect.width * 0.9,
        bounds.height >= displayRect.height * 0.9,
        bounds.intersects(displayRect)
      else { continue }
      return true
    }
    return false
  }

  private static func applicationHasVisibleWindowOnActiveSpace(pid: pid_t) -> Bool {
    guard
      let list = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID)
        as? [[String: Any]]
    else { return false }
    for info in list {
      let ownerPID = info[kCGWindowOwnerPID as String] as? pid_t ?? 0
      let layer = info[kCGWindowLayer as String] as? Int ?? 0
      let alpha = info[kCGWindowAlpha as String] as? Double ?? 0
      if ownerPID == pid && layer == 0 && alpha > 0.01 {
        return true
      }
    }
    return false
  }
}

// MARK: - App lifecycle

enum DesktopPlacement {
  /// Select the display containing the card, not the display of the key window.
  /// Screen coordinates may be negative or above the primary display.
  static func clampedAnchor(
    _ anchor: NSPoint, cardSize: NSSize, visibleFrames: [NSRect]
  ) -> NSPoint {
    guard !visibleFrames.isEmpty else { return anchor }
    let safeAnchor: NSPoint
    if anchor.x.isFinite && anchor.y.isFinite {
      safeAnchor = anchor
    } else {
      let first = visibleFrames[0]
      safeAnchor = NSPoint(x: first.maxX - cardSize.width - 28, y: first.maxY - 28)
    }
    let card = NSRect(
      x: safeAnchor.x, y: safeAnchor.y - cardSize.height,
      width: cardSize.width, height: cardSize.height)
    let center = NSPoint(x: card.midX, y: card.midY)
    func overlap(_ frame: NSRect) -> CGFloat {
      let intersection = frame.intersection(card)
      return intersection.isNull ? 0 : intersection.width * intersection.height
    }
    func distance(_ frame: NSRect) -> CGFloat {
      let dx = max(frame.minX - center.x, 0, center.x - frame.maxX)
      let dy = max(frame.minY - center.y, 0, center.y - frame.maxY)
      return dx * dx + dy * dy
    }
    let visible = visibleFrames.sorted {
      let a = overlap($0), b = overlap($1)
      return a == b ? distance($0) < distance($1) : a > b
    }[0]
    let margin: CGFloat = 12
    let minX = visible.minX + margin
    let maxX = max(minX, visible.maxX - cardSize.width - margin)
    let minTopY = visible.minY + cardSize.height + margin
    let maxTopY = max(minTopY, visible.maxY - margin)
    return NSPoint(
      x: min(max(safeAnchor.x, minX), maxX),
      y: min(max(safeAnchor.y, minTopY), maxTopY))
  }
}

final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
  private var panels: [DiskPanel] = []
  private var previewPlaceholderPanel: DiskPanel?
  private var isSettingsWindowVisible = false
  private var timer: Timer?
  private var desktopPresentationTimer: Timer?
  private var layout = WidgetLayout().normalized()
  private var layoutEditor: LayoutEditorWindowController?
  private var statusItem: NSStatusItem?
  private var groupDragStartOrigins: [ObjectIdentifier: NSPoint] = [:]
  private var screenLayoutWorkItem: DispatchWorkItem?
  private var pendingRefreshAfterInteraction = false
  private var isDesktopActive = true

  private weak var reorderSource: DiskPanel?
  private var reorderBasePanels: [DiskPanel] = []
  private var reorderAnchor: NSPoint?

  private var diskImageMountPaths: Set<String> = []
  private var lastKnownVolumePaths: Set<String> = []
  private var diskImageScanInFlight = false
  private var hasLoadedDiskImageMountPaths = false
  private var lastDiskImageScan = Date.distantPast
  private var lastPublishedSnapshot: DiskWidgetSnapshot?
  private var isObservingWidgetCommands = false
  private var globalMouseMonitor: Any?
  private var localMouseMonitor: Any?
  private var appearanceObservation: NSKeyValueObservation?

  func applicationDidFinishLaunching(_ notification: Notification) {
    LSRegisterURL(Bundle.main.bundleURL as CFURL, true)
    NSApp.setActivationPolicy(.accessory)
    updateDesktopActiveState()
    updateStatusItemVisibility()
    registerWidgetCommandObserver()
    scheduleDiskImageMountRefresh(force: true)
    refresh()
    processPendingWidgetCommands()

    // Recovery path: when both the menu-bar icon and desktop cards are absent,
    // a cold launch must not leave the app completely invisible.
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
      guard let self else { return }
      if !self.layout.showMenuBarItem && (!self.layout.showDesktopCards || self.panels.isEmpty) {
        self.openLayoutEditor()
      }
    }

    let timer = Timer(timeInterval: 5, repeats: true) { [weak self] _ in
      self?.refresh()
    }
    self.timer = timer
    RunLoop.main.add(timer, forMode: .common)

    let presentationTimer = Timer(timeInterval: 0.15, repeats: true) { [weak self] _ in
      self?.syncDesktopPresentationVisibility()
    }
    self.desktopPresentationTimer = presentationTimer
    RunLoop.main.add(presentationTimer, forMode: .common)

    let workspaceNotifications = NSWorkspace.shared.notificationCenter
    [
      NSWorkspace.didMountNotification,
      NSWorkspace.didUnmountNotification,
      NSWorkspace.didRenameVolumeNotification,
      NSWorkspace.didWakeNotification,
    ].forEach {
      workspaceNotifications.addObserver(
        self,
        selector: #selector(volumeChanged(_:)),
        name: $0,
        object: nil
      )
    }
    workspaceNotifications.addObserver(
      self,
      selector: #selector(activeSpaceChanged(_:)),
      name: NSWorkspace.activeSpaceDidChangeNotification,
      object: nil
    )
    workspaceNotifications.addObserver(
      self,
      selector: #selector(activeAppChanged(_:)),
      name: NSWorkspace.didActivateApplicationNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(screenParametersChanged(_:)),
      name: NSApplication.didChangeScreenParametersNotification,
      object: nil
    )

    globalMouseMonitor = NSEvent.addGlobalMonitorForEvents(
      matching: [.leftMouseDown, .rightMouseDown]
    ) { [weak self] event in
      DispatchQueue.main.async {
        self?.handleMouseDownEvent(event)
      }
    }
    localMouseMonitor = NSEvent.addLocalMonitorForEvents(
      matching: [.leftMouseDown, .rightMouseDown]
    ) { [weak self] event in
      self?.handleMouseDownEvent(event)
      return event
    }

    appearanceObservation = NSApp.observe(\.effectiveAppearance, options: [.new]) { [weak self] _, _ in
      DispatchQueue.main.async {
        self?.handleSystemAppearanceChanged()
      }
    }
    DistributedNotificationCenter.default().addObserver(
      self,
      selector: #selector(systemInterfaceThemeChanged(_:)),
      name: Notification.Name("AppleInterfaceThemeChangedNotification"),
      object: nil
    )
  }

  @objc private func systemInterfaceThemeChanged(_ notification: Notification) {
    DispatchQueue.main.async { [weak self] in
      self?.handleSystemAppearanceChanged()
    }
  }

  private func handleSystemAppearanceChanged() {
    panels.forEach { $0.refreshAppearanceForSystemThemeChange() }
    previewPlaceholderPanel?.refreshAppearanceForSystemThemeChange()
    layoutEditor?.refreshPreviewForSystemAppearance()
  }

  private func setupStatusItem() {
    guard statusItem == nil else { return }
    let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    item.button?.image = NSImage(
      systemSymbolName: "externaldrive", accessibilityDescription: "DiskWidget")
    item.button?.toolTip = "DiskWidget"

    let menu = NSMenu(title: "DiskWidget")
    menu.delegate = self
    item.menu = menu
    statusItem = item
    rebuildStatusMenu(menu)
  }

  func menuNeedsUpdate(_ menu: NSMenu) {
    rebuildStatusMenu(menu)
  }

  private func rebuildStatusMenu(_ menu: NSMenu) {
    menu.removeAllItems()

    let realPanels = panels.filter { !$0.isPreviewPlaceholder }
    if realPanels.isEmpty {
      let emptyItem = NSMenuItem(title: "当前未连接外置磁盘", action: nil, keyEquivalent: "")
      emptyItem.isEnabled = false
      menu.addItem(emptyItem)
    } else {
      let header = NSMenuItem(title: "外置磁盘（\(realPanels.count)）", action: nil, keyEquivalent: "")
      header.isEnabled = false
      menu.addItem(header)

      for panel in realPanels {
        let item = NSMenuItem(title: panel.menuSummaryTitle, action: nil, keyEquivalent: "")
        let sub = NSMenu(title: panel.effectiveTitleText)
        if panel.isConnectedVolume {
          let open = NSMenuItem(
            title: "在 Finder 中打开",
            action: #selector(DiskPanel.requestOpenDisk),
            keyEquivalent: ""
          )
          open.target = panel
          sub.addItem(open)

          let eject = NSMenuItem(
            title: "安全推出",
            action: #selector(DiskPanel.requestSafeUnmount),
            keyEquivalent: ""
          )
          eject.target = panel
          sub.addItem(eject)
        } else if panel.isUnmountedReconnectable {
          let reconnect = NSMenuItem(
            title: "重新连接",
            action: #selector(DiskPanel.requestReconnect),
            keyEquivalent: ""
          )
          reconnect.target = panel
          sub.addItem(reconnect)
        }
        item.submenu = sub
        menu.addItem(item)
      }

      if realPanels.contains(where: \.isConnectedVolume) {
        let ejectAll = NSMenuItem(
          title: "安全推出所有外置磁盘",
          action: #selector(ejectAllFromMenu),
          keyEquivalent: "e"
        )
        ejectAll.target = self
        menu.addItem(ejectAll)
      }
      if realPanels.contains(where: \.isUnmountedReconnectable) {
        let reconnectAll = NSMenuItem(
          title: "重新连接全部已卸载磁盘",
          action: #selector(reconnectAllFromMenu),
          keyEquivalent: ""
        )
        reconnectAll.target = self
        menu.addItem(reconnectAll)
      }
    }

    menu.addItem(.separator())

    let refreshItem = NSMenuItem(title: "刷新", action: #selector(refreshFromMenu), keyEquivalent: "r")
    refreshItem.target = self
    menu.addItem(refreshItem)
    let arrangeItem = NSMenuItem(
      title: "整理组件", action: #selector(arrangeFromMenu), keyEquivalent: "")
    arrangeItem.target = self
    menu.addItem(arrangeItem)
    let settingsItem = NSMenuItem(
      title: "设置…", action: #selector(settingsFromMenu), keyEquivalent: ",")
    settingsItem.target = self
    menu.addItem(settingsItem)
    menu.addItem(.separator())
    let quitItem = NSMenuItem(
      title: "退出 DiskWidget", action: #selector(quitFromMenu), keyEquivalent: "q")
    quitItem.target = self
    menu.addItem(quitItem)
  }

  private func updateStatusItemVisibility() {
    if layout.showMenuBarItem {
      setupStatusItem()
    } else if let item = statusItem {
      NSStatusBar.system.removeStatusItem(item)
      statusItem = nil
    }
  }

  func applicationShouldHandleReopen(
    _ sender: NSApplication,
    hasVisibleWindows flag: Bool
  ) -> Bool {
    // If the menu-bar icon is hidden, relaunching DiskWidget becomes the recovery
    // path to settings even when no removable disk is currently connected.
    if !layout.showMenuBarItem || !layout.showDesktopCards || panels.isEmpty {
      openLayoutEditor()
    }
    return true
  }

  func application(_ application: NSApplication, open urls: [URL]) {
    for url in urls {
      handleIncomingURL(url)
    }
  }

  @objc private func refreshFromMenu() {
    scheduleDiskImageMountRefresh(force: true)
    refresh()
    publishWidgetSnapshot(forceReload: true)
  }
  @objc private func ejectAllFromMenu() { ejectAllConnectedDisks() }
  @objc private func reconnectAllFromMenu() { reconnectAllUnmountedDisks() }
  @objc private func arrangeFromMenu() { arrangePanels() }
  @objc private func settingsFromMenu() { openLayoutEditor() }
  @objc private func quitFromMenu() { NSApp.terminate(nil) }

  private func ejectAllConnectedDisks() {
    for panel in panels where panel.isConnectedVolume {
      panel.requestSafeUnmount()
    }
  }

  private func reconnectAllUnmountedDisks() {
    for panel in panels where panel.isUnmountedReconnectable {
      panel.requestReconnect()
    }
  }

  private func toggleRingPercentageMode() {
    layout.ringShowsAvailablePercentage.toggle()
    layout.save()
    layoutEditor?.syncLayout(layout)
    panels.forEach { $0.applyLayout(layout) }
    previewPlaceholderPanel?.applyLayout(layout)
    publishWidgetSnapshot(forceReload: true)
  }

  func applicationWillTerminate(_ notification: Notification) {
    timer?.invalidate()
    desktopPresentationTimer?.invalidate()
    screenLayoutWorkItem?.cancel()
    if let globalMouseMonitor {
      NSEvent.removeMonitor(globalMouseMonitor)
      self.globalMouseMonitor = nil
    }
    if let localMouseMonitor {
      NSEvent.removeMonitor(localMouseMonitor)
      self.localMouseMonitor = nil
    }
    appearanceObservation?.invalidate()
    appearanceObservation = nil
    DistributedNotificationCenter.default().removeObserver(self)
    unregisterWidgetCommandObserver()
    NSWorkspace.shared.notificationCenter.removeObserver(self)
    NotificationCenter.default.removeObserver(self)
  }

  @objc private func volumeChanged(_ notification: Notification) {
    scheduleDiskImageMountRefresh(force: true)
    refresh()
    if notification.name == NSWorkspace.didWakeNotification {
      scheduleScreenParametersRelayout()
    }
  }

  @objc private func activeSpaceChanged(_ notification: Notification) {
    // The window server owns Space and Mission Control visibility. Never force
    // panels to order front or trigger layout/process scans during a Space transition.
    panels.forEach { $0.ensureDesktopLevelWithoutOrdering() }
    previewPlaceholderPanel?.ensureDesktopLevelWithoutOrdering()
    syncDesktopPresentationVisibility()
  }

  private func syncDesktopPresentationVisibility() {
    let managed = activeManagedPanels
    guard !managed.isEmpty else { return }

    if isSettingsWindowVisible, let settingsWin = layoutEditor?.window,
      settingsWin.isVisible && settingsWin.isOnActiveSpace
    {
      managed.forEach { $0.setHiddenForDesktopPresentation(false) }
      return
    }

    guard let primaryHeight = NSScreen.screens.first?.frame.height, primaryHeight > 0 else {
      return
    }
    guard
      let windowList = CGWindowListCopyWindowInfo([.optionAll], kCGNullWindowID)
        as? [[String: Any]]
    else { return }

    let displayRects = NSScreen.screens.map {
      CGRect(
        x: $0.frame.minX,
        y: primaryHeight - $0.frame.maxY,
        width: $0.frame.width,
        height: $0.frame.height
      )
    }
    let desktopWidgetLayer = Int(CGWindowLevelForKey(.desktopIconWindow)) + 2

    struct ParsedWindow {
      let owner: String
      let name: String
      let layer: Int
      let onScreen: Bool
      let bounds: CGRect
    }

    var fullscreenBackdrops: [CGRect] = []
    var dockOverlays: [CGRect] = []
    var nativeWidgetWindows: [ParsedWindow] = []

    for info in windowList {
      let owner = info[kCGWindowOwnerName as String] as? String ?? ""
      let layer = info[kCGWindowLayer as String] as? Int ?? 0
      let name = info[kCGWindowName as String] as? String ?? ""
      let onScreen = (info[kCGWindowIsOnscreen as String] as? Int ?? 0) == 1
      guard
        let boundsDict = info[kCGWindowBounds as String] as? NSDictionary,
        let bounds = CGRect(dictionaryRepresentation: boundsDict),
        bounds.width > 0, bounds.height > 0
      else { continue }

      if owner == "WindowManager" && layer == -2147483622 && onScreen {
        fullscreenBackdrops.append(bounds)
      } else if (owner == "Dock" || owner == "程序坞") && layer >= 18 && onScreen {
        dockOverlays.append(bounds)
      } else if (owner == "通知中心" || owner == "NotificationCenter")
        && layer == desktopWidgetLayer
      {
        nativeWidgetWindows.append(
          ParsedWindow(
            owner: owner, name: name, layer: layer, onScreen: onScreen, bounds: bounds))
      }
    }

    for panel in managed {
      let cgCenter = CGPoint(x: panel.frame.midX, y: primaryHeight - panel.frame.midY)
      let displayRect =
        displayRects.first(where: { $0.contains(cgCenter) })
        ?? panel.screen.map {
          CGRect(
            x: $0.frame.minX,
            y: primaryHeight - $0.frame.maxY,
            width: $0.frame.width,
            height: $0.frame.height
          )
        }
        ?? displayRects.first
        ?? CGRect(x: 0, y: 0, width: 1920, height: primaryHeight)

      let hasFullscreenBackdrop = fullscreenBackdrops.contains {
        $0.width >= displayRect.width * 0.9
          && $0.height >= displayRect.height * 0.9
          && $0.intersects(displayRect)
      }
      if hasFullscreenBackdrop {
        // Cards live strictly on ordinary Desktop Spaces via `.fullScreenNone`, so keep
        // `alphaValue = 1` while another Fullscreen Space is active — WindowServer then
        // slides the cards in attached to the Desktop wallpaper with zero delay.
        panel.setHiddenForDesktopPresentation(false)
        continue
      }
      let hasDockOverlay = dockOverlays.contains {
        $0.width >= displayRect.width * 0.9
          && $0.height >= displayRect.height * 0.9
          && $0.intersects(displayRect)
      }
      let widgetsOnDisplay = nativeWidgetWindows.filter { $0.bounds.intersects(displayRect) }
      let nativeWidgetsHiddenOnDisplay =
        !widgetsOnDisplay.isEmpty && widgetsOnDisplay.allSatisfy { !$0.onScreen }

      panel.setHiddenForDesktopPresentation(hasDockOverlay || nativeWidgetsHiddenOnDisplay)
    }
  }

  @objc private func activeAppChanged(_ notification: Notification) {
    updateDesktopActiveState()
  }

  private func updateDesktopActiveState() {
    let frontBundle = NSWorkspace.shared.frontmostApplication?.bundleIdentifier
    let active = (frontBundle == "com.apple.finder" || frontBundle == Bundle.main.bundleIdentifier)
    setDesktopActiveState(active)
  }

  private func setDesktopActiveState(_ active: Bool) {
    isDesktopActive = active
    panels.forEach { $0.setDesktopActive(active) }
    previewPlaceholderPanel?.setDesktopActive(active)
  }

  private func handleMouseDownEvent(_ event: NSEvent) {
    let cocoaPoint = NSEvent.mouseLocation
    guard let primaryHeight = NSScreen.screens.first?.frame.height, primaryHeight > 0 else {
      return
    }
    let cgPoint = CGPoint(x: cocoaPoint.x, y: primaryHeight - cocoaPoint.y)
    let maxLayer = Int(CGWindowLevelForKey(.statusWindow))
    let myPID = ProcessInfo.processInfo.processIdentifier

    guard
      let list = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID)
        as? [[String: Any]]
    else { return }

    for info in list {
      let alpha = info[kCGWindowAlpha as String] as? Double ?? 0
      guard alpha > 0.01 else { continue }
      let layer = info[kCGWindowLayer as String] as? Int ?? 0
      guard layer < maxLayer else { continue }
      guard
        let boundsDict = info[kCGWindowBounds as String] as? NSDictionary,
        let bounds = CGRect(dictionaryRepresentation: boundsDict),
        bounds.width > 0, bounds.height > 0,
        bounds.contains(cgPoint)
      else { continue }

      let ownerPID = info[kCGWindowOwnerPID as String] as? Int32 ?? 0
      setDesktopActiveState(layer < 0 || ownerPID == myPID)
      return
    }
  }

  @objc private func screenParametersChanged(_ notification: Notification) {
    scheduleScreenParametersRelayout()
  }

  private func scheduleScreenParametersRelayout() {
    // Wake, Dock and display changes can arrive in a burst with intermediate
    // geometry. Restore from the user's position after that geometry settles.
    screenLayoutWorkItem?.cancel()
    let work = DispatchWorkItem { [weak self] in
      guard let self, self.groupDragStartOrigins.isEmpty, self.reorderSource == nil else { return }
      self.relayoutPanels(anchor: self.preferredGroupAnchor())
    }
    screenLayoutWorkItem = work
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: work)
  }

  @objc private func refresh() {
    guard groupDragStartOrigins.isEmpty, reorderSource == nil else {
      pendingRefreshAfterInteraction = true
      return
    }
    pendingRefreshAfterInteraction = false

    let keys: Set<URLResourceKey> = [
      .volumeNameKey,
      .volumeUUIDStringKey,
      .volumeIsLocalKey,
      .volumeIsInternalKey,
      .volumeAvailableCapacityKey,
      .volumeTotalCapacityKey,
      .volumeIsReadOnlyKey,
      .volumeIsRemovableKey,
      .volumeLocalizedFormatDescriptionKey,
    ]
    let volumes =
      FileManager.default.mountedVolumeURLs(
        includingResourceValuesForKeys: Array(keys), options: []
      ) ?? []

    let currentVolumePaths = Set(volumes.map { $0.standardizedFileURL.path })
    let volumePathsChanged = currentVolumePaths != lastKnownVolumePaths
    lastKnownVolumePaths = currentVolumePaths
    if !hasLoadedDiskImageMountPaths || volumePathsChanged {
      scheduleDiskImageMountRefresh(force: volumePathsChanged || !hasLoadedDiskImageMountPaths)
    }

    if !layout.showDiskImagesInWidget && !hasLoadedDiskImageMountPaths { return }

    var externalVolumes: [(url: URL, name: String, uuid: String?, isDiskImage: Bool)] = []
    for url in volumes {
      guard let values = try? url.resourceValues(forKeys: keys),
        values.volumeIsLocal == true,
        let name = values.volumeName,
        !name.isEmpty
      else { continue }

      guard DiskPanel.isDisplayableMount(url: url, values: values) else { continue }
      let path = url.standardizedFileURL.path
      let isDiskImage = diskImageMountPaths.contains(path)
      // Physical internal volumes stay excluded, but mounted DMG/ISO images are
      // allowed through so the user can explicitly choose their display location.
      guard isDiskImage || values.volumeIsInternal != true else { continue }
      if isDiskImage && !layout.showDiskImagesInWidget { continue }
      externalVolumes.append((url, name, values.volumeUUIDString, isDiskImage))
    }

    for panel in panels {
      if let path = panel.mountedPath {
        panel.setDiskImageClassification(diskImageMountPaths.contains(path))
      }
    }

    // Capture before any mutations: a newly discovered drive or removed first
    // card must not alter the group's intended anchor.
    let discoveryAnchor = preferredGroupAnchor()
    var needsRelayout = false

    if !layout.showDiskImagesInWidget {
      let hidden = panels.filter { $0.isDiskImage }
      if !hidden.isEmpty {
        detachPanels(hidden)
        needsRelayout = true
      }
    }

    panels.forEach { $0.refresh(using: volumes) }

    let unavailablePanels = panels.filter { $0.shouldAutoRemoveWhenUnavailable }
    if !unavailablePanels.isEmpty {
      detachPanels(unavailablePanels)
      needsRelayout = true
    }

    var addedPanel = false
    for volume in externalVolumes {
      let alreadyRepresented = panels.contains {
        $0.representsVolume(name: volume.name, uuid: volume.uuid)
      }
      guard !alreadyRepresented else { continue }

      let panel = DiskPanel(
        diskName: volume.name,
        initialVolumeUUID: volume.uuid,
        isDiskImage: volume.isDiskImage,
        initialLayout: layout
      )
      configurePanel(panel)
      panel.setDesktopActive(isDesktopActive)
      panel.applyLayout(layout)
      panel.refresh(using: volumes)
      panels.append(panel)
      addedPanel = true
      needsRelayout = true
    }

    if addedPanel {
      applySavedPanelOrder()
    }
    updatePreviewPlaceholderVisibility()
    if needsRelayout {
      relayoutPanels(anchor: discoveryAnchor)
    }

    let snapshot = panels
    for panel in snapshot {
      panel.verifyBackingDevicePresence { [weak self, weak panel] exists in
        guard let self, let panel, !exists, self.panels.contains(where: { $0 === panel }) else {
          return
        }
        self.removePanelsFromDesktop([panel])
      }
    }
    publishWidgetSnapshot()
    syncDesktopPresentationVisibility()
  }

  private func updatePreviewPlaceholderVisibility() {
    let shouldShowPreview = isSettingsWindowVisible && panels.isEmpty && layout.showDesktopCards
    if shouldShowPreview {
      if previewPlaceholderPanel == nil {
        let placeholder = DiskPanel(
          diskName: "示例外置硬盘",
          isPreviewPlaceholder: true,
          initialLayout: layout
        )
        configurePanel(placeholder)
        placeholder.setDesktopActive(isDesktopActive)
        placeholder.applyLayout(layout)
        previewPlaceholderPanel = placeholder
        relayoutPanels(anchor: preferredGroupAnchor())
      }
    } else if let placeholder = previewPlaceholderPanel {
      placeholder.orderOut(nil)
      previewPlaceholderPanel = nil
    }
  }

  private func configurePanel(_ panel: DiskPanel) {
    UserDefaults.standard.removeObject(forKey: "disk-widget-position-\(panel.diskName)")
    panel.removalRequested = { [weak self] panel in self?.removePanel(panel) }
    panel.layoutEditorRequested = { [weak self] in self?.openLayoutEditor() }
    panel.ringModeToggleRequested = { [weak self] in self?.toggleRingPercentageMode() }
    panel.ejectAllRequested = { [weak self] in self?.ejectAllConnectedDisks() }
    panel.groupDragBegan = { [weak self] panel in self?.beginGroupDrag(from: panel) }
    panel.groupDragChanged = { [weak self] panel, delta in
      self?.updateGroupDrag(from: panel, delta: delta)
    }
    panel.groupDragEnded = { [weak self] panel in self?.endGroupDrag(from: panel) }
    panel.reorderDragBegan = { [weak self] panel in self?.beginReorder(from: panel) }
    panel.reorderDragChanged = { [weak self] panel, delta in
      self?.updateReorder(from: panel, delta: delta)
    }
    panel.reorderDragEnded = { [weak self] panel in self?.endReorder(from: panel) }
    panel.stateChanged = { [weak self] in self?.publishWidgetSnapshot(forceReload: true) }
  }

  private func detachPanels(_ panelsToRemove: [DiskPanel]) {
    guard !panelsToRemove.isEmpty else { return }
    let identifiers = Set(panelsToRemove.map(ObjectIdentifier.init))
    for panel in panelsToRemove {
      let id = ObjectIdentifier(panel)
      groupDragStartOrigins.removeValue(forKey: id)
      if reorderSource === panel {
        reorderSource = nil
        reorderBasePanels.removeAll()
        reorderAnchor = nil
      }
      panel.setReorderActive(false)
      panel.orderOut(nil)
    }
    panels.removeAll { identifiers.contains(ObjectIdentifier($0)) }
    if !reorderBasePanels.isEmpty {
      reorderBasePanels.removeAll { identifiers.contains(ObjectIdentifier($0)) }
    }
  }

  private func removePanelsFromDesktop(_ panelsToRemove: [DiskPanel]) {
    guard !panelsToRemove.isEmpty else { return }
    let anchor = preferredGroupAnchor()
    detachPanels(panelsToRemove)
    updatePreviewPlaceholderVisibility()
    if !activeManagedPanels.isEmpty { relayoutPanels(anchor: anchor) }
    publishWidgetSnapshot(forceReload: true)
  }

  private func removePanel(_ panel: DiskPanel) {
    let key = panel.orderingKey
    removePanelsFromDesktop([panel])
    UserDefaults.standard.removeObject(forKey: "disk-widget-volume-uuid-\(panel.diskName)")
    let order = savedPanelOrder().filter { $0 != key }
    UserDefaults.standard.set(order, forKey: "disk-widget-panel-order")
    publishWidgetSnapshot(forceReload: true)
  }

  private func applyLayout(_ newLayout: WidgetLayout) {
    let anchor = preferredGroupAnchor()
    let oldDiskImageSetting = layout.showDiskImagesInWidget
    layout = newLayout.normalized()
    layout.save()
    updateStatusItemVisibility()
    panels.forEach { $0.applyLayout(layout) }
    previewPlaceholderPanel?.applyLayout(layout)
    updatePreviewPlaceholderVisibility()
    relayoutPanels(anchor: anchor)
    if oldDiskImageSetting != layout.showDiskImagesInWidget {
      scheduleDiskImageMountRefresh(force: true)
      refresh()
    }
    publishWidgetSnapshot()
    syncDesktopPresentationVisibility()
  }

  private func openLayoutEditor() {
    if layoutEditor == nil {
      let editor = LayoutEditorWindowController(layout: layout, cardPanels: panels) { [weak self] newLayout in
        self?.applyLayout(newLayout)
      }
      editor.onVisibilityChanged = { [weak self] visible in
        guard let self else { return }
        self.isSettingsWindowVisible = visible
        self.updatePreviewPlaceholderVisibility()
      }
      layoutEditor = editor
    } else {
      layoutEditor?.syncLayout(layout)
      layoutEditor?.updateCardPanels(panels)
    }
    layoutEditor?.present()
  }

  private func arrangePanels() {
    guard !activeManagedPanels.isEmpty else { return }
    let anchor = clampedGroupAnchor(currentGroupAnchor() ?? preferredGroupAnchor())
    saveGroupAnchor(anchor)
    relayoutPanels(anchor: anchor, animated: true)
  }

  private var activeManagedPanels: [DiskPanel] {
    if !panels.isEmpty { return panels }
    if let previewPlaceholderPanel { return [previewPlaceholderPanel] }
    return []
  }

  // Normal drag moves the whole widget group.
  private func beginGroupDrag(from source: DiskPanel) {
    let managed = activeManagedPanels
    guard managed.contains(where: { $0 === source }) else { return }
    groupDragStartOrigins = Dictionary(
      uniqueKeysWithValues: managed.map { (ObjectIdentifier($0), $0.frame.origin) })
  }

  private func updateGroupDrag(from source: DiskPanel, delta: NSPoint) {
    let managed = activeManagedPanels
    guard managed.contains(where: { $0 === source }), !groupDragStartOrigins.isEmpty else { return }
    for panel in managed {
      guard let origin = groupDragStartOrigins[ObjectIdentifier(panel)] else { continue }
      panel.setManagedPosition(NSPoint(x: origin.x + delta.x, y: origin.y + delta.y))
    }
  }

  private func endGroupDrag(from source: DiskPanel) {
    let managed = activeManagedPanels
    guard managed.contains(where: { $0 === source }) else {
      groupDragStartOrigins.removeAll()
      return
    }
    groupDragStartOrigins.removeAll()
    if let rawAnchor = currentGroupAnchor() {
      let clamped = clampedGroupAnchor(rawAnchor)
      saveGroupAnchor(clamped)
      relayoutPanels(anchor: clamped)
    }
    if pendingRefreshAfterInteraction {
      refresh()
    }
  }

  // Option + drag reorders a single card while keeping the group anchored.
  private func beginReorder(from source: DiskPanel) {
    guard panels.contains(where: { $0 === source }) else { return }
    reorderSource = source
    reorderBasePanels = panels
    reorderAnchor = currentGroupAnchor() ?? savedGroupAnchor() ?? defaultGroupAnchor()
    source.setReorderActive(true)
  }

  private func updateReorder(from source: DiskPanel, delta: NSPoint) {
    guard reorderSource === source,
      let baseIndex = reorderBasePanels.firstIndex(where: { $0 === source })
    else { return }

    let stride = max(1, layout.height + layout.stackSpacing)
    let offset = Int((-delta.y / stride).rounded())
    let targetIndex = min(max(baseIndex + offset, 0), max(0, reorderBasePanels.count - 1))

    var reordered = reorderBasePanels
    reordered.remove(at: baseIndex)
    reordered.insert(source, at: targetIndex)
    guard zip(panels, reordered).contains(where: { $0 !== $1 }) else { return }
    NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .default)
    panels = reordered
    relayoutPanels(anchor: reorderAnchor ?? defaultGroupAnchor(), animated: true)
  }

  private func endReorder(from source: DiskPanel) {
    source.setReorderActive(false)
    guard reorderSource === source else { return }
    savePanelOrder()
    reorderSource = nil
    reorderBasePanels.removeAll()
    reorderAnchor = nil
    publishWidgetSnapshot(forceReload: true)
    if pendingRefreshAfterInteraction {
      refresh()
    }
  }

  private func savedPanelOrder() -> [String] {
    UserDefaults.standard.stringArray(forKey: "disk-widget-panel-order") ?? []
  }

  private func savePanelOrder() {
    UserDefaults.standard.set(panels.map(\.orderingKey), forKey: "disk-widget-panel-order")
  }

  private func applySavedPanelOrder() {
    let saved = savedPanelOrder()
    guard !saved.isEmpty else { return }
    let rank = Dictionary(uniqueKeysWithValues: saved.enumerated().map { ($0.element, $0.offset) })
    let currentOrder = Dictionary(
      uniqueKeysWithValues: panels.enumerated().map { (ObjectIdentifier($0.element), $0.offset) })
    panels.sort {
      let a = rank[$0.orderingKey] ?? Int.max
      let b = rank[$1.orderingKey] ?? Int.max
      if a != b { return a < b }
      // Preserve existing desktop order for unranked drives so newly inserted
      // drives append cleanly at the bottom without jumping ahead of existing cards.
      return (currentOrder[ObjectIdentifier($0)] ?? 0) < (currentOrder[ObjectIdentifier($1)] ?? 0)
    }
  }

  private func scheduleDiskImageMountRefresh(force: Bool = false) {
    guard !diskImageScanInFlight else { return }
    if !force && Date().timeIntervalSince(lastDiskImageScan) < 3 { return }
    diskImageScanInFlight = true
    lastDiskImageScan = Date()

    DispatchQueue.global(qos: .utility).async { [weak self] in
      let paths = Self.mountedDiskImagePaths()
      DispatchQueue.main.async {
        guard let self else { return }
        self.diskImageScanInFlight = false
        let isInitialLoad = !self.hasLoadedDiskImageMountPaths
        self.hasLoadedDiskImageMountPaths = true
        let changed = paths != self.diskImageMountPaths
        self.diskImageMountPaths = paths
        for panel in self.panels {
          if let path = panel.mountedPath {
            panel.setDiskImageClassification(paths.contains(path))
          }
        }
        if changed || (isInitialLoad && !self.layout.showDiskImagesInWidget) {
          self.refresh()
        }
      }
    }
  }

  private static func mountedDiskImagePaths() -> Set<String> {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/hdiutil")
    process.arguments = ["info", "-plist"]
    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = Pipe()

    let finished = DispatchSemaphore(value: 0)
    process.terminationHandler = { _ in finished.signal() }
    do { try process.run() } catch { return [] }
    guard finished.wait(timeout: .now() + 5) == .success else {
      process.terminate()
      return []
    }
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    guard process.terminationStatus == 0,
      let rawPlist = try? PropertyListSerialization.propertyList(from: data, format: nil),
      let plist = rawPlist as? [String: Any],
      let images = plist["images"] as? [[String: Any]]
    else { return [] }

    var paths = Set<String>()
    for image in images {
      let entities = image["system-entities"] as? [[String: Any]] ?? []
      for entity in entities {
        if let mount = entity["mount-point"] as? String, !mount.isEmpty {
          paths.insert(URL(fileURLWithPath: mount).standardizedFileURL.path)
        }
      }
    }
    return paths
  }

  private func currentGroupAnchor() -> NSPoint? {
    guard let first = activeManagedPanels.first else { return nil }
    return NSPoint(x: first.frame.minX, y: first.frame.maxY)
  }

  private func preferredGroupAnchor() -> NSPoint {
    savedGroupAnchor() ?? currentGroupAnchor() ?? defaultGroupAnchor()
  }

  private func defaultGroupAnchor() -> NSPoint {
    guard let visible = (NSScreen.main ?? NSScreen.screens.first)?.visibleFrame else {
      return NSPoint(x: 100, y: 700)
    }
    return NSPoint(
      x: (visible.maxX - layout.width - 28).rounded(),
      y: (visible.maxY - 28).rounded()
    )
  }

  private func savedGroupAnchor() -> NSPoint? {
    guard
      let stored = UserDefaults.standard.dictionary(forKey: "disk-widget-group-position"),
      let x = stored["x"] as? NSNumber,
      let y = stored["y"] as? NSNumber
    else { return nil }
    let point = NSPoint(x: x.doubleValue, y: y.doubleValue)
    guard point.x.isFinite, point.y.isFinite else { return nil }
    return point
  }

  private func saveGroupAnchor(_ anchor: NSPoint) {
    guard anchor.x.isFinite, anchor.y.isFinite else { return }
    UserDefaults.standard.set(
      ["x": anchor.x, "y": anchor.y],
      forKey: "disk-widget-group-position"
    )
  }

  private func relayoutPanels(anchor: NSPoint, animated: Bool = false) {
    let managed = activeManagedPanels
    guard !managed.isEmpty else { return }
    let clamped = clampedGroupAnchor(anchor)
    // Only an explicit drag/arrange replaces a saved position. A temporary
    // fallback while a screen is unavailable must not overwrite it.
    if savedGroupAnchor() == nil && !NSScreen.screens.isEmpty {
      saveGroupAnchor(clamped)
    }
    let managedSize = NSSize(width: layout.width.rounded(), height: layout.height.rounded())
    let spacing = layout.stackSpacing.rounded()

    // Determine the screen containing the clamped anchor so large multi-drive
    // stacks can automatically wrap into columns instead of falling off the bottom.
    let targetScreenFrame =
      NSScreen.screens.map(\.visibleFrame).first {
        $0.contains(NSPoint(x: clamped.x + 1, y: clamped.y - 1))
      } ?? NSScreen.main?.visibleFrame

    let minBottomY = (targetScreenFrame?.minY ?? -10_000) + 12
    let prefersLeftWrap: Bool
    if let screenFrame = targetScreenFrame {
      prefersLeftWrap = (clamped.x + managedSize.width * 2 + spacing + 12 > screenFrame.maxX)
    } else {
      prefersLeftWrap = true
    }
    let columnStepX =
      prefersLeftWrap ? -(managedSize.width + spacing) : (managedSize.width + spacing)

    var columnX = clamped.x
    var cursorY = clamped.y
    for (index, panel) in managed.enumerated() {
      if index > 0 && (cursorY - managedSize.height < minBottomY) && managed.count > 2 {
        columnX += columnStepX
        cursorY = clamped.y
      }
      cursorY -= managedSize.height
      panel.cardIndex = index
      panel.setManagedFrame(
        NSRect(
          x: columnX,
          y: cursorY,
          width: managedSize.width,
          height: managedSize.height
        ),
        animated: animated
      )
      panel.reassertDesktopLevel()
      cursorY -= spacing
    }
  }

  private func clampedGroupAnchor(_ anchor: NSPoint) -> NSPoint {
    DesktopPlacement.clampedAnchor(
      anchor, cardSize: NSSize(width: layout.width, height: layout.height),
      visibleFrames: NSScreen.screens.map(\.visibleFrame))
  }

  // MARK: - WidgetKit Bridge

  private func buildCurrentSnapshot() -> DiskWidgetSnapshot {
    let rgb = layout.accentColor.usingColorSpace(.sRGB)
    let color = DiskSnapshotColor(
      red: Double(rgb?.redComponent ?? layout.accentRed),
      green: Double(rgb?.greenComponent ?? layout.accentGreen),
      blue: Double(rgb?.blueComponent ?? layout.accentBlue)
    )
    let items = panels.filter { !$0.isPreviewPlaceholder }.map { $0.makeSnapshotItem() }
    return DiskWidgetSnapshot(
      generatedAt: Date(),
      accentColor: color,
      ringShowsAvailablePercentage: layout.ringShowsAvailablePercentage,
      showDiskImages: layout.showDiskImagesInWidget,
      disks: items
    )
  }

  private func snapshotPayloadMatches(_ lhs: DiskWidgetSnapshot?, _ rhs: DiskWidgetSnapshot) -> Bool {
    guard let lhs else { return false }
    return lhs.accentColor == rhs.accentColor
      && lhs.ringShowsAvailablePercentage == rhs.ringShowsAvailablePercentage
      && lhs.showDiskImages == rhs.showDiskImages
      && lhs.disks == rhs.disks
  }

  private func publishWidgetSnapshot(forceReload: Bool = false) {
    let snapshot = buildCurrentSnapshot()
    let changed = !snapshotPayloadMatches(lastPublishedSnapshot, snapshot)
    guard changed || forceReload else { return }
    lastPublishedSnapshot = snapshot
    DiskWidgetSharedStore.writeSnapshot(snapshot)
    WidgetCenter.shared.reloadAllTimelines()
  }

  private func registerWidgetCommandObserver() {
    guard !isObservingWidgetCommands else { return }
    isObservingWidgetCommands = true
    let center = CFNotificationCenterGetDarwinNotifyCenter()
    let observer = Unmanaged.passUnretained(self).toOpaque()
    CFNotificationCenterAddObserver(
      center,
      observer,
      { _, observer, _, _, _ in
        guard let observer else { return }
        let delegate = Unmanaged<AppDelegate>.fromOpaque(observer).takeUnretainedValue()
        DispatchQueue.main.async {
          delegate.processPendingWidgetCommands()
        }
      },
      DiskWidgetSharedConfig.commandDarwinNotification as CFString,
      nil,
      .deliverImmediately
    )
  }

  private func unregisterWidgetCommandObserver() {
    guard isObservingWidgetCommands else { return }
    isObservingWidgetCommands = false
    let center = CFNotificationCenterGetDarwinNotifyCenter()
    let observer = Unmanaged.passUnretained(self).toOpaque()
    CFNotificationCenterRemoveEveryObserver(center, observer)
  }

  private func processPendingWidgetCommands() {
    let commands = DiskWidgetSharedStore.drainCommands()
    guard !commands.isEmpty else { return }
    for command in commands {
      switch command.kind {
      case .refresh:
        scheduleDiskImageMountRefresh(force: true)
        refresh()
        publishWidgetSnapshot(forceReload: true)
      case .toggleMetricMode:
        toggleRingPercentageMode()
      case .ejectAll:
        ejectAllConnectedDisks()
        publishWidgetSnapshot(forceReload: true)
      case .openSettings:
        openLayoutEditor()
      case .openDisk:
        if let id = command.diskID, let panel = panels.first(where: { $0.orderingKey == id }) {
          panel.requestOpenDisk()
        }
      case .ejectDisk:
        if let id = command.diskID, let panel = panels.first(where: { $0.orderingKey == id }) {
          panel.requestSafeUnmount()
        }
      case .reconnectDisk:
        if let id = command.diskID, let panel = panels.first(where: { $0.orderingKey == id }) {
          panel.requestReconnect()
        }
      }
    }
  }

  private func handleIncomingURL(_ url: URL) {
    guard url.scheme?.lowercased() == DiskWidgetSharedConfig.urlScheme else { return }
    let host = (url.host ?? "").lowercased()
    let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
    let id = components?.queryItems?.first(where: { $0.name == "id" })?.value

    switch host {
    case "settings":
      openLayoutEditor()
    case "open":
      if let id, let panel = panels.first(where: { $0.orderingKey == id }) {
        panel.requestOpenDisk()
      } else if let firstConnected = panels.first(where: { $0.isConnectedVolume }) {
        firstConnected.requestOpenDisk()
      }
    case "eject":
      if let id, let panel = panels.first(where: { $0.orderingKey == id }) {
        panel.requestSafeUnmount()
      }
    case "reconnect":
      if let id, let panel = panels.first(where: { $0.orderingKey == id }) {
        panel.requestReconnect()
      }
    default:
      break
    }
  }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
