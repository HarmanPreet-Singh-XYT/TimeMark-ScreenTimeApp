#!/bin/bash
# aggressive_clean.sh
# This completely removes all traces and forces rebuild

echo "🧹 Starting aggressive clean..."

# 1. Flutter clean
echo "1. Running flutter clean..."
flutter clean

# 2. Remove all build artifacts
echo "2. Removing build directories..."
rm -rf build/
rm -rf macos/build/
rm -rf .dart_tool/

# 3. Remove all Flutter plugin files
echo "3. Removing Flutter plugin files..."
rm -rf .flutter-plugins
rm -rf .flutter-plugins-dependencies
rm -rf macos/Flutter/ephemeral/

# 4. Remove all CocoaPods files
echo "4. Removing CocoaPods files..."
rm -rf macos/Pods
rm -rf macos/.symlinks
rm -rf macos/Podfile.lock

# 5. Clear CocoaPods cache (this is key!)
echo "5. Clearing CocoaPods cache..."
cd macos
pod cache clean --all
pod deintegrate
cd ..

# 6. Clear pub cache for this plugin (optional but thorough)
echo "6. Clearing pub cache for local_notifier..."
rm -rf ~/.pub-cache/hosted/pub.dev/local_notifier-*

# 7. Regenerate
echo "7. Running flutter pub get..."
flutter pub get

# 8. Verify local plugin is recognized
echo "8. Checking .flutter-plugins..."
if grep -q "local_notifier=packages/local_notifier_custom" .flutter-plugins; then
    echo "✅ Local plugin is recognized!"
else
    echo "❌ WARNING: Local plugin NOT recognized in .flutter-plugins"
    echo "Contents of .flutter-plugins:"
    cat .flutter-plugins
fi

# 9. Reinstall pods
echo "9. Installing pods..."
cd macos
pod install --verbose
cd ..

echo ""
echo "✅ Aggressive clean complete!"
echo ""
echo "Next steps:"
echo "1. Open macos/Runner.xcworkspace in Xcode"
echo "2. Check that local_notifier appears under 'Development Pods'"
echo "3. Product → Clean Build Folder (Cmd+Shift+K)"
echo "4. Product → Build (Cmd+B)"
echo ""
echo "Or try: flutter build macos"