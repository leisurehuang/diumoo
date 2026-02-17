# Changelog

All notable changes to Diumoo will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Modern Xcode asset catalog management (Assets.xcassets)
- Native Swift NetEase Music API integration
- AES-128-CBC and RSA encryption for secure API calls
- Documentation (README, CONTRIBUTING, CHANGELOG)

### Changed
- Migrated from Node.js API server to native implementation
- Updated minimum macOS version to 10.12 (for crypto APIs)
- Improved resource management with asset catalogs

### Removed
- Baidu Music API fetcher
- Local music file support
- Douban FM channel integration
- Local plist-based channel list loading
- channel.diumoo.net remote service dependency
- Node.js API server (api-enhanced)
- 17 obsolete documentation files
- Development shell scripts

### Fixed
- Project file references after dependency removal
- Xcode project structure issues

## [1.6.0] - 2026-02-17

### Major Changes
- **NetEase Cloud Music Integration**: Complete rewrite of music source integration
  - Native Swift implementation of NetEase Music API
  - No longer requires external Node.js server
  - Direct communication with NetEase services

### Technical Improvements
- Implemented custom crypto module (DMNetEaseCrypto)
  - AES-128-CBC encryption for API parameters
  - RSA encryption for security keys
  - Compatible with macOS 10.12+
- Refactored fetcher architecture for better maintainability
- Removed legacy API integrations (Baidu, Local, Douban)

### Deprecated
- Local channel list loading from plist files
- Remote channel update service

## [1.5.x] and earlier

*Historical versions maintained Douban FM integration and other features that have been removed in 1.6.0.*

---

## Version Summary

| Version | Date | Key Changes |
|---------|------|-------------|
| 1.6.0 | 2026-02-17 | NetEase Cloud Music integration, major refactor |
| 1.5.x | Previous | Douban FM support (removed) |
