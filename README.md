# Diumoo

🎵 Diumoo 是一款 macOS 状态栏音乐播放器，支持网易云音乐。

## 功能特性

- ✅ **状态栏播放**: 在菜单栏中控制音乐播放
- ✅ **网易云音乐**: 接入网易云音乐 62+ 热门榜单
- ✅ **原生实现**: 纯 Swift 调用网易云音乐 API，无需本地服务器
- ✅ **自动播放**: 支持自动播放下一首歌曲
- ✅ **快捷键支持**: 全局快捷键控制播放

## 系统要求

- macOS 10.12 (Sierra) 或更高版本
- 网络连接

## 安装

### 从源码构建

1. 克隆仓库
2. 在 Xcode 中打开 `diumoo.xcworkspace`
3. ⌘+B 构建并运行

## 使用说明

### 基本使用

1. 点击菜单栏图标打开主界面
2. 选择音乐频道（如"热歌榜"）
3. 点击播放按钮开始播放
4. 使用控制按钮：播放/暂停、上一首/下一首

### 快捷键

- ⌘ + Control + P: 播放/暂停
- ⌘ + Control + [: 上一首
- ⌘ + Control + ]: 下一首
- ⌘ + Control + S: 喜欢/取消喜欢
- ⌘ + Control + B: 不再播放
- ⌘ + Control + H: 隐藏窗口

## 技术实现

### API 集成

本项目使用纯 Swift 原生调用网易云音乐 API：

- **加密算法**: AES-128-CBC, AES-128-ECB, RSA-1024
- **协议支持**: WeAPI, LinuxAPI, EAPI
- **核心文件**:
  - `DMNetEaseCrypto.swift` - 加密算法实现
  - `DMNetEaseAPIClient.swift` - API 客户端
  - `DMNetEaseMusicFetcher.swift` - 音乐获取器

### 架构

```
Diumoo App
    ↓
Swift Native API Calls
    ↓
NetEase Cloud Music API
```

### 频道列表

支持 62+ 热门榜单，包括：

- 热歌榜
- 新歌榜
- 飙升榜
- 说唱榜
- 欧美榜
- 古典榜
- 电子榜
- 抖音榜
- UK排行榜
- 美国Billboard榜
- 韩国Melon排行榜
- 日本公信榜
- 等等...

## 开源协议

本项目采用 GPLv3 协议开源。

## 致谢

- 网易云音乐 API
- 所有贡献者

---

**更新日志**: 2026-02-17 - 集成网易云音乐原生 API，移除 Douban FM 依赖
