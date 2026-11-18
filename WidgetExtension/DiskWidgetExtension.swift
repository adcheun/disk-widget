import AppIntents
import SwiftUI
import WidgetKit

// MARK: - AppIntents

enum WidgetMetricOverride: String, AppEnum {
  case followApp
  case used
  case available

  static var typeDisplayRepresentation: TypeDisplayRepresentation {
    "显示比例"
  }

  static var caseDisplayRepresentations: [WidgetMetricOverride: DisplayRepresentation] {
    [
      .followApp: "跟随主应用设置",
      .used: "已用空间比例",
      .available: "剩余空间比例",
    ]
  }
}

struct DiskChoiceEntity: AppEntity, Identifiable, Hashable {
  static var typeDisplayRepresentation: TypeDisplayRepresentation {
    "外置磁盘"
  }

  static var defaultQuery = DiskChoiceQuery()

  var id: String
  var title: String
  var subtitle: String

  var displayRepresentation: DisplayRepresentation {
    DisplayRepresentation(title: "\(title)", subtitle: subtitle.isEmpty ? nil : "\(subtitle)")
  }

  static let auto = DiskChoiceEntity(
    id: "__auto__",
    title: "自动（首个已连接磁盘）",
    subtitle: "随插拔自动切换"
  )
}

struct DiskChoiceQuery: EntityQuery {
  func entities(for identifiers: [String]) async throws -> [DiskChoiceEntity] {
    let all = availableChoices()
    let map = Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })
    return identifiers.compactMap { map[$0] }
  }

  func suggestedEntities() async throws -> [DiskChoiceEntity] {
    availableChoices()
  }

  func defaultResult() async -> DiskChoiceEntity? {
    .auto
  }

  private func availableChoices() -> [DiskChoiceEntity] {
    var list: [DiskChoiceEntity] = [.auto]
    if let snapshot = WidgetSnapshotFallback.resolveSnapshot() {
      for disk in snapshot.disks {
        list.append(
          DiskChoiceEntity(
            id: disk.id,
            title: disk.displayName,
            subtitle: disk.statusText
          )
        )
      }
    }
    return list
  }
}

struct DashboardConfigIntent: WidgetConfigurationIntent {
  static var title: LocalizedStringResource = "外置磁盘总览"
  static var description = IntentDescription("查看全部已连接外置磁盘的容量、状态与快捷操作。")

  @Parameter(title: "百分比显示", default: .followApp)
  var metricMode: WidgetMetricOverride
}

struct SingleDiskConfigIntent: WidgetConfigurationIntent {
  static var title: LocalizedStringResource = "指定磁盘卡片"
  static var description = IntentDescription("持续追踪某一个指定外置磁盘或自动显示首个磁盘。")

  @Parameter(title: "目标磁盘")
  var disk: DiskChoiceEntity?

  @Parameter(title: "百分比显示", default: .followApp)
  var metricMode: WidgetMetricOverride
}

struct RefreshDisksIntent: AppIntent {
  static var title: LocalizedStringResource = "刷新磁盘状态"
  static var openAppWhenRun: Bool = false

  func perform() async throws -> some IntentResult {
    DiskWidgetSharedStore.enqueueCommand(DiskWidgetCommand(kind: .refresh))
    DiskWidgetSharedStore.postCommandNotification()
    return .result()
  }
}

struct ToggleDiskMetricIntent: AppIntent {
  static var title: LocalizedStringResource = "切换已用或剩余比例"
  static var openAppWhenRun: Bool = false

  func perform() async throws -> some IntentResult {
    if var snapshot = DiskWidgetSharedStore.readSnapshot() {
      snapshot.ringShowsAvailablePercentage.toggle()
      snapshot.generatedAt = Date()
      DiskWidgetSharedStore.writeSnapshot(snapshot)
    }
    DiskWidgetSharedStore.enqueueCommand(DiskWidgetCommand(kind: .toggleMetricMode))
    DiskWidgetSharedStore.postCommandNotification()
    WidgetCenter.shared.reloadAllTimelines()
    return .result()
  }
}

struct EjectDiskIntent: AppIntent {
  static var title: LocalizedStringResource = "安全推出磁盘"
  static var openAppWhenRun: Bool = false

  @Parameter(title: "磁盘 ID")
  var diskID: String

  init() {
    self.diskID = ""
  }

  init(diskID: String) {
    self.diskID = diskID
  }

  func perform() async throws -> some IntentResult {
    guard !diskID.isEmpty else { return .result() }
    if var snapshot = DiskWidgetSharedStore.readSnapshot(),
      let index = snapshot.disks.firstIndex(where: { $0.id == diskID })
    {
      snapshot.disks[index].state = .unmounting
      snapshot.disks[index].statusText = "正在安全推出…"
      snapshot.generatedAt = Date()
      DiskWidgetSharedStore.writeSnapshot(snapshot)
    }
    DiskWidgetSharedStore.enqueueCommand(DiskWidgetCommand(kind: .ejectDisk, diskID: diskID))
    DiskWidgetSharedStore.postCommandNotification()
    WidgetCenter.shared.reloadAllTimelines()
    return .result()
  }
}

struct ReconnectDiskIntent: AppIntent {
  static var title: LocalizedStringResource = "重新连接磁盘"
  static var openAppWhenRun: Bool = false

  @Parameter(title: "磁盘 ID")
  var diskID: String

  init() {
    self.diskID = ""
  }

  init(diskID: String) {
    self.diskID = diskID
  }

  func perform() async throws -> some IntentResult {
    guard !diskID.isEmpty else { return .result() }
    if var snapshot = DiskWidgetSharedStore.readSnapshot(),
      let index = snapshot.disks.firstIndex(where: { $0.id == diskID })
    {
      snapshot.disks[index].state = .reconnecting
      snapshot.disks[index].statusText = "正在重新连接…"
      snapshot.generatedAt = Date()
      DiskWidgetSharedStore.writeSnapshot(snapshot)
    }
    DiskWidgetSharedStore.enqueueCommand(DiskWidgetCommand(kind: .reconnectDisk, diskID: diskID))
    DiskWidgetSharedStore.postCommandNotification()
    WidgetCenter.shared.reloadAllTimelines()
    return .result()
  }
}

