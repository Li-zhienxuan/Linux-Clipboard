#!/bin/bash
# 包装脚本 - 发布
# 实际脚本位于 scripts/release.sh

SCRIPT_DIR="$(dirname "$0")"
exec "$SCRIPT_DIR/scripts/release.sh" "$@"
