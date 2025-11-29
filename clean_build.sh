#!/bin/bash

echo "🧹 Starting deep clean of iOS build..."

# Navigate to project root
cd "$(dirname "$0")"

# Clean Flutter
echo "Cleaning Flutter..."
flutter clean

# Get Flutter dependencies
echo "Getting Flutter dependencies..."
flutter pub get

# Clean iOS
echo "Cleaning iOS Pods and build artifacts..."
cd ios
rm -rf Pods
rm -f Podfile.lock
rm -rf build
rm -rf .symlinks

# Clean Xcode DerivedData
echo "Cleaning Xcode DerivedData..."
rm -rf ~/Library/Developer/Xcode/DerivedData

# Reinstall Pods
echo "Installing Pods..."
pod install

cd ..

echo "✅ Deep clean complete!"
echo ""
echo "Next steps:"
echo "1. Close Xcode completely"
echo "2. Open ios/Runner.xcworkspace"
echo "3. Product > Clean Build Folder (Shift+Cmd+K)"
echo "4. Run the app (Cmd+R)"
