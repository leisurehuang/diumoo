#!/bin/bash

# 修复NetEase集成 - 将新Swift文件添加到Xcode项目

echo "🔧 修复NetEase Cloud Music集成..."
echo ""

PROJECT_FILE="diumoo.xcodeproj/project.pbxproj"

# 备份项目文件
cp "$PROJECT_FILE" "${PROJECT_FILE}.backup"
echo "✅ 已备份项目文件到 ${PROJECT_FILE}.backup"
echo ""

# 检查Swift文件是否已存在
if ! grep -q "DMNetEaseAPIClient.swift" "$PROJECT_FILE"; then
    echo "⚠️  DMNetEaseAPIClient.swift 未在Xcode项目中"
    echo ""
    echo "请手动添加："
    echo "1. 打开 Xcode: open diumoo.xcworkspace"
    echo "2. 在左侧导航器中，右键点击 'core' 文件夹"
    echo "3. 选择 'Add Files to diumoo...'"
    echo "4. 选择 DMNetEaseAPIClient.swift 和 DMNetEasePlaylistFetcher.swift"
    echo "5. 确保勾选 'diumoo' target"
    echo "6. 点击 'Add'"
    echo ""
else
    echo "✅ DMNetEaseAPIClient.swift 已在项目中"
fi

# 清理构建缓存
echo "🧹 清理构建缓存..."
rm -rf ~/Library/Developer/Xcode/DerivedData/diumoo-*
echo "✅ 已清理 DerivedData"
echo ""

# 提供Xcode操作步骤
echo "📝 接下来的步骤："
echo ""
echo "方法1: 使用Xcode (推荐)"
echo "  1. open diumoo.xcworkspace"
echo "  2. 在Xcode菜单中选择: Product → Clean Build Folder (Shift+Cmd+K)"
echo "  3. 然后选择: Product → Build (Cmd+B)"
echo "  4. 运行: Product → Run (Cmd+R)"
echo ""
echo "方法2: 验证文件已添加"
echo "  在Xcode左侧项目中，检查这些文件存在且不是红色："
echo "  - diumoo/core/DMNetEaseAPIClient.swift"
echo "  - diumoo/core/DMPlaylistFetcher.swift"
echo ""

# 检查编译
if command -v xcodebuild &> /dev/null; then
    echo "方法3: 命令行编译"
    echo "  xcodebuild -workspace diumoo.xcworkspace -scheme diumoo clean"
    echo "  xcodebuild -workspace diumoo.xcworkspace -scheme diumoo build"
    echo ""
else
    echo "⚠️  xcodebuild 未安装，请使用Xcode GUI"
    echo ""
fi

echo "✅ 修复脚本执行完毕"
echo ""
echo "💡 如果问题仍然存在，请查看 FIX_NETEASE_INTEGRATION.md 获取详细步骤"
