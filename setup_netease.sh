#!/bin/bash

# 一键配置NetEase集成 - 无需在Xcode中添加新文件

echo "🎵 配置Diumoo使用NetEase Cloud Music..."
echo ""

# 备份原文件
if [ ! -f "diumoo/core/DMPlaylistFetcher.swift.backup" ]; then
    cp diumoo/core/DMPlaylistFetcher.swift diumoo/core/DMPlaylistFetcher.swift.backup
    echo "✅ 已备份原始文件"
fi

echo ""
echo "📝 当前配置："
echo ""
grep "USE_NETEASE" diumoo/core/DMPlaylistFetcher.swift | head -1
echo ""

echo "🔧 接下来的步骤："
echo ""
echo "1. 打开Xcode:"
echo "   open diumoo.xcworkspace"
echo ""
echo "2. 清理项目:"
echo "   在Xcode菜单选择: Product → Clean Build Folder (Shift+Cmd+K)"
echo ""
echo "3. 重新编译:"
echo "   在Xcode菜单选择: Product → Build (Cmd+B)"
echo ""
echo "4. 运行app:"
echo "   在Xcode菜单选择: Product → Run (Cmd+R)"
echo ""
echo "5. 查看Console日志验证:"
echo "   open -a Console"
echo "   在搜索框输入: diumoo"
echo "   应该看到: 🎵 Fetching from NetEase Personal FM"
echo ""
echo "✅ 配置完成！"
echo ""
echo "💡 提示："
echo "  - 所有NetEase代码已经集成到 DMPlaylistFetcher.swift 中"
echo "  - 不需要添加任何新文件到Xcode项目"
echo "  - 只需要清理并重新编译即可"
echo ""
