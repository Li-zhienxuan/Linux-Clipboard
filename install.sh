#!/bin/bash
# 包装脚本 - 安装
# 实际脚本位于 scripts/install.sh

SCRIPT_DIR="$(dirname "$0")"
exec "$SCRIPT_DIR/scripts/install.sh" "$@"
