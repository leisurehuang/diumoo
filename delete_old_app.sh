#!/bin/bash
# 删除旧的diumoo app以确保使用新编译的版本

echo "🗑️  删除旧的diumoo app..."
echo ""

# 删除构建目录中的app
if [ -d "build/Release/diumoo.app" ]; then
    rm -rf build/Release/diumoo.app
    echo "✅ 已删除 build/Release/diumoo.app"
fi

# 删除Applications中的app（如果安装了）
if [ -d "/Applications/diumoo.app" ]; then
    rm -rf /Applications/diumoo.app
    echo "✅ 已删除 /Applications/diumoo.app"
fi

# 删除Debug版本的app
if [ -d "build/Debug/diumoo.app" ]; then
    rm -rf build/Debug/diumoo.app
    echo "✅ 已删除 build/Debug/diumoo.app"
fi

echo ""
echo "✅ 所有旧版本已删除！"
echo ""
echo "📝 接下来："
echo "1. 在Xcode中: Product → Clean Build Folder (Shift+Cmd+K)"
echo "2. 在Xcode中: Product → Build (Cmd+B)"
echo "3. 在Xcode中: Product → Run (Cmd+R)"
echo ""
