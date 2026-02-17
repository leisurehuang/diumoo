#!/bin/bash

# Diumoo Build Script with NetEase Integration
# This script builds the diumoo app with NetEase Cloud Music support

echo "🎵 Building Diumoo with NetEase Cloud Music Integration..."

# Check if workspace exists
if [ ! -f "diumoo.xcworkspace" ]; then
    echo "❌ Error: diumoo.xcworkspace not found!"
    echo "Please run this script from the diumoo root directory."
    exit 1
fi

# Install dependencies if needed
if [ ! -d "Pods" ]; then
    echo "📦 Installing CocoaPods dependencies..."
    pod install
fi

# Clean build
echo "🧹 Cleaning previous build..."
xcodebuild -workspace diumoo.xcworkspace -scheme diumoo clean

# Build the project
echo "🔨 Building diumoo..."
xcodebuild -workspace diumoo.xcworkspace \
    -scheme diumoo \
    -configuration Release \
    build

# Check if build succeeded
if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo ""
    echo "🎉 Diumoo with NetEase Cloud Music is ready!"
    echo ""
    echo "To run the app:"
    echo "  open build/Release/diumoo.app"
    echo ""
    echo "Or from Xcode:"
    echo "  open diumoo.xcworkspace"
    echo ""
    echo "Features:"
    echo "  ✅ NetEase Personal FM (works without login)"
    echo "  ✅ High-quality streaming (up to 320kbps)"
    echo "  ✅ Automatic song recommendations"
    echo "  ✅ Persistent sessions"
    echo ""
else
    echo "❌ Build failed!"
    echo "Please check the error messages above."
    exit 1
fi
