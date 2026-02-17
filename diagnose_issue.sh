# 🎯 快速诊断命令 - 检查为什么还在使用Douban

echo "🔍 快速诊断为什么还在使用Douban API..."
echo ""

# 1. 检查USE_NETEASE标志
echo "1️⃣ 检查USE_NETEASE标志:"
echo ""
grep -n "USE_NETEASE" diumoo/core/DMPlaylistFetcher.swift | head -1
echo ""

# 2. 检查条件判断代码
echo "2️⃣ 检查条件判断代码:"
echo ""
sed -n '78,85p' diumoo/core/DMPlaylistFetcher.swift
echo ""

# 3. 检查是否有旧的编译产物
echo "3️⃣ 检查旧的app:"
echo ""
if [ -f "build/Release/diumoo.app/Contents/MacOS/diumoo" ]; then
    echo "❌ 旧的app仍然存在！必须删除它！"
    echo "   运行: ./delete_old_app.sh"
else
    echo "✅ 旧app已删除（或从未存在）"
fi
echo ""

# 4. 检查是否有备份文件
echo "4️⃣ 检查备份文件:"
echo ""
ls -la diumoo/core/DMPlaylistFetcher.swift* 2>/dev/null || echo "没有备份文件"
echo ""

# 5. 显示fetchNetEasePlaylist方法的前几行
echo "5️⃣ 验证NetEase方法存在:"
echo ""
sed -n '112,125p' diumoo/core/DMPlaylistFetcher.swift
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 诊断结果："
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 检查所有关键项
all_good=true

if grep -q "USE_NETEASE = true" diumoo/core/DMPlaylistFetcher.swift; then
    echo "✅ USE_NETEASE = true - 正确"
else
    echo "❌ USE_NETEASE 不是 true - 错误！"
    all_good=false
fi

if grep -q "fetchNetEasePlaylist(channel:" diumoo/core/DMPlaylistFetcher.swift; then
    echo "✅ fetchNetEasePlaylist() 方法存在 - 正确"
else
    echo "❌ fetchNetEasePlaylist() 方法不存在 - 错误！"
    all_good=false
fi

if [ -f "build/Release/diumoo.app/Contents/MacOS/diumoo" ]; then
    echo "❌ 旧的app仍然存在 - 需要删除！"
    echo "   运行: ./delete_old_app.sh"
    all_good=false
else
    echo "✅ 旧app已删除 - 正确"
fi

echo ""
if [ "$all_good" = true ]; then
    echo "🎯 配置正确！问题应该是缓存问题。"
    echo ""
    echo "📝 解决步骤："
    echo "1. 在Xcode中: Product → Clean Build Folder (Shift+Cmd+K)"
    echo "2. 切换到Release配置: Product → Edit Scheme → Build Config → Release"
    echo "3. Product → Build (Cmd+B)"
    echo "4. Product → Run (Cmd+R)"
else
    echo "⚠️ 发现配置问题，需要修复"
fi
