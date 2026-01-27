#!/bin/bash
# 包装脚本 - CNB 设置
# 实际脚本位于 scripts/setup-cnb.sh

SCRIPT_DIR="$(dirname "$0")"
exec "$SCRIPT_DIR/scripts/setup-cnb.sh" "$@"
