#!/bin/bash
# 启动网易云音乐API服务器

echo "🎵 启动网易云音乐API服务器..."
echo ""

cd /Users/lei/Documents/diumoo/api-enhanced

# 检查是否已经安装依赖
if [ ! -d "node_modules" ]; then
    echo "📦 首次启动，安装依赖..."
    npm install
fi

# 检查端口3000是否被占用
if lsof -Pi :3000 -sTCP:LISTEN -t >/dev/null 2>&1 ; then
    echo "⚠️  端口3000已被占用"
    echo "正在停止旧进程..."
    lsof -ti:3000 | xargs kill -9 2>/dev/null
    sleep 2
fi

echo "🚀 启动服务器 (http://localhost:3000)..."
node app.js &

sleep 3

# 检查服务器是否启动成功
if curl -s "http://localhost:3000" > /dev/null 2>&1; then
    echo ""
    echo "✅ 服务器启动成功！"
    echo ""
    echo "📡 API端点:"
    echo "   - 搜索: http://localhost:3000/search?keywords=歌曲名"
    echo "   - 歌单: http://localhost:3000/playlist/track/all?id=歌单ID"
    echo "   - 歌曲URL: http://localhost:3000/song/url?id=歌曲ID"
    echo ""
    echo "💡 提示: 保持此终端窗口打开以维持服务运行"
    echo "   如需停止服务器，按 Ctrl+C 或关闭此窗口"
    echo ""
else
    echo "❌ 服务器启动失败，请检查错误信息"
fi