struct EjectAllDisksIntent: AppIntent {
  static var title: LocalizedStringResource = "安全推出所有外置磁盘"
  static var openAppWhenRun: Bool = false

  func perform() async throws -> some IntentResult {
    if var snapshot = DiskWidgetSharedStore.readSnapshot() {
      for idx in snapshot.disks.indices where snapshot.disks[idx].state == .connected {
        snapshot.disks[idx].state = .unmounting
        snapshot.disks[idx].statusText = "正在安全推出…"
      }
      snapshot.generatedAt = Date()
      DiskWidgetSharedStore.writeSnapshot(snapshot)
    }
    DiskWidgetSharedStore.enqueueCommand(DiskWidgetCommand(kind: .ejectAll))
    DiskWidgetSharedStore.postCommandNotification()
    WidgetCenter.shared.reloadAllTimelines()
    return .result()
  }
}

// MARK: - Timeline Entries & Providers

struct DiskTimelineEntry: TimelineEntry {
  let date: Date
  let snapshot: DiskWidgetSnapshot?
  let metricMode: WidgetMetricOverride
  let selectedDiskID: String?
  let isPlaceholder: Bool

  static var sampleSnapshot: DiskWidgetSnapshot {
    DiskWidgetSnapshot(
      generatedAt: Date(),
      accentColor: DiskSnapshotColor(red: 0.04, green: 0.52, blue: 1.0),
      ringShowsAvailablePercentage: false,
      showDiskImages: true,
      disks: [
        DiskSnapshotItem(
          id: "sample-ssd",
          name: "External SSD",
          displayName: "工作素材 SSD",
          volumePath: "/Volumes/External SSD",
          volumeUUID: "SAMPLE-1",
          iconSymbol: "externaldrive.fill",
          state: .connected,
          statusText: "612GB 可用 · 共 2TB",
          formatDescription: "APFS",
          isReadOnly: false,
          isDiskImage: false,
          usedBytes: 1_388_000_000_000,
          availableBytes: 612_000_000_000,
          totalBytes: 2_000_000_000_000
        ),
        DiskSnapshotItem(
          id: "sample-sd",
          name: "SDCARD",
          displayName: "相机存储卡",
          volumePath: "/Volumes/SDCARD",
          volumeUUID: "SAMPLE-2",
          iconSymbol: "sdcard.fill",
          state: .connected,
          statusText: "92GB 可用 · 共 128GB",
          formatDescription: "ExFAT",
          isReadOnly: false,
          isDiskImage: false,
          usedBytes: 36_000_000_000,
          availableBytes: 92_000_000_000,
          totalBytes: 128_000_000_000
        ),
        DiskSnapshotItem(
          id: "sample-tm",
          name: "Backup",
          displayName: "时间机器备份",
          volumePath: "/Volumes/Backup",
          volumeUUID: "SAMPLE-3",
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
  }

  var resolvedSnapshot: DiskWidgetSnapshot? {
    isPlaceholder ? Self.sampleSnapshot : snapshot
  }

  var showsAvailablePercentage: Bool {
    switch metricMode {
    case .followApp:
      return resolvedSnapshot?.ringShowsAvailablePercentage ?? false
    case .used:
      return false
    case .available:
      return true
    }
  }

  var accentColor: Color {
    guard let c = resolvedSnapshot?.accentColor else {
      return Color(.sRGB, red: 0.259, green: 0.522, blue: 0.957, opacity: 1)
    }
    return Color(.sRGB, red: c.red, green: c.green, blue: c.blue, opacity: 1)
  }
}

enum WidgetSnapshotFallback {
  static func resolveSnapshot() -> DiskWidgetSnapshot? {
    if let shared = DiskWidgetSharedStore.readSnapshot() {
      return shared
    }
    return scanLiveExternalSnapshot()
  }

  // Fallback for cold-start or unprovisioned ad-hoc builds so mounted external
  // drives still render immediately inside the widget extension.
  static func scanLiveExternalSnapshot() -> DiskWidgetSnapshot? {
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

    var items: [DiskSnapshotItem] = []
    for url in volumes {
      let path = url.standardizedFileURL.path
      guard path.hasPrefix("/Volumes/"), path != "/Volumes/Recovery" else { continue }
      guard let values = try? url.resourceValues(forKeys: keys),
        values.volumeIsLocal == true,
        values.volumeIsInternal != true,
        let name = values.volumeName,
        !name.isEmpty
      else { continue }

      let formatDesc = (values.volumeLocalizedFormatDescription ?? "").trimmingCharacters(
        in: .whitespacesAndNewlines
      )
      let loweredFormat = formatDesc.lowercased()
      if loweredFormat.contains("autofs") || loweredFormat.contains("devicefs") { continue }

      let totalBytes = Int64(max(0, values.volumeTotalCapacity ?? 0))
      let availableBytes = Int64(max(0, values.volumeAvailableCapacity ?? 0))
      let usedBytes = max(0, totalBytes - availableBytes)
      let uuid = values.volumeUUIDString
      let id = (uuid?.isEmpty == false) ? "uuid:\(uuid!)" : "name:\(name)"
      let statusText =
        totalBytes > 0
        ? "\(WidgetFormatters.compactBytes(availableBytes)) 可用 · 共 \(WidgetFormatters.compactBytes(totalBytes))"
        : "已连接"
      let iconSymbol = (values.volumeIsRemovable == true && loweredFormat.contains("fat"))
        ? "sdcard.fill"
        : "externaldrive.fill"

      items.append(
        DiskSnapshotItem(
          id: id,
          name: name,
          displayName: name,
          volumePath: path,
          volumeUUID: uuid,
          iconSymbol: iconSymbol,
          state: .connected,
          statusText: statusText,
          formatDescription: formatDesc.isEmpty ? nil : formatDesc,
          isReadOnly: values.volumeIsReadOnly == true,
          isDiskImage: false,
          usedBytes: usedBytes,
          availableBytes: availableBytes,
          totalBytes: totalBytes
        )
      )
    }

    guard !items.isEmpty else { return nil }
    items.sort { $0.displayName.localizedStandardCompare($1.displayName) == .orderedAscending }
    return DiskWidgetSnapshot(
      generatedAt: Date(),
      accentColor: DiskSnapshotColor(red: 0.259, green: 0.522, blue: 0.957),
      ringShowsAvailablePercentage: false,
      showDiskImages: false,
      disks: items
    )
  }
}

struct DashboardTimelineProvider: AppIntentTimelineProvider {
  func placeholder(in context: Context) -> DiskTimelineEntry {
    DiskTimelineEntry(
      date: Date(),
      snapshot: nil,
      metricMode: .followApp,
      selectedDiskID: nil,
      isPlaceholder: true
    )
  }

  func snapshot(for configuration: DashboardConfigIntent, in context: Context) async -> DiskTimelineEntry {
    let live = WidgetSnapshotFallback.resolveSnapshot()
    return DiskTimelineEntry(
      date: Date(),
      snapshot: live,
      metricMode: configuration.metricMode,
      selectedDiskID: nil,
      isPlaceholder: context.isPreview && live == nil
    )
  }

  func timeline(for configuration: DashboardConfigIntent, in context: Context) async -> Timeline<DiskTimelineEntry> {
    let live = WidgetSnapshotFallback.resolveSnapshot()
    let entry = DiskTimelineEntry(
      date: Date(),
      snapshot: live,
      metricMode: configuration.metricMode,
      selectedDiskID: nil,
      isPlaceholder: false
    )
    let nextRefresh = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date().addingTimeInterval(900)
    return Timeline(entries: [entry], policy: .after(nextRefresh))
  }
}

struct SingleDiskTimelineProvider: AppIntentTimelineProvider {
  func placeholder(in context: Context) -> DiskTimelineEntry {
    DiskTimelineEntry(
      date: Date(),
      snapshot: nil,
      metricMode: .followApp,
      selectedDiskID: nil,
      isPlaceholder: true
    )
  }

  func snapshot(for configuration: SingleDiskConfigIntent, in context: Context) async -> DiskTimelineEntry {
    let live = WidgetSnapshotFallback.resolveSnapshot()
    return DiskTimelineEntry(
      date: Date(),
      snapshot: live,
      metricMode: configuration.metricMode,
      selectedDiskID: configuration.disk?.id,
      isPlaceholder: context.isPreview && live == nil
    )
  }

  func timeline(for configuration: SingleDiskConfigIntent, in context: Context) async -> Timeline<DiskTimelineEntry> {
    let live = WidgetSnapshotFallback.resolveSnapshot()
    let entry = DiskTimelineEntry(
      date: Date(),
      snapshot: live,
      metricMode: configuration.metricMode,
      selectedDiskID: configuration.disk?.id,
      isPlaceholder: false
    )
    let nextRefresh = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date().addingTimeInterval(900)
    return Timeline(entries: [entry], policy: .after(nextRefresh))
  }
}

// MARK: - Formatting, Palette & URL Helpers

enum WidgetFormatters {
  static func compactBytes(_ bytes: Int64) -> String {
    guard bytes > 0 else { return "0B" }
    return ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
      .replacingOccurrences(of: " ", with: "")
  }

  static func spacedBytes(_ bytes: Int64) -> String {
    guard bytes > 0 else { return "0 B" }
    return ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
  }

  static func openURL(for diskID: String) -> URL {
    var components = URLComponents()
    components.scheme = DiskWidgetSharedConfig.urlScheme
    components.host = "open"
    components.queryItems = [URLQueryItem(name: "id", value: diskID)]
    return components.url ?? URL(string: "\(DiskWidgetSharedConfig.urlScheme)://settings")!
  }

  static var settingsURL: URL {
    URL(string: "\(DiskWidgetSharedConfig.urlScheme)://settings")!
  }
}

enum WidgetDiskPalette {
  private static let swatches: [Color] = [
    Color(.sRGB, red: 0.259, green: 0.522, blue: 0.957, opacity: 1),  // #4285f4
    Color(.sRGB, red: 0.286, green: 0.639, blue: 0.690, opacity: 1),  // #49a3b0
    Color(.sRGB, red: 0.416, green: 0.706, blue: 0.941, opacity: 1),  // #6ab4f0
    Color(.sRGB, red: 0.800, green: 0.486, blue: 0.369, opacity: 1),  // #cc7c5e
    Color(.sRGB, red: 0.302, green: 0.420, blue: 0.996, opacity: 1),  // #4d6bfe
  ]

  static func color(for index: Int, primary: Color) -> Color {
    if index == 0 { return primary }
    return swatches[index % swatches.count]
  }
}

// MARK: - Token-Monitor-Style Surface & Reusable Primitives

struct WidgetBackground: View {
  @Environment(\.widgetRenderingMode) private var renderingMode
  let accentColor: Color

  var body: some View {
    if renderingMode == .fullColor {
      ZStack {
        LinearGradient(
          colors: [
            Color(.sRGB, red: 0.095, green: 0.125, blue: 0.175, opacity: 1),
            Color(.sRGB, red: 0.065, green: 0.088, blue: 0.128, opacity: 1),
          ],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )
        RadialGradient(
          colors: [
            accentColor.opacity(0.16),
            Color.clear,
          ],
          center: .topTrailing,
          startRadius: 8,
          endRadius: 210
        )
      }
      .overlay(
        ContainerRelativeShape()
          .strokeBorder(Color.white.opacity(0.10), lineWidth: 0.8)
      )
      .environment(\.colorScheme, .dark)
    } else {
      Color.clear
    }
  }
}

struct WidgetRefreshBackground: View {
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.widgetRenderingMode) private var renderingMode

  var body: some View {
    if renderingMode == .fullColor {
      Circle()
        .fill(
          colorScheme == .dark
            ? Color.white.opacity(0.08)
            : Color.black.opacity(0.055)
        )
        .overlay(
          Circle()
            .stroke(Color.primary.opacity(0.08), lineWidth: 0.5)
        )
    } else {
      Circle()
        .fill(Color.primary.opacity(0.10))
    }
  }
}

struct WidgetRefreshButton: View {
  var size: CGFloat = 22

  var body: some View {
    Button(intent: RefreshDisksIntent()) {
      Image(systemName: "arrow.clockwise")
        .font(.system(size: size * 0.46, weight: .semibold))
        .foregroundStyle(.secondary)
        .frame(width: size, height: size)
        .background(WidgetRefreshBackground())
        .contentShape(Circle())
    }
    .buttonStyle(.plain)
  }
}

struct WidgetMetricBlock: View {
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.widgetRenderingMode) private var renderingMode

  let label: String
  let value: String
  let detail: String
  let accentColor: Color?

  var body: some View {
    VStack(alignment: .leading, spacing: 3) {
      Text(label.uppercased())
        .font(.system(size: 8.5, weight: .bold, design: .rounded))
        .tracking(0.55)
        .foregroundStyle(.secondary)
        .lineLimit(1)

      Text(value)
        .font(.system(size: 17, weight: .bold, design: .rounded))
        .monospacedDigit()
        .foregroundStyle(accentColor ?? .primary)
        .lineLimit(1)
        .minimumScaleFactor(0.75)

      Text(detail)
        .font(.system(size: 9.5, weight: .medium))
        .monospacedDigit()
        .foregroundStyle(.tertiary)
        .lineLimit(1)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.horizontal, 9)
    .padding(.vertical, 7)
    .background(blockSurface)
  }

  @ViewBuilder
  private var blockSurface: some View {
    let shape = RoundedRectangle(cornerRadius: 10, style: .continuous)
    if renderingMode == .fullColor {
      shape
        .fill(colorScheme == .dark ? Color.white.opacity(0.055) : Color.black.opacity(0.035))
        .overlay(
          shape.stroke(
            colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.06),
            lineWidth: 0.6
          )
        )
    } else {
      shape.fill(Color.primary.opacity(0.08))
    }
  }
}

