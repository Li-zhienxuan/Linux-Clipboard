#!/bin/bash
# 包装脚本 - 构建
# 实际脚本位于 scripts/build.sh

SCRIPT_DIR="$(dirname "$0")"
exec "$SCRIPT_DIR/scripts/build.sh" "$@"
