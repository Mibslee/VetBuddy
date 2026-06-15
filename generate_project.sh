#!/bin/bash
# VetBuddy Xcode Project Generator
# 用法: 在 VetBuddy 根目录下运行此脚本
# 前提: 已安装 xcodegen (brew install xcodegen)

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== VetBuddy 项目生成器 ==="

# 检查 xcodegen
if ! command -v xcodegen &> /dev/null; then
    echo "错误: 未安装 xcodegen"
    echo "请运行: brew install xcodegen"
    exit 1
fi

# 生成 project.yml
cat > project.yml << 'EOF'
name: VetBuddy
options:
  bundleIdPrefix: com.shanestudio
  deploymentTarget:
    iOS: "17.0"
  xcodeVersion: "15.0"
  generateEmptyDirectories: true
  groupSortPosition: top

settings:
  base:
    SWIFT_VERSION: "5.9"
    INFOPLIST_FILE: Info.plist
    CODE_SIGN_ENTITLEMENTS: VetBuddy.entitlements
    MARKETING_VERSION: "1.0.0"
    CURRENT_PROJECT_VERSION: "1"
    DEVELOPMENT_TEAM: ""
    PRODUCT_BUNDLE_IDENTIFIER: com.shanestudio.VetBuddy
    TARGETED_DEVICE_FAMILY: "1"
    SUPPORTS_XR_DESIGNED_FOR_IPHONE_IPAD: false

targets:
  VetBuddy:
    type: application
    platform: iOS
    sources:
      - path: App
        group: App
      - path: Core
        group: Core
      - path: DesignSystem
        group: DesignSystem
      - path: Features
        group: Features
    resources:
      - path: Resources
        group: Resources
    settings:
      base:
        INFOPLIST_FILE: Info.plist
        CODE_SIGN_ENTITLEMENTS: VetBuddy.entitlements
    dependencies:
      - target: VetBuddyTests
        embed: false

  VetBuddyTests:
    type: bundle.unit-test
    platform: iOS
    sources:
      - path: Tests/VetBuddyTests
        group: VetBuddyTests
    settings:
      base:
        TEST_HOST: ""
    dependencies:
      - target: VetBuddy
EOF

echo "✅ project.yml 已生成"
echo ""

# 运行 xcodegen
echo "正在生成 Xcode 项目..."
xcodegen generate

if [ -d "VetBuddy.xcodeproj" ]; then
    echo "✅ VetBuddy.xcodeproj 已生成"
    echo ""
    echo "下一步:"
    echo "  1. 打开 VetBuddy.xcodeproj"
    echo "  2. 在 Xcode 中设置 Development Team"
    echo "  3. 选择模拟器或真机"
    echo "  4. Cmd+R 运行"
else
    echo "❌ 项目生成失败"
    exit 1
fi
