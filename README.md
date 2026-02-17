# Diumoo

![macOS](https://img.shields.io/badge/macOS-10.12+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

> A lightweight, elegant macOS menu bar music player powered by NetEase Cloud Music.

![Diumoo Screenshot](resources/screenshot.png)

## ✨ Features

- **Menu Bar Integration** - Lives in your menu bar, stays out of the way
- **NetEase Cloud Music** - Access to millions of songs and curated playlists
- **Hot Playlists** - Quick access to trending music charts
- **Personal Radio** - Discover new music based on your preferences
- **Keyboard Controls** - Play/pause, skip, rate with media keys
- **Social Sharing** - Share what you're listening to
- **Lightweight** - Native Swift implementation, no external API servers needed

## 📋 Requirements

- macOS 10.12 (Sierra) or later
- Xcode 12.0 or later (for building)
- CocoaPods (for dependency management)

## 🚀 Installation

### Building from Source

1. **Clone the repository**
   ```bash
   git clone https://github.com/leisurehuang/diumoo.git
   cd diumoo
   ```

2. **Install dependencies**
   ```bash
   pod install
   ```

3. **Open the workspace**
   ```bash
   open diumoo.xcworkspace
   ```

4. **Build and run**
   - Select the `diumoo` scheme
   - Press `⌘R` or click the Run button

### Manual Installation

After building, find `diumoo.app` in the `build/` directory and drag it to your `Applications` folder.

## 🛠️ Technical Stack

- **Language**: Swift 5.0 + Objective-C
- **Architecture**: Native macOS AppKit
- **Music Source**: NetEase Cloud Music API
- **Dependency Management**: CocoaPods

### Key Dependencies

- [MASShortcut](https://github.com/shpakovski/MASShortcut) - Keyboard shortcuts
- [SPMediaKeyTap](https://github.com/nevyn/SPMediaKeyTap) - Media key handling
- [SMTabBar](https://github.com/smic/InspectorTabBar) - Tab bar UI component

> **Note**: SPMediaKeyTap and SMTabBar are included as local dependencies since official CocoaPods specs are not available.

## 📁 Project Structure

```
diumoo/
├── diumoo/
│   ├── core/              # Core business logic
│   │   ├── DMNetEaseMusicFetcher.swift
│   │   ├── DMNetEaseAPIClient.swift
│   │   ├── DMNetEaseCrypto.swift
│   │   └── DMPlaylistFetcher.swift
│   ├── ui/                # User interface
│   │   ├── DMPanel/       # Main panel UI
│   │   └── DMDocument/    # Document window
│   └── Assets.xcassets/   # Image resources
├── resources/             # Additional resources
├── third-party/           # Local CocoaPods dependencies
└── Pods/                  # CocoaPods dependencies
```

## 🎵 Usage

### Getting Started

1. **Launch Diumoo** - Click the menu bar icon
2. **Select a Playlist** - Browse hot playlists or personal recommendations
3. **Enjoy Music** - Use the controls to play, pause, skip, or rate songs

### Keyboard Shortcuts

- **Play/Pause**: Media key (Play/Pause)
- **Next Track**: Media key (Next)
- **Previous Track**: Media key (Previous)
- **Love Song**: Click the heart icon

### Menu Bar Options

- **Channels**: Browse and switch between playlists
- **Share**: Share current track to social media
- **Preferences**: Customize your experience

## 🔧 Development

### Architecture Overview

Diumoo follows the **Model-View-Controller (MVC)** pattern:

- **Models**: `DMPlayableItem`, `DMPlaylistFetcher`
- **Views**: XIB-based UI components
- **Controllers**: `DMPanelWindowController`, `DMPopUpMenuController`

### NetEase Music API Integration

The app uses a native Swift implementation to communicate with NetEase Cloud Music:

- **AES-128-CBC** encryption for API parameters
- **RSA** encryption for security keys
- **RESTful API** calls for music data
- **No external dependencies** on Node.js servers

See `diumoo/core/DMNetEaseAPIClient.swift` and `diumoo/core/DMNetEaseCrypto.swift` for implementation details.

### Adding New Features

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 🐛 Troubleshooting

### Common Issues

**Q: Build fails with "Cannot find module" errors**
- A: Run `pod install` in the project directory and open `diumoo.xcworkspace` (not `.xcodeproj`)

**Q: Media keys not working**
- A: Check System Preferences → Security & Privacy → Accessibility → Ensure Diumoo has permission

**Q: Songs won't play**
- A: Verify your network connection and ensure you're logged in to your NetEase account

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

This project is a fork of the original **[Diumoo](https://github.com/shanzi/diumoo)** by **[Shanzi](https://github.com/shanzi)**.

Special thanks to:
- **[Shanzi](https://github.com/shanzi)** - Original author and creator of Diumoo
- **NetEase Cloud Music** - For providing the music API
- **All Contributors** - Who have helped improve this project over the years

## 📮 Contact

- **Author**: leisure.huang
- **GitHub**: [@leisurehuang](https://github.com/leisurehuang)
- **Issues**: [GitHub Issues](https://github.com/leisurehuang/diumoo/issues)

---

<div align="center">

**Made with ❤️ for macOS music lovers**

[⬆ Back to Top](#diumoo)

</div>