struct PercentageBar: View {
  let fraction: Double
  let tint: Color
  let isActive: Bool
  var height: CGFloat = 5.5

  var body: some View {
    GeometryReader { proxy in
      let clamped = min(max(fraction, 0), 1)
      let fillWidth = max(clamped > 0 ? height : 0, proxy.size.width * clamped)
      ZStack(alignment: .leading) {
        Capsule()
          .fill(Color.primary.opacity(0.10))
        if isActive && clamped > 0 {
          Capsule()
            .fill(
              LinearGradient(
                colors: [tint.opacity(0.88), tint],
                startPoint: .leading,
                endPoint: .trailing
              )
            )
            .frame(width: min(proxy.size.width, fillWidth))
            .widgetAccentable()
        }
      }
    }
    .frame(height: height)
  }
}

struct SegmentedCapacityBar: View {
  let items: [DiskSnapshotItem]
  let totalCapacity: Int64
  let primaryAccent: Color

  var body: some View {
    GeometryReader { proxy in
      let connected = items.filter { $0.state == .connected && $0.totalBytes > 0 }
      let denom = Double(max(1, totalCapacity))
      HStack(spacing: 2) {
        ForEach(Array(connected.enumerated()), id: \.element.id) { idx, item in
          let ratio = max(0.02, Double(item.usedBytes) / denom)
          Capsule()
            .fill(WidgetDiskPalette.color(for: idx, primary: primaryAccent))
            .frame(width: max(4, (proxy.size.width - CGFloat(connected.count) * 2) * ratio))
            .widgetAccentable()
        }
        Spacer(minLength: 0)
      }
      .padding(2)
      .background(Color.primary.opacity(0.09), in: Capsule())
    }
    .frame(height: 8)
  }
}

