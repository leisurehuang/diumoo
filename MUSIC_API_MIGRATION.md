# 音乐API替换说明

## 当前状态

由于以下原因，所有主流音乐平台的直接 API 都已失效：

- **豆瓣 FM API**: TLS 错误，服务已停止
- **百度音乐 FM API**: 域名 (fm.baidu.com) 无法解析，服务已关闭
- **网易云音乐 API**: 没有个人电台 (personal_fm) API
- **QQ音乐**: 需要第三方中间服务器

## 当前解决方案

已实现**本地歌单系统** (DMLocalMusicFetcher)，使用公开可访问的测试音乐：

1. **文件**: `diumoo/core/DMLocalMusicFetcher.swift`
2. **功能**:
   - 提供本地歌单（默认包含3首测试歌曲）
   - 支持频道切换（本地歌单、测试音乐）
   - 支持添加自定义歌曲 (`addCustomSong` 方法)

3. **使用方式**:
   ```swift
   let fetcher = DMLocalMusicFetcher()
   fetcher.addCustomSong(title: "歌曲名", artist: "歌手", url: "MP3直链")
   ```

## 在 Xcode 中添加文件

1. 打开 `diumoo.xcworkspace`
2. 在项目导航器中右键点击 `core` 文件夹
3. 选择 "Add Files to diumoo..."
4. 选择以下文件：
   - `DMBaiduMusicFetcher.swift` (可选，用于参考)
   - `DMLocalMusicFetcher.swift` (必需)
   - `DMPlaylistFetcher.swift` (已修改)
5. 确保 Target 选中 "diumoo"
6. 点击 "Add"

## 长期解决方案建议

### 选项1: 使用第三方音乐API服务

需要运行本地 Node.js 服务器：

1. **netease-cloud-music-api** (推荐)
   ```bash
   git clone https://github.com/Binaryify/NeteaseCloudMusicApi.git
   cd NeteaseCloudMusicApi
   npm install
   node app.js  # 默认端口 3000
   ```

2. **qq-music-api**
   ```bash
   git clone https://github.com/Rain120/qq-music-api.git
   cd qq-music-api
   npm install
   node index.js
   ```

然后修改 `DMLocalMusicFetcher.swift` 使用本地API端点。

### 选项2: 使用付费音乐API服务

- **妖狐API**: https://api.yaohud.cn/ - 提供多平台音乐解析
- **NathanAPI**: https://api.nanyinet.com/ - 聚合音乐解析

### 选项3: 自定义音乐源

使用 `DMLocalMusicFetcher.addCustomSong()` 方法添加自己的音乐：

```swift
DMPlaylistFetcher.sharedController.localFetcher.addCustomSong(
    title: "你的歌曲",
    artist: "歌手名",
    url: "https://example.com/song.mp3",
    picture: "https://example.com/cover.jpg"
)
```

## 测试步骤

1. 在 Xcode 中添加新文件
2. 构建 (⌘+B)
3. 运行应用
4. 测试播放功能

## 已知问题

- ✅ 认证错误已禁用（DMAuthHelper.swift 已修改）
- ✅ 使用本地歌单作为临时解决方案
- ⏳ 需要在 Xcode 中手动添加文件到项目

## 下一步

1. 测试本地歌单系统是否正常工作
2. 根据需要选择长期解决方案（自建API服务或使用付费API）
3. 实现 API 配置界面，让用户可以轻松切换音乐源
