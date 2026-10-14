#!/usr/bin/env python3
"""Build tests against production AppKit code without launching the disk scanner."""
from pathlib import Path
import subprocess
import tempfile

root = Path(__file__).resolve().parents[1]
source = (root / "DiskWidget.swift").read_text()
entry = "let app = NSApplication.shared\nlet delegate = AppDelegate()"
assert source.count(entry) == 1, "App entry point changed; update test harness"
source = source.split(entry)[0]
source = source.replace("UserDefaults.standard", "isolatedDefaults")
prefix = '''import AppKit
let testSuite = "local.diskwidget.tests." + UUID().uuidString
let isolatedDefaults = UserDefaults(suiteName: testSuite)!
'''
with tempfile.TemporaryDirectory(prefix="diskwidget-tests-") as directory:
    main = Path(directory) / "main.swift"
    binary = Path(directory) / "regressions"
    main.write_text(prefix + source + (root / "tests/window_regressions.swift").read_text())
    subprocess.run(["swiftc", str(main), "-o", str(binary), "-framework", "AppKit"], check=True)
    subprocess.run([str(binary)], check=True)