struct DiskRingGauge: View {
  let fraction: Double
  let text: String
  let accentColor: Color
  let isConnected: Bool
  let isBusy: Bool
  let size: CGFloat
  let lineWidth: CGFloat
  let fontSize: CGFloat

  var body: some View {
    ZStack {
      Circle()
        .stroke(Color.primary.opacity(0.11), lineWidth: lineWidth)

      if isConnected && !isBusy {
        Circle()
          .trim(from: 0, to: CGFloat(min(max(fraction, 0), 1)))
          .stroke(
            accentColor,
            style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
          )
          .rotationEffect(.degrees(-90))
          .widgetAccentable()
      } else if isBusy {
        Circle()
          .trim(from: 0, to: 0.35)
          .stroke(
            accentColor.opacity(0.75),
            style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
          )
          .rotationEffect(.degrees(-90))
          .widgetAccentable()
      }

      Text(text)
        .font(.system(size: fontSize, weight: .bold, design: .rounded))
        .monospacedDigit()
        .foregroundStyle(isConnected ? .primary : .secondary)
        .lineLimit(1)
        .minimumScaleFactor(0.75)
    }
    .frame(width: size, height: size)
  }
}

struct DiskFormatBadge: View {
  let text: String
  let isReadOnly: Bool

  var body: some View {
    HStack(spacing: 2.5) {
      if isReadOnly {
        Image(systemName: "lock.fill")
          .font(.system(size: 7.5, weight: .semibold))
      }
      Text(text)
        .font(.system(size: 9, weight: .semibold, design: .rounded))
    }
    .foregroundStyle(.secondary)
    .padding(.horizontal, 5.5)
    .padding(.vertical, 1.5)
    .background(Color.primary.opacity(0.08), in: Capsule())
  }
}

struct DiskIconBadge: View {
  let symbol: String
  let accentColor: Color
  let isConnected: Bool
  let boxSize: CGFloat
  let iconSize: CGFloat

  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: boxSize * 0.30, style: .continuous)
        .fill(isConnected ? accentColor.opacity(0.16) : Color.primary.opacity(0.07))
        .overlay(
          RoundedRectangle(cornerRadius: boxSize * 0.30, style: .continuous)
            .stroke(isConnected ? accentColor.opacity(0.24) : Color.clear, lineWidth: 0.5)
        )
      Image(systemName: symbol)
        .font(.system(size: iconSize, weight: .semibold))
        .foregroundStyle(isConnected ? accentColor : .secondary)
        .widgetAccentable()
    }
    .frame(width: boxSize, height: boxSize)
  }
}

