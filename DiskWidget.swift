import AppKit
import QuartzCore

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
  var dimWhenDesktopInactive: Bool = false

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
    if defaults.object(forKey: "disk-widget-dim-when-inactive") != nil {
      dimWhenDesktopInactive = defaults.bool(forKey: "disk-widget-dim-when-inactive")
    }
    normalize()
  }

  static var factoryDefaults: WidgetLayout {
    WidgetLayout(loadSavedValues: false)
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
    height = min(max(height.rounded(), 72), 120)
    iconSize = min(max(iconSize.rounded(), 16), 48)
    ringSize = min(max(ringSize.rounded(), 34), 60)
    ejectSize = min(max(ejectSize.rounded(), 16), 36)
    cornerRadius = min(max(cornerRadius.rounded(), 8), min(28, (height / 2).rounded()))
    nameFontSize = min(max(nameFontSize.rounded(), 10), 18)
    statusFontSize = min(max(statusFontSize.rounded(), 8), 13)
    ringTextFontSize = min(max(ringTextFontSize.rounded(), 7), 16)
    opacity = min(max(opacity, 0), 1)
    stackSpacing = min(max(stackSpacing.rounded(), 4), 40)
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
    defaults.set(layout.dimWhenDesktopInactive, forKey: "disk-widget-dim-when-inactive")
  }
}

// MARK: - Card interaction

