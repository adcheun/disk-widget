# 窗口行为修复 · 2026-10-12

## 问题与原因

- 调度中心中卡片继续显示：窗口使用了 `.stationary`。它的含义是让窗口在调度中心中保持静止可见，并非隐藏。移除 `.canJoinAllSpaces` 不能解决这个问题。
- 多显示器位置跳动：位置边界只使用 `NSScreen.main`，会把副屏上的合法坐标夹到当前主屏。修复前在本机两个显示器上运行原有位置函数，能稳定复现跨屏移动。
- 临时位置覆盖手动位置：原来的每次重新布局都会保存坐标，屏幕临时不可用或系统调整窗口后，原位置容易丢失。
- 新设备排序可能改变第一张卡片：现在在发现和排序新卡片之前取得整组位置，避免以新窗口的初始坐标重新定位整组。

## 实现

窗口使用 `[.canJoinAllSpaces, .transient, .ignoresCycle]`：在普通桌面显示，由窗口服务器处理调度中心隐藏/恢复。仍使用桌面窗口层级，切换 Space 时不再强制把已有卡片前置。

位置校正比较所有显示器与卡片的相交区域；没有相交时选择最近的显示器。布局优先读取用户保存的位置，屏幕变更延迟 0.5 秒处理以合并连续通知。临时边界校正不再覆盖保存位置；普通拖动和主动整理会保存新位置。

此修复保留全局坐标，不将位置改成显示器 UUID 加相对坐标。改变显示器排列或缩放后，位置仍会按新的屏幕边界校正。

## 验证

- `tests/run_window_regressions.py`：覆盖多屏顺序变化、负坐标、屏幕断开/恢复、临时窗口位移、保存位置、拖动、移除首张卡片和窗口层级。
- 桌面实测使用生产 `DiskPanel` 加测试标记：修复前标记在调度中心仍可见；修复后进入时消失、退出时恢复。
- 测试名称和数据均为虚拟值；个人磁盘信息、完整桌面截图及偏好设置不纳入仓库。

参考：[Apple — stationary](https://developer.apple.com/documentation/appkit/nswindow/collectionbehavior-swift.struct/stationary)、[Apple — transient](https://developer.apple.com/documentation/appkit/nswindow/collectionbehavior-swift.struct/transient)。