struct DiskQuickActionButton: View {
  let item: DiskSnapshotItem
  let compact: Bool

  var body: some View {
    if item.state == .connected {
      Button(intent: EjectDiskIntent(diskID: item.id)) {
        Image(systemName: "eject.fill")
          .font(.system(size: compact ? 9.5 : 10.5, weight: .semibold))
          .foregroundStyle(.secondary)
          .frame(width: compact ? 22 : 25, height: compact ? 22 : 25)
          .background(WidgetRefreshBackground())
          .contentShape(Circle())
      }
      .buttonStyle(.plain)
    } else if item.state == .unmounted {
      Button(intent: ReconnectDiskIntent(diskID: item.id)) {
        Image(systemName: "arrow.clockwise")
          .font(.system(size: compact ? 9.5 : 10.5, weight: .semibold))
          .foregroundStyle(.secondary)
          .frame(width: compact ? 22 : 25, height: compact ? 22 : 25)
          .background(WidgetRefreshBackground())
          .contentShape(Circle())
      }
      .buttonStyle(.plain)
    } else if item.state.isBusy {
      Image(systemName: "hourglass")
        .font(.system(size: compact ? 9.5 : 10.5, weight: .medium))
        .foregroundStyle(.tertiary)
        .frame(width: compact ? 22 : 25, height: compact ? 22 : 25)
    }
  }
}

struct QuotaWindowCell: View {
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.widgetRenderingMode) private var renderingMode

  let item: DiskSnapshotItem
  let tint: Color
  let showsAvailable: Bool
  let cardPadding: CGFloat

  var body: some View {
    HStack(spacing: 8) {
      Link(destination: WidgetFormatters.openURL(for: item.id)) {
        VStack(alignment: .leading, spacing: 5) {
          HStack(spacing: 6) {
            Circle()
              .fill(item.state == .connected ? tint : Color.secondary.opacity(0.4))
              .frame(width: 7, height: 7)
              .widgetAccentable()

            Text(item.displayName)
              .font(.system(size: 11.5, weight: .semibold))
              .foregroundStyle(.primary)
              .lineLimit(1)

            if let fmt = item.formatDescription, !fmt.isEmpty {
              DiskFormatBadge(text: fmt, isReadOnly: item.isReadOnly)
            }

            Spacer(minLength: 4)

            Text(item.displayedPercentText(showsAvailable: showsAvailable))
              .font(.system(size: 11.5, weight: .bold, design: .rounded))
              .monospacedDigit()
              .foregroundStyle(item.state == .connected ? .primary : .secondary)
          }

          PercentageBar(
            fraction: item.displayedFraction(showsAvailable: showsAvailable),
            tint: tint,
            isActive: item.state == .connected,
            height: 5
          )

          HStack {
            if item.state == .connected && item.totalBytes > 0 {
              Text(
                showsAvailable
                  ? "可用 \(WidgetFormatters.compactBytes(item.availableBytes))"
                  : "已用 \(WidgetFormatters.compactBytes(item.usedBytes))"
              )
              .foregroundStyle(.secondary)
              Spacer()
              Text("共 \(WidgetFormatters.compactBytes(item.totalBytes))")
                .foregroundStyle(.tertiary)
            } else {
              Text(item.statusText)
                .foregroundStyle(.secondary)
              Spacer()
            }
          }
          .font(.system(size: 9.5, weight: .medium))
          .monospacedDigit()
          .lineLimit(1)
        }
      }
      .buttonStyle(.plain)

      DiskQuickActionButton(item: item, compact: true)
    }
    .padding(.horizontal, 9)
    .padding(.vertical, cardPadding)
    .background(cellSurface)
  }

  @ViewBuilder
  private var cellSurface: some View {
    let shape = RoundedRectangle(cornerRadius: 10, style: .continuous)
    if renderingMode == .fullColor {
      shape
        .fill(colorScheme == .dark ? Color.white.opacity(0.05) : Color.black.opacity(0.032))
        .overlay(
          shape.stroke(
            colorScheme == .dark ? Color.white.opacity(0.075) : Color.black.opacity(0.055),
            lineWidth: 0.6
          )
        )
    } else {
      shape.fill(Color.primary.opacity(0.07))
    }
  }
}

struct EmptyDiskWidgetView: View {
  let needsAppLaunch: Bool
  let accentColor: Color
  let compact: Bool