final class DiskCardView: NSView {
  var acceptsFiles: (() -> Bool)?
  var receivesFiles: (([URL]) -> Bool)?
  var highlightsDrop: ((Bool) -> Void)?
  var opensDisk: (() -> Void)?
  var hoverChanged: ((Bool) -> Void)?
  var pressChanged: ((Bool) -> Void)?
  var appearanceChanged: (() -> Void)?
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
    }
    cancelActiveDrag()
  }

  override func rightMouseDown(with event: NSEvent) {
    pressChanged?(false)
    showsSettingsMenu?(event)
  }

  override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
    guard acceptsFiles?() == true,
      sender.draggingPasteboard.canReadObject(forClasses: [NSURL.self], options: nil)
    else {
      return []
    }
    NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .default)
    highlightsDrop?(true)
    return .copy
  }

  override func draggingExited(_ sender: NSDraggingInfo?) { highlightsDrop?(false) }
  override func draggingEnded(_ sender: NSDraggingInfo) { highlightsDrop?(false) }

  override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
    acceptsFiles?() == true
  }

  override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
    defer { highlightsDrop?(false) }
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
    superview?.mouseEntered(with: event)
  }

  override func mouseExited(with event: NSEvent) {
    isHovered = false
  }

  override func draw(_ dirtyRect: NSRect) {
    if isEnabled && (isHovered || isHighlighted) {
      let pillRect = bounds.insetBy(dx: 1, dy: 1)
      let pill = NSBezierPath(ovalIn: pillRect)
      let alpha: CGFloat = isHighlighted ? 0.16 : 0.09
      NSColor.labelColor.withAlphaComponent(alpha).setFill()
      pill.fill()
    }
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
  private var spinPhase: CGFloat = 0
  private var spinTimer: Timer?
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

  override func mouseDown(with event: NSEvent) { superview?.mouseDown(with: event) }
  override func mouseDragged(with event: NSEvent) { superview?.mouseDragged(with: event) }
  override func mouseUp(with event: NSEvent) { superview?.mouseUp(with: event) }
  override func rightMouseDown(with event: NSEvent) { superview?.rightMouseDown(with: event) }

  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    let lineWidth: CGFloat = 4
    let radius = max(1, min(bounds.width, bounds.height) / 2 - lineWidth)
    let center = NSPoint(x: bounds.midX, y: bounds.midY)

    let track = NSBezierPath()
    track.lineWidth = lineWidth
    track.lineCapStyle = .round
    track.appendArc(withCenter: center, radius: radius, startAngle: 90, endAngle: 450)
    NSColor.quaternaryLabelColor.setStroke()
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
      accentColor.withAlphaComponent(0.85).setStroke()
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
        if clamped >= 0.9 {
          ringColor = .systemOrange
        } else {
          ringColor = accentColor
        }
        ringColor.setStroke()
        usage.stroke()
      }
    }

    let attributes: [NSAttributedString.Key: Any] = [
      .font: NSFont.monospacedDigitSystemFont(ofSize: textFontSize, weight: .semibold),
      .foregroundColor: NSColor.labelColor,
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
  private(set) var isDiskImage: Bool

  private let nameLabel = NSTextField(labelWithString: "")
  private let statusLabel = NSTextField(labelWithString: "")
  private let diskIcon = NSImageView()
  private let usageRing = UsageRingView()
  private let ejectButton = ContextForwardingButton()
  private let materialView = NSVisualEffectView()
  private var surface: DiskCardView!

  private var volumeURL: URL?
  private var isReadOnlyVolume = false
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
  private var maskCornerRadius: CGFloat = -1
  private var maskSize: NSSize = .zero

  private var hoverDetails = ""
  private var hoverTimer: Timer?
  private var isDropTarget = false {
    didSet { if isDropTarget != oldValue { updateAppearance() } }
  }
  private var isCardHovered = false {
    didSet { if isCardHovered != oldValue { updateAppearance() } }
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
  private var accentColor: NSColor = .systemBlue

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
  var groupDragBegan: ((DiskPanel) -> Void)?
  var groupDragChanged: ((DiskPanel, NSPoint) -> Void)?
  var groupDragEnded: ((DiskPanel) -> Void)?
  var reorderDragBegan: ((DiskPanel) -> Void)?
  var reorderDragChanged: ((DiskPanel, NSPoint) -> Void)?
  var reorderDragEnded: ((DiskPanel) -> Void)?

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
    initialLayout: WidgetLayout
  ) {
    self.diskName = diskName
    self.isDiskImage = isDiskImage
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
    hasShadow = true
    level = Self.desktopWidgetLevel
    // Let the window server hide cards during Mission Control and restore
    // them afterward. `.stationary` explicitly keeps them visible there.
    collectionBehavior = [.canJoinAllSpaces, .transient, .ignoresCycle]
    hidesOnDeactivate = false
    ignoresMouseEvents = false
    acceptsMouseMovedEvents = true
    animationBehavior = .none
    delegate = self
    becomesKeyOnlyIfNeeded = true

    let card = DiskCardView(frame: contentView?.bounds ?? .zero)
    card.acceptsFiles = { [weak self] in
      guard let self else { return false }
      return self.state == .connected && self.volumeURL != nil && !self.isReadOnlyVolume
    }
    card.receivesFiles = { [weak self] urls in self?.copyDroppedFiles(urls) ?? false }
    card.highlightsDrop = { [weak self] highlighted in self?.isDropTarget = highlighted }
    card.opensDisk = { [weak self] in self?.openDisk() }
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
    card.registerForDraggedTypes([.fileURL])
    surface = card
    surface.toolTip = "拖动移动整组 · 按住 ⌥ 拖动调整顺序"
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
    surface.addSubview(materialView)
    NSLayoutConstraint.activate([
      materialView.leadingAnchor.constraint(equalTo: surface.leadingAnchor),
      materialView.trailingAnchor.constraint(equalTo: surface.trailingAnchor),
      materialView.topAnchor.constraint(equalTo: surface.topAnchor),
      materialView.bottomAnchor.constraint(equalTo: surface.bottomAnchor),
    ])

    setDiskIconSymbol(isDiskImage ? "opticaldiscdrive.fill" : "externaldrive.fill")
    diskIcon.contentTintColor = .secondaryLabelColor
    diskIcon.symbolConfiguration = NSImage.SymbolConfiguration(pointSize: 22, weight: .regular)
    diskIcon.imageScaling = .scaleProportionallyUpOrDown

    nameLabel.stringValue = diskName
    nameLabel.font = .systemFont(ofSize: layout.nameFontSize, weight: .semibold)
    nameLabel.textColor = .labelColor
    nameLabel.lineBreakMode = .byTruncatingTail
    // Card width is globally managed. Text must yield to that width instead of
    // contributing a different fitting width for each disk name/capacity string.
    nameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
    nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

    statusLabel.font = .systemFont(ofSize: layout.statusFontSize, weight: .medium)
    statusLabel.textColor = .secondaryLabelColor
    statusLabel.lineBreakMode = .byTruncatingTail
    statusLabel.alignment = .left
    statusLabel.usesSingleLineMode = true
    statusLabel.maximumNumberOfLines = 1
    statusLabel.cell?.wraps = false
    statusLabel.cell?.truncatesLastVisibleLine = true
    statusLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
    statusLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

    ejectButton.imagePosition = .imageOnly
    ejectButton.isBordered = false
    ejectButton.imageScaling = .scaleProportionallyDown
    ejectButton.contentTintColor = .secondaryLabelColor
    ejectButton.target = self
    ejectButton.action = #selector(diskAction)
    ejectButton.focusRingType = .none

    usageRing.hoverChanged = { [weak self] hovering in self?.showHoverDetails(hovering) }

    [diskIcon, nameLabel, statusLabel, usageRing, ejectButton].forEach {
      $0.translatesAutoresizingMaskIntoConstraints = false
      surface.addSubview($0)
    }

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
      lessThanOrEqualTo: ejectButton.leadingAnchor, constant: -7)
    nameTrailing.priority = .defaultHigh
    let statusTrailing = statusLabel.trailingAnchor.constraint(
      lessThanOrEqualTo: ejectButton.leadingAnchor, constant: -8)
    statusTrailing.priority = .defaultHigh

    NSLayoutConstraint.activate([
      iconXConstraint,
      iconYConstraint,
      iconWidthConstraint,
      iconHeightConstraint,
      nameXConstraint,
      nameYConstraint,
      nameTrailing,
      statusXConstraint,
      statusBottomConstraint,
      statusTrailing,
      ejectXConstraint,
      ejectCenterConstraint,
      ejectWidthConstraint,
      ejectHeightConstraint,
      ringXConstraint,
      ringCenterConstraint,
      ringWidthConstraint,
      ringHeightConstraint,
    ])

    applyLayout(layout)
    showDisconnectedState(message: "未连接")
  }

  private static var desktopWidgetLevel: NSWindow.Level {
    NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopIconWindow)) + 1)
  }

  /// Places the panel onto the desktop once when first added. Subsequent calls
  /// only verify the window level and never call `orderFrontRegardless()`, so
  /// WindowServer remains in full control of hiding/restoring the panel during
  /// Mission Control and Space transitions.
  func reassertDesktopLevel() {
    if level != Self.desktopWidgetLevel { level = Self.desktopWidgetLevel }
    guard !hasOrderedOnDesktop else { return }
    hasOrderedOnDesktop = true
    orderFrontRegardless()
  }

  func ensureDesktopLevelWithoutOrdering() {
    if level != Self.desktopWidgetLevel { level = Self.desktopWidgetLevel }
  }

  func setDesktopActive(_ active: Bool) {
    isDesktopActive = active
  }

  func representsVolume(name: String, uuid: String?) -> Bool {
    if let uuid, !uuid.isEmpty, let lastVolumeUUID, !lastVolumeUUID.isEmpty {
      return uuid == lastVolumeUUID
    }
    return name == currentDisplayName || name == diskName
  }

  var orderingKey: String {
    if let lastVolumeUUID, !lastVolumeUUID.isEmpty { return "uuid:\(lastVolumeUUID)" }
    return "name:\(diskName)"
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
      refresh()
    }
  }

  /// A normal disconnected card should not remain on the desktop. The only
  /// intentional no-mount state we keep is `.unmounted`, because the device is
  /// still attached and can be software-mounted again.
  var shouldAutoRemoveWhenUnavailable: Bool {
    state == .disconnected && volumeURL == nil
  }

  /// When a disk was deliberately software-unmounted, FileManager can no longer
  /// see its volume. Verify that the underlying /dev device still exists so a
  /// physically removed USB drive does not leave behind a stale reconnect card.
  func verifyBackingDevicePresence(_ completion: @escaping (Bool) -> Void) {
    guard state == .unmounted else {
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

  func setBackgroundOpacity(_ opacity: CGFloat) {
    let clamped = max(0, min(opacity, 1))
    if abs(materialView.alphaValue - clamped) > 0.001 {
      materialView.alphaValue = clamped
    }
    let shouldHide = clamped <= 0.001
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
    setBackgroundOpacity(layout.opacity)
    dimWhenDesktopInactive = layout.dimWhenDesktopInactive
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
    nameLabel.font = .systemFont(ofSize: layout.nameFontSize, weight: .semibold)
    statusLabel.font = .systemFont(ofSize: layout.statusFontSize, weight: .medium)
    surface.layer?.cornerRadius = layout.cornerRadius
    surface.layer?.cornerCurve = .continuous
    materialView.layer?.cornerRadius = layout.cornerRadius
    materialView.layer?.cornerCurve = .continuous
    let targetSize = NSSize(width: layout.width, height: layout.height)
    enforceManagedSize(targetSize)
    updateMaterialMaskIfNeeded(size: targetSize, cornerRadius: layout.cornerRadius)
    surface.needsLayout = true
    surface.layoutSubtreeIfNeeded()
    updateAppearance()
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
    setDiskIconSymbol("externaldrive.fill")
  }

  private func showSettingsMenu(for event: NSEvent) {
    let menu = NSMenu(title: currentDisplayName.isEmpty ? diskName : currentDisplayName)

    if state == .connected {
      let openItem = NSMenuItem(
        title: "在 Finder 中打开", action: #selector(requestOpenDisk), keyEquivalent: "")
      openItem.target = self
      openItem.image = NSImage(systemSymbolName: "folder", accessibilityDescription: nil)
      menu.addItem(openItem)

      let infoItem = NSMenuItem(
        title: "显示简介", action: #selector(requestShowVolumeInfo), keyEquivalent: "")
      infoItem.target = self
      infoItem.image = NSImage(systemSymbolName: "info.circle", accessibilityDescription: "显示简介")
      menu.addItem(infoItem)
      menu.addItem(.separator())
    }

    switch state {
    case .connected:
      let safeItem = NSMenuItem(
        title: "安全推出", action: #selector(requestSafeUnmount), keyEquivalent: "")
      safeItem.target = self
      safeItem.image = NSImage(systemSymbolName: "eject", accessibilityDescription: nil)
      menu.addItem(safeItem)

      let fullEjectItem = NSMenuItem(
        title: "完全推出…", action: #selector(requestFullEject), keyEquivalent: "")
      fullEjectItem.target = self
      fullEjectItem.image = NSImage(
        systemSymbolName: "eject.fill", accessibilityDescription: "完全推出")
      menu.addItem(fullEjectItem)

    case .unmounted:
      let reconnectItem = NSMenuItem(
        title: "重新连接", action: #selector(requestReconnect), keyEquivalent: "")
      reconnectItem.target = self
      reconnectItem.image = NSImage(
        systemSymbolName: "arrow.clockwise", accessibilityDescription: nil)
      menu.addItem(reconnectItem)

      if reconnectWholeDiskIdentifier != nil {
        let fullEjectItem = NSMenuItem(
          title: "完全推出…", action: #selector(requestFullEject), keyEquivalent: "")
        fullEjectItem.target = self
        fullEjectItem.image = NSImage(
          systemSymbolName: "eject.fill", accessibilityDescription: "完全推出")
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

    let editorItem = NSMenuItem(
      title: "统一组件设置…", action: #selector(requestLayoutEditor), keyEquivalent: "")
    editorItem.target = self
    editorItem.image = NSImage(
      systemSymbolName: "slider.horizontal.3", accessibilityDescription: nil)
    menu.addItem(editorItem)

    if state != .connected {
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

  @objc private func requestOpenDisk() { openDisk() }
  @objc private func requestShowVolumeInfo() { showVolumeInfo() }
  @objc private func requestLayoutEditor() { layoutEditorRequested?() }
  @objc private func requestRemoval() { removalRequested?(self) }
  @objc private func requestReconnect() { reconnectDisk() }
  @objc private func requestSafeUnmount() { safeUnmountForReconnect() }
  @objc private func requestFullEject() { fullyEjectDisk() }

  func refresh(using mountedVolumes: [URL]? = nil) {
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
    state = .connected
    usageRing.isBusy = false
    disconnectedMessage = "未连接"
    currentDisplayName = values.volumeName ?? diskName
    if nameLabel.stringValue != currentDisplayName {
      nameLabel.stringValue = currentDisplayName
    }
    updateDiskIconForCurrentVolume()

    if let uuid = values.volumeUUIDString, !uuid.isEmpty, uuid != lastVolumeUUID {
      lastVolumeUUID = uuid
      UserDefaults.standard.set(uuid, forKey: "disk-widget-volume-uuid-\(diskName)")
    }

    if let total = values.volumeTotalCapacity,
      let available = values.volumeAvailableCapacity,
      total > 0
    {
      let used = max(0, total - available)
      let fraction = min(max(CGFloat(used) / CGFloat(total), 0), 1)
      usageRing.fraction = fraction
      usageRing.centerText = "\(Int((fraction * 100).rounded()))%"
      let compactAvailable = Self.size(available).replacingOccurrences(of: " ", with: "")
      let compactTotal = Self.size(total).replacingOccurrences(of: " ", with: "")
      hoverDetails =
        isReadOnlyVolume
        ? "只读 · 共 \(compactTotal)"
        : "\(compactAvailable) 可用 · 共 \(compactTotal)"
      let readOnlySuffix = isReadOnlyVolume ? " · 只读卷" : ""
      let newToolTip =
        "已用 \(Self.size(used)) · 可用 \(Self.size(available)) · 总容量 \(Self.size(total))\(readOnlySuffix)"
      if usageRing.toolTip != newToolTip {
        usageRing.toolTip = newToolTip
      }
    } else {
      usageRing.fraction = 0
      usageRing.centerText = "—"
      hoverDetails = isReadOnlyVolume ? "只读卷" : "容量信息不可用"
      if usageRing.toolTip != hoverDetails {
        usageRing.toolTip = hoverDetails
      }
    }

    let hasActiveStatusOverride =
      statusOverrideUntil.map { Date() < $0 } ?? false
    if !isReorderActive && !hasActiveStatusOverride && statusLabel.stringValue != hoverDetails {
      statusLabel.stringValue = hoverDetails
    }

    setEjectButtonSymbol("eject.fill", accessibilityDescription: "安全推出")
    let ejectTip = "安全推出 \(currentDisplayName)（可重新连接）"
    if ejectButton.toolTip != ejectTip {
      ejectButton.toolTip = ejectTip
    }
    if !ejectButton.isEnabled { ejectButton.isEnabled = true }
    if ejectButton.isHidden { ejectButton.isHidden = false }
    updateAppearance()
  }

  private func showUnmountedState() {
    volumeURL = nil
    isReadOnlyVolume = false
    statusOverrideUntil = nil
    usageRing.isBusy = false
    usageRing.fraction = 0
    usageRing.centerText = "—"
    hoverDetails = "硬盘已安全卸载"
    usageRing.toolTip = "已安全卸载，可重新连接"
    if !isReorderActive {
      statusLabel.stringValue = "已安全推出 · 可重连"
    }
    diskIcon.contentTintColor = .secondaryLabelColor
    setEjectButtonSymbol("arrow.clockwise.circle.fill", accessibilityDescription: "重新连接")
    ejectButton.toolTip = "重新连接 \(currentDisplayName.isEmpty ? diskName : currentDisplayName)"
    ejectButton.isEnabled = true
    ejectButton.isHidden = false
  }

  private func showDisconnectedState(message: String) {
    volumeURL = nil
    isReadOnlyVolume = false
    statusOverrideUntil = nil
    usageRing.isBusy = false
    usageRing.fraction = 0
    usageRing.centerText = "—"
    hoverDetails = message
    usageRing.toolTip = message
    if !isReorderActive {
      statusLabel.stringValue = message
    }
    diskIcon.contentTintColor = .tertiaryLabelColor
    setEjectButtonSymbol("xmark.circle.fill", accessibilityDescription: "移除卡片")
    ejectButton.toolTip = "移除 \(diskName) 卡片"
    ejectButton.isEnabled = true
    ejectButton.isHidden = false
  }

  private func showBusyState(_ message: String, symbol: String) {
    volumeURL = nil
    statusOverrideUntil = nil
    usageRing.isBusy = true
    usageRing.fraction = 0
    usageRing.centerText = "…"
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
    guard state == .connected, !isReadOnlyVolume, let destinationRoot = volumeURL, !urls.isEmpty
    else {
      return false
    }

    statusOverrideUntil = Date().addingTimeInterval(60)
    statusLabel.stringValue = "正在复制 \(urls.count) 项…"
    let displayName = currentDisplayName

    copyQueue.async { [weak self] in
      var copied = 0
      for source in urls {
        do {
          let destination = Self.uniqueDestination(for: source, in: destinationRoot)
          try FileManager.default.copyItem(at: source, to: destination)
          copied += 1
        } catch {
          NSLog(
            "Could not copy \(source.lastPathComponent) to \(displayName): \(error.localizedDescription)"
          )
        }
      }

      DispatchQueue.main.async { [weak self] in
        guard let self else { return }
        self.isDropTarget = false
        if self.state == .connected {
          self.statusOverrideUntil = Date().addingTimeInterval(2.4)
          self.statusLabel.stringValue = copied > 0 ? "已复制 \(copied) 项" : "复制失败"
          DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
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
    guard state == .connected, let url = volumeURL else { return }

    operationGeneration += 1
    let generation = operationGeneration
    state = .unmounting
    showBusyState("正在安全推出…", symbol: "eject")
    updateAppearance()

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
          self.reconnectVolumeIdentifier = target.volumeIdentifier
          self.reconnectWholeDiskIdentifier = target.wholeDiskIdentifier
          if let uuid = target.volumeUUID {
            self.lastVolumeUUID = uuid
            UserDefaults.standard.set(uuid, forKey: "disk-widget-volume-uuid-\(self.diskName)")
          }
          self.state = .unmounted
          self.showUnmountedState()
          self.updateAppearance()
        }
      } catch {
        NSLog("Could not safely unmount \(self?.diskName ?? "disk"): \(error.localizedDescription)")
        DispatchQueue.main.async { [weak self] in
          guard let self, self.operationGeneration == generation else { return }
          self.state = .disconnected
          self.refresh()
          if self.state == .connected {
            self.statusOverrideUntil = Date().addingTimeInterval(2.5)
            self.statusLabel.stringValue = "推出失败"
          } else {
            self.disconnectedMessage = "推出失败"
            self.showDisconnectedState(message: "推出失败")
          }
        }
      }
    }
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
          if self.state != .connected {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
              self?.refresh()
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
          self.reconnectVolumeIdentifier = nil
          self.reconnectWholeDiskIdentifier = nil
          self.state = .disconnected
          // A fully ejected device no longer exists from the user's point of view,
          // so remove its card instead of leaving a disconnected placeholder.
          self.removalRequested?(self)
        }
      } catch {
        NSLog("Could not fully eject \(self?.diskName ?? "disk"): \(error.localizedDescription)")
        DispatchQueue.main.async { [weak self] in
          guard let self, self.operationGeneration == generation else { return }
          self.state = .disconnected
          self.refresh()
          if self.state == .connected {
            self.statusOverrideUntil = Date().addingTimeInterval(2.5)
            self.statusLabel.stringValue = "完全推出失败"
          } else {
            self.disconnectedMessage = "完全推出失败"
            self.showDisconnectedState(message: self.disconnectedMessage)
          }
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

  private func updateAppearance() {
    guard surface != nil else { return }

    let isDark =
      surface.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
    let shouldDimIdle =
      dimWhenDesktopInactive && !isDesktopActive && !isCardHovered && !isDropTarget
      && !isReorderActive

    let effectiveAccent: NSColor = shouldDimIdle ? .secondaryLabelColor : accentColor
    if state == .connected && diskIcon.contentTintColor != effectiveAccent {
      diskIcon.contentTintColor = effectiveAccent
    }
    usageRing.accentColor = effectiveAccent

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
        let baseAlpha: CGFloat = isDark ? 0.13 : 0.08
        borderColor =
          (isDark ? NSColor.white : NSColor.black).withAlphaComponent(
            materialView.isHidden ? 0 : baseAlpha)
        borderWidth = materialView.isHidden ? 0 : 0.75
        fillColor = .clear
      }

      surface.layer?.borderColor = borderColor.cgColor
      surface.layer?.borderWidth = borderWidth
      surface.layer?.backgroundColor = fillColor.cgColor
    }

    let targetCardAlpha: CGFloat = shouldDimIdle ? 0.78 : 1.0
    if abs(alphaValue - targetCardAlpha) > 0.01 {
      alphaValue = targetCardAlpha
    }

    let targetAlpha: CGFloat
    if state == .connected || state == .unmounted {
      targetAlpha = isCardHovered ? 1.0 : 0.68
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
    super.init(frame: NSRect(x: 0, y: 0, width: 370, height: 38))

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
      widthAnchor.constraint(equalToConstant: 370),
      heightAnchor.constraint(equalToConstant: 38),
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

  init(title: String, control: NSView, height: CGFloat = 34) {
    super.init(frame: .zero)
    titleLabel.stringValue = title
    titleLabel.font = .systemFont(ofSize: 12)
    titleLabel.textColor = .labelColor
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    control.translatesAutoresizingMaskIntoConstraints = false
    addSubview(titleLabel)
    addSubview(control)
    NSLayoutConstraint.activate([
      heightAnchor.constraint(equalToConstant: height),
      widthAnchor.constraint(equalToConstant: 370),
      titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
      titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
      titleLabel.widthAnchor.constraint(equalToConstant: 112),
      control.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 10),
      control.trailingAnchor.constraint(equalTo: trailingAnchor),
      control.centerYAnchor.constraint(equalTo: centerYAnchor),
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
    let available = bounds.insetBy(dx: 16, dy: 10)
    let scale = min(available.width / layout.width, available.height / layout.height, 1.25)
    let cardSize = NSSize(width: layout.width * scale, height: layout.height * scale)
    let card = NSRect(
      x: bounds.midX - cardSize.width / 2,
      y: bounds.midY - cardSize.height / 2,
      width: cardSize.width,
      height: cardSize.height
    )

    let path = NSBezierPath(
      roundedRect: card,
      xRadius: layout.cornerRadius * scale,
      yRadius: layout.cornerRadius * scale
    )
    NSColor.windowBackgroundColor.withAlphaComponent(max(0.20, layout.opacity)).setFill()
    path.fill()
    NSColor.separatorColor.withAlphaComponent(0.7).setStroke()
    path.lineWidth = 1
    path.stroke()

    func sx(_ value: CGFloat) -> CGFloat { value * scale }
    let accent = layout.accentColor

    let centerY = card.midY + sx(layout.iconY)
    let iconRect = NSRect(
      x: card.minX + sx(layout.iconX),
      y: centerY - sx(layout.iconSize) / 2,
      width: sx(layout.iconSize),
      height: sx(layout.iconSize)
    )
    accent.setFill()
    NSBezierPath(roundedRect: iconRect, xRadius: sx(7), yRadius: sx(7)).fill()

    let name = "外置硬盘"
    name.draw(
      at: NSPoint(
        x: card.minX + sx(layout.nameX),
        y: card.midY + sx(layout.nameY) - sx(layout.nameFontSize) / 2
      ),
      withAttributes: [
        .font: NSFont.systemFont(ofSize: max(8, sx(layout.nameFontSize)), weight: .semibold),
        .foregroundColor: NSColor.labelColor,
      ]
    )

    let ringRect = NSRect(
      x: card.maxX - sx(layout.ringX + layout.ringSize),
      y: card.midY + sx(layout.ringY) - sx(layout.ringSize) / 2,
      width: sx(layout.ringSize),
      height: sx(layout.ringSize)
    )
    let ring = NSBezierPath(ovalIn: ringRect)
    ring.lineWidth = max(2, sx(4))
    accent.setStroke()
    ring.stroke()
    let percent = "68%" as NSString
    let percentAttrs: [NSAttributedString.Key: Any] = [
      .font: NSFont.monospacedDigitSystemFont(
        ofSize: max(7, sx(layout.ringTextFontSize)), weight: .semibold),
      .foregroundColor: NSColor.labelColor,
    ]
    let percentSize = percent.size(withAttributes: percentAttrs)
    percent.draw(
      at: NSPoint(
        x: ringRect.midX - percentSize.width / 2, y: ringRect.midY - percentSize.height / 2),
      withAttributes: percentAttrs
    )

    let status = "120GB可用 · 共1TB"
    status.draw(
      at: NSPoint(x: card.minX + sx(layout.statusX), y: card.minY + sx(layout.statusBottom)),
      withAttributes: [
        .font: NSFont.systemFont(ofSize: max(7, sx(layout.statusFontSize)), weight: .medium),
        .foregroundColor: NSColor.secondaryLabelColor,
      ]
    )
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

final class LayoutEditorWindowController: NSWindowController {
  private var layout: WidgetLayout
  private let onChange: (WidgetLayout) -> Void
  private let preview = LayoutPreviewView()
  private var advancedEditor: AdvancedLayoutWindowController?
  private weak var accentPresetControl: NSPopUpButton?
  private weak var customAccentWell: NSColorWell?

  init(layout: WidgetLayout, onChange: @escaping (WidgetLayout) -> Void) {
    self.layout = layout.normalized()
    self.onChange = onChange
    let window = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 438, height: 792),
      styleMask: [.titled, .closable],
      backing: .buffered,
      defer: false
    )
    window.title = "DiskWidget 设置"
    window.isReleasedWhenClosed = false
    super.init(window: window)
    buildInterface()
  }

  required init?(coder: NSCoder) { nil }

  private func buildInterface() {
    guard let content = window?.contentView else { return }
    content.subviews.forEach { $0.removeFromSuperview() }

    let title = NSTextField(labelWithString: "个性化")
    title.font = .systemFont(ofSize: 17, weight: .semibold)
    let hint = NSTextField(labelWithString: "所有磁盘共用一套设置")
    hint.font = .systemFont(ofSize: 11)
    hint.textColor = .secondaryLabelColor

    preview.layout = layout
    preview.translatesAutoresizingMaskIntoConstraints = false

    let stack = NSStackView()
    stack.orientation = .vertical
    stack.alignment = .leading
    stack.spacing = 3
    stack.translatesAutoresizingMaskIntoConstraints = false

    typealias Row = (
      String, CGFloat, CGFloat, CGFloat, (Double) -> String, (inout WidgetLayout, CGFloat) -> Void
    )
    let rows: [Row] = [
      ("卡片宽度", 180, 360, layout.width, { "\(Int($0)) pt" }, { $0.width = $1 }),
      ("卡片高度", 72, 120, layout.height, { "\(Int($0)) pt" }, { $0.height = $1 }),
      ("卡片间距", 4, 40, layout.stackSpacing, { "\(Int($0)) pt" }, { $0.stackSpacing = $1 }),
      ("玻璃背景", 0, 1, layout.opacity, { "\(Int($0 * 100))%" }, { $0.opacity = $1 }),
      ("圆角", 8, 28, layout.cornerRadius, { "\(Int($0)) pt" }, { $0.cornerRadius = $1 }),
      ("名称字号", 10, 18, layout.nameFontSize, { "\(Int($0)) pt" }, { $0.nameFontSize = $1 }),
      ("容量字号", 8, 13, layout.statusFontSize, { "\(Int($0)) pt" }, { $0.statusFontSize = $1 }),
      ("圆环数字", 7, 16, layout.ringTextFontSize, { "\(Int($0)) pt" }, { $0.ringTextFontSize = $1 }),
    ]

    for row in rows {
      let control = LayoutSliderView(
        title: row.0, value: row.3, min: row.1, max: row.2, formatter: row.4)
      control.onChange = { [weak self] value in
        guard let self else { return }
        row.5(&self.layout, value)
        self.commitLayout()
      }
      stack.addArrangedSubview(control)
    }

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
    presetControl.widthAnchor.constraint(equalToConstant: 154).isActive = true
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
    stack.addArrangedSubview(SimpleSettingRow(title: "主题色", control: colorControls))

    let installerMode = NSSegmentedControl(
      labels: ["小组件", "Finder 桌面"],
      trackingMode: .selectOne,
      target: self,
      action: #selector(installerModeChanged(_:))
    )
    installerMode.selectedSegment = layout.showDiskImagesInWidget ? 0 : 1
    installerMode.toolTip = "DMG/ISO 等安装镜像。Finder 桌面模式不会修改 Finder 自身的桌面显示偏好。"
    stack.addArrangedSubview(SimpleSettingRow(title: "安装镜像", control: installerMode))

    let dimToggle = NSButton(
      checkboxWithTitle: "使用其他应用时自动柔和淡化",
      target: self,
      action: #selector(desktopDimmingChanged(_:))
    )
    dimToggle.state = layout.dimWhenDesktopInactive ? .on : .off
    dimToggle.toolTip = "类似 macOS 原生桌面小组件：专注使用其他窗口时柔和降噪，鼠标悬停或回到桌面时恢复鲜艳。"
    stack.addArrangedSubview(SimpleSettingRow(title: "桌面融合", control: dimToggle))

    let menuBarToggle = NSButton(
      checkboxWithTitle: "显示",
      target: self,
      action: #selector(menuBarVisibilityChanged(_:))
    )
    menuBarToggle.state = layout.showMenuBarItem ? .on : .off
    menuBarToggle.toolTip = "关闭后仍可通过磁盘卡片右键进入设置；再次启动 DiskWidget 也可重新打开设置。"
    stack.addArrangedSubview(SimpleSettingRow(title: "菜单栏图标", control: menuBarToggle))

    let advancedButton = NSButton(
      title: "高级设置…", target: self, action: #selector(openAdvancedSettings))
    advancedButton.bezelStyle = .rounded
    advancedButton.image = NSImage(
      systemSymbolName: "slider.horizontal.3", accessibilityDescription: nil)
    advancedButton.imagePosition = .imageLeading
    advancedButton.toolTip = "精细调整图标、文字、容量环和操作按钮的位置与大小"
    stack.addArrangedSubview(SimpleSettingRow(title: "精细布局", control: advancedButton))

    let shortcutIcon = NSImageView()
    shortcutIcon.image = NSImage(
      systemSymbolName: "arrow.up.arrow.down", accessibilityDescription: nil)
    shortcutIcon.contentTintColor = .secondaryLabelColor
    shortcutIcon.symbolConfiguration = NSImage.SymbolConfiguration(pointSize: 11, weight: .medium)
    shortcutIcon.translatesAutoresizingMaskIntoConstraints = false
    shortcutIcon.widthAnchor.constraint(equalToConstant: 14).isActive = true
    shortcutIcon.heightAnchor.constraint(equalToConstant: 14).isActive = true

    let shortcutLabel = NSTextField(labelWithString: "⌥ 拖动卡片调整顺序")
    shortcutLabel.font = .systemFont(ofSize: 11)
    shortcutLabel.textColor = .secondaryLabelColor

    let shortcutHint = NSStackView(views: [shortcutIcon, shortcutLabel])
    shortcutHint.orientation = .horizontal
    shortcutHint.alignment = .centerY
    shortcutHint.spacing = 6
    shortcutHint.toolTip = "普通拖动移动整组；按住 Option 拖动单张卡片可以调整顺序。"
    shortcutHint.translatesAutoresizingMaskIntoConstraints = false

    let reset = NSButton(title: "恢复默认", target: self, action: #selector(resetLayout))
    reset.bezelStyle = .rounded
    let done = NSButton(title: "完成", target: self, action: #selector(closeEditor))
    done.bezelStyle = .rounded
    done.keyEquivalent = "\r"

    [title, hint, preview, stack, shortcutHint, reset, done].forEach {
      $0.translatesAutoresizingMaskIntoConstraints = false
      content.addSubview($0)
    }

    NSLayoutConstraint.activate([
      title.topAnchor.constraint(equalTo: content.topAnchor, constant: 20),
      title.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 24),
      hint.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 4),
      hint.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 24),
      hint.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -24),

      preview.topAnchor.constraint(equalTo: hint.bottomAnchor, constant: 10),
      preview.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 20),
      preview.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -20),
      preview.heightAnchor.constraint(equalToConstant: 108),

      stack.topAnchor.constraint(equalTo: preview.bottomAnchor, constant: 10),
      stack.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 34),
      stack.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -34),

      shortcutHint.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 9),
      shortcutHint.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 34),

      reset.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 24),
      reset.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -18),
      done.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -24),
      done.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -18),
      shortcutHint.bottomAnchor.constraint(lessThanOrEqualTo: reset.topAnchor, constant: -10),
    ])
  }

  private struct AccentPreset {
    let name: String
    let color: NSColor
  }

  /// Restrained, familiar colors chosen to stay readable on macOS materials
  /// instead of using a bright system-color rainbow.
  private var accentPresets: [AccentPreset] {
    [
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

  @objc private func desktopDimmingChanged(_ sender: NSButton) {
    layout.dimWhenDesktopInactive = sender.state == .on
    commitLayout()
  }

  @objc private func menuBarVisibilityChanged(_ sender: NSButton) {
    layout.showMenuBarItem = sender.state == .on
    commitLayout()
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

  @objc private func closeEditor() { window?.performClose(nil) }

  @objc private func resetLayout() {
    layout = .factoryDefaults
    layout.save()
    onChange(layout)
    buildInterface()
  }

  func present() {
    if window?.isVisible != true {
      window?.center()
    }
    showWindow(nil)
    NSApp.activate(ignoringOtherApps: true)
    window?.makeKeyAndOrderFront(nil)
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

final class AppDelegate: NSObject, NSApplicationDelegate {
  private var panels: [DiskPanel] = []
  private var timer: Timer?
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

  func applicationDidFinishLaunching(_ notification: Notification) {
    NSApp.setActivationPolicy(.accessory)
    updateDesktopActiveState()
    updateStatusItemVisibility()
    scheduleDiskImageMountRefresh(force: true)
    refresh()

    // Recovery path: when both the menu-bar icon and all disk cards are absent,
    // a cold launch must not leave the app completely invisible.
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
      guard let self else { return }
      if !self.layout.showMenuBarItem && self.panels.isEmpty {
        self.openLayoutEditor()
      }
    }

    let timer = Timer(timeInterval: 5, repeats: true) { [weak self] _ in
      self?.refresh()
    }
    self.timer = timer
    RunLoop.main.add(timer, forMode: .common)

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
  }

  private func setupStatusItem() {
    guard statusItem == nil else { return }
    let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    item.button?.image = NSImage(
      systemSymbolName: "externaldrive", accessibilityDescription: "DiskWidget")
    item.button?.toolTip = "DiskWidget"

    let menu = NSMenu(title: "DiskWidget")
    let refreshItem = NSMenuItem(title: "刷新", action: #selector(refreshFromMenu), keyEquivalent: "")
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
    item.menu = menu
    statusItem = item
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
    if !layout.showMenuBarItem || panels.isEmpty {
      openLayoutEditor()
    }
    return true
  }

  @objc private func refreshFromMenu() {
    scheduleDiskImageMountRefresh(force: true)
    refresh()
  }
  @objc private func arrangeFromMenu() { arrangePanels() }
  @objc private func settingsFromMenu() { openLayoutEditor() }
  @objc private func quitFromMenu() { NSApp.terminate(nil) }

  func applicationWillTerminate(_ notification: Notification) {
    timer?.invalidate()
    screenLayoutWorkItem?.cancel()
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
  }

  @objc private func activeAppChanged(_ notification: Notification) {
    updateDesktopActiveState()
  }

  private func updateDesktopActiveState() {
    let frontBundle = NSWorkspace.shared.frontmostApplication?.bundleIdentifier
    let active = (frontBundle == "com.apple.finder" || frontBundle == Bundle.main.bundleIdentifier)
    isDesktopActive = active
    panels.forEach { $0.setDesktopActive(active) }
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
  }

  private func configurePanel(_ panel: DiskPanel) {
    UserDefaults.standard.removeObject(forKey: "disk-widget-position-\(panel.diskName)")
    panel.removalRequested = { [weak self] panel in self?.removePanel(panel) }
    panel.layoutEditorRequested = { [weak self] in self?.openLayoutEditor() }
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
    if !panels.isEmpty { relayoutPanels(anchor: anchor) }
  }

  private func removePanel(_ panel: DiskPanel) {
    let key = panel.orderingKey
    removePanelsFromDesktop([panel])
    UserDefaults.standard.removeObject(forKey: "disk-widget-volume-uuid-\(panel.diskName)")
    let order = savedPanelOrder().filter { $0 != key }
    UserDefaults.standard.set(order, forKey: "disk-widget-panel-order")
  }

  private func applyLayout(_ newLayout: WidgetLayout) {
    let anchor = preferredGroupAnchor()
    let oldDiskImageSetting = layout.showDiskImagesInWidget
    layout = newLayout.normalized()
    layout.save()
    updateStatusItemVisibility()
    panels.forEach { $0.applyLayout(layout) }
    relayoutPanels(anchor: anchor)
    if oldDiskImageSetting != layout.showDiskImagesInWidget {
      scheduleDiskImageMountRefresh(force: true)
      refresh()
    }
  }

  private func openLayoutEditor() {
    if layoutEditor == nil {
      layoutEditor = LayoutEditorWindowController(layout: layout) { [weak self] newLayout in
        self?.applyLayout(newLayout)
      }
    }
    layoutEditor?.present()
  }

  private func arrangePanels() {
    guard !panels.isEmpty else { return }
    let anchor = clampedGroupAnchor(currentGroupAnchor() ?? preferredGroupAnchor())
    saveGroupAnchor(anchor)
    relayoutPanels(anchor: anchor, animated: true)
  }

  // Normal drag moves the whole widget group.
  private func beginGroupDrag(from source: DiskPanel) {
    guard panels.contains(where: { $0 === source }) else { return }
    groupDragStartOrigins = Dictionary(
      uniqueKeysWithValues: panels.map { (ObjectIdentifier($0), $0.frame.origin) })
  }

  private func updateGroupDrag(from source: DiskPanel, delta: NSPoint) {
    guard panels.contains(where: { $0 === source }), !groupDragStartOrigins.isEmpty else { return }
    for panel in panels {
      guard let origin = groupDragStartOrigins[ObjectIdentifier(panel)] else { continue }
      panel.setManagedPosition(NSPoint(x: origin.x + delta.x, y: origin.y + delta.y))
    }
  }

  private func endGroupDrag(from source: DiskPanel) {
    guard panels.contains(where: { $0 === source }) else {
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
    guard let first = panels.first else { return nil }
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
    guard !panels.isEmpty else { return }
    let clamped = clampedGroupAnchor(anchor)
    // Only an explicit drag/arrange replaces a saved position. A temporary
    // fallback while a screen is unavailable must not overwrite it.
    if savedGroupAnchor() == nil && !NSScreen.screens.isEmpty {
      saveGroupAnchor(clamped)
    }
    var cursorY = clamped.y
    let managedSize = NSSize(width: layout.width.rounded(), height: layout.height.rounded())
    let spacing = layout.stackSpacing.rounded()
    for panel in panels {
      cursorY -= managedSize.height
      panel.setManagedFrame(
        NSRect(
          x: clamped.x,
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
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
