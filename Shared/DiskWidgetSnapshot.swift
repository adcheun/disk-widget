import Foundation

enum DiskWidgetSharedConfig {
  static let appGroupIdentifier = "874DMUC5RW.local.adc.disk-widget"
  static let fallbackAppGroupIdentifier = "group.local.adc.disk-widget"
  static let dashboardWidgetKind = "local.adc.disk-widget.dashboard"
  static let singleDiskWidgetKind = "local.adc.disk-widget.single"
  static let snapshotFileName = "snapshot.json"
  static let commandFileName = "command.json"
  static let commandDarwinNotification = "local.adc.disk-widget.command"
  static let urlScheme = "diskwidget"
}

enum DiskSnapshotState: String, Codable, Equatable {
  case connected
  case unmounting
  case unmounted
  case reconnecting
  case fullyEjecting
  case disconnected
  case copying

  var isBusy: Bool {
    switch self {
    case .unmounting, .reconnecting, .fullyEjecting, .copying:
      return true
    case .connected, .unmounted, .disconnected:
      return false
    }
  }
}

struct DiskSnapshotColor: Codable, Equatable {
  var red: Double
  var green: Double
  var blue: Double
}

struct DiskSnapshotItem: Codable, Equatable, Identifiable {
  var id: String
  var name: String
  var displayName: String
  var volumePath: String?
  var volumeUUID: String?
  var iconSymbol: String
  var state: DiskSnapshotState
  var statusText: String
  var formatDescription: String?
  var isReadOnly: Bool
  var isDiskImage: Bool
  var usedBytes: Int64
  var availableBytes: Int64
  var totalBytes: Int64

  var usedFraction: Double {
    guard totalBytes > 0 else { return 0 }
    return min(max(Double(usedBytes) / Double(totalBytes), 0), 1)
  }

  var availableFraction: Double {
    guard totalBytes > 0 else { return 0 }
    return min(max(Double(availableBytes) / Double(totalBytes), 0), 1)
  }

  func displayedFraction(showsAvailable: Bool) -> Double {
    showsAvailable ? availableFraction : usedFraction
  }

  func displayedPercentText(showsAvailable: Bool) -> String {
    guard state == .connected, totalBytes > 0 else {
      return state.isBusy ? "…" : "—"
    }
    let pct = Int((displayedFraction(showsAvailable: showsAvailable) * 100).rounded())
    return "\(pct)%"
  }
}

struct DiskWidgetSnapshot: Codable, Equatable {
  var schemaVersion: Int = 1
  var generatedAt: Date
  var accentColor: DiskSnapshotColor
  var ringShowsAvailablePercentage: Bool
  var showDiskImages: Bool
  var disks: [DiskSnapshotItem]

  var connectedCount: Int {
    disks.filter { $0.state == .connected }.count
  }

  var totalBytesSum: Int64 {
    disks.filter { $0.state == .connected }.reduce(0) { $0 + max(0, $1.totalBytes) }
  }

  var availableBytesSum: Int64 {
    disks.filter { $0.state == .connected }.reduce(0) { $0 + max(0, $1.availableBytes) }
  }

  var usedBytesSum: Int64 {
    disks.filter { $0.state == .connected }.reduce(0) { $0 + max(0, $1.usedBytes) }
  }
}

enum DiskWidgetCommandKind: String, Codable, Equatable {
  case refresh
  case toggleMetricMode
  case openDisk
  case ejectDisk
  case reconnectDisk
  case ejectAll
  case openSettings
}

struct DiskWidgetCommand: Codable, Equatable {
  var id: String
  var kind: DiskWidgetCommandKind
  var diskID: String?
  var createdAt: Date

  init(kind: DiskWidgetCommandKind, diskID: String? = nil, createdAt: Date = Date()) {
    self.id = UUID().uuidString
    self.kind = kind
    self.diskID = diskID
    self.createdAt = createdAt
  }
}

enum DiskWidgetSharedStore {
  static func containerURL() -> URL? {
    let fm = FileManager.default
    if let primary = fm.containerURL(
      forSecurityApplicationGroupIdentifier: DiskWidgetSharedConfig.appGroupIdentifier)
    {
      return primary
    }
    if let secondary = fm.containerURL(
      forSecurityApplicationGroupIdentifier: DiskWidgetSharedConfig.fallbackAppGroupIdentifier)
    {
      return secondary
    }
    return nil
  }

  static func snapshotURL() -> URL? {
    containerURL()?.appendingPathComponent(DiskWidgetSharedConfig.snapshotFileName)
  }

  static func commandsDirectoryURL() -> URL? {
    containerURL()?.appendingPathComponent("commands", isDirectory: true)
  }

  static func writeSnapshot(_ snapshot: DiskWidgetSnapshot) {
    guard let url = snapshotURL() else { return }
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    encoder.outputFormatting = [.sortedKeys]
    guard let data = try? encoder.encode(snapshot) else { return }
    try? FileManager.default.createDirectory(
      at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    try? data.write(to: url, options: .atomic)
  }

  static func readSnapshot() -> DiskWidgetSnapshot? {
    guard let url = snapshotURL(),
      let data = try? Data(contentsOf: url)
    else { return nil }
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return try? decoder.decode(DiskWidgetSnapshot.self, from: data)
  }

  static func enqueueCommand(_ command: DiskWidgetCommand) {
    guard let dir = commandsDirectoryURL() else { return }
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    guard let data = try? encoder.encode(command) else { return }
    try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    let stamp = Int64(command.createdAt.timeIntervalSince1970 * 1000)
    let url = dir.appendingPathComponent("\(stamp)-\(command.id).json")
    try? data.write(to: url, options: .atomic)
  }

  static func drainCommands() -> [DiskWidgetCommand] {
    guard let dir = commandsDirectoryURL(),
      let files = try? FileManager.default.contentsOfDirectory(
        at: dir, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
    else { return [] }
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    var commands: [DiskWidgetCommand] = []
    for file in files.sorted(by: { $0.lastPathComponent < $1.lastPathComponent }) {
      defer { try? FileManager.default.removeItem(at: file) }
      guard let data = try? Data(contentsOf: file),
        let cmd = try? decoder.decode(DiskWidgetCommand.self, from: data)
      else { continue }
      commands.append(cmd)
    }
    return commands
  }

  static func postCommandNotification() {
    let center = CFNotificationCenterGetDarwinNotifyCenter()
    let name = CFNotificationName(DiskWidgetSharedConfig.commandDarwinNotification as CFString)
    CFNotificationCenterPostNotification(center, name, nil, nil, true)
  }
}