  var body: some View {
    VStack(spacing: compact ? 7 : 10) {
      ZStack {
        Circle()
          .fill(accentColor.opacity(0.15))
          .frame(width: compact ? 36 : 44, height: compact ? 36 : 44)
        Image(systemName: needsAppLaunch ? "externaldrive.badge.plus" : "externaldrive")
          .font(.system(size: compact ? 16 : 19, weight: .semibold))
          .foregroundStyle(accentColor)
          .widgetAccentable()
      }

      VStack(spacing: 2.5) {
        Text(needsAppLaunch ? "请先启动 DiskWidget" : "未连接外置磁盘")
          .font(.system(size: compact ? 12 : 13, weight: .semibold))
          .foregroundStyle(.primary)
          .lineLimit(1)
        Text(needsAppLaunch ? "运行后将自动同步磁盘数据" : "接入硬盘、SD 卡或镜像后自动显示")
          .font(.system(size: 10.5))
          .foregroundStyle(.secondary)
          .multilineTextAlignment(.center)
          .lineLimit(2)
      }

      if !compact {
        HStack(spacing: 8) {
          Button(intent: RefreshDisksIntent()) {
            Label("刷新", systemImage: "arrow.clockwise")
              .font(.system(size: 10.5, weight: .medium))
              .foregroundStyle(.primary)
              .padding(.horizontal, 10)
              .padding(.vertical, 4.5)
              .background(Color.primary.opacity(0.11), in: Capsule())
              .overlay(Capsule().stroke(Color.primary.opacity(0.10), lineWidth: 0.6))
          }
          .buttonStyle(.plain)

          Link(destination: WidgetFormatters.settingsURL) {
            Label("设置", systemImage: "slider.horizontal.3")
              .font(.system(size: 10.5, weight: .medium))
              .foregroundStyle(.primary)
              .padding(.horizontal, 10)
              .padding(.vertical, 4.5)
              .background(Color.primary.opacity(0.11), in: Capsule())
              .overlay(Capsule().stroke(Color.primary.opacity(0.10), lineWidth: 0.6))
          }
          .buttonStyle(.plain)
        }
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .widgetURL(WidgetFormatters.settingsURL)
  }
}

// MARK: - Dashboard Widget Views

struct DashboardWidgetView: View {
  @Environment(\.widgetFamily) private var family
  let entry: DiskTimelineEntry

  var body: some View {
    Group {
      if let snapshot = entry.resolvedSnapshot {
        if snapshot.disks.isEmpty {
          EmptyDiskWidgetView(
            needsAppLaunch: false,
            accentColor: entry.accentColor,
            compact: family == .systemSmall
          )
        } else {
          switch family {
          case .systemSmall:
            SmallUsageDiskView(
              item: preferredDisk(in: snapshot),
              totalDiskCount: snapshot.disks.count,
              showsAvailable: entry.showsAvailablePercentage,
              accentColor: entry.accentColor
            )
          case .systemMedium:
            MediumUsageDiskView(
              snapshot: snapshot,
              showsAvailable: entry.showsAvailablePercentage,
              accentColor: entry.accentColor
            )
          case .systemLarge:
            LargeDashboardDiskView(
              snapshot: snapshot,
              showsAvailable: entry.showsAvailablePercentage,
              accentColor: entry.accentColor
            )
          default:
            MediumUsageDiskView(
              snapshot: snapshot,
              showsAvailable: entry.showsAvailablePercentage,
              accentColor: entry.accentColor
            )
          }
        }
      } else {
        EmptyDiskWidgetView(
          needsAppLaunch: true,
          accentColor: entry.accentColor,
          compact: family == .systemSmall
        )
      }
    }
    .environment(\.colorScheme, .dark)
    .containerBackground(for: .widget) {
      WidgetBackground(accentColor: entry.accentColor)
    }
  }

  private func preferredDisk(in snapshot: DiskWidgetSnapshot) -> DiskSnapshotItem {
    snapshot.disks.first(where: { $0.state == .connected }) ?? snapshot.disks[0]
  }
}

struct SmallUsageDiskView: View {
  let item: DiskSnapshotItem
  let totalDiskCount: Int?
  let showsAvailable: Bool
  let accentColor: Color

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack(alignment: .center, spacing: 6) {
        DiskIconBadge(
          symbol: item.iconSymbol,
          accentColor: accentColor,
          isConnected: item.state == .connected,
          boxSize: 28,
          iconSize: 13
        )
        Spacer(minLength: 4)
        if let fmt = item.formatDescription, !fmt.isEmpty {
          DiskFormatBadge(text: fmt, isReadOnly: item.isReadOnly)
        }
        if let totalDiskCount, totalDiskCount > 1 {
          Text("1/\(totalDiskCount)")
            .font(.system(size: 9.5, weight: .semibold, design: .rounded))
            .monospacedDigit()
            .foregroundStyle(.tertiary)
        }
      }

      Spacer(minLength: 6)

      VStack(alignment: .leading, spacing: 2) {
        Text(item.displayName)
          .font(.system(size: 11.5, weight: .semibold))
          .foregroundStyle(.secondary)
          .lineLimit(1)

        if item.state == .connected && item.totalBytes > 0 {
          let heroBytes = showsAvailable ? item.availableBytes : item.usedBytes
          HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text(WidgetFormatters.spacedBytes(heroBytes))
              .font(.system(size: 22, weight: .bold, design: .rounded))
              .monospacedDigit()
              .foregroundStyle(.primary)
              .lineLimit(1)
              .minimumScaleFactor(0.7)
          }
          Text(showsAvailable ? "可用空间" : "已用空间")
            .font(.system(size: 9.5, weight: .medium))
            .foregroundStyle(.tertiary)
        } else {
          Text(item.statusText)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(.primary)
            .lineLimit(2)
        }
      }

      Spacer(minLength: 6)

      VStack(spacing: 5) {
        PercentageBar(
          fraction: item.displayedFraction(showsAvailable: showsAvailable),
          tint: accentColor,
          isActive: item.state == .connected,
          height: 5.5
        )

        HStack {
          Text(
            item.state == .connected
              ? "\(item.displayedPercentText(showsAvailable: showsAvailable)) \(showsAvailable ? "剩余" : "已用")"
              : (item.state == .unmounted ? "可重连" : "离线")
          )
          .font(.system(size: 10, weight: .semibold, design: .rounded))
          .monospacedDigit()
          .foregroundStyle(.secondary)

          Spacer()

          if item.totalBytes > 0 {
            Text("共 \(WidgetFormatters.compactBytes(item.totalBytes))")
              .font(.system(size: 10, weight: .medium))
              .monospacedDigit()
              .foregroundStyle(.tertiary)
          }
        }
      }
    }
    .padding(1)
    .widgetURL(WidgetFormatters.openURL(for: item.id))
  }
}

struct MediumUsageDiskView: View {
  let snapshot: DiskWidgetSnapshot
  let showsAvailable: Bool
  let accentColor: Color

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      headerBar

