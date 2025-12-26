#!/bin/bash
set -e

echo "=== 启动 Flutter 前端 ==="

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR/../frontend"

# 检查 Flutter
command -v flutter >/dev/null || {
  echo "❌ Flutter 未安装或未加入 PATH"
  exit 1
}

flutter pub get

echo "🔍 检查可用设备..."

# 获取 Android 设备数量
ANDROID_DEVICE=$(flutter devices --machine \
  | jq -r '.[] | select(.platform=="android") | .id' | head -n 1)

if [ -n "$ANDROID_DEVICE" ]; then
  echo "📱 使用 Android 真机: $ANDROID_DEVICE"
  flutter run -d "$ANDROID_DEVICE"
  exit 0
fi

# 检查 Web
if flutter devices --machine | jq -e '.[] | select(.id=="chrome")' >/dev/null; then
  echo "🌐 使用 Web (Chrome)"
  flutter run -d chrome --web-port 3000
  exit 0
fi

echo "❌ 未发现可用设备"
flutter devices
exit 1
