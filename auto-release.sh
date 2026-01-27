#!/bin/bash
# 包装脚本 - 自动发布
# 实际脚本位于 scripts/auto-release.sh

SCRIPT_DIR="$(dirname "$0")"
exec "$SCRIPT_DIR/scripts/auto-release.sh" "$@"
