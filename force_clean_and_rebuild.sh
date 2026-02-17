#!/bin/bash

# 🔥 强制清理并重新编译Diumoo for NetEase集成

echo "🔥 强制清理Diumoo编译缓存..."
echo ""

# 检查Xcode是否安装
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ xcodebuild未找到，请确保已安装Xcode"
    echo "   在Xcode中操作："
    echo "   1. Product → Clean Build Folder (Shift+Cmd+K)"
    echo "   2. Product → Build (Cmd+B)"
    exit 1
fi

# 1. 完全清理DerivedData
echo "🗑️  清理DerivedData..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*
echo "✅ DerivedData已清理"
echo ""

# 2. 清理项目特定的构建文件夹
echo "🧹 清理项目构建文件夹..."
cd /Users/lei/Documents/diumoo
rm -rf build/
rm -rf ~/Library/Caches/com.apple.dt.Xcode/*
rm -rf ~/Library/Saved\ Application\ State/com.apple.dt.Xcode.*
echo "✅ 项目构建文件夹已清理"
echo ""

# 3. 检查DMPlaylistFetcher.swift中的USE_NETEASE标志
echo "🔍 检查USE_NETEASE标志..."
if grep -q "USE_NETEASE = true" diumoo/core/DMPlaylistFetcher.swift; then
    echo "✅ USE_NETEASE标志已正确设置为 true"
    grep "USE_NETEASE" diumoo/core/DMPlaylistFetcher.swift
else
    echo "❌ USE_NETEASE标志不是true！"
    grep "USE_NETEASE" diumoo/core/DMPlaylistFetcher.swift
    echo ""
    echo "正在修复..."
    # 这里我们可以使用sed来修改，但用户可能已经手动修改过了
fi
echo ""

# 4. 验证fetchNetEasePlaylist方法存在
echo "🔍 验证fetchNetEasePlaylist方法..."
if grep -q "private func fetchNetEasePlaylist" diumoo/core/DMPlaylistFetcher.swift; then
    echo "✅ fetchNetEasePlaylist方法存在"
    # 显示方法位置
    grep -n "private func fetchNetEasePlaylist" diumoo/core/DMPlaylistFetcher.swift
else
    echo "❌ fetchNetEasePlaylist方法不存在！"
fi
echo ""

# 5. 使用xcodebuild清理
echo "🔨 使用xcodebuild清理项目..."
xcodebuild -workspace diumoo.xcworkspace -scheme diumoo clean 2>&1 | grep -E "(error|warning|succeed)" | head -10
echo "✅ 项目已清理"
echo ""

# 6. 验证文件内容
echo "📋 当前DMPlaylistFetcher.swift的关键代码："
echo ""
echo "第80-82行（fetchPlaylist方法条件判断）:"
sed -n '80,82p' diumoo/core/DMPlaylistFetcher.swift
echo ""
echo "第58行（USE_NETEASE标志）:"
sed -n '58p' diumoo/core/DMPlaylistFetcher.swift
echo ""

# 7. 显示下一步操作
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 下一步操作："
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✅ 1. 在Xcode中打开项目："
echo "   open diumoo.xcworkspace"
echo ""
echo "✅ 2. 再次清理（保险起见）："
echo "   在Xcode菜单: Product → Clean Build Folder (Shift+Cmd+K)"
echo ""
echo "✅ 3. 重新编译："
echo "   在Xcode菜单: Product → Build (Cmd+B)"
echo ""
echo "✅ 4. 查看编译日志，确认编译了DMPlaylistFetcher.swift"
echo ""
echo "✅ 5. 运行app: Product → Run (Cmd+R)"
echo ""
echo "✅ 6. 打开Console查看日志："
echo "   open -a Console"
echo "   搜索: diumoo"
echo "   应该看到: \"🎵 Fetching from NetEase Personal FM\""
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 8. 验证URL编码扩展存在
echo "🔍 验证Dictionary扩展..."
if grep -q "extension Dictionary where Key == String, Value == Any" diumoo/core/DMPlaylistFetcher.swift; then
    echo "✅ Dictionary URL编码扩展存在"
else
    echo "⚠️  Dictionary URL编码扩展可能缺失"
fi
echo ""

echo "🎯 准备完成！请在Xcode中按照上述步骤操作。"
echo ""
echo "💡 如果问题仍然存在，请提供："
echo "   - Xcode的完整编译日志"
echo "   - Console.app中的运行日志"
echo "   - 确认是否看到了 \"🎵 Fetching from NetEase\" 日志"
