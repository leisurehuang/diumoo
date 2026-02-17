#!/bin/bash

# 🎯 终极解决方案 - 强制Xcode重新编译

echo "🎯 强制Xcode重新编译DMPlaylistFetcher.swift..."
echo ""

# 1. 修改文件时间戳，强制Xcode认为文件已更改
echo "📝 步骤1: 更新文件时间戳..."
touch diumoo/core/DMPlaylistFetcher.swift
echo "✅ 文件时间戳已更新"
echo ""

# 2. 添加一个空行到文件末尾（强制文件内容改变）
echo "📝 步骤2: 添加内容变更标记..."
echo "" >> diumoo/core/DMPlaylistFetcher.swift
# 立即删除这行，保持文件干净
sed -i '' '$d' diumoo/core/DMPlaylistFetcher.swift
echo "✅ 文件内容已更改"
echo ""

# 3. 显示文件修改时间
echo "📅 文件最后修改时间:"
stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" diumoo/core/DMPlaylistFetcher.swift
echo ""

# 4. 再次确认USE_NETEASE标志
echo "🔍 确认USE_NETEASE标志:"
grep "USE_NETEASE" diumoo/core/DMPlaylistFetcher.swift | head -1
echo ""

# 5. 检查调试日志
echo "🔍 确认调试日志已添加:"
if grep -q "🔴🔴🔴 fetchPlaylist 被调用" diumoo/core/DMPlaylistFetcher.swift; then
    echo "✅ 调试日志已添加到 fetchPlaylist"
else
    echo "❌ 调试日志未找到！"
fi

if grep -q "🎵🎵🎵 fetchNetEasePlaylist 被调用" diumoo/core/DMPlaylistFetcher.swift; then
    echo "✅ 调试日志已添加到 fetchNetEasePlaylist"
else
    echo "❌ 调试日志未找到！"
fi
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 文件已标记为需要重新编译！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📝 现在请在Xcode中："
echo ""
echo "1. 打开项目:"
echo "   open diumoo.xcworkspace"
echo ""
echo "2. 查看DMPlaylistFetcher.swift:"
echo "   - 在Xcode左侧找到这个文件"
echo "   - 打开它，应该能看到带有🔴🔴🔴的调试日志"
echo ""
echo "3. Clean Build Folder:"
echo "   Product → Clean Build Folder (Shift+Cmd+K)"
echo ""
echo "4. Build (Cmd+B)"
echo "   - 编译日志中应该看到 \"Compiling DMPlaylistFetcher.swift\""
echo "   - 如果没看到，说明Xcode没有检测到文件变化！"
echo ""
echo "5. Run (Cmd+R)"
echo ""
echo "6. 查看Console日志:"
echo "   open -a Console"
echo "   搜索: 🔴 或 fetchPlaylist"
echo ""
echo "   ✅ 如果看到 \"🔴🔴🔴 fetchPlaylist 被调用!\" 说明代码被执行了"
echo "   ✅ 如果看到 \"🎵🎵🎵 fetchNetEasePlaylist 被调用!\" 说明NetEase方法被调用"
echo "   ❌ 如果看到 \"❌❌❌ 警告: 执行了Douban代码分支!\" 说明条件判断失败"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
