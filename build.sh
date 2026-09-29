#!/bin/sh
set -eu

swiftc DiskWidget.swift \
  -o DiskWidget.app/Contents/MacOS/DiskWidget \
  -framework AppKit

echo "Built DiskWidget.app"
