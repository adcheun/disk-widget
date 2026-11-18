// Compiled in the same file as production code by run_window_regressions.py.
// Tests use an isolated defaults suite; no personal volumes or settings.
func expect(_ value: @autoclosure () -> Bool, _ message: String) {
  guard value() else { fatalError("FAIL: \(message)") }
  print("PASS: \(message)")
}

extension AppDelegate {
  func runPlacementRegressions() {
    let defaultLayout = WidgetLayout.factoryDefaults
    expect(defaultLayout.width == 236 && defaultLayout.height == 90, "default card size parameters remain unchanged")
    expect(defaultLayout.iconX == 16 && defaultLayout.iconY == 8 && defaultLayout.iconSize == 30, "default icon parameters remain unchanged")
    expect(defaultLayout.nameX == 56 && defaultLayout.nameY == 11 && defaultLayout.nameFontSize == 13, "default name parameters remain unchanged")
    expect(defaultLayout.statusX == 56 && defaultLayout.statusBottom == 15 && defaultLayout.statusFontSize == 10, "default status parameters remain unchanged")
    expect(defaultLayout.ringX == 12 && defaultLayout.ringY == 7 && defaultLayout.ringSize == 44 && defaultLayout.ringTextFontSize == 9, "default ring parameters remain unchanged")
    expect(defaultLayout.ejectX == 64 && defaultLayout.ejectY == 7 && defaultLayout.ejectSize == 22, "default eject button parameters remain unchanged")
    expect(defaultLayout.cornerRadius == 18 && defaultLayout.stackSpacing == 12 && abs(defaultLayout.opacity - 0.70) < 0.001, "default corner radius, spacing, and opacity remain unchanged")

    let first = DiskPanel(diskName: "Test A", initialVolumeUUID: "UUID-A", initialLayout: layout)
    let second = DiskPanel(diskName: "Test B", initialVolumeUUID: "UUID-B", initialLayout: layout)
    panels = [first, second]
    defer { panels.forEach { $0.orderOut(nil) } }

    expect(first.collectionBehavior.contains(.stationary), "cards stay pinned on desktop click")
    expect(first.collectionBehavior.contains(.canJoinAllSpaces), "cards return on every ordinary desktop")
    expect(first.collectionBehavior.contains(.ignoresCycle), "cards do not enter window cycle")
    expect(first.collectionBehavior.contains(.fullScreenNone), "cards stay on desktop spaces and do not join fullscreen app spaces")
    expect(first.level.rawValue < NSWindow.Level.normal.rawValue, "cards remain below normal windows")
    expect(!first.canBecomeKey && !first.canBecomeMain, "cards never steal key or main window focus")
    expect(first.contentView?.layer?.cornerCurve == .continuous, "cards use native continuous squircle corners")

    let offMainFrame = NSRect(x: -900, y: 1200, width: 236, height: 90)
    expect(
      first.constrainFrameRect(offMainFrame, to: NSScreen.main) == offMainFrame,
      "AppKit frame constraint does not pull secondary-screen cards to main screen"
    )

    expect(
      !first.representsVolume(name: "Test A", uuid: "UUID-OTHER"),
      "same-named volumes with distinct UUIDs are not conflated"
    )
    expect(
      first.representsVolume(name: "Renamed A", uuid: "UUID-A"),
      "renamed volume with matching UUID stays bound to its card"
    )

    let placeholder = DiskPanel(diskName: "Preview", isPreviewPlaceholder: true, initialLayout: layout)
    expect(
      !placeholder.representsVolume(name: "Preview", uuid: nil),
      "preview placeholder never matches real mounted volumes"
    )
    placeholder.orderOut(nil)

    for screen in NSScreen.screens {
      let point = NSPoint(x: screen.visibleFrame.minX + 100, y: screen.visibleFrame.maxY - 100)
      expect(clampedGroupAnchor(point) == point, "valid position on connected display stays fixed")
    }

    let intended = clampedGroupAnchor(NSPoint(x: 400, y: 850))
    saveGroupAnchor(intended)
    relayoutPanels(anchor: preferredGroupAnchor())
    expect(currentGroupAnchor() == intended, "initial layout restores saved position")

    // Simulate AppKit moving windows during a display change, followed by the
    // app's ordinary relayout path. Live window frames must not become intent.
    first.setManagedPosition(NSPoint(x: 10, y: 100))
    relayoutPanels(anchor: preferredGroupAnchor())
    expect(currentGroupAnchor() == intended, "temporary system movement is not adopted")

    let unavailable = NSPoint(x: 99_999, y: 99_999)
    saveGroupAnchor(unavailable)
    relayoutPanels(anchor: preferredGroupAnchor())
    expect(currentGroupAnchor() != unavailable, "unavailable display gets an on-screen fallback")
    expect(savedGroupAnchor() == unavailable, "fallback never overwrites preferred position")

    saveGroupAnchor(intended)
    relayoutPanels(anchor: preferredGroupAnchor())
    beginGroupDrag(from: first)
    updateGroupDrag(from: first, delta: NSPoint(x: 30, y: -20))
    endGroupDrag(from: first)
    let dragged = NSPoint(x: intended.x + 30, y: intended.y - 20)
    expect(savedGroupAnchor() == dragged, "explicit drag saves new position")
    expect(second.frame.minX == first.frame.minX, "group drag keeps cards aligned")

    // Verify that adding a new unranked drive when saved order exists appends at the end
    // without jumping ahead of existing unranked cards.
    isolatedDefaults.set(["uuid:LEGACY"], forKey: "disk-widget-panel-order")
    let third = DiskPanel(diskName: "Alpha Drive", initialVolumeUUID: "UUID-ALPHA", initialLayout: layout)
    panels = [first, second, third]
    applySavedPanelOrder()
    expect(
      panels[0] === first && panels[1] === second && panels[2] === third,
      "newly connected unranked drive does not displace existing cards"
    )
    panels = [first, second]

    removePanelsFromDesktop([first])
    expect(currentGroupAnchor() == dragged, "removing first drive does not shift group anchor")
  }
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let primary = NSRect(x: 0, y: 0, width: 1920, height: 1050)
let secondary = NSRect(x: -1080, y: -400, width: 1080, height: 1890)
let cardSize = NSSize(width: 260, height: 76)
let secondaryAnchor = NSPoint(x: -900, y: 1200)
for frames in [[primary, secondary], [secondary, primary]] {
  expect(
    DesktopPlacement.clampedAnchor(secondaryAnchor, cardSize: cardSize, visibleFrames: frames)
      == secondaryAnchor,
    "display enumeration/focus cannot move a secondary-screen card")
}
let fallback = DesktopPlacement.clampedAnchor(
  secondaryAnchor, cardSize: cardSize, visibleFrames: [primary])
expect(fallback != secondaryAnchor, "disconnected screen uses remaining display")
expect(
  DesktopPlacement.clampedAnchor(secondaryAnchor, cardSize: cardSize, visibleFrames: [primary, secondary])
    == secondaryAnchor,
  "reconnected screen restores original coordinate")
expect(
  DesktopPlacement.clampedAnchor(secondaryAnchor, cardSize: cardSize, visibleFrames: []) == secondaryAnchor,
  "transient empty screen list preserves anchor")
AppDelegate().runPlacementRegressions()
isolatedDefaults.removePersistentDomain(forName: testSuite)
print("All window placement regressions passed.")