      if snapshot.disks.count == 1, let item = snapshot.disks.first {
        singleFeaturedLayout(item)
      } else {
        VStack(spacing: 5.5) {
          ForEach(Array(snapshot.disks.prefix(2).enumerated()), id: \.element.id) { idx, item in
            QuotaWindowCell(
              item: item,
              tint: WidgetDiskPalette.color(for: idx, primary: accentColor),
              showsAvailable: showsAvailable,
              cardPadding: 6
            )
          }
        }
        Spacer(minLength: 0)
      }
    }
    .padding(1)
  }

  private var headerBar: some View {
    HStack(spacing: 6) {
      Circle()
        .fill(snapshot.connectedCount > 0 ? Color.green : Color.secondary.opacity(0.5))
        .frame(width: 6.5, height: 6.5)

      Text("外置磁盘")
        .font(.system(size: 12, weight: .semibold))
      Text("\(snapshot.connectedCount)/\(snapshot.disks.count)")
        .font(.system(size: 9.5, weight: .bold, design: .rounded))
        .monospacedDigit()
        .foregroundStyle(.secondary)
        .padding(.horizontal, 6)
        .padding(.vertical, 1.5)
        .background(Color.primary.opacity(0.08), in: Capsule())

      Spacer()

      Button(intent: ToggleDiskMetricIntent()) {
        Text(showsAvailable ? "剩余%" : "已用%")
          .font(.system(size: 9.5, weight: .semibold, design: .rounded))
          .foregroundStyle(.secondary)
          .padding(.horizontal, 7.5)
          .padding(.vertical, 3)
          .background(Color.primary.opacity(0.07), in: Capsule())
      }
      .buttonStyle(.plain)

      WidgetRefreshButton(size: 22)
    }
  }

  private func singleFeaturedLayout(_ item: DiskSnapshotItem) -> some View {
    HStack(spacing: 10) {
      Link(destination: WidgetFormatters.openURL(for: item.id)) {
        HStack(spacing: 10) {
          WidgetMetricBlock(
            label: showsAvailable ? "AVAILABLE" : "USED",
            value: item.state == .connected && item.totalBytes > 0
              ? WidgetFormatters.spacedBytes(showsAvailable ? item.availableBytes : item.usedBytes)
              : (item.state == .unmounted ? "已卸载" : "离线"),
            detail: item.totalBytes > 0
              ? "\(item.displayName) · 共 \(WidgetFormatters.compactBytes(item.totalBytes))"
              : item.statusText,
            accentColor: item.state == .connected ? accentColor : .secondary
          )

          DiskRingGauge(
            fraction: item.displayedFraction(showsAvailable: showsAvailable),
            text: item.displayedPercentText(showsAvailable: showsAvailable),
            accentColor: accentColor,
            isConnected: item.state == .connected,
            isBusy: item.state.isBusy,
            size: 62,
            lineWidth: 6,
            fontSize: 13
          )
        }
      }
      .buttonStyle(.plain)

      VStack(spacing: 6) {
        DiskQuickActionButton(item: item, compact: false)
        if let fmt = item.formatDescription, !fmt.isEmpty {
          DiskFormatBadge(text: fmt, isReadOnly: item.isReadOnly)
        }
      }
    }
  }
}

struct LargeDashboardDiskView: View {
  let snapshot: DiskWidgetSnapshot
  let showsAvailable: Bool
  let accentColor: Color

  var body: some View {
    VStack(alignment: .leading, spacing: 9) {
      headerStrip

      HStack(spacing: 7) {
        WidgetMetricBlock(
          label: "CONNECTED",
          value: "\(snapshot.connectedCount) 盘",
          detail: "共记录 \(snapshot.disks.count) 项",
          accentColor: accentColor
        )
        WidgetMetricBlock(
          label: "AVAILABLE",
          value: snapshot.totalBytesSum > 0
            ? WidgetFormatters.compactBytes(snapshot.availableBytesSum)
            : "—",
          detail: snapshot.totalBytesSum > 0
            ? "总计 \(WidgetFormatters.compactBytes(snapshot.totalBytesSum))"
            : "暂无统计",
          accentColor: nil
        )
        WidgetMetricBlock(
          label: "USED",
          value: snapshot.totalBytesSum > 0
            ? WidgetFormatters.compactBytes(snapshot.usedBytesSum)
            : "—",
          detail: snapshot.totalBytesSum > 0
            ? "\(Int((Double(snapshot.usedBytesSum) / Double(snapshot.totalBytesSum) * 100).rounded()))% 占用"
            : "暂无统计",
          accentColor: nil
        )
      }

      if snapshot.totalBytesSum > 0 {
        SegmentedCapacityBar(
          items: snapshot.disks,
          totalCapacity: snapshot.totalBytesSum,
          primaryAccent: accentColor
        )
      }

      VStack(spacing: 5.5) {
        ForEach(Array(snapshot.disks.prefix(4).enumerated()), id: \.element.id) { idx, item in
          QuotaWindowCell(
            item: item,
            tint: WidgetDiskPalette.color(for: idx, primary: accentColor),
            showsAvailable: showsAvailable,
            cardPadding: 6.5
          )
        }
      }

      Spacer(minLength: 0)

      footerBar
    }
    .padding(1)
  }

  private var headerStrip: some View {
    HStack(spacing: 7) {
      DiskIconBadge(
        symbol: "externaldrive.connected.to.line.below",
        accentColor: accentColor,
        isConnected: snapshot.connectedCount > 0,
        boxSize: 24,
        iconSize: 11.5
      )

      VStack(alignment: .leading, spacing: 0.5) {
        Text("DiskWidget 仪表盘")
          .font(.system(size: 12.5, weight: .semibold))
        Text("更新于 \(snapshot.generatedAt.formatted(date: .omitted, time: .shortened))")
          .font(.system(size: 9.5))
          .monospacedDigit()
          .foregroundStyle(.tertiary)
      }

      Spacer()

      Button(intent: ToggleDiskMetricIntent()) {
        Text(showsAvailable ? "显示: 剩余" : "显示: 已用")
          .font(.system(size: 9.5, weight: .semibold, design: .rounded))
          .foregroundStyle(.secondary)
          .padding(.horizontal, 8)
          .padding(.vertical, 3.5)
          .background(Color.primary.opacity(0.07), in: Capsule())
      }
      .buttonStyle(.plain)

      if snapshot.connectedCount > 0 {
        Button(intent: EjectAllDisksIntent()) {
          Image(systemName: "eject.fill")
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(.secondary)
            .frame(width: 22, height: 22)
            .background(WidgetRefreshBackground())
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
      }

      WidgetRefreshButton(size: 22)
    }
  }

  private var footerBar: some View {
    HStack {
      if snapshot.disks.count > 4 {
        Text("还有 \(snapshot.disks.count - 4) 个磁盘可在菜单栏查看")
          .font(.system(size: 9.5))
          .foregroundStyle(.tertiary)
      } else {
        Text("点击磁盘可在 Finder 中打开")
          .font(.system(size: 9.5))
          .foregroundStyle(.tertiary)
      }
      Spacer()
      Link(destination: WidgetFormatters.settingsURL) {
        HStack(spacing: 3) {
          Image(systemName: "slider.horizontal.3")
            .font(.system(size: 9.5))
          Text("设置")
            .font(.system(size: 10, weight: .medium))
        }
        .foregroundStyle(.secondary)
      }
    }
  }
}

// MARK: - Single Disk Widget View

struct SingleDiskWidgetView: View {
  @Environment(\.widgetFamily) private var family
  let entry: DiskTimelineEntry

