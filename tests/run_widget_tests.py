#!/usr/bin/env python3
"""Verify WidgetKit shared snapshot models, command queue, and DiskPanel widget bridge."""
from pathlib import Path
import subprocess
import tempfile

root = Path(__file__).resolve().parents[1]
source = (root / "DiskWidget.swift").read_text()
shared_source = (root / "Shared/DiskWidgetSnapshot.swift").read_text()
entry = "let app = NSApplication.shared\nlet delegate = AppDelegate()"
assert source.count(entry) == 1
source = source.split(entry)[0]
source = source.replace("UserDefaults.standard", "isolatedDefaults")

test_body = '''
import Foundation

func assertTrue(_ condition: Bool, _ message: String) {
  if !condition {
    fputs("FAIL: \\(message)\\n", stderr)
    exit(1)
  }
  print("PASS: \\(message)")
}

// 1. Snapshot Codable round-trip and totals
let sample = DiskWidgetSnapshot(
  generatedAt: Date(timeIntervalSince1970: 1_700_000_000),
  accentColor: DiskSnapshotColor(red: 0.1, green: 0.5, blue: 0.9),
  ringShowsAvailablePercentage: true,
  showDiskImages: false,
  disks: [
    DiskSnapshotItem(
      id: "uuid:111",
      name: "WorkSSD",
      displayName: "工作盘",
      volumePath: "/Volumes/WorkSSD",
      volumeUUID: "111",
      iconSymbol: "externaldrive.fill",
      state: .connected,
      statusText: "250GB 可用 · 共 1TB",
      formatDescription: "APFS",
      isReadOnly: false,
      isDiskImage: false,
      usedBytes: 750_000_000_000,
      availableBytes: 250_000_000_000,
      totalBytes: 1_000_000_000_000
    ),
    DiskSnapshotItem(
      id: "uuid:222",
      name: "Backup",
      displayName: "Backup",
      volumePath: nil,
      volumeUUID: "222",
      iconSymbol: "externaldrive.badge.timemachine",
      state: .unmounted,
      statusText: "已安全推出 · 可重连",
      formatDescription: "APFS",
      isReadOnly: false,
      isDiskImage: false,
      usedBytes: 0,
      availableBytes: 0,
      totalBytes: 0
    ),
  ]
)

let encoder = JSONEncoder()
encoder.dateEncodingStrategy = .iso8601
let decoder = JSONDecoder()
decoder.dateDecodingStrategy = .iso8601
let encoded = try! encoder.encode(sample)
let decoded = try! decoder.decode(DiskWidgetSnapshot.self, from: encoded)
assertTrue(decoded == sample, "DiskWidgetSnapshot survives ISO8601 JSON round-trip")
assertTrue(decoded.connectedCount == 1, "connectedCount excludes unmounted drives")
assertTrue(decoded.totalBytesSum == 1_000_000_000_000, "totalBytesSum sums connected volumes")
assertTrue(decoded.availableBytesSum == 250_000_000_000, "availableBytesSum sums connected volumes")

let ssd = decoded.disks[0]
assertTrue(ssd.displayedPercentText(showsAvailable: false) == "75%", "used percentage formats as 75%")
assertTrue(ssd.displayedPercentText(showsAvailable: true) == "25%", "available percentage formats as 25%")
assertTrue(decoded.disks[1].displayedPercentText(showsAvailable: false) == "—", "unmounted disk shows dash")

// 2. Layout showDesktopCards persistence
var layout = WidgetLayout(defaults: isolatedDefaults)
assertTrue(layout.showDesktopCards == true, "showDesktopCards defaults to true")
layout.showDesktopCards = false
layout.save(to: isolatedDefaults)
let reloadedLayout = WidgetLayout(defaults: isolatedDefaults)
assertTrue(reloadedLayout.showDesktopCards == false, "showDesktopCards persists to UserDefaults")

// 3. DiskPanel export + suppressed desktop window mode
_ = NSApplication.shared
let panel = DiskPanel(
  diskName: "TestDrive",
  initialVolumeUUID: "TEST-UUID-1",
  isDiskImage: false,
  initialLayout: reloadedLayout
)
panel.applyLayout(reloadedLayout)
panel.reassertDesktopLevel()
assertTrue(!panel.isVisible, "panel stays hidden when showDesktopCards is false")
let exported = panel.makeSnapshotItem()
assertTrue(exported.id == "uuid:TEST-UUID-1", "panel snapshot item uses UUID orderingKey")
assertTrue(exported.displayName == "TestDrive", "panel snapshot item exports display name")

print("All WidgetKit bridge tests passed.")
'''

prefix = '''import AppKit
let testSuite = "local.diskwidget.widgettests." + UUID().uuidString
let isolatedDefaults = UserDefaults(suiteName: testSuite)!
'''

with tempfile.TemporaryDirectory(prefix="diskwidget-widgettests-") as directory:
    main = Path(directory) / "main.swift"
    shared = Path(directory) / "DiskWidgetSnapshot.swift"
    binary = Path(directory) / "widget_tests"
    shared.write_text(shared_source)
    main.write_text(prefix + source + test_body)
    subprocess.run(
        ["swiftc", str(main), str(shared), "-o", str(binary), "-framework", "AppKit", "-framework", "WidgetKit"],
        check=True,
    )
    subprocess.run([str(binary)], check=True)
