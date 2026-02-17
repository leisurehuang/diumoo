# AGENTS.md - Diumoo Agent Coding Guide

**Project**: Diumoo - Douban.FM client for macOS
**Language**: Objective-C + Swift (hybrid codebase, migrating to Swift)
**Platform**: macOS 10.10+
**Build System**: Xcode + CocoaPods

---

## Build Commands

```bash
# Install dependencies
pod install

# Open workspace (NOT .xcodeproj!)
open diumoo.xcworkspace

# Build
xcodebuild -workspace diumoo.xcworkspace -scheme diumoo -configuration Release build

# Clean
xcodebuild -workspace diumoo.xcworkspace -scheme diumoo clean

# Run app
open build/Release/diumoo.app
```

### Testing
No test suite exists. Use XCTest when adding tests. Run single test:
```bash
xcodebuild test -workspace diumoo.xcworkspace -scheme diumoo -only-testing:diumooTests/YourTestClass/testMethodName
```

---

## Code Structure

```
diumoo/
├── core/           # Business logic (Swift being phased in)
│   ├── DMControlCenter
│   ├── DMService
│   ├── DMUtils
│   └── *.swift     # Core Swift modules
├── ui/             # UI components (mostly Objective-C)
│   ├── DMPanel/    # Main panel UI
│   └── DMPrefsPanel/
├── DMAppDelegate.h/m
├── DMApp.h/m
├── main.m
└── diumoo-Bridging-Header.h  # ObjC→Swift bridge
```

---

## Code Style Guidelines

### Naming Conventions

**Prefix**: All classes use `DM` prefix

**Objective-C**: `DMPanelWindowController` (PascalCase), `channelChangeActionWithSender:` (camelCase)
**Swift**: `DMPlayableItem` (PascalCase), `musicInfo` (camelCase)

### Import Style

**Objective-C**: Framework imports first (`<Cocoa/Cocoa.h>`), then local (`"DMPanel.h"`)
**Swift**: `import Foundation`, `import AppKit`

### Interoperability

- Add Swift classes to `diumoo-Bridging-Header.h` if needed by ObjC
- Use `@objc` and `@objcMembers` for Swift classes exposed to ObjC
- Import Swift-generated header in ObjC: `#import "diumoo-Swift.h"`

### Properties & Variables

**Objective-C**:
```objc
@property(nonatomic, strong) IBOutlet DMCoverControlView *coreView;
@property(copy) NSString *openURL;
@property(nonatomic) BOOL hasActivePanel;
```

**Swift**:
```swift
public var cover: NSImage?
public var like: Bool
public var musicInfo: [String: AnyObject]!
```

### Methods & Functions

**Objective-C**:
```objc
- (void)channelChangeActionWithSender:(id)sender;
- (void)invokeChannelWithCid:(NSInteger)cid andTitle:(NSString *)title andPlay:(BOOL)immediately;
```

**Swift**:
```swift
func prepareCoverWithCallbackBlock(_ block: @escaping (NSImage?) -> Void)
func shareAttributeWithChannel(_ channel: String) -> String?
```

### Memory Management & Error Handling

- ARC enabled. Use `strong` by default, `weak` for delegates
- Check optionals before unwrapping: `if aDict["aid"] != nil { self.musicInfo["aid"] = aDict["aid"]! }`
- Use guard for early returns: `guard let data = data, error == nil else { return }`

---

## Project-Specific Conventions

- **CocoaPods**: Always open `.xcworkspace`, not `.xcodeproj`. Custom pods in `third-party/`
- **Localization**: Use `NSLocalizedString` with keys like `"BITRATE_CHANGED"`
- **Media Keys**: Uses `SPMediaKeyTap` for global media key events
- **UI**: Custom classes in `ui/DMPanel/`. Images via `[NSImage imageNamed:]`
- **JSON**: Swift uses `[String: AnyObject]` with `String(describing:)` for conversion

---

## When Modifying Code

1. **Existing Objective-C**: Maintain current style, don't convert to Swift unless necessary
2. **New Features**: Prefer Swift, add to `core/` when appropriate
3. **UI Changes**: Keep UI components in Objective-C unless there's a compelling reason
4. **Bridge Carefully**: Update bridging header when adding new Swift classes called from ObjC
5. **Test Manually**: No automated tests - verify changes by running the app

---

## Common Patterns

**Singleton (ObjC)**:
```objc
+ (instancetype)sharedController {
    static id shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}
```

**Async (Swift)**:
```swift
URLSession.shared.dataTask(with: request) { data, _, error in
    DispatchQueue.main.async { /* Update UI */ }
}.resume()
```

---

## Notes for AI Agents

- **Legacy macOS app** migrating from Objective-C to Swift 3+
- **No CI/CD or automated tests** - manual verification required
- **Mixed codebase** - be prepared to work in both languages
- **Status bar app** - uses `LSUIElement = true` to run without dock icon
- **GPLv3 licensed** - all modifications must remain open source
- **Target**: macOS 10.10+, Xcode 8.1+