  var body: some View {
    Group {
      if let snapshot = entry.resolvedSnapshot {
        if let item = resolveSelectedDisk(in: snapshot) {
          switch family {
          case .systemSmall:
            SmallUsageDiskView(
              item: item,
              totalDiskCount: nil,
              showsAvailable: entry.showsAvailablePercentage,
              accentColor: entry.accentColor
            )
          default:
            MediumSingleFocusView(
              item: item,
              showsAvailable: entry.showsAvailablePercentage,
              accentColor: entry.accentColor
            )
          }
        } else {
          EmptyDiskWidgetView(
            needsAppLaunch: false,
            accentColor: entry.accentColor,
            compact: family == .systemSmall
          )
        }
      } else {
        EmptyDiskWidgetView(
          needsAppLaunch: true,
          accentColor: entry.accentColor,
          compact: family == .systemSmall
        )
      }
    }
    .environment(\.colorScheme, .dark)
    .containerBackground(for: .widget) {
      WidgetBackground(accentColor: entry.accentColor)
    }
  }

  private func resolveSelectedDisk(in snapshot: DiskWidgetSnapshot) -> DiskSnapshotItem? {
    if let id = entry.selectedDiskID, id != DiskChoiceEntity.auto.id {
      if let exact = snapshot.disks.first(where: { $0.id == id }) {
        return exact
      }
    }
    return snapshot.disks.first(where: { $0.state == .connected }) ?? snapshot.disks.first
  }
}

struct MediumSingleFocusView: View {
  let item: DiskSnapshotItem
  let showsAvailable: Bool
  let accentColor: Color

  var body: some View {
    VStack(spacing: 8) {
      HStack(spacing: 6) {
        DiskIconBadge(
          symbol: item.iconSymbol,
          accentColor: accentColor,
          isConnected: item.state == .connected,
          boxSize: 24,
          iconSize: 11.5
        )
        Text(item.displayName)
          .font(.system(size: 13, weight: .semibold))
          .lineLimit(1)
        if let fmt = item.formatDescription, !fmt.isEmpty {
          DiskFormatBadge(text: fmt, isReadOnly: item.isReadOnly)
        }
        Spacer()
        Button(intent: ToggleDiskMetricIntent()) {
          Text(showsAvailable ? "剩余%" : "已用%")
            .font(.system(size: 9.5, weight: .semibold, design: .rounded))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 7.5)
            .padding(.vertical, 3)
            .background(Color.primary.opacity(0.07), in: Capsule())
        }
        .buttonStyle(.plain)
        DiskQuickActionButton(item: item, compact: true)
      }

      HStack(spacing: 10) {
        Link(destination: WidgetFormatters.openURL(for: item.id)) {
          HStack(spacing: 8) {
            WidgetMetricBlock(
              label: showsAvailable ? "AVAILABLE" : "USED",
              value: item.state == .connected && item.totalBytes > 0
                ? WidgetFormatters.spacedBytes(showsAvailable ? item.availableBytes : item.usedBytes)
                : (item.state == .unmounted ? "已卸载" : "离线"),
              detail: item.totalBytes > 0
                ? "共 \(WidgetFormatters.compactBytes(item.totalBytes))"
                : item.statusText,
              accentColor: item.state == .connected ? accentColor : .secondary
            )

            WidgetMetricBlock(
              label: showsAvailable ? "USED" : "AVAILABLE",
              value: item.state == .connected && item.totalBytes > 0
                ? WidgetFormatters.spacedBytes(showsAvailable ? item.usedBytes : item.availableBytes)
                : "—",
              detail: item.isReadOnly ? "只读卷" : "可写入",
              accentColor: nil
            )
          }
        }
        .buttonStyle(.plain)

        DiskRingGauge(
          fraction: item.displayedFraction(showsAvailable: showsAvailable),
          text: item.displayedPercentText(showsAvailable: showsAvailable),
          accentColor: accentColor,
          isConnected: item.state == .connected,
          isBusy: item.state.isBusy,
          size: 56,
          lineWidth: 5.5,
          fontSize: 12.5
        )
      }

      PercentageBar(
        fraction: item.displayedFraction(showsAvailable: showsAvailable),
        tint: accentColor,
        isActive: item.state == .connected,
        height: 5.5
      )
    }
    .padding(1)
  }
}

// MARK: - Widget Definitions

struct DiskDashboardWidget: Widget {
  let kind = DiskWidgetSharedConfig.dashboardWidgetKind

  var body: some WidgetConfiguration {
    AppIntentConfiguration(
      kind: kind,
      intent: DashboardConfigIntent.self,
      provider: DashboardTimelineProvider()
    ) { entry in
      DashboardWidgetView(entry: entry)
    }
    .configurationDisplayName("外置磁盘总览")
    .description("查看已连接外置硬盘、存储卡与镜像的容量、格式，支持快速打开与安全推出。")
    .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
  }
}

struct DiskSingleWidget: Widget {
  let kind = DiskWidgetSharedConfig.singleDiskWidgetKind

  var body: some WidgetConfiguration {
    AppIntentConfiguration(
      kind: kind,
      intent: SingleDiskConfigIntent.self,
      provider: SingleDiskTimelineProvider()
    ) { entry in
      SingleDiskWidgetView(entry: entry)
    }
    .configurationDisplayName("指定外置磁盘")
    .description("专注于单个外置硬盘或 SD 卡的容量指标与快捷推出。")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}

@main
struct DiskWidgetExtensionBundle: WidgetBundle {
  var body: some Widget {
    DiskDashboardWidget()
    DiskSingleWidget()
  }
}
